// Import Chai's expect for assertions in unit tests
const { expect } = require("chai");
// Ethers v6 no longer has ethers.utils.parseUnits;
// we use ethers.parseUnits and ethers.formatUnits directly.
// Import Hardhat's Ethers.js instance for contract deployment
const { ethers } = require("hardhat");

// Test suite for MarsCoin contract
describe("MarsCoin", function () {
  let owner, addr1, addr2;
  let marsCoin;

// This runs before each test - deploys a new MarsCoin instance
  beforeEach(async function () {
    // 1) Grab three signers so addr1 and addr2 aren't undefined
    [owner, addr1, addr2] = await ethers.getSigners();

    // 2) Deploy the MarsCoin contract
    const MarsCoin = await ethers.getContractFactory("MarsCoin");
    marsCoin = await MarsCoin.deploy();
    // In Ethers v6, deploy() already waits for confirmation, 
    // so marsCoin is fully deployed at this point.
  });

// Test that ensures all 1 trillion tokens are assigned to the deployer at launch
  it("Should deploy and assign total supply of 1 trillion MARS to the owner", async function () {
    // 1 trillion with 18 decimals, stored as a bigint
    const expectedTotalSupply = ethers.parseUnits("1000000000000", 18);

    const actualTotalSupply = await marsCoin.totalSupply();
    const ownerBalance = await marsCoin.balanceOf(owner.address);

    expect(actualTotalSupply).to.equal(expectedTotalSupply);
    expect(ownerBalance).to.equal(expectedTotalSupply);
  });

// Test that verifies 1% of each transfer is burned and total supply decreases
  it("Should burn 1% on each transfer", async function () {
    // Transfer 100 tokens from owner to addr1
    const amount = ethers.parseUnits("100", 18);
    await marsCoin.transfer(addr1.address, amount);

    // 1% of 100 => 1 token
    const burnAmount = ethers.parseUnits("1", 18);
    const netAmount = ethers.parseUnits("99", 18);

    // Check addr1 balance
    const addr1Balance = await marsCoin.balanceOf(addr1.address);
    expect(addr1Balance).to.equal(netAmount);

    // totalSupply should go down by 1
    const expectedSupplyAfterBurn = await marsCoin.totalSupply();
    const oneTrillionMinusOne = ethers.parseUnits("999999999999", 18);
    expect(expectedSupplyAfterBurn).to.equal(oneTrillionMinusOne);

    // Check that the burn address got the burned tokens
    const BURN_ADDRESS = "0x000000000000000000000000000000000000dEaD";
    const burnAddressBalance = await marsCoin.balanceOf(BURN_ADDRESS);
    expect(burnAddressBalance).to.equal(burnAmount);
  });

// Test that checks if multiple transfers apply the burn correctly
  it("Should handle multiple transfers and accumulate burns correctly", async function () {
    // Transfer 100 from owner to addr1
    await marsCoin.transfer(addr1.address, ethers.parseUnits("100", 18));
    // Then transfer 50 from addr1 to addr2
    await marsCoin.connect(addr1).transfer(addr2.address, ethers.parseUnits("50", 18));

    // Check final balances
    const ownerBalance = await marsCoin.balanceOf(owner.address);
    const addr1Balance = await marsCoin.balanceOf(addr1.address);
    const addr2Balance = await marsCoin.balanceOf(addr2.address);
    const finalSupply = await marsCoin.totalSupply();

    // We'll parse big numbers to strings for optional logging
    const parsedOwnerBalance = ethers.formatUnits(ownerBalance, 18);
    const parsedAddr1Balance = ethers.formatUnits(addr1Balance, 18);
    const parsedAddr2Balance = ethers.formatUnits(addr2Balance, 18);
    const parsedFinalSupply = ethers.formatUnits(finalSupply, 18);

    // For reference, 1 trillion MARS with 18 decimals (bigint)
    const trillion = ethers.parseUnits("1000000000000", 18);

    // Owner's balance should be 1 trillion - 100 => 999999999900
    // Notice we do direct subtraction: (bigintA - bigintB)
    expect(ownerBalance).to.equal(trillion - ethers.parseUnits("100", 18));

    // addr1 first received 99 (1 burned from 100),
    // then sent out 50 (with 0.5 burned), leaving 49
    expect(addr1Balance).to.equal(ethers.parseUnits("49", 18));

    // addr2 should get 49.5 => "49500000000000000000"
    expect(addr2Balance).to.equal("49500000000000000000");

    // totalSupply should have burned 1.5 total
    const expectedFinalSupply = trillion - ethers.parseUnits("1.5", 18);
    expect(finalSupply).to.equal(expectedFinalSupply);
  });
});
