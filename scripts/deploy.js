// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [owner] = await hre.ethers.getSigners();
  const MultisigContractFactory = await hre.ethers.getContractFactory("Multisig");
  const MultisigContract = await MultisigContractFactory.deploy([owner.address, "0x0708C30FF4DD48C5596CbfaCCC030C7b3D67010b"], 2);
  await MultisigContract.deployed();

  console.log("MultisigContract deployed to:", MultisigContract.address);
  console.log("MultisigContract owner address:", owner.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
