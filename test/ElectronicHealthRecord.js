
const { expect } = require("chai");
const { ethers } = require("hardhat");

const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("EHR Smart Contract", function () {
  async function deployTokenFixture() {  
    const ElectronicHealthRecord = await ethers.getContractFactory("ElectronicHealthRecord");
    const [pharm, patient1, patient2, patient3, doctor1, doctor2] = await ethers.getSigners();
    const EHR = await ElectronicHealthRecord.deploy();
    await EHR.deployed();
    return { ElectronicHealthRecord, EHR, pharm, patient1, patient2, patient3, doctor1, doctor2 };
  }

  describe("Deployment", function () {
   
    it("Assign deployer to pharmacy address", async function () {
      const { EHR, pharm } = await loadFixture(deployTokenFixture);  
      expect(await EHR.viewPharmacy()).to.equal(pharm.address);
    });
  });

  describe("Patient Records", function () {

    it("Patient registration", async function () {
      const { EHR, patient1 } = await loadFixture(deployTokenFixture);
      const patientInfo = await EHR.connect(patient1).registerPatient("patient1", 25);
      expect(await EHR.connect(patient1).viewRecords()).to.deep.equal([patient1.address, 25, "patient1", [], []]);
    });
    /*
    it("Patient View self only", async function () {
      const { EHR, patient1, patient2 } = await loadFixture(deployTokenFixture);
      const patientInfo = await EHR.connect(patient1).registerPatient("patient1", 25);
      expect(await EHR.connect(patient2).viewRecords()).to.be.revertedWith("Not a registered patient");
    });
    */
    it("Patient adds health issue and update age", async function () {
      const { EHR, patient1 } = await loadFixture(deployTokenFixture);
      const patientInfo = await EHR.connect(patient1).registerPatient("patient1", 25);
      const patientMeds = await EHR.connect(patient1).addDisease("chronic migraine");
      const patientAge = await EHR.connect(patient1).updateRecords(26);
      expect(await EHR.connect(patient1).viewRecords()).to.deep.equal([patient1.address, 26, "patient1", ["chronic migraine"], []]);
    })
  });

  describe("Doctor Records and Access")
});
