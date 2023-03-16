// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


contract auction {
    constructor() {
        
    }

    address[] admins;
    bool AuctionStarted;


modifier onlyAdmin {
    for (uint i = 0; i< admins.length; i++) {
        address admin = admins[i];
       require(admin == msg.sender);
    }
    _;
}

    function startAuction() public onlyAdmin returns (bool _started){
        AuctionStarted = true;
        
        _started = true;
    }
    


}