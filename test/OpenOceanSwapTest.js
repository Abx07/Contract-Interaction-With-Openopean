const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

describe("OpenOceanSwap Contract", function () {
  let owner, user1, user2;
  let openOceanSwap;
  let ETH_ADDRESS;
  let mockToken;
  let openOceanMock;

  const initialOwnerBalance = ethers.utils.parseEther("1000");
  const initialUserBalance = ethers.utils.parseEther("100");

  before(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy OpenOceanSwap contract
    const OpenOceanSwap = await ethers.getContractFactory("OpenOceanSwap");
    openOceanSwap = await OpenOceanSwap.deploy();
    await openOceanSwap.deployed();

    // Deploy a mock token contract
    const MockToken = await ethers.getContractFactory("MockToken");
    mockToken = await MockToken.deploy("MockToken", "MTK");
    await mockToken.deployed();

    // Deploy a mock OpenOcean contract
    const OpenOceanMock = await ethers.getContractFactory("OpenOceanMock");
    openOceanMock = await OpenOceanMock.deploy();
    await openOceanMock.deployed();

    ETH_ADDRESS = ethers.constants.AddressZero;

    // Send initial ETH and tokens to users
    await owner.sendTransaction({
      to: user1.address,
      value: initialUserBalance,
    });
    await mockToken.transfer(user1.address, initialUserBalance);
  });

  it("should initialize the contract correctly", async function () {
    expect(await openOceanSwap.owner()).to.equal(owner.address);
  });

  it("should set the OpenOcean contract address", async function () {
    await openOceanSwap.setOpenOceanContract(openOceanMock.address);
    expect(await openOceanSwap.openOceanContractAddress()).to.equal(openOceanMock.address);
  });

  it("should allow the owner to rescue tokens", async function () {
    const rescueAmount = ethers.utils.parseEther("10");
    await openOceanSwap.rescueTokens(mockToken.address, rescueAmount);
    const ownerBalance = await mockToken.balanceOf(owner.address);
    expect(ownerBalance).to.equal(rescueAmount);
  });

  it("should swap tokens", async function () {
    const fromTokenAmount = ethers.utils.parseEther("10");
    const minReturnAmount = ethers.utils.parseEther("5");
    const pools = [];
    await mockToken.connect(user1).approve(openOceanSwap.address, fromTokenAmount);

    const initialUser1Balance = await mockToken.balanceOf(user1.address);
    const initialUser2Balance = await mockToken.balanceOf(user2.address);

    await openOceanSwap
      .connect(user1)
      .swapTokens(
        mockToken.address,
        ETH_ADDRESS,
        fromTokenAmount,
        minReturnAmount,
        pools
      );

    const finalUser1Balance = await mockToken.balanceOf(user1.address);
    const finalUser2Balance = await mockToken.balanceOf(user2.address);

    expect(finalUser1Balance).to.lt(initialUser1Balance);
    expect(finalUser2Balance).to.gt(initialUser2Balance);
  });
});
