// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Variables {
    //状态变量存储在区块链中。
    string public text = "hello";
    uint public num = 123;

    function doSomething() public {
        //本地变量不保存到区块链。
        uint i = 456;
        // 全局变量
        uint timestamp = block.timestamp; // Current block timestamp
        address sender = msg.sender; // address of the caller
    }
}
