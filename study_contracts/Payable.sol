// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Payable {
    //有payable修饰的地址变量可以发送以太坊主币
    address payable public owner;

    constructor() payable {
        // msg.sender没有payable属性, 而owner有payable属性,所以需要payable(msg.sender)这样写
        owner = payable(msg.sender);
    }
    //有payable修饰的方法可以接受以太坊主币的传入,不标记就会报错
    function deposit() public payable {}
    //助手函数,获取当前余额(多次执行deposit方法之后再次执行这个方法会发现是增加的)
    function getBalance() public view returns (uint){
        return address(this).balance;
    }

    function notPayable() public {}

    function withdraw() public {
        // 当前余额
        uint amount = address(this).balance;
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function transfer(address payable _to, uint amount) public {
        (bool success, ) = _to.call{value: amount}("");
        require(success, "Failed to send Ether");
    }
}
