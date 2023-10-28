const hre = require('hardhat');
const prompts = require('prompts');
const colors = require('colors');

require('dotenv').config();

async function main() {
  const signers = await hre.ethers.getSigners();
  const minter = signers[0];

  const contractName = await prompts(
    {
      type: 'text',
      name: 'contractName',
      message: 'Enter the contract name you want to mint from',
    }
  )

  const contractAddress = await prompts(
    {
      type: 'text',
      name: 'contractAddress',
      message: 'Enter the contract address you want to mint from',
    }
  )

  const ethAmount = await prompts(
    {
      type: 'text',
      name: 'ethAmount',
      message: 'Enter the amount of ETH you want to send',
    }
  )

  const ethValue = hre.ethers.parseEther(ethAmount.ethAmount);

  const contractDeployed = await hre.ethers.getContractAt(contractName.contractName, contractAddress.contractAddress, minter);

  if(hre.network.name === 'localhost') {
    console.log('minting from localhost contract'.cyan);
  } else {
    console.log(`minting from ${hre.network.name} contract`.cyan);
  }

  const address = await minter.getAddress();
  const transactionResponse = await contractDeployed.mint(address, { value: ethValue });

  const transactionReceipt = await transactionResponse.wait();

  console.log(`Minted ${contractName.contractName} to ${address} on ${hre.network.name}`.green); 
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  }); 