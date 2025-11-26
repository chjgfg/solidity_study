// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MyToken {
    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    mapping(address => uint256) public balanceOf;
    constructor() {
        balanceOf[msg.sender] = 1000;
    }
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,100
    function transfer(address _to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[_to] += amount;
        return true;
    }
    address public sender;
    function getMessageSender() public {
        sender = msg.sender;
    }
}
contract FunctionSelector {
    //"transfer(address,uint256)" => 0xa9059cbb
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }
}
contract CallerContract {
    // 我们从 FunctionSelector 合约得到的选择器
    // bytes4 public constant TRANSFER_SELECTOR = 0xa9059cbb;
    // 0x15897B66FABea0010470984a6F9BaAFd61061F56,0xa9059cbb,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,100
    function callTransfer(address tokenAddress, bytes4 transferSelector, address _to, uint256 amount) public returns (bool) {
        (bool success, bytes memory data) = tokenAddress.delegatecall(
            abi.encodeWithSelector(transferSelector, _to, amount)
        );
        require(success, "Call to transfer failed");
        // 检查返回值。transfer 函数返回一个 bool 值。
        // abi.decode 会尝试将 returnData 解码为一个 bool，如果失败会 revert。
        return abi.decode(data, (bool));
    }
}
