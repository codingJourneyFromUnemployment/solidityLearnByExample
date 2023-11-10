const { expect } = require('chai');

let Box;
let BoxV2;
let box;
let boxAddress;
let boxV2;

describe("BoxV2 (proxy)", function () {
  beforeEach(async function () {
    Box = await ethers.getContractFactory("Box");
    BoxV2 = await ethers.getContractFactory("BoxV2");
    box = await upgrades.deployProxy(Box, [42], { initializer: 'store' });
    await box.waitForDeployment();
    boxAddress = await box.getAddress();
    boxV2 = await upgrades.upgradeProxy(boxAddress, BoxV2);
    await boxV2.waitForDeployment();
  });

  it("should retrieve returns a value previously incremented", async function () {
    await boxV2.increment();
    await boxV2.increment();
    await boxV2.increment();
    expect((await boxV2.retrieveResult()).toString()).to.equal('45');
  });
});