// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  // Get the deployer's wallet (the first account from your `accounts` array in hardhat.config.js)
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Get the MarsCoin contract factory
  const MarsCoin = await hre.ethers.getContractFactory("MarsCoin");
  // Deploy the contract
  const marsCoin = await MarsCoin.deploy(); 
  // Wait (optional in Ethers v6)
  // await marsCoin.waitForDeployment();

  console.log("MarsCoin deployed to:", await marsCoin.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
