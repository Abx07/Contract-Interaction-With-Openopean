const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("OpenOceanSwap", function () {
  let owner;
  let user;
  let openOceanSwap;
  let erc20Token1; // 0x7EA2be2df7BA6E54B1A9C70676f668455E329d29 (USDC)
  let erc20Token2; // 0x6B175474E89094C44Da98b954EedeAC495271d0F (DAI)
  let usdcToken;  // Address of USDC token
  let daiToken;   // Address of DAI token

  const ETH_ADDRESS = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
  const initialBalance = ethers.utils.parseEther("1000");
  const swapAmount = ethers.utils.parseEther("1");
  const minReturnAmount = ethers.utils.parseEther("0.9");
  const emptyBytes32Array = [];

  before(async function () {
    [owner, user] = await ethers.getSigners();

    const OpenOceanSwap = await ethers.getContractFactory("OpenOceanSwap");
    openOceanSwap = await OpenOceanSwap.deploy();
    await openOceanSwap.deployed();

    // Impersonate the ERC20 tokens
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x7EA2be2df7BA6E54B1A9C70676f668455E329d29"], // USDC address
    });
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0x6B175474E89094C44Da98b954EedeAC495271d0F"], // DAI address
    });

    erc20Token1 = await ethers.getSigner("0x7EA2be2df7BA6E54B1A9C70676f668455E329d29");
    erc20Token2 = await ethers.getSigner("0x6B175474E89094C44Da98b954EedeAC495271d0F");

    // Deploy ERC20 token contracts or use existing ones
    // Set the addresses of the impersonated tokens
    usdcToken = "0x7EA2be2df7BA6E54B1A9C70676f668455E329d29";
    daiToken = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    // Fund the user and OpenOceanSwap contract with ERC20 tokens and ETH
  });

  describe("setOpenOceanContract", function () {
    it("should allow the owner to set the OpenOcean contract address", async function () {
      const newAddress = "0xNewOpenOceanAddress"; // Replace with the new address
      await openOceanSwap.setOpenOceanContract(newAddress);
      expect(await openOceanSwap.openOceanContractAddress()).to.equal(newAddress);
    });
  });

  describe("swapTokens", function () {
    it("should swap ETH to USDC", async function () {
      // Approve the OpenOceanSwap contract to spend user's ERC20 tokens
      await erc20Token1.sendTransaction({
        to: openOceanSwap.address,
        value: swapAmount,
      });

      // Perform the swap
      await expect(() =>
        openOceanSwap
          .connect(user)
          .swapTokens(
            ETH_ADDRESS,
            usdcToken,
            swapAmount,
            minReturnAmount,
            emptyBytes32Array
          )
      )
        .to.changeTokenBalance(usdcToken, user, minReturnAmount)
        .and.to.changeEtherBalance(user, -swapAmount);

      const fromBalance = await openOceanSwap.getBalance(ETH_ADDRESS);
      const toBalance = await openOceanSwap.getBalance(usdcToken);

      expect(fromBalance).to.equal(0);
      expect(toBalance).to.equal(0);
    });
  });

  describe("rescueTokens", function () {
    it("should allow the owner to rescue tokens", async function () {
      const rescueAmount = ethers.utils.parseEther("10");
      await openOceanSwap.rescueTokens(erc20Token1.address, rescueAmount);
      const ownerBalance = await erc20Token1.balanceOf(owner.address);
      expect(ownerBalance).to.equal(rescueAmount);
    });
  });
});
