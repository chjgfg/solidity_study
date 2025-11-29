// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721 {
    function transferFrom(address, address, uint) external;
}

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount);

    IERC721 public immutable nft;
    uint public nftId;
    address payable public seller;
    uint public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    // 最高出价者的出价
    uint public highestBid;
    mapping(address => uint) public bids;

    // _startingBid 初始价格
    constructor(address _nft, uint _nftId, uint _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    function start() external {
        require(!started, "started");
        require(msg.sender == seller, "not seller");
        nft.transferFrom(seller, address(this), nftId);
        started = true;
        endAt = uint32(block.timestamp + 240);
        emit Start();
    }

    // 拍卖
    function bid() external payable {
        require(started, "not started");
        require(block.timestamp < endAt, "ended");
        require(msg.value > highestBid, "value < highest");
        // 把上一次的最高出价者的钱退回给他
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit Bid(msg.sender, msg.value);
    }

    // 取回方法
    function withdraw() external {
        // 如果出价被覆盖了,就把自己之前的出价拿出来,把数组对应位置归零,
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        // 把钱发回自己的账户
        payable(msg.sender).transfer(bal);
        // 触发取款事件
        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        // 如果出价者的地址不是0地址,才代表有人出过价
        if (highestBidder != address(0)) {
            // 把合约中的NFT从当前合约发送到最高出价者的账户上
            nft.transferFrom(address(this), highestBidder, nftId);
            // 把合约中的主币发送到销售者的地址上,发送的数量以最高出价者的数量为准
            seller.transfer(highestBid);
        } else {
            // 如果都没出价,可以把nft退还给销售者
            nft.transferFrom(address(this), seller, nftId);
        }
        emit End(highestBidder, highestBid);
    }
}
