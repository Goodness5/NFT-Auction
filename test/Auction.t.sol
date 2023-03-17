// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/forge-std/src/Test.sol";
// import "../lib/openzeppelin-contracts/contacts/token/ERC721/IERC721.sol";
import "../src/Auction.sol";
import "../Mock/NFT.sol";

contract AuctionTest is Test {
    Auction public auction;
    NFT public nft;

    function setUp() public {
        auction = new Auction();
        auction.addAdmin(address(this));
        nft = new NFT();
        nft.approve(address(auction), 1);
        // nft.transferFrom(address(this), address(auction), 1);
    }

    // function test_addAdmin() public {
    //     uint admincounts = auction.admins.length;
    //     auction.addAdmin(address(0x1234567890123456789012345678901234567890));
    //     uint newAdminCount = auction.admins.length;
    //     assertTrue(newAdminCount == newAdminCount + 1);
    // }

    // function test_removeAdmin() public {
    //     auction.addAdmin(address(0x1234567890123456789012345678901234567890));
    //     uint initialAdminCount = auction.admins.length;
    //     auction.removeAdmin(address(0x1234567890123456789012345678901234567890));
    //     uint newAdminCount = auction.admins.length;
    //     assertTrue(newAdminCount == initialAdminCount - 1);
    // }

    function test_startAuction() public {
        // auction.startAuction()
        // uint initialAuctionCount = auction.auctionId();
        auction.startAuction("testnft", nft, 1, 999999999, 1, address(this));
        // uint newAuctionCount = auction.auctionId();
        // assertTrue(newAuctionCount == initialAuctionCount + 1);
    }

    // function test_placeBid() public payable {
    //     auction.startAuction("testnft", nft, 1, 8999, 1, address(this));
    //     uint initialBid = auction.bids(address(this));
    //     auction.placeBid{value: 1000}(1);
    //     uint newBid = auction.bids(address(this));
    //     assertTrue(newBid == initialBid + 1000);
    // }

    // function test_withdraw() public payable {
    //     auction.startAuction("testnft", nft, 1, 8999, 1, address(this));
    //     auction.placeBid{value: 1000}(1);
    //     uint initialBalance = address(this).balance;
    //     auction.withdraw(1);
    //     uint newBalance = address(this).balance;
    //     assertTrue(newBalance == initialBalance + 900);
    // }

    // function test_endAuction() public {
    //     auction.startAuction("testnft", nft, 1, 8999, 1, address(this));
    //     auction.placeBid{value: 1000}(1);
    //     address initialNftOwner = nft.ownerOf(1);
    //     auction.endAuction(1);
    //     address newNftOwner = nft.ownerOf(1);
    //     assertTrue(newNftOwner == address(this));
    //     assertTrue(auction.bids(address(this)) == 0);
    // }

    // function test_withdrawNft() public {
    //     auction.startAuction("testnft", nft, 1, 8999, 1, address(this));
    //     auction.endAuction(1);
    //     auction.withdrawNft(1, address(this));
    //     assertTrue(nft.ownerOf(1) == address(this));
    // }
}
