// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SubastaEnzoVinella {
    //PARA DINERO uint256
    uint256 public initialValue;
    uint256 public minimumIncreaseInBid;

    // Timestamps
    uint public startTimestamp;
    uint public bidDuration;
    uint public extensionTimeAfterBid; 
    // Constructor - opcional

    constructor(uint256 _initialValue, uint256 _minIncrease, uint _bidDuration, uint _extension) {
        initialValue = _initialValue;
        minimumIncreaseInBid = _minIncrease;
        bidDuration = _bidDuration;
        extensionTimeAfterBid = _extension;

        startTimestamp = block.timestamp;

    }

    // Funciones
    
}