const { expect } = require("chai");
const hre = require("hardhat");
const web3 = hre.web3;

function stringToBytes32(str) {
  var hexStr = web3.utils.asciiToHex(str);
  console.log("string:", str, "as hex:", hexStr, "hex length:", hexStr.length);
  if(hexStr.length > 64)
    throw new Exception("maximum length of hex string is 64, but " + str + "has length " + hexStr.length);

  //console.log("padLeft:", 64 - hexStr.length);
  return web3.utils.padLeft(hexStr, 64);
  //return hexStr;
}

function trimHexPrefix(str) {
  return str.startsWith('0x') ? str.slice(2) : str;
}

describe("SimpleCocktail", function () {
  let SimpleCocktail;

  const CocktailName = "Michelada";

  const BaseIngredients = ""

  before(async () => {
    SimpleCocktail = await ethers.getContractFactory("SimpleCocktail");
  });

  it("Should return the new name once it's changed", async function () {
    const startName = "Chelada";
    const cocktail = await SimpleCocktail.deploy(startName);
    await cocktail.deployed();
    expect(await cocktail.name()).to.equal(startName);

    const setNameTx = await cocktail.setName(CocktailName);
    // wait until the transaction is mined
    await setNameTx.wait();
    expect(await cocktail.name()).to.equal(CocktailName);
  });

  it("Should return the new ingredients after addIngredients()", async function () {
    const cocktail = await SimpleCocktail.deploy(CocktailName);
    await cocktail.deployed();

    // check out-of-bounds index guard 
    await expect(cocktail.getIngredient(0)).to.be.revertedWith("index must be less than length of ingredients");

    const addedIngredient = "Mexican lager";
    const addIngredientTx = await cocktail.addIngredient(addedIngredient);
    await addIngredientTx.wait();
    expect(await cocktail.getIngredient(0)).to.equal(addedIngredient);
  });

  it("Should return the new ingredients after setIngredients()", async function () {
    const cocktail = await SimpleCocktail.deploy(CocktailName);
    await cocktail.deployed();

    const ingredient0 = stringToBytes32("1 pint Mexican lager");
    const ingredient1 = stringToBytes32("2oz tomato juice");
    const ingredient2 = stringToBytes32("1/2 juiced lime, quartered");
    const setIngredientTx = await cocktail.setIngredients([ingredient0, ingredient1, ingredient2]);
    await setIngredientTx.wait(); // wait for tx mine

    expect(await cocktail.getIngredient(0)).to.equal(trimHexPrefix(ingredient0));
    expect(await cocktail.getIngredient(1)).to.equal(trimHexPrefix(ingredient1));
    expect(await cocktail.getIngredient(2)).to.equal(trimHexPrefix(ingredient2));
    // make sure only 3 string slots were allocated 
    await expect(cocktail.getIngredient(3)).to.be.revertedWith("index must be less than length of ingredients");

    // make sure that adding ingredients still works after initializing to a fixed length
    const ingredient3 = "dash of salt";
    const addIngredientTx = await cocktail.addIngredient(ingredient3);
    await addIngredientTx.wait();
    expect(await cocktail.getIngredient(3)).to.equal(trimHexPrefix(ingredient3));
  });
});
