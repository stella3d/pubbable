//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./Owned.sol";

contract SimpleCocktail is Owned {
    string public name;
    bytes32[] public ingredients;

    string indexError = "index must be less than length of ingredients";

    constructor(string memory _name) {
        console.log("Deploying a SimpleCocktail:", _name);
        owner = msg.sender;
        name = _name;
    }

    // TODO - add address of owner to init, since we won't get it from deployer
    function init(string memory _name, bytes32[] memory _ingredients) public {
        console.log("cocktail INIT, name '%s', ingredient count: '%s'", name, _ingredients.length);
        name = _name;
        ingredients = _ingredients;
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
        require(index < ingredients.length, indexError);
        return ingredients[index];
    }

    function setIngredient(uint256 index, bytes32 value) public {
        require(index < ingredients.length, indexError);
        ingredients[index] = value;
    }
}