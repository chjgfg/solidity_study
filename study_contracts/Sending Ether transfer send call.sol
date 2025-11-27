// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ReceiveEther {
    /*
    Which function is called, fallback() or receive()?

           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */
    event Log(uint amount, uint gas);
    receive() external payable {
        emit Log(msg.value, gasleft());
    }
    fallback() external payable {}
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
contract SendEther {
    //传入主币, 这个不写会报错
    constructor() payable {}
    //传入主币
    receive() external payable {}
    function sendViaTransfer(address payable _to) public payable {
        //使用transfer发送会带有2300个gas,失败就会revert
        _to.transfer(msg.value);
    }
    function sendViaSend(address payable _to) public payable {
        //使用send发送会带有2300个gas,会返回bool标记是否成功和失败
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }
    function sendViaCall(address payable _to) public payable {
        //使用call发送会发送所有剩余的gas,会返回bool和一个data数据,如果发送给一个智能合约,智能合约有返回值,就会在data里体现
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
