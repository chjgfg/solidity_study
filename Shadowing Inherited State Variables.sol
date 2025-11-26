// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract A {
    string public name = "Contract A";

    function getName() public view returns (string memory) {
        return name;
    }
}

contract C is A {
    // 这是覆盖继承状态变量的正确方法。
    constructor() {
        name = "Contract C";
    }
}
