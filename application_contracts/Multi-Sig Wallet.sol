// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// 多签钱包合约
// 必须有合约中多个人同意的情况下才能将合约的主币转出
contract MultiSigWallet {
    //存款事件
    event Deposit(address indexed sender, uint amount, uint balance);
    //提交一个交易的申请
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    //由合约中的签名人进行批准,合约中有多个签名人就需要进行多次批准
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    //撤销批准,在这个交易没有被提交之前可以进行撤销
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    //执行, 执行之后就可以传输一定数量的主币到另一个目标地址上了
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    //保存该合约中所有的签名人
    address[] public owners;
    //数组中进行快速的查找,查找某一个用户是不是签名人中的一个地址
    mapping(address => bool) public isOwner;
    //确认数,不管合约中有多少个签名人,只要有这么多签名人同意,这笔钱就可以转出去,钱包中的交易才能够被批准
    uint public numConfirmationsRequired;
    //交易结构体,保存着每一次对外交易的信息
    struct Transaction {
        //交易发送的目标地址
        address to;
        //发送的主币数量
        uint value;
        //如果目标地址是合约地址,就可以执行合约中的一些函数
        bytes data;
        //这笔交易是否被执行了
        bool executed;
        //最小确认数
        uint numConfirmations;
    }
    //交易的ID号(交易数组的索引值)->签名人地址->bool, 某一个交易下的某一个签名人是否批准了这笔交易
    mapping(uint => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions;

    //只能签名人调用
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
    //只能签名人调用
    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _; 
    }
    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _; 
    }
    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _; 
    }
    //[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB]
    //4
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "invalid number of required confirmations");
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            //每一个地址不能是0地址
            require(owner != address(0), "invalid owner");
            //每一个地址不能是重复地址
            require(!isOwner[owner], "owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }
    //接收主币
    receive() external payable {
        //触发收款事件
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    //0x617F2E2fD72FD9D5503197092aC168c91465E7f2,100,0x
    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        uint txIndex = transactions.length;
        Transaction memory transaction = Transaction ({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        });
        transactions.push(transaction);
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }
    //四个账号分别执行一次这个
    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;
        emit ConfirmTransaction(msg.sender, _txIndex);
    }
    //当一个交易id的批准人数达到了最小确认数,就可以执行该方法把主币发送到目标地址
    function executeTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmations >= numConfirmationsRequired, "cannot execute tx");
        require(address(this).balance >= transaction.value, "Insufficient balance");
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data //在这里填上交易结构体中的数据,如果对方是一个合约地址,那么合约地址中的一些方法也可以被我们执行
        );
        require(success, "tx failed");
        emit ExecuteTransaction(msg.sender, _txIndex);
    }
    function revokeConfirmation(uint _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");
        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;
        emit RevokeConfirmation(msg.sender, _txIndex);
    }
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }
    function getTransaction(uint _txIndex) public view returns (address to, uint value, bytes memory data, bool executed, uint numConfirmations) {
        Transaction storage transaction = transactions[_txIndex];
        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numConfirmations);
    }

}
