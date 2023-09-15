// require("@nomicfoundation/hardhat-toolbox");

require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
// require("@nomicfoundation/hardhat-verify");

/** @type import('hardhat/config').HardhatUserConfig */
const { INFURA_URL } = process.env;
module.exports = {
  solidity: {
    version: "0.8.19", 
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  networks: {
    hardhat: {
      forking: {
        url: INFURA_URL,
      }
    }
  },
}
