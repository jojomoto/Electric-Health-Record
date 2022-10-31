//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract ElectronicHealthRecord {
    //Patients

    address pharmacyID; //default     
    uint medicineID; //medication index.
    
    //Default contract deployer address to pharmacyID
    constructor() {
        pharmacyID = msg.sender;
    }

    struct Medicine {
        string medicineName;
        uint expiryDate;
        string dose;
        uint price;
    }
    


    //mapping of medication index to information
    mapping(uint => Medicine) medications;

    modifier pharmacyOnly() {
        require(msg.sender == pharmacyID, "Only authorized by pharmacy");
        _;
    }


    struct Patient {
        string name;
        uint age;
        string[] disease;
        string[] medicine;
    }
    struct Doctor {
        string name;
        string qualification;
        string workPlace;
    }

    address[] approvedPatients;
    address[] approvedDoctors;

    mapping(address => Doctor) doctors;
    mapping(address => Patient) patients;

    modifier doctorOnly() {
        bool isDoctor;
        for (uint i = 0; i < approvedDoctors.length; i++) {
            if (approvedDoctors[i] == msg.sender) {
                isDoctor = true;
                break;
            }
        }
        require(isDoctor, "Not an approved doctor");
        _;
    }

    modifier patientOnly() {
        bool isPatient = false;
        for (uint i = 0; i < approvedPatients.length; i++) {
            if (msg.sender == approvedPatients[i]) {
                isPatient = true;
                break;
            }
        }

        require(isPatient, "Not a registered patient");
        _;

    }

    //sender of this function registers a patient account (Automatic approval for assignment).
    function registerPatient ( string memory _name,
                               uint _age )
                               public {

            patients[msg.sender].name = _name;
            patients[msg.sender].age = _age;

            approvedPatients.push(msg.sender);
            }

    //patient can add conditions into account
    function addDisease (string memory _disease) public patientOnly {
        patients[msg.sender].disease.push(_disease);
    }

    function viewRecords () public view patientOnly returns (address _patientID, 
                                                             uint _age,
                                                             string memory _name,
                                                             string[] memory _disease,
                                                             string[] memory _medicine)
                                                             {
            
            return ( msg.sender,
                     patients[msg.sender].age,
                     patients[msg.sender].name,
                     patients[msg.sender].disease,
                     patients[msg.sender].medicine );
            }

    //patients can update their age (approved patients only
    function updateRecords ( uint _age ) public patientOnly {
        
        patients[msg.sender].age = _age;
    
    }

    //Doctors



    //the account that calls this function registers a doctor account (Automatically approved for this assignment)
    function registerDoctor( string memory _name, 
                             string memory _qualification,
                             string memory _workPlace )
                             public {
            
            doctors[msg.sender] = Doctor({ name : _name,
                                           qualification : _qualification,
                                           workPlace : _workPlace
                                           });

            approvedDoctors.push(msg.sender);

            }

    //function addPatient( address _patientID) public {}
    function viewPatient( address _patientID) public view doctorOnly returns ( address patientID,
                                                                               uint _age,
                                                                               string memory _name,
                                                                               string[] memory _diseases,
                                                                               string[] memory _medicine)
                                                                               {
            return ( _patientID,
                     patients[_patientID].age,
                     patients[_patientID].name,
                     patients[_patientID].disease,
                     patients[_patientID].medicine);
                                                               }

    function prescribeMedicine( uint _medicineID,
                                address _patientID )
                                public doctorOnly {
            require(_medicineID < medicineID, "Medicine ID does not exist"); //checking if medicine index exists
            patients[_patientID].medicine.push(medications[_medicineID].medicineName); 
            }

    function viewDoctor ( address _doctorID ) public view returns ( string memory _name,
                                                                    string memory _qualification,
                                                                    string memory _workPlace )
                                                                    {
            return (doctors[_doctorID].name,
                    doctors[_doctorID].qualification,
                    doctors[_doctorID].workPlace);
            }

    /////////Pharmacy/////////////////////////
    


    //add medication to contract (pharmacy access only).
    function addMedicine( string memory _medicineName,
                          uint _expiryDate,
                          string memory _dose,
                          uint _price )
                          public pharmacyOnly {

            medications[medicineID] = Medicine( {medicineName : _medicineName,
                                                expiryDate : _expiryDate,
                                                dose : _dose,
                                                price : _price
                                                });
            medicineID++;
            }

    function viewMedicineDetails( uint _medicineID) public view returns (string memory _name,
                                                                         uint _expiryData,
                                                                         string memory _dose,
                                                                         uint _price) {
            return (medications[_medicineID].medicineName,
                    medications[_medicineID].expiryDate,
                    medications[_medicineID].dose,
                    medications[_medicineID].price);
            }

}
