// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/forge-std/src/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../src/Auction.sol";
import "../Mock/NFT.sol";

contract AuctionTest is Test {
    Auction public auction;
    NFT nft;
    address tester1 = mkaddr("tester1");
    address bid = mkaddr("bider");

    function setUp() public {
        vm.startPrank(tester1);
        auction = new Auction();
        auction.addAdmin(tester1);
        nft = new NFT();
        vm.stopPrank();
        console.log(nft.balanceOf(tester1));
    }

    function testCreate() public {
        vm.startPrank(tester1);
        nft.approve(address(auction), 1);
        auction.startAuction("test", address(nft), 1, 765762, 1, tester1);
        vm.stopPrank();
        
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    // function test_startAuction() public {
    //     // vm.startPrank(tester1);

    //     uint initialAuctionCount = auction.auctionId();
    //     nft.approve(address(this), 1);
    //     auction.startAuction("testnft", address(nft), 1, 8999, 1, address(this));
    //     uint newAuctionCount = auction.auctionId();
    //     assertTrue(newAuctionCount == initialAuctionCount + 1);
    // }
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


    function test_placeBid() public payable {
        vm.startPrank(tester1);
         nft.approve(address(auction), 1);
        auction.startAuction("testnft", address(nft), 1, 8999, 1, tester1);
        vm.stopPrank();
         vm.startPrank(bid);
        vm.deal(bid, 100000 ether);
        auction.placeBid{value: 1000}(1);
        uint newBid = auction.bids(address(this));
         vm.stopPrank();
    }

    function test_withdraw() public payable {
        vm.startPrank(tester1);
        nft.approve(address(auction), 1);
        auction.startAuction("testnft", address(nft), 1, 8999, 1, tester1);
        vm.stopPrank();
         vm.startPrank(bid);
        vm.deal(bid, 100000 ether);
        auction.placeBid{value: 1000}(1);
        // uint initialBalance = auction.bidders[bid];
        auction.withdraw(1);
        uint newBalance = address(this).balance;
        // assertTrue(newBalance == initialBalance + 900);
    }

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

    // test all functions in auction.sol
}
