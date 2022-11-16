import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config()


const POLYGON_TESTNET_URL = process.env.POLYGON_TESTNET_URL
const GOERLI_TESTNET_URL = process.env.GOERLI_TESTNET_URL
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY
const PRIVATE_KEY = process.env.PRIVATE_KEY || ''

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    matic: {
      url: POLYGON_TESTNET_URL,
      accounts: [PRIVATE_KEY],
      gas: 2100000,
      gasPrice: 8000000000
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};

export default config;
