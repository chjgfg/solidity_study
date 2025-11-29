
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// 委托调用只能够调用自身合约 contract TestMultiDelegatecall is MultiDelegatecall {}
// 不是自己写的合约就没办法进行委托调用
contract MultiDelegatecall {
    error DelegatecallFailed();
    /*
    
    调用前两个方法
    ["0x3cb8008500000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002","0xb1ade4db"]
    
    */

    /*
    调用3次铸造方法 mint, 并传入1ETH, 看结果
    ["0x1249c58b","0x1249c58b","0x1249c58b"]    
    */
    function multiDelegatecall(bytes[] memory data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);

        for (uint i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegatecallFailed();
            }
            results[i] = res;
        }
    }
}

// Why use multi delegatecall? Why not multi call?
// alice -> multi call --- call ---> test (msg.sender = multi call)
// alice -> test --- delegatecall ---> test (msg.sender = alice)
contract TestMultiDelegatecall is MultiDelegatecall {
    event Log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        // msg.sender = alice
        emit Log(msg.sender, "func1", x + y);
    }

    function func2() external returns (uint) {
        // msg.sender = alice
        emit Log(msg.sender, "func2", 2);
        return 111;
    }

    mapping(address => uint) public balanceOf;

    // WARNING: unsafe code when used in combination with multi-delegatecall
    // user can mint multiple times for the price of msg.value
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    // 0x3cb8008500000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002
    function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
    }
    // 0xb1ade4db
    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
    }
    // 0x1249c58b
    function getMintData() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecall.mint.selector);
    }
}
