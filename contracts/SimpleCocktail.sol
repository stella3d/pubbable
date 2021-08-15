//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Owned {
    address owner;

    modifier onlyOwner {
        require(owner == msg.sender, "only owner can set name");
        _;
    }

    // TODO - move these to proper utils lib
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        bytes memory bytesArray = new bytes(64);
        for (i = 0; i < bytesArray.length; i++) {
            uint8 _f = uint8(_bytes32[i/2] & 0x0f);
            uint8 _l = uint8(_bytes32[i/2] >> 4);
            bytesArray[i] = toByte(_l);
            bytesArray[i + 1] = toByte(_f);
        }
        return string(bytesArray);
    }

    function toByte(uint8 _uint8) internal pure returns (bytes1) {
        return bytes1(_uint8 + (_uint8 < 10 ? 48 : 87));
    }
}

contract SimpleCocktail is Owned {
    string public name;
    string[] public ingredients;

    constructor(string memory _name) {
        console.log("Deploying a SimpleCocktail:", _name);
        owner = msg.sender;
        name = _name;
    }

    function setName(string memory _name) public onlyOwner {
        console.log("Changing name from '%s' to '%s'", name, _name);
        name = _name;
    }

    function addIngredient(string memory _ingredient) public onlyOwner {
        console.log("adding ingredient:", _ingredient);
        ingredients.push(_ingredient);

        console.log(ingredients[0]);
    }

    function setIngredients(bytes32[] memory _ingredients) public {
        ingredients = new string[](_ingredients.length);
        for (uint256 i = 0; i < _ingredients.length; i++) {
            ingredients[i] = bytes32ToString(_ingredients[i]);
        }
    }

    function getIngredient(uint index) public view returns(string memory) {
        require(index < ingredients.length, "index must be less than length of ingredients");
        return ingredients[index];
    }
}