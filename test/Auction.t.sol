// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/forge-std/src/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../src/Auction.sol";

contract AuctionTest is Test {
    Auction public auction;
    IERC721 public nft;

    function setUp() public {
        auction = new Auction();
        auction.addAdmin(address(this));
        nft = IERC721(address(this));
        nft.transferFrom(address(this), address(auction), 1);
    }

    function test_addAdmin() public {
        address admin = auction.admins;
        uint admincounts = admin.length;
        auction.addAdmin(address(0x1234567890123456789012345678901234567890));
        uint newAdminCount = auction.admins.length;
        assertTrue(newAdminCount == admincount + 1);
    }

    function test_removeAdmin() public {
        auction.addAdmin(address(0x1234567890123456789012345678901234567890));
        uint initialAdminCount = auction.admins.length;
        auction.removeAdmin(address(0x1234567890123456789012345678901234567890));
        uint newAdminCount = auction.admins.length;
        assertTrue(newAdminCount == initialAdminCount - 1);
    }

    function test_startAuction() public {
        uint initialAuctionCount = auction.auctionId();
        auction.startAuction("testnft", nft, 1, 8999, 1);
        uint newAuctionCount = auction.auctionId();
        assertTrue(newAuctionCount == initialAuctionCount + 1);
        assertTrue(auction.auctionItems(newAuctionCount).nftAddress() == address(nft));
    }

    function test_placeBid() public payable {
        auction.startAuction("testnft", nft, 1, 8999, 1);
        uint initialBid = auction.bids(address(this));
        auction.placeBid{value: 1000}(1);
        uint newBid = auction.bids(address(this));
        assertTrue(newBid == initialBid + 1000);
    }

    function test_withdraw() public payable {
        auction.startAuction("testnft", nft, 1, 8999, 1);
        auction.placeBid{value: 1000}(1);
        uint initialBalance = address(this).balance;
        auction.withdraw();
        uint newBalance = address(this).balance;
        assertTrue(newBalance == initialBalance + 900);
    }

    function test_endAuction() public {
        auction.startAuction("testnft", nft, 1, 8999, 1);
        auction.placeBid{value: 1000}(1);
        uint initialNftOwner = nft.ownerOf(1);
        auction.endAuction(1);
        uint newNftOwner = nft.ownerOf(1);
        assertTrue(newNftOwner == address(this));
        assertTrue(auction.bids(address(this)) == 0);
    }

    function test_withdrawNft() public {
        auction.startAuction("testnft", nft, 1, 8999, 1);
        auction.endAuction(1);
        auction.withdrawNft(1, address(this));
        assertTrue(nft.ownerOf(1) == address(this));
    }
}
