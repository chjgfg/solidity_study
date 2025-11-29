/*
众筹ERC20代币

用户创建一个活动。
用户可以承诺，将代币转移到活动中。
活动结束后，如果承诺的总金额超过活动目标，活动创建者可以领取资金。
否则，活动未达标，用户可以撤回承诺。
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./IERC20.sol";

contract CrowdFund {
    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint32 startAt,
        uint32 endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    // 筹款活动
    struct Campaign {
        // 众筹的创建者
        address creator;
        // 众筹的目标
        uint goal;
        // 现在已经众筹了多少了
        uint pledged;
        // 众筹的开始时间
        uint32 startAt;
        // 众筹的结束时间
        uint32 endAt;
        // 标记这次众筹是否已经被领取过，默认false是没被领取
        bool claimed;
    }

    IERC20 public immutable token;
    // 筹款活动的计数
    uint public count;
    mapping(uint => Campaign) public campaigns;
    // 承诺的数量,筹款活动的id=>筹款活动的用户地址=>筹款活动的token数额
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address _token) {
        // 规定当前合约必须只能使用哪个token的地址
        token = IERC20(_token);
    }

    // 创建众筹活动
    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "end at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");
        count += 1;
        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });
    }
    // 取消众筹活动,创建众筹的创建者可以在众筹开始之前取消众筹
    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "not creator");
        require(block.timestamp < campaign.startAt, "started");
        delete campaigns[_id];
        emit Cancel(_id);
    }
    // 参与众筹,其他用户拿一些token的数量去参与众筹
    function pledge(uint _id, uint _amount) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");
        campaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledge(_id, msg.sender, _amount);
    }
    // 不想参与众筹的可以取消自己参与的众筹
    function unpledge(uint _id, uint _amount) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");
        campaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);
    }
    // 领走token,当参与众筹的数量达到了目标之后众筹的创建者就可以把用户参与众筹的token按照数量领取出来
    function claim(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");
        require(campaign.creator == msg.sender, "not creator");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");
        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);
        emit Claim(_id);
    }
    // 没有达到目标,参与众筹的用户还可以把自己的token领取回去,这次众筹失败
    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp <= campaign.endAt, "ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);
        emit Refund(_id, msg.sender, bal);
    }
}
