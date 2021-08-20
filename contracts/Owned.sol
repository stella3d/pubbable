//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Owned {
    address owner;

    modifier onlyOwner {
        require(owner == msg.sender, "only owner can set name");
        _;
    }
}