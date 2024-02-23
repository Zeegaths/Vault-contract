// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Vault {
    address public owner;
    mapping(address => Grant) public grants;

    struct Grant {
        uint amount;
        uint unlockTime;
        bool claimed;
    }

    event GrantOffered(address indexed donor, address indexed beneficiary, uint amount, uint unlockTime);
    event GrantClaimed(address indexed beneficiary, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier grantNotClaimed(address _beneficiary) {
        require(!grants[_beneficiary].claimed, "Grant has already been claimed");
        _;
    }

    modifier onlyBeneficiary(address _beneficiary) {
        require(msg.sender == _beneficiary, "Only the beneficiary can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function offerGrant(address _beneficiary, uint _unlockTime) external payable onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");

        Grant storage grant = grants[_beneficiary];
        require(!grant.claimed, "Grant for this beneficiary already exists");

        grant.amount = msg.value;
        grant.unlockTime = _unlockTime;

        emit GrantOffered(msg.sender, _beneficiary, msg.value, _unlockTime);
    }

    function claimGrant() external onlyBeneficiary(msg.sender) grantNotClaimed(msg.sender) {
        Grant storage grant = grants[msg.sender];
        require(block.timestamp >= grant.unlockTime, "Grant is not yet unlocked");

        grant.claimed = true;
        payable(msg.sender).transfer(grant.amount);

        emit GrantClaimed(msg.sender, grant.amount);
    }

    function getGrantDetails(address _beneficiary) external view returns (uint amount, uint unlockTime, bool claimed) {
        Grant storage grant = grants[_beneficiary];
        return (grant.amount, grant.unlockTime, grant.claimed);
    }
}
