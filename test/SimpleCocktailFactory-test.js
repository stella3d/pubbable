
const { expect } = require("chai");
const util = require("./util.js");

describe("SimpleCocktailFactory", function () {
    let Factory, Cocktail;
    let factory, cocktail;

    before(async function() {
        //console.log(ethers);
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
        const ingredients = util.stringToBytes32(["i0", "i1", "i2"]);
        let newCocktailTx = await factory.create(name, ingredients);
        let receipt = await newCocktailTx.wait();

        let createEvent = receipt.events[0];
        console.log(createEvent);

        let deployedAddress = createEvent.args[0];
        let instance = await Cocktail.attach(deployedAddress);

        const deployedIngredients = await instance.getIngredients();
        console.log(deployedIngredients);
        expect(deployedIngredients).to.deep.equal(ingredients);
    });
  });
  