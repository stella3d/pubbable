//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./Owned.sol";
import "./SimpleCocktail.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "hardhat/console.sol";


contract SimpleCocktailFactory is Owned {

    // TODO - remove, adapt test to create() function
    function deployNew(string memory _name, bytes32[] memory ingredients) 
        public onlyOwner
        returns(SimpleCocktail) 
    {
        SimpleCocktail cocktail = new SimpleCocktail(_name);
        cocktail.setIngredients(ingredients);

        console.log("deployed new Cocktail contract,", _name,  ", at:", address(cocktail));
        return cocktail;
    }

    address public libraryAddress;

    event CocktailCreated(address newThingAddress);

    // needs to be passed address of deployed SimpleCocktail contract
    constructor(address _libraryAddress) {
        libraryAddress = _libraryAddress;
        owner = msg.sender;
    }

    function setLibraryAddress(address _libraryAddress) public onlyOwner {
        libraryAddress = _libraryAddress;
    }

    function create(string memory _name, bytes32[] memory ingredients) 
        public
    {
        address clone = Clones.clone(libraryAddress);
        SimpleCocktail(clone).init(_name, ingredients);
        emit CocktailCreated(clone);
    }
}