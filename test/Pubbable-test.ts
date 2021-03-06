import { expect } from "chai";
import { BigNumber, Contract, ContractFactory, Transaction } from "ethers";
import { ethers } from "hardhat";
import { printArgs, stringToBytes32 } from "./util";

describe("Pubbable", function () {
    let Pubbable: ContractFactory; 
    let pubbable: Contract;

    let senderAddress: BigNumber;

    const testMetadataUri = "https://pubbable.xyz/{id}.json";

    before(async function() {
        Pubbable = await ethers.getContractFactory("Pubbable");
        pubbable = await Pubbable.deploy(testMetadataUri);
        await pubbable.deployed();
    });

    // mintBar() sets up some state for mintCocktail tests, don't change order
    // messy dependency but easier than making a new sender address (maybe?)
    describe("mintBar()", function() {
        const initialSupply = 21000;
        let txReceipt: any, mintEvent: any, mintArgs : any;
        let lastBarId: BigNumber; 

        before(async function() {
            lastBarId = await pubbable.barIdCounter();
            // run the mint function here, check individual effects in tests
            let newBarTx = await pubbable.mintBar(initialSupply);
            txReceipt = await newBarTx.wait();
            mintEvent = txReceipt.events[0];
            mintArgs = mintEvent.args;
            senderAddress = mintArgs[0];
        });
        
        it("mints with the expected new token ID", async function () {
            const idArg = mintArgs[3];
            // make sure we incremented by 2, so the LSB of the id stays the same
            expect(parseInt(idArg)).to.equal(lastBarId.toNumber() + 2);
        });

        it("mints with the correct initial supply", async function () {
            const supplyArg = mintArgs[4];
            expect(supplyArg).to.equal(initialSupply);
        });

        it("gives the minter the whole initial supply", async function () {
            const lastBarId: BigNumber = await pubbable.barIdCounter();
            const balance = await pubbable.balanceOf(senderAddress, lastBarId);
            expect(balance).to.equal(initialSupply);
        });

        it("has same operator & to arguments, transfers from 0 address", async function () {
            expect(mintArgs[0]).to.equal(mintArgs[2]);
            expect(mintArgs[1]).to.equal(ethers.constants.AddressZero);
        });
    });

    describe("mintCocktail()", function() {
        let txReceipt: any, mintEvent: any, mintArgs : any;
        let lastCocktailId: BigNumber, lastBarId: BigNumber;
        let toAddress: BigNumber
        let previousCocktailCount: number;

        before(async function() {
            lastCocktailId = await pubbable.cocktailIdCounter();
            lastBarId = await pubbable.barIdCounter();
            previousCocktailCount = await pubbable.getCurrentCocktailCount(lastBarId);
            // TODO - vary the 'to' address from the initial message sender
            toAddress = senderAddress
            // run the mint function here and test effects in tests
            let mintTx = await pubbable.mintCocktail(toAddress, lastBarId);

            txReceipt = await mintTx.wait();
            mintEvent = txReceipt.events[0];
            mintArgs = mintEvent.args;
            senderAddress = mintArgs[0];
        });
        
        it("mints with the expected new token ID", async function () {
            const idArg = mintArgs[3];
            // make sure we incremented by 2, so the LSB of the id stays the same
            expect(parseInt(idArg)).to.equal(lastCocktailId.toNumber() + 2);
        });

        it("gives the minter a balance of 1 in the new token", async function () {
            const newCocktailId: BigNumber = await pubbable.cocktailIdCounter();
            const balance = await pubbable.balanceOf(senderAddress, newCocktailId);
            expect(balance).to.equal(1);
        });

        it("has correct 'to' address argument, transfers from 0 address", async function () {
            expect(mintArgs[0]).to.equal(mintArgs[2]);
            expect(mintArgs[1]).to.equal(ethers.constants.AddressZero);
        });

        it("resets the minting bar's last cocktail mint time", async function () {
            const mintTime = await pubbable.getLastCocktailMintTime(lastBarId);
            // TODO - replace this check with one for exact equality with the block's timestamp,
            // not sure how to get that in TS yet
            expect(mintTime.toNumber()).to.be.greaterThan(0);
        });

        it("increases the bar's current cocktail count by 1", async function () {
            const newCount = await pubbable.getCurrentCocktailCount(lastBarId);
            expect(newCount).to.be.equal(previousCocktailCount + 1);
        });
    });
  });
  