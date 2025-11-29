/*

NFT的荷兰拍卖。

拍卖
NFT卖家部署该合约，设定NFT起始价格。
拍卖期为期7天。
NFT价格会随着时间下降。
参与者可以通过存入高于智能合约当前价格的ETH来购买。
拍卖在买家购买NFT时结束。

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC721 {
    function transferFrom(address, address, uint) external;
}

contract DutchAuction {
    // 拍卖时间
    uint private constant DURATION = 7 days;

    IERC721 public immutable nft;
    // 一个nftId对应一个nft,如果想要拍卖其他的nft就必须新建一个合约
    uint public immutable nftId;
    // 销售者的地址,也就是nft当前的持有者,由他的账户拍卖出去
    address payable public immutable seller;
    // 起拍价
    uint public immutable startingPrice;
    // 开始时间
    uint public immutable startAt;
    // 这次拍卖的过期时间,当这次拍卖到达了过期时间之后就相当于发生了流拍这个事件,相当于这次拍卖不成功了
    uint public immutable expiresAt;
    // 每秒的折扣率,每秒都在起拍价的基础上减去一个数量
    uint public immutable discountRate;

    constructor(
        uint _startingPrice,
        uint _discountRate,
        address _nft,
        uint _nftId
    ) {
        // 销售成功后需要把主币发送给销售者,因此需要加上payable属性
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        discountRate = _discountRate;
        expiresAt = block.timestamp + DURATION;
        require(
            _startingPrice >= _discountRate * DURATION,
            "starting price < min"
        );

        nft = IERC721(_nft);
        nftId = _nftId;
    }
    // 获取每秒后的拍品价格
    function getPrice() public view returns (uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = timeElapsed * discountRate;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");
        uint price = getPrice();
        require(msg.value >= price, "ETH < price");
        // 把nft从卖家账户发送到当前买家账户
        nft.transferFrom(seller, msg.sender, nftId);
        // 退款金额
        uint refund = msg.value - price;
        // 如果买家出的价格比当前秒的价格高就把当前退款金额退回给买家
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        // 使用自毁方法不仅可以把剩余的主币发送给销售者的账户中,
        // 还可以将这次合约部署的时候所占用的空间消耗的gas也退还给销售者的账户中
        selfdestruct(seller);
    }
}