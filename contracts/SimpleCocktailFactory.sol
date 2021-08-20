//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./Owned.sol";
import "./SimpleCocktail.sol";


contract SimpleCocktailFactory is Owned {

    constructor() {
        console.log("Deploying a SimpleCocktailFactory");
        owner = msg.sender;
    }

    function deployNew(string memory _name, bytes32[] memory ingredients) public onlyOwner {
        console.log("deploying new Cocktail contract:  ", _name);
        SimpleCocktail cocktail = new SimpleCocktail(_name);
        cocktail.setIngredients(ingredients);

        console.log("new Cocktail contract deployed at:  ", address(cocktail));
    }
}