//Tests go here
//Working progress
const { expect } = require("chai");
const { ethers } = require("hardhat");
describe("ElectronicHealthRecord", function () {
  it("Should assign the admin to the deploying address", async function () {
    const [admin] = await ethers.getSigners();

    
    const ElectronicHealthRecord = await ethers.getContractFactory("ElectronicHealthRecord");

    const EHR = await ElectronicHealthRecord.deploy();

    await EHR.viewAdmin();

    expect(await EHR.viewAdmin()).to.equal(admin.address);
  });
  

  it("Should add doctor if admin approves", async function () {
    const [admin, doc] = await ethers.getSigners();

    const ElectronicHealthRecord = await ethers.getContractFactory("ElectronicHealthRecord");

    const EHR = await ElectronicHealthRecord.deploy();

    await EHR.viewAdmin();

    expect(await EHR.viewAdmin()).to.equal(admin.address);

    await EHR.addDoctor(doc.address);

    expect(await EHR.isDoctor(doc.address)).is.equal(true);
  });

});
