const prompts = require('prompts');

async function promptForContractDeployment() {
  const response = await prompts(
    {
      type: 'text',
      name: 'contractName',
      message: 'Enter the contract name you want to deploy',
    }
  )
  const noOfArguments = await prompts(
    {
      type: 'number',
      name: 'noOfArguments',
      message: 'Enter the number of arguments you want to pass to the contract',
    }
  )
  
  const argumentsArray = [];
  if (noOfArguments.noOfArguments > 0) {
    for (let i = 0; i < noOfArguments.noOfArguments; i++) {
      const argument = await prompts(
        {
          type: 'text',
          name: 'argument',
          message: `Enter argument ${i + 1}`,
        }
      )
      argumentsArray.push(argument.argument);
    }
  }
  return [response.contractName, argumentsArray];
}

module.exports = { promptForContractDeployment }