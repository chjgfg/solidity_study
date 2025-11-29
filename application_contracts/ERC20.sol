// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    //当前合约的token总量
    uint public totalSupply;
    //一个地址对应一个数字就是一个账本
    mapping(address => uint) public balanceOf;
    //批准的映射
    mapping(address => mapping(address => uint)) public allowance;
    //token名称
    string public name = "Solidity by Example";
    //token的缩写
    string public symbol = "SOLBYEX";
    //token的精度,一个整数1后面跟着18个0的小数,例如0.5就是一个5后面跟着17个0
    uint public decimals = 18;

    //把把账户中的余额由当前调用者发送到另一个账户中,是一个写入方法,会向外部发送一个transfer事件,通过transfer事件可以查询token的流转
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,100
    function transfer(address recipient, uint amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    //把我账户中的数量批准给另一个账户spender,allowance用来查询
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,500
    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    //向另一个合约存款的时候,另一个合约必须调用transferFrom才能把我们账户中的token拿到它的账户中,和approve联合使用
    //切换到 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,50
    function transferFrom(
        address sender, // 发送者
        address recipient, //接收者
        uint256 amount
    ) external returns (bool) {
        // 1. 检查授权额度是否足够
        require(allowance[sender][msg.sender] >= amount, "ERC20: insufficient allowance");
        // 2. 检查发送者余额是否足够
        require(balanceOf[sender] >= amount, "ERC20: transfer amount exceeds balance");
        // 3. 更新状态
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        // 4. 发射事件
        emit Transfer(sender, recipient, amount);
        return true;
    }
    //铸币方法,让合约的部署者有余额可以进行消费
    // 1000
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        //从0地址发出的都是铸币事件
        emit Transfer(address(0), msg.sender, amount);
    }
    //销毁方法
    //900
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
