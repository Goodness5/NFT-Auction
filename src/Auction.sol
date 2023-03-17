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
        uint256[] Bids;
        address highestbidder;
        uint256 startingPrice;
        mapping(address => uint256) bidders;
        mapping(uint256 => address) getbidders;
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
        require(_duration > block.timestamp, "invalid time");
        newItem.auctionStarted = true;
        newItem.highestBid = 0;
        newItem.startingPrice = _startingprice;
        IERC721(newItem.nftAddress).safeTransferFrom(_nftOwner, address(this), newItem.nftId);

        if (block.timestamp == _duration) {
            endAuction(newItem.nftId);
        }
        newItem.bidders[_nftOwner] = _startingprice;
        if (newItem.duration== block.timestamp) {
            endAuction(_nftId);
        }

    }

    function placeBid(uint256 _auctionId) public payable {
        AuctionItem storage item = auctionItems[_auctionId];
        require(item.auctionStarted, "auction not started");
        
        require(msg.value > item.startingPrice);

        item.bidders[msg.sender] = msg.value;
        item.Bids.push(msg.value);
        item.getbidders[msg.value] = msg.sender;
        
    }

    function updateBid(uint256 _auctionId) public payable returns  (bool _updated) {
        AuctionItem storage item = auctionItems[_auctionId];
        require(msg.sender != address(0));
        require(item.bidders[msg.sender] != 0, "you don't have a bid");
        require(item.auctionStarted, "this auction is not in progress");
        uint amount = msg.value;
        (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "update failed failed.");
        item.bidders[msg.sender] += amount;
    }

    function withdraw(uint256 _auctionid) public {
        AuctionItem storage aunction = auctionItems[_auctionid];
        require(aunction.bidders[msg.sender] > 0, "You don't have a bid.");

        uint amount = (aunction.bidders[msg.sender] * 9) / 10;

        if (msg.sender != address(0)) {
        (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "Transfer failed.");
            aunction.bidders[msg.sender] = 0;   
        }
        else{
            revert("invalid caller");
        }
}

   function endAuction(uint256 _auctionId) public onlyAdmin {
        AuctionItem storage item = auctionItems[_auctionId];
        require(item.auctionStarted, "Auction not in progress");

        address bidders;
        for (uint i = 0; i < item.Bids.length; i++) {
            if (item.Bids[i] > item.highestBid) {
                item.highestBid = item.Bids[i];
                item.highestbidder = item.getbidders[item.highestBid];
            }
        }



    item.auctionStarted = false;
    if (bidders == address(0)) {
        item.nftAddress.safeTransferFrom(address(this), _owner, item.nftId);
    }

    else{
    item.nftAddress.safeTransferFrom(address(this), bidders, item.nftId);
        payable(owner()).transfer(item.highestBid);
    }
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
