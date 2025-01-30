require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { PRIVATE_KEY } = process.env;

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    pulsechain: {
      url: "https://rpc.pulsechain.com",
      chainId: 369,
      accounts: [PRIVATE_KEY],
    },
  },
  solidity: "0.8.28",
};
