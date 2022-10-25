//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract ElectronicHealthRecord {

    address admin;

    //initializing admin to address that deployed contract
    constructor() {
        admin = msg.sender; //only the person that deployed smart contract is an admin
        admins[admin] = true;
    }

    //patient records (approved doctor and symptom of patient)
    struct PatientRecord {
        address drID;
        string symptom;
    }

    //mapping of patient's address to their record history
    mapping(address => PatientRecord[]) patientRecords;
    //list of admin on the network (Currently one admin)
    mapping(address => bool) admins;
    //list of doctors approved by admin
    mapping(address => bool) doctors;
    //list of patients approved by doctor
    mapping(address => bool) patients;


    ///////////////MODIFIERS/////////////////

    //modifier for admin access only
    modifier adminOnly() {
        require(admin == msg.sender, "only the admin has access");
        _;
    }

    //modifier for approved doctors only
    modifier doctorOnly(address _doctorID) {
        require(doctors[_doctorID] == true, "Not an approved doctor");
        _;
    }

    //modifier to confirm person executing is the patient themself
    modifier patientOnly(address _patientID) {
        require(_patientID == msg.sender, "patients can only create own account");
        _;
    }

    /////////////FUNCTIONS//////////////////

    //view admin account (public for everyone)
    function viewAdmin() public view returns(address) {
        return admin;
    }

    //add doctor to approved doctors (Must be approved by admin)
    function addDoctor(address _doctorID) public adminOnly {
        require(!doctors[_doctorID], "Already a registered doctor");
        doctors[_doctorID] = true;
        
    }
    //removes doctor from approved doctors (must be approved by admin)
    function removeDoctor(address _doctorID) public adminOnly {
        delete doctors[_doctorID];
    }
    //Checks if address is approved doctor (publc for everyone)
    function isDoctor(address _doctorID) public view returns (bool) {
        return doctors[_doctorID];  
    }

    //Adding a patient may only be by patient
    function addPatient(address _patientID) public patientOnly(_patientID) {
        require(!patients[_patientID], "Patient already exists");
        patients[_patientID] = true;
    }


    //Only approved doctors can update patient records
    function addPatientRecord(address _patientID, string memory _symptom) public doctorOnly(msg.sender) {
        require(patients[_patientID], "Not a patient");
        patientRecords[_patientID].push(PatientRecord(msg.sender, _symptom));
    }

    //Only patient or approved doctors can view the patient record
    function viewPatient(address _patientID) public view returns (PatientRecord[] memory) {
        require(doctors[msg.sender] || _patientID == msg.sender, "Access approved by doctor or patient");
        return patientRecords[_patientID];
    }
}