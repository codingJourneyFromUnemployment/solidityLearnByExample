const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { assert } = require("chai");
const { ethers } = require("hardhat");

describe("Proxy", function () {
  async function deployFixture() {

    const Proxy = await ethers.getContractFactory("Proxy");
    const proxy = await Proxy.deploy();
    const proxyAddress = await proxy.getAddress();

    const Logic1 = await ethers.getContractFactory("Logic1");
    const logic1 = await Logic1.deploy();
    const logic1Address = await logic1.getAddress();

    const Logic2 = await ethers.getContractFactory("Logic2");
    const logic2 = await Logic2.deploy();
    const logic2Address = await logic2.getAddress();

    //1.使用代理合约的地址和逻辑合约的abi生成了一个并不存在的假合约实例，其目的是将交易发送到代理合约地址，但是calldata中又要包含逻辑合约的abi。2.如果不构造这个假合约实例，在发送交易时，ethers.js在代理合约的abi中找不到被调用的逻辑合约的abi，会报错，而不是落入fallback函数。3.发送交易时，ethers.js会将逻辑合约的abi和参数拼接到calldata中，发送到代理合约的地址，代理合约识别不了这个函数，会落入fallback函数。4.fallback函数在代理合约的上下文中通过delegatecall调用逻辑合约中对应的函数，修改的是代理合约本身的storage。5.通过修改implementation，在fallback中使用delegatecall调用不同的逻辑合约中的函数，实现了升级。6.在Solidity中，存储的每个槽位都是存在的，但如果没有被初始化或赋值，它们的默认值是0。因此只要通过StorageSlot.getAddressSlot(keccak256("XXX"))来存储地址，确保不发生槽位位置的冲突，实际上不需要在代理合约的存储中显式定义任何变量。
    const proxyAsLogic1 = await ethers.getContractAt("Logic1", proxyAddress);
    const proxyAsLogic2 = await ethers.getContractAt("Logic2", proxyAddress);

    return { proxy, logic1, logic2, proxyAsLogic1, proxyAsLogic2 };
  }

  async function lookupUint(contractAdd, slot) {
    return parseInt(await ethers.provider.getStorage(contractAdd, slot));
  }

  it("should work with logic1", async function () {
    const { proxy, proxyAsLogic1, logic1 } = await loadFixture(deployFixture);

    const logic1Address = await logic1.getAddress();
    const proxyAddress = await proxy.getAddress();
    await proxy.changeImplementation(logic1Address);

    assert.equal(await lookupUint(proxyAddress, "0x0"), 0);

    await proxyAsLogic1.changeX(52);
    assert.equal(await lookupUint(proxyAddress, "0x0"), 52);
  });

  it("should work with upgrades", async function () {
    const { proxy, logic1, logic2, proxyAsLogic1, proxyAsLogic2 } = await loadFixture(deployFixture);
    // start at logic 1
    const proxyAddress = await proxy.getAddress();
    const logic1Address = await logic1.getAddress();
    await proxy.changeImplementation(logic1Address);
    await proxyAsLogic1.changeX(45);
    assert.equal(await lookupUint(proxyAddress, "0x0"), 45);
    // upgrade to logic 2
    const logic2Address = await logic2.getAddress();
    await proxy.changeImplementation(logic2Address);
    assert.equal(await lookupUint(proxyAddress, "0x0"), 45);

    await proxyAsLogic2.changeX(25);
    await proxyAsLogic2.tripleX();

    assert.equal(await lookupUint(proxyAddress, "0x0"), 75);

  });

});