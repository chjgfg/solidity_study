// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Counter {
    uint public count;

    function get() public view returns (uint) {
        return count;
    }

    function inc() public {
        count += 1;
    }
    function dec() public {
        count -= 1;
    }
}

contract MyContract1 {
    uint public balance; // 状态变量

    // 读取状态变量，用 view 修饰
    function getBalance() public view returns (uint) {
        return balance;
    }

    // 读取状态变量并计算，仍为 view
    function getDoubleBalance() public view returns (uint) {
        return balance * 2;
    }
}

contract MyContract2 {
    uint public balance; // 状态变量

    // 仅依赖输入参数计算，用 pure 修饰
    function add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }

    // 错误示例：尝试读取状态变量，会编译报错
    // function badPure() public pure returns (uint) {
    //     return balance; // 编译错误：pure 函数不能读取状态变量
    // }
}
