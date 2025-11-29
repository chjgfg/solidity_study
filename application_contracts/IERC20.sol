// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    //代表当前合约的token总量
    function totalSupply() external view returns (uint);
    //代表某一个账户的当前余额
    function balanceOf(address account) external view returns (uint);
    //把把账户中的余额由当前调用者发送到另一个账户中,是一个写入方法,会向外部发送一个transfer事件,通过transfer事件可以查询token的流转
    function transfer(address recipient, uint amount) external returns (bool);
    //可以查询一个账户对另一个账户的批准额度是多少
    function allowance(address owner, address spender) external view returns (uint);
    //把我账户中的数量批准给另一个账户,allowance用来查询
    function approve(address spender, uint amount) external returns (bool);
    //向另一个合约存款的时候,另一个合约必须调用transferFrom才能把我们账户中的token拿到它的账户中,和approve联合使用
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
