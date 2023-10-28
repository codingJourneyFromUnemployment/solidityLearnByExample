const colors = require('colors');
const hre = require('hardhat');
const { promptForContractDeployment } = require('./helpers');

require('dotenv').config();

async function main() {
  const [contractName, argumentsArray] = await promptForContractDeployment();

  console.log(`Deploying ${contractName}`.cyan);
  const signers = await hre.ethers.getSigners();
  const deployer = signers[0];
  
  if(hre.network.name === 'localhost') {
    console.log('Deploying to local network'.cyan);
  } else {
    console.log(`Deploying to ${hre.network.name}`.cyan);
  }
  
  const contractFactory = await hre.ethers.getContractFactory(contractName, deployer);
  const contract = await contractFactory.deploy(...argumentsArray);
  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();
  console.log(`Deployed ${contractName} to ${contractAddress}`.green);
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
}); 