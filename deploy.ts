import { ethers } from "hardhat";

async function main() {
  const Vault = await ethers.getContractFactory('Vault');
  const vault = await Vault.deploy();

  await vault.waitForDeployment();

  console.log `Vault deployed to ${vault.target}`
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
