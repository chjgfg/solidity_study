// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * @title 透明代理合约（Transparent Proxy）
 * @dev 这是一个透明代理合约，用于实现可升级合约模式。
 *      所有函数调用都会通过 fallback 或 receive 函数委托给实现合约（implementation）。
 *      通过 setImplementation 可以升级合约逻辑而不改变合约地址。
 */
contract Proxy {
    // 实现合约地址，存储当前逻辑合约的地址
    address public implementation;

    /**
     * @dev 设置新的实现合约地址
     * @param _imp 新的实现合约地址
     * @notice 此函数没有访问控制，生产环境中应添加 onlyOwner 修饰符
     */
    function setImplementation(address _imp) external {
        implementation = _imp;
    }

    /**
     * @dev 内部委托函数，将调用委托给实现合约
     * @param _imp 实现合约地址
     * @notice 使用 assembly 实现高效的 delegatecall
     */
    function _delegate(address _imp) internal virtual {
        assembly {
            // calldatacopy(t, f, s) - 将 calldata 复制到内存
            // 将当前调用的所有输入数据（calldata）复制到内存地址 0 开始的位置
            // 参数：目标内存地址(0), calldata起始位置(0), calldata长度(calldatasize())
            calldatacopy(0, 0, calldatasize())

            // delegatecall(g, a, in, insize, out, outsize) - 执行委托调用
            // 调用实现合约 _imp，使用复制到内存中的 calldata 作为输入
            // 参数：gas限制(gas()), 目标地址(_imp), 输入数据内存起始地址(0),
            //      输入数据长度(calldatasize()), 输出数据内存起始地址(0), 输出数据长度(0)
            // 返回值：0 表示失败，1 表示成功
            let result := delegatecall(gas(), _imp, 0, calldatasize(), 0, 0)

            // returndatacopy(t, f, s) - 将返回数据复制到内存
            // 将 delegatecall 的返回数据复制到内存地址 0 开始的位置
            // 参数：目标内存地址(0), 返回数据起始位置(0), 返回数据长度(returndatasize())
            returndatacopy(0, 0, returndatasize())

            // 根据 delegatecall 的结果决定返回或回滚
            switch result
            case 0 {
                // revert(p, s) - 回滚交易并返回数据
                // 如果 delegatecall 失败，回滚并返回错误数据
                // 参数：内存起始地址(0), 数据长度(returndatasize())
                revert(0, returndatasize())
            }
            default {
                // return(p, s) - 返回数据
                // 如果 delegatecall 成功，返回结果数据
                // 参数：内存起始地址(0), 数据长度(returndatasize())
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev Fallback 函数，处理所有不匹配的函数调用
     * @notice 所有不存在的函数调用和带 calldata 的 ETH 转账都会触发此函数
     *         然后通过 _delegate 委托给实现合约
     */
    fallback() external payable {
        _delegate(implementation);
    }

    /**
     * @dev Receive 函数，处理纯 ETH 转账（无 calldata）
     * @notice 当直接向合约发送 ETH 时触发（如 user.send(1 ether)）
     *         然后通过 _delegate 委托给实现合约
     */
    receive() external payable {
        _delegate(implementation);
    }
}

// 第一版实现合约，包含基本功能
contract V1 {
    uint public x;

    function inc() external {
        x += 1;
    }
}
// 第二版实现合约，增加了额外功能
contract V2 {
    uint public x;

    function inc() external {
        x += 1;
    }

    function dec() external {
        x -= 1;
    }
}

// 计算合约的函数名的哈希值
contract SelectorCalculator {
    function getSelector(string memory functionSignature) public pure returns (bytes4) {
        return bytes4(keccak256(bytes(functionSignature)));
    }
}
