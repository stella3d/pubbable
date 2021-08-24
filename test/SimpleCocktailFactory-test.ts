import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { stringToBytes32 } from "./util";

describe("SimpleCocktailFactory", function () {
    let Factory: ContractFactory; 
    let factory: Contract;
    let Cocktail: ContractFactory;
    let cocktail: Contract;

    before(async function() {
        Cocktail = await ethers.getContractFactory("SimpleCocktail");
        Factory = await ethers.getContractFactory("SimpleCocktailFactory");

        cocktail = await Cocktail.deploy("Library Contract");
        await cocktail.deployed();

        console.log("address of Cocktail lib: " + cocktail.address);
        factory = await Factory.deploy(cocktail.address);
        await factory.deployed();
    });
  
    // TODO - update after using proper clone factory
    it("Should deploy a new Cocktail contract", async function () {
        const name = "factory made contract 1";
        const ingredients = stringToBytes32(["i0", "i1", "i2"]);
        let newCocktailTx = await factory.create(name, ingredients);
        let receipt = await newCocktailTx.wait();

        // every Event logged within a transaction is available,
        // this is how we get multiple return arguments
        let createEvent = receipt.events[0];
        let deployedAddress = createEvent.args[0];
        // get Cocktail type instance from deployed contract address
        let instance = await Cocktail.attach(deployedAddress);

        expect(await instance.name()).to.equal(name);
        expect(await instance.getIngredients()).to.deep.equal(ingredients);
    });
  });
  