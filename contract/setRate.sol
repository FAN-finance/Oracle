pragma solidity =0.5.12;

contract LibNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  usr,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {
        _;
        assembly {
        // log an 'anonymous' event with a constant 6 words of calldata
        // and four indexed topics: selector, caller, arg1 and arg2
            let mark := msize                         // end of memory ensures zero
            mstore(0x40, add(mark, 288))              // update free memory pointer
            mstore(mark, 0x20)                        // bytes type data offset
            mstore(add(mark, 0x20), 224)              // bytes size (padded)
            calldatacopy(add(mark, 0x40), 0, 224)     // bytes payload
            log4(mark, 288,                           // calldata
            shl(224, shr(224, calldataload(0))), // msg.sig
            caller,                              // msg.sender
            calldataload(4),                     // arg1
            calldataload(36)                     // arg2
            )
        }
    }
}

contract Owner {

    address private owner;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() public {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface IRate {
    function setRefinance(uint city, uint product, uint _rate, uint _apr) external returns(bool);
}

contract setRate is LibNote,Owner {
    event AddData(address indexed who, uint indexed city, uint indexed product, uint rate, uint apr);
    event SetOracle(uint indexed city, uint indexed product, uint rate, uint apr);

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) external note isOwner { wards[guy] = 1; }
    function deny(address guy) external note isOwner { wards[guy] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "not-authorized");
        _;
    }

    address public oracle;

    constructor(address _oracle) public {
        wards[msg.sender] = 1;
        oracle = _oracle;
    }

    uint public providerNum = 5;

    function setProviderNum(uint n) external note isOwner {
        require(n>=5, "providerNum must ge 5");
        providerNum = n;
    }

    struct RateData {
        uint rate;
        uint apr;
        uint timestamp;
        address Provider;
    }

    mapping(uint => mapping(uint => RateData[])) rateData;
    mapping(uint => mapping(uint => mapping(address => bool))) rateSign;

    function addData(uint city, uint product, uint _rate, uint _apr) external auth {
        if (rateData[city][product].length < providerNum) {
            require(!rateSign[city][product][msg.sender], "You have update in this round");
            // cache
            RateData memory tmp = RateData(_rate,_apr,now,msg.sender);
            rateData[city][product].push(tmp);
            rateSign[city][product][msg.sender] = true;
            emit AddData(msg.sender, city, product, _rate, _apr);

            if (rateData[city][product].length == providerNum) {
                // update
                uint maxRate;
                uint minRate = rateData[city][product][0].rate;

                uint maxApr;
                uint minApr  = rateData[city][product][0].apr;

                uint sumRate;
                uint sumApr;

                for (uint i=0;i<rateData[city][product].length;i++) {
                    if (maxRate < rateData[city][product][i].rate) {
                        maxRate = rateData[city][product][i].rate;
                    }

                    if (maxApr < rateData[city][product][i].apr) {
                        maxApr = rateData[city][product][i].apr;
                    }

                    if (minRate > rateData[city][product][i].rate) {
                        minRate = rateData[city][product][i].rate;
                    }

                    if (minApr > rateData[city][product][i].apr) {
                        minApr = rateData[city][product][i].apr;
                    }

                    sumRate += rateData[city][product][i].rate;
                    sumApr  += rateData[city][product][i].apr;
                }

                sumRate = sumRate - maxRate - minRate;
                sumApr = sumApr - maxApr - minApr;

                require(IRate(oracle).setRefinance(city, product, sumRate / (providerNum -2), sumApr / (providerNum -2)), "set oracle fail");
                emit SetOracle(city, product, sumRate / (providerNum -2), sumApr / (providerNum -2));

                // clear
                for (uint i=0;i<rateData[city][product].length;i++) {
                    delete rateSign[city][product][rateData[city][product][i].Provider];
                }
                delete rateData[city][product];
            }
        }

    }

    function getRL(uint city, uint product) external view returns(uint) {
        return rateData[city][product].length;
    }
}
