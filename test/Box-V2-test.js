const { expect, assert } = require('chai');

let BoxV2;
let boxV2;

describe('BoxV2', function () {
  beforeEach(async function () {
    BoxV2 = await ethers.getContractFactory("BoxV2");
    boxV2 = await BoxV2.deploy();
    await boxV2.waitForDeployment();
  });

  it("should retrieve a value previously stored", async function () {
    await boxV2.store(42);
    expect((await boxV2.retrieve()).toString()).to.equal('42');
  });

  it("should retrieve returns a value previously incremented", async function () {
    await boxV2.increment();
    expect((await boxV2.retrieveResult()).toString()).to.equal('1');
  });
});