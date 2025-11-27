// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract MyToken {
    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    mapping(address => uint256) public balanceOf;
    constructor() {
        balanceOf[msg.sender] = 1000;
    }
    address public sender;
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,100
    function transfer(address _to, uint256 amount) public returns (bool) {
        sender = msg.sender;
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[_to] += amount;
        return true;
    }
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
    mapping(address => uint256) public balanceOf;
    address public sender;
    // 我们从 FunctionSelector 合约得到的选择器
    // bytes4 public constant TRANSFER_SELECTOR = 0xa9059cbb;
    // 0x6eef01557aE461A863c6214A96B0dD872601b53d,0xa9059cbb,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,100
    function callTransfer(address tokenAddress, bytes4 transferSelector, address _to, uint256 amount) public returns (bool) {
        (bool success, bytes memory data) = tokenAddress.delegatecall(
            abi.encodeWithSelector(transferSelector, _to, amount)
        );
        require(success, "Call to transfer failed");
        // abi.decode 会尝试将 returnData 解码为一个 bool，如果失败会 revert。
        return abi.decode(data, (bool));
    }
}
