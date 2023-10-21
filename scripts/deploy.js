const colors = require('colors');
const hre = require('hardhat');
const prompts = require('prompts');
require('dotenv').config();

async function main() {
  const response = await prompts(
    {
      type: 'text',
      name: 'contractName',
      message: 'Enter the contract name you want to deploy',
    }
  )

  console.log(`Deploying ${response.contractName}`.cyan);
  const signers = await hre.ethers.getSigners();
  const deployer = signers[0];
  
  if(hre.network.name === 'localhost') {
    console.log('Deploying to local network'.cyan);
  } else {
    console.log(`Deploying to ${hre.network.name}`.cyan);
  }
  
  const contractFactory = await hre.ethers.getContractFactory(response.contractName, deployer);
  const contract = await contractFactory.deploy();
  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();
  console.log(`Deployed ${response.contractName} to ${contractAddress}`.green);
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});