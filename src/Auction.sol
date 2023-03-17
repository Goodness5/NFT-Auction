// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Auction is Ownable{

    address[] public admins;
    uint256 public auctionId;
    mapping(address => uint) public bids;
    address _owner;

    struct AuctionItem {
        string name;
        IERC721 nftAddress;
        uint256 nftId;
        uint256 duration;
        bool auctionStarted;
        uint256 highestBid;
        address highestBidder;
        uint256 startingPrice;
    }
    mapping(uint256 => AuctionItem) public auctionItems;

    modifier onlyAdmin() {
        bool isAdmin = false;
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == msg.sender) {
                isAdmin = true;
                break;
            }
        }
        require(isAdmin, "Only admins");
        _;
    }

    constructor() {
        admins.push(msg.sender);
        _owner=msg.sender;
    }

    function addAdmin(address _admin) public onlyAdmin {
        admins.push(_admin);
    }

    function removeAdmin(address _admin) public onlyOwner {
        for (uint i = 0; i < admins.length; i++) {
            if (admins[i] == _admin) {
                delete admins[i];
                break;
            }
        }
    }

    function startAuction(
        string memory _itemName,
        IERC721 _nftAddress,
        uint256 _nftId,
        uint256 _duration,
        uint256 _startingprice,
        address _nftOwner
    ) public onlyAdmin {
        auctionId += 1;
        AuctionItem storage newItem = auctionItems[auctionId];
        newItem.name = _itemName;
        newItem.nftAddress = _nftAddress;
        newItem.nftId = _nftId;
        newItem.duration = _duration;
        newItem.auctionStarted = true;
        newItem.highestBid = 0;
        newItem.highestBidder = address(0);
        newItem.startingPrice = _startingprice;
        IERC721(newItem.nftAddress).safeTransferFrom(_nftOwner, address(this), newItem.nftId);
    }

    function placeBid(uint256 _auctionId) public payable {
        AuctionItem storage item = auctionItems[_auctionId];
        require(item.auctionStarted, "auction not started");
        require(
            msg.value > item.highestBid,
            "Your bid must be higher than the current highest bid."
        );
        require(msg.value > item.startingPrice);

        if (item.highestBidder != address(0)) {
            bids[item.highestBidder] += item.highestBid;
        }

        item.highestBid = msg.value;
        item.highestBidder = msg.sender;
    }

    function withdraw() public {
        require(bids[msg.sender] > 0, "You don't have a bid.");

        uint amount = (bids[msg.sender] * 9) / 10;
        bids[msg.sender] = 0;

        if (!payable(msg.sender).send(amount)) {
            bids[msg.sender] = amount;
        }
    }

    function endAuction(uint256 _auctionId) public onlyAdmin {
        AuctionItem storage item = auctionItems[_auctionId];
        require(item.auctionStarted, "Auction not in progress");

        item.auctionStarted = false;
        if (item.highestBidder == address(0)) {
            item.nftAddress.safeTransferFrom(address(this), _owner, item.nftId);
        }
        item.nftAddress.safeTransferFrom(
            address(this),
            item.highestBidder,
            item.nftId
        );

        // if (item.highestBidder != address(0)) {
        //     payable(owner).transfer(item.highestBid);
        // }
    }

    function withdrawNft(uint256 _auctionId, address _to) public onlyAdmin {
        AuctionItem storage item = auctionItems[_auctionId];
        require(!item.auctionStarted, "Auction is still ongoing.");
        require(
            item.nftAddress.ownerOf(item.nftId) == address(this),
            "nft not present"
        );
        item.nftAddress.safeTransferFrom(address(this), _to, item.nftId);
    }

    receive() payable external {

    }

    fallback() external payable{
        
    }
}
