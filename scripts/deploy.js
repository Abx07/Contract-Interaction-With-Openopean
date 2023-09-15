async function main() {
  // Grabbing the contract factory 
  const OpenOceanSwap = await ethers.getContractFactory("OpenOceanSwap");

  // Starting deployment, returning a promise that resolves to a contract object
  const openOceanSwapContract = await OpenOceanSwap.deploy(); // Instance of the contract 
  console.log("Contract deployed to address:", openOceanSwapContract.address);
}

main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });