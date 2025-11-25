// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Mapping {
    mapping(address => uint) public map;

    function get(address _addr) public view returns (uint) {
        return map[_addr];
    }

    function set(address _addr, uint _i) public {
        map[_addr] = _i;
    }

    function del(address _addr) public {
        delete map[_addr];
    }
}

contract NestedMapping {
    mapping(address => mapping(uint => bool)) public nested;

    function get(address _addr, uint _i) public view returns (bool) {
        return nested[_addr][_i];
    }

    function set(address _addr, uint _i, bool _boo) public {
        nested[_addr][_i] = _boo;
    }

    function del(address _addr, uint _i) public {
        delete nested[_addr][_i];
    }
}
