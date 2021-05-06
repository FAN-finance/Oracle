## 数据读取合约

- 合约名：Rate
- 文件名：rate.sol
- 类型：预言机 - 提供房贷利率信息
- 合约源码
- 合约部署情况

| 版本  | 网络  |                                            |
| ----- | ----- | ------------------------------------------ |
| 1.0.0 | kovan | 0x2941B084601905f858730Ca2CD5e690191d10336 |



### 1.概述

预言机核心合约。接受其他合约调用读取美国10大城市房产抵押贷款利率数据。可被授权的合约写入利率信息。

### 2.合约细节

#### 合约存储

- wards - 授权机制
- getPurchase - 新购房产抵押利率
- getRefinance - 再融资反铲抵押利率

#### 公共方法

##### 管理员方法

- rely / deny ：增加或移除一个被授权的用户。

##### 订阅读取方法

- getPurchase(uint city, uint product) ：返回新购房产抵押利率

- getRefinance(uint city, uint product) ：返回再融资房产抵押利率

##### 订阅更新方法

- setPurchase(uint city, uint product, uint _rate, uint _apr)  external note auth returns(bool) ：更新某城市某款产品的利率信息（新购房产）

- setRefinance(uint city, uint product, uint _rate, uint _apr) external note auth returns(bool) ：更新某城市某款产品的利率信息（再融资）

### 3.相关参数

#### 函数参数

| 参数    | 类型 | 说明     |
| ------- | ---- | -------- |
| city    | uint | 城市     |
| product | uint | 产品     |
| _rate   | uint | 基准利率 |
| _apr    | uint | 平均利率 |

#### 参数对应表1

| city          | value |
| ------------- | ----- |
| New York      | 1     |
| Los Angeles   | 2     |
| Chicago       | 3     |
| Houston       | 4     |
| Philadelphia  | 5     |
| Detroit       | 6     |
| San Francisco | 7     |
| Boston        | 8     |
| Pittsburgh    | 9     |
| Atlanta       | 10    |

#### 参数对应表2

| product                 | value |
| ----------------------- | ----- |
| 15 year fixed refinance | 1     |
| 15 year jumbo refinance | 2     |
| 10/1 ARM refinance      | 3     |

### 4.调用示例

```javascript
var Web3 = require('web3');

var rateContractAddr = '0x2941b084601905f858730ca2cd5e690191d10336'; // kovan测试网络合约地址
var web3 = new Web3(new Web3.providers.HttpProvider("https://kovan.infura.io/v3/88ae15efc1c04e35bcc227e4d3284676"));

var rateContract = new web3.eth.Contract([{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":true,"inputs":[{"indexed":true,"internalType":"bytes4","name":"sig","type":"bytes4"},{"indexed":true,"internalType":"address","name":"usr","type":"address"},{"indexed":true,"internalType":"bytes32","name":"arg1","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"arg2","type":"bytes32"},{"indexed":false,"internalType":"bytes","name":"data","type":"bytes"}],"name":"LogNote","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"city","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"product","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"rate","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"apr","type":"uint256"}],"name":"SetOracle","type":"event"},{"constant":false,"inputs":[{"internalType":"address","name":"guy","type":"address"}],"name":"deny","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"getPurchase","outputs":[{"internalType":"uint256","name":"rate","type":"uint256"},{"internalType":"uint256","name":"apr","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"getRefinance","outputs":[{"internalType":"uint256","name":"rate","type":"uint256"},{"internalType":"uint256","name":"apr","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"guy","type":"address"}],"name":"rely","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"city","type":"uint256"},{"internalType":"uint256","name":"product","type":"uint256"},{"internalType":"uint256","name":"_rate","type":"uint256"},{"internalType":"uint256","name":"_apr","type":"uint256"}],"name":"setPurchase","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"city","type":"uint256"},{"internalType":"uint256","name":"product","type":"uint256"},{"internalType":"uint256","name":"_rate","type":"uint256"},{"internalType":"uint256","name":"_apr","type":"uint256"}],"name":"setRefinance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"wards","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}], rateContractAddr);

var gasLimit = 300000;

var city = 1;
var product = 1;

rateContract.methods.getRefinance(city, product).call({},(err,res)=>console.log)
```

### 5.返回值

```json
{
    "0":"2671",
    "1":"2996",
    "rate":"2671",
    "apr":"2996"
}
```



## 数据写入合约

- 合约名：setRate
- 合约文件：setRate.sol
- 类型：预言机 - 节点提交利率信息
- 合约源码
- 合约部署情况

| 版本  | 网络  | 合约地址                                   |
| ----- | ----- | ------------------------------------------ |
| 1.0.0 | kovan | 0x4b724A99a247993e0133d34Ec6AbfD4939812F79 |



### 1.概述

