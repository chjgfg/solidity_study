// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// 任何人都可以发送ETH。
// 只有车主可以提取。
contract EtherWallet {
    address payable public owner;
    constructor() {
        owner = payable(msg.sender);
    }
    //回退函数接收主币
    receive() external payable {}
    function withdraw(uint _amount) public {
        require(msg.sender == owner, "caller is not owner");
        payable(msg.sender).transfer(_amount);
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
