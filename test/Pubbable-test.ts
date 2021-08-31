import { expect } from "chai";
import { BigNumber, Contract, ContractFactory, Transaction } from "ethers";
import { ethers } from "hardhat";
import { printArgs } from "./util";

describe("Pubbable", function () {
    let Pubbable: ContractFactory; 
    let pubbable: Contract;

    before(async function() {
        Pubbable = await ethers.getContractFactory("Pubbable");
        pubbable = await Pubbable.deploy();
        await pubbable.deployed();
    });

    describe("mintBar()", function() {
        const initialSupply = 21000;
        let txReceipt: any, mintEvent: any, mintArgs : any;
        let lastCreatedBarId: BigNumber;

        before(async function() {
            lastCreatedBarId = await pubbable.barIdCounter();
            // run the mint function here, check individual effects in tests
            let newBarTx = await pubbable.mintBar(initialSupply);
            txReceipt = await newBarTx.wait();
            mintEvent = txReceipt.events[0];
            mintArgs = mintEvent.args;
        });
        
        it("mints with the expected new token ID", async function () {
            const idArg = mintArgs[3];
            // make sure we incremented by 2, so the LSB of the id stays the same
            expect(parseInt(idArg)).to.equal(lastCreatedBarId.toNumber() + 2);
        });

        it("mints with the correct initial supply", async function () {
            const supplyArg = mintArgs[4];
            expect(supplyArg).to.equal(initialSupply);
        });

        it("transfers from 0 address", async function () {
            expect(mintArgs[1]).to.equal(ethers.constants.AddressZero);
        });

        it("has the same operator & to address arguments", async function () {
            expect(mintArgs[0]).to.equal(mintArgs[2]);
        });
    });
  });
  