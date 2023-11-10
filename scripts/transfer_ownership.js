const colors = require('colors');
const hre = require('hardhat');
const prompts = require('prompts');

async function main() {
  const res = await prompts(
    {
      type: 'text',
      name: 'gnosisSafeAddress',
      message: 'Enter the Gnosis Safe address',
    }
  )

  const gnosisSafeAddress = res.gnosisSafeAddress;
  await upgrades.admin.transferProxyAdminOwnership(gnosisSafeAddress);

  console.log('Ownership transferred to: '.green, gnosisSafeAddress);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  }); 