//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Owned {
    address owner;

    modifier onlyOwner {
        require(owner == msg.sender, "only owner can set name");
        _;
    }
}

contract SimpleCocktail is Owned {
    string public name;
    bytes32[] public ingredients;

    constructor(string memory _name) {
        console.log("Deploying a SimpleCocktail:", _name);
        owner = msg.sender;
        name = _name;
    }

    function setName(string memory _name) public onlyOwner {
        console.log("Changing name from '%s' to '%s'", name, _name);
        name = _name;
    }

    function addIngredient(bytes32 _ingredient) public onlyOwner {
        //console.log("adding ingredient:", _ingredient);
        ingredients.push(_ingredient);
    }

    function getIngredients() public view returns(bytes32[] memory) {
        return ingredients;
    }

    function setIngredients(bytes32[] memory _ingredients) public onlyOwner {
        ingredients = _ingredients;
    }

    function getIngredient(uint index) public view returns(bytes32) {
        require(index < ingredients.length, "index must be less than length of ingredients");
        return ingredients[index];
    }
}