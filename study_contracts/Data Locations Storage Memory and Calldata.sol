// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DataLocations {
    uint[] public arr;
    mapping(uint => address) map;
    struct MyStruct {
        uint foo;
    }
    mapping(uint => MyStruct) public myStruct;

    function f() public {
        _f(arr, map, myStruct[0]);

        // 从mapping中获取一个结构体
        MyStruct storage myStruct1 = myStruct[1];
        // 从memory中创建一个结构体
        MyStruct memory myMemStruct = MyStruct(0);
        myStruct[2] = MyStruct({foo: 2});
    }

    function _f(
        uint[] storage _arr,
        mapping(uint => address) storage _map,
        MyStruct storage _myStruct
    ) internal {}

    // You can return memory variables
    function g(uint[] memory _arr) public returns (uint[] memory) {
        // do something with memory array
    }

    function h(uint[] calldata _arr) external {
        // do something with calldata array
    }
}
