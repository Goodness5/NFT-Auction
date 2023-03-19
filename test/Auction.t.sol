// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../lib/forge-std/src/Test.sol";
// import "../lib/openzeppelin-contracts/contacts/token/ERC721/IERC721.sol";
import "../src/Auction.sol";
import "../Mock/NFT.sol";

contract AuctionTest is Test {
    Auction public auction;
    mockNFT nft;
    address tester1 = mkaddr("tester1");
    address bid = mkaddr("bider");

    function setUp() public {
        auction = new Auction();
        vm.prank(tester1);
        nft = new mockNFT();
    }

    function testCreate() public {
        vm.startPrank(tester1);
        nft.approve(0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, 1);
        auction.createAuction(0, 20, address(nft), 1);
        vm.stopPrank();
        vm.deal(bid, 10 ether);
        vm.prank(bid);

        auction.bid{value: 0.3 ether}(1);
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}
