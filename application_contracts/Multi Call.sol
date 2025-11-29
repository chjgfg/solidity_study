/*
对一个或多个合约的多次函数调用打包整合在一个交易中,对合约再进行调用
好处是有时我们需要在同一个网站前端页面中对合约进行几十次调用而一个链的RPC节点又限制了每一个客户对链的调用在20秒间隔之内只能够调用一次
所以我们就要把多个合约的读取调用打包在一起成为一次调用这样就可以在一次调用中把我们想要的数据都读取出来
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MultiCall {
    /*
    
    ["0x73DeAC4CE5Ae3caCe36F1481B62cb635D9733E0D"]
    ["0x29e99f07000000000000000000000000000000000000000000000000000000000000000a"]


    0x000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000692a90fc
    */
    function multiCall(
        address[] calldata targets, //两次调用分别是调用的哪一个合约的地址
        bytes[] calldata data //两次调用对合约发出的数据
    ) external view returns (bytes[] memory) {
        require(targets.length == data.length, "target length != data length");
        bytes[] memory results = new bytes[](data.length);
        for (uint i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(
                data[i]
            );
            require(success, "call failed");
            results[i] = result;
        }
        return results;
    }
}

// 地址: 0x73DeAC4CE5Ae3caCe36F1481B62cb635D9733E0D
contract TestMultiCall {
    function test(uint _i) external view returns (uint, uint) {
        return (_i, block.timestamp);
    }

    // 0x29e99f07000000000000000000000000000000000000000000000000000000000000000a
    function getData(uint _i) external pure returns (bytes memory) {
        // abi.encodeWithSignature("test(uint)", _i); 
        // abi.encodeWithSelector(this.test.selector, _i); 这两种写法等价
        return abi.encodeWithSelector(this.test.selector, _i);
    }
}
