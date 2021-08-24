import { expect } from "chai";
import { ContractFactory } from "ethers";
import { ethers } from "hardhat";
import { stringToBytes32 } from "./util";

describe("Cocktail", function () {
  let Cocktail: ContractFactory;

  const CocktailName = "Michelada";

  before(async () => {
    Cocktail = await ethers.getContractFactory("Cocktail");
  });

  it("Should return the new name once it's changed", async function () {
    const startName = "Chelada";
    const cocktail = await Cocktail.deploy(startName);
    await cocktail.deployed();
    expect(await cocktail.name()).to.equal(startName);

    const setNameTx = await cocktail.setName(CocktailName);
    // wait until the transaction is mined
    await setNameTx.wait();
    expect(await cocktail.name()).to.equal(CocktailName);
  });

  it("Should return the new ingredients after addIngredients()", async function () {
    const cocktail = await Cocktail.deploy(CocktailName);
    await cocktail.deployed();

    const addedIngredient = stringToBytes32("Mexican lager");
    const addIngredientTx = await cocktail.addIngredient(addedIngredient);
    await addIngredientTx.wait();
    expect(await cocktail.ingredients(0)).to.equal(addedIngredient);
  });

  it("Should return the new ingredients after setIngredients()", async function () {
    const cocktail = await Cocktail.deploy(CocktailName);
    await cocktail.deployed();

    const ingredient0 = stringToBytes32("1 pint Mexican lager");
    const ingredient1 = stringToBytes32("2oz tomato juice");
    const ingredient2 = stringToBytes32("1/2 juiced lime, quartered");
    const setIngredientTx = await cocktail.setIngredients([ingredient0, ingredient1, ingredient2]);
    await setIngredientTx.wait(); // wait for tx mine

    expect(await cocktail.ingredients(0)).to.equal(ingredient0);
    expect(await cocktail.ingredients(1)).to.equal(ingredient1);
    expect(await cocktail.ingredients(2)).to.equal(ingredient2);

    // make sure that adding ingredients still works after initializing to a fixed length
    const ingredient3 = stringToBytes32("dash of salt");
    const addIngredientTx = await cocktail.addIngredient(ingredient3);
    await addIngredientTx.wait();
    expect(await cocktail.ingredients(3)).to.equal(ingredient3);
  });

  it("Should return a new ingredient at the right index after setIngredient()", async function () {
    const cocktail = await Cocktail.deploy(CocktailName);
    await cocktail.deployed();

    const ingredient0 = stringToBytes32("1 pint Mexican lager");
    const ingredient1 = stringToBytes32("2oz tomato juice");
    const setIngredientsTx = await cocktail.setIngredients([ingredient0, ingredient1]);
    await setIngredientsTx.wait(); // wait for tx mine
    // make sure initial value is set
    expect(await cocktail.ingredients(1)).to.equal(ingredient1);

    // make sure that adding ingredients still works after initializing to a fixed length
    const newIngredient1 = stringToBytes32("dash of salt");
    const setIngredientTx = await cocktail.setIngredient(1, newIngredient1);
    await setIngredientTx.wait();
    expect(await cocktail.ingredients(1)).to.equal(newIngredient1);
  });


  it("Should allow retrieving the ingredient list as a bytes32[]", async function () {
    const cocktail = await Cocktail.deploy(CocktailName);
    await cocktail.deployed();

    const ingredient0 = stringToBytes32("1 pint Mexican lager");
    const ingredient1 = stringToBytes32("2oz tomato juice");
    const setIngredientTx = await cocktail.setIngredients([ingredient0, ingredient1]);
    await setIngredientTx.wait(); // wait for tx mine

    //const ingredients = await cocktail.getIngredients();
    expect(await cocktail.ingredients(0)).to.equal(ingredient0);
    expect(await cocktail.ingredients(1)).to.equal(ingredient1);
  });
});