节点程序通过本合约向预言机程序提供数据。被授权的节点获取相应城市节点信息后提交数据到本合约，集齐足够数量（默认为5个）的数据后，合约会按照约定的算法计算利率，并提交至数据读取合约（核心合约）。

### 2.合约细节

#### 合约储存

- wards - 授权机制
- oracle - 核心合约地址
- providerNum - 数据提交节点数量。即当第providerNum个被授权节点向本合约提交数据后，合约触发计算方法，向核心合约提交计算后的利率数据
- rateData - 保存节点提交的利率数据
- rateSign - 保存以提交数据节点的账户地址，防止节点在本轮重复提交数据

#### 公共方法

##### 管理员方法

- rely / deny ：增加或移除一个被授权的用户。

- setProviderNum(uint n) external note isOwner ：配置节点数量

##### 其他方法

- addData(uint city, uint product, uint _rate, uint _apr) external auth ： 提交利率数据
- getRL(uint city, uint product) external view returns(uint) ：查询当前数据提交情况。返回某城市某产品有多少节点提交了数据

### 3.相关参数

#### 函数参数

| 参数    | 类型 | 说明     |
| ------- | ---- | -------- |
| city    | uint | 城市     |
| product | uint | 产品     |
| _rate   | uint | 基准利率 |
| _apr    | uint | 平均利率 |

#### 参数对应表1

| city          | value |
| ------------- | ----- |
| New York      | 1     |
| Los Angeles   | 2     |
| Chicago       | 3     |
| Houston       | 4     |
| Philadelphia  | 5     |
| Detroit       | 6     |
| San Francisco | 7     |
| Boston        | 8     |
| Pittsburgh    | 9     |
| Atlanta       | 10    |

#### 参数对应表2

| product                 | value |
| ----------------------- | ----- |
| 15 year fixed refinance | 1     |
| 15 year jumbo refinance | 2     |
| 10/1 ARM refinance      | 3     |

### 4.调用示例

```javascript
var Web3 = require('web3');

var privateKey = 'fb3c882ae7d620d366131f4dbb76ecd5a9b7746f1719818e518dd4f06d0cacfa'; // 私钥1

var setrateContractAddr = '0x4b724A99a247993e0133d34Ec6AbfD4939812F79';
var web3 = new Web3(new Web3.providers.HttpProvider("https://kovan.infura.io/v3/88ae15efc1c04e35bcc227e4d3284676"));

var setrateContract = new web3.eth.Contract([{"inputs":[{"internalType":"address","name":"_oracle","type":"address"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"who","type":"address"},{"indexed":true,"internalType":"uint256","name":"city","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"product","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"rate","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"apr","type":"uint256"}],"name":"AddData","type":"event"},{"anonymous":true,"inputs":[{"indexed":true,"internalType":"bytes4","name":"sig","type":"bytes4"},{"indexed":true,"internalType":"address","name":"usr","type":"address"},{"indexed":true,"internalType":"bytes32","name":"arg1","type":"bytes32"},{"indexed":true,"internalType":"bytes32","name":"arg2","type":"bytes32"},{"indexed":false,"internalType":"bytes","name":"data","type":"bytes"}],"name":"LogNote","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"oldOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnerSet","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"uint256","name":"city","type":"uint256"},{"indexed":true,"internalType":"uint256","name":"product","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"rate","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"apr","type":"uint256"}],"name":"SetOracle","type":"event"},{"constant":false,"inputs":[{"internalType":"uint256","name":"city","type":"uint256"},{"internalType":"uint256","name":"product","type":"uint256"},{"internalType":"uint256","name":"_rate","type":"uint256"},{"internalType":"uint256","name":"_apr","type":"uint256"}],"name":"addData","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"changeOwner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"guy","type":"address"}],"name":"deny","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getOwner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"uint256","name":"city","type":"uint256"},{"internalType":"uint256","name":"product","type":"uint256"}],"name":"getRL","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"oracle","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"providerNum","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"guy","type":"address"}],"name":"rely","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"uint256","name":"n","type":"uint256"}],"name":"setProviderNum","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"wards","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"}], setrateContractAddr);

var gasLimit = 500000;

var city = 1;
var product = 1;

var txData = setrateContract.methods.addData(city, product, rate, apr).encodeABI();
var rawTx = {
    'to': setrateContractAddr,
    'gasLimit': web3.utils.toHex(gasLimit),
    'value': '0x00',
    'data': txData
};

web3.eth.accounts.signTransaction(rawTx , privateKey).then(tx => {
    var raw = tx.rawTransaction;

    web3.eth.sendSignedTransaction(raw).on('receipt', res => {
        var now = new Date().toLocaleString();
        console.log(now, '利率数据上报成功---city=', city, ' product=', product);
        // console.log(res);
    }).on('error', err => {
        var now = new Date().toLocaleString();
        console.log(now, '利率数据上报异常: city=', city, ' product=', product);
        console.log(err);
    });
});	
```



### 