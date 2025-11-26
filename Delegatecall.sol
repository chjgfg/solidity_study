// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
//被调用合约,参数必须和委托合约一样,这里改的变量是委托合约的变量,它也存不了传过来的ETH,只有委托合约能存ETH
contract B {
    uint public num;
    address public sender;
    uint public value;
    function setVars(uint _num) public payable {
        num = _num * 2;
        sender = msg.sender;
        value = msg.value;
    }
}
//委托合约,参数必须和被调用合约一样
contract A {
    uint public num;
    address public sender;
    uint public value;
    function setVars(address _contract, uint _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}
