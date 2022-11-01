const { expect } = require("chai");
const { ethers } = require("hardhat");

const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("EHR Smart Contract", function () {
  async function deployTokenFixture() {  
    const ElectronicHealthRecord = await ethers.getContractFactory("ElectronicHealthRecord");
    const [pharm, patient, doctor, other] = await ethers.getSigners();
    const EHR = await ElectronicHealthRecord.deploy();
    await EHR.deployed();
    return { EHR, pharm, patient, doctor, other };
  }

  describe("Deployment", function () {
   
    it("Assign deployer to pharmacy address", async function () {
      const { EHR, pharm } = await loadFixture(deployTokenFixture);  
      expect(await EHR.viewPharmacy()).to.equal(pharm.address);
    });
  });

  describe("Pharmacy Functions", async function () {
    it("Register Medication", async function () {
    const { EHR, pharm, other } = await loadFixture(deployTokenFixture);
    const med1 = await EHR.addMedicine("med1", 1, "2", 3);
    const med2 = await EHR.addMedicine("med2", 2, "3", 4);
    const med3 = await EHR.addMedicine("med3", 3, "4", 5);
    const outsideCaller = EHR.connect(other);
    expect(await EHR.viewMedicineDetails(0)).to.deep.equal(["med1", 1, "2", 3]);
    await expect(outsideCaller.addMedicine("med4", 3, "4", 5)).to.be.revertedWith("Only authorized by pharmacy");
  })
})

  describe("Patient Records", function () {

    it("Patient registration", async function () {
      const { EHR, patient } = await loadFixture(deployTokenFixture);
      const patientInfo = await EHR.connect(patient).registerPatient("patient1", 25);
      expect(await EHR.connect(patient).viewRecords()).to.deep.equal([patient.address, 25, "patient1", [], []]);
    });
    
    it("Patient View self only", async function () {
      const { EHR, patient, other } = await loadFixture(deployTokenFixture);
      const patientInfo = await EHR.connect(patient).registerPatient("patient1", 25);
      const contractAsPatient2 = EHR.connect(other);
      await expect(contractAsPatient2.viewRecords()).to.be.revertedWith("Not a registered patient");
    });
    
    it("Patient adds health issue and update age", async function () {
      const { EHR, patient } = await loadFixture(deployTokenFixture);
      const patientInfo = await EHR.connect(patient).registerPatient("patient1", 25);
      const patientMeds = await EHR.connect(patient).addDisease("chronic migraine");
      const patientAge = await EHR.connect(patient).updateRecords(26);
      expect(await EHR.connect(patient).viewRecords()).to.deep.equal([patient.address, 26, "patient1", ["chronic migraine"], []]);
    })
  });

  describe("Doctor Records and Access", function () {

    it("Registers a doctor", async function () {
      const { EHR, patient, doctor } = await loadFixture(deployTokenFixture);
      const doctorInfo = await EHR.connect(doctor).registerDoctor("Doctor","MD","Destination");
      expect( await EHR.connect(patient).viewDoctor(doctor.address)).to.deep.equal(["Doctor", "MD", "Destination"]);
    })

    it("Doctor prescribes medication to patient", async function () {
      const { EHR, pharm, patient, doctor, other } = await loadFixture(deployTokenFixture);
      const doctorInfo = await EHR.connect(doctor).registerDoctor("Doctor","MD","Destination");
      const patientInfo = await EHR.connect(patient).registerPatient("patient1", 25);
      const med1 = await EHR.addMedicine("med1", 1, "2", 3);
      const med2 = await EHR.addMedicine("med2", 2, "3", 4);
      const med3 = await EHR.addMedicine("med3", 3, "4", 5);
      const prescribe = await EHR.connect(doctor).prescribeMedicine(1, patient.address);
      expect(await EHR.connect(patient).viewRecords()).to.deep.equal([patient.address, 25, "patient1", [], ["med2"]]);
      const contractAsPatient1 = EHR.connect(other)
      await expect(contractAsPatient1.prescribeMedicine(2, patient.address)).to.be.revertedWith("Not an approved doctor");

    })
  })
});
