//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract Insurance {
    struct accidentDetails {
        uint accidentId;
        string vehicleRegNo;
        uint accidentTimestamp;
        string accidentCause;
        string location;
        string insuranceCompany;
    }

    struct Person {
        uint citizenID;
        string name;
    }

    struct Vehicle {
        string vehicleRegNo;
        string owner;
        string insurance;
    }

    struct Accident {
        uint accidentId;
        Vehicle v;
        uint accidentTimestamp;
        string location;
        string accidentCause;
    }

    struct MedicalRecord {
        uint mrID;
        uint citizenId;
        string[] diagnosis;
        uint bill;
        string hospital;
    }

    struct MedicalInsurance {
        uint insuranceId;
        uint citizenId;
        address insurer;
        string[] policies;
        uint maxAmount;
    }
    struct InsuranceCompany {
        address wallet;
        string name;
        string gstno;
    }
    struct User {
        address wallet;
        string name;
        uint citizenID;
    }


    uint public accidentId;
    uint public mrId;
    uint public insuranceId;
    address public owner;
    accidentDetails[] private allAccidents;

    // mapping(string => accidentDetails) public regNoToAccidentDetails;
    // mapping(string => address) public companyAddresses;
    // mapping(address => accidentDetails[]) public accidentsByAddress;

    // mapping(string => Vehicle) regNoToVehicle;
    mapping(uint => Person) citizenIdToPerson;
    mapping(address => bool) public hospitals;
    mapping(address => bool) public governmentAuthorities;
    mapping (string => InsuranceCompany) public insuranceCompanies;
    mapping(uint => MedicalRecord[]) personMedicalRecords;
    mapping(uint =>MedicalRecord) idToMedicalRecord;
    mapping(uint => bool) insuranceValidity;
    mapping(uint => MedicalInsurance) idToMedicalInsurance;
    mapping(uint => address) citizenAddress;
    mapping(uint => User) citizenIdToUser;


    // MedicalInsurance[] public medicalInsurances;

    constructor() {
        owner = msg.sender;
        accidentId = 1000;
        mrId = 1000;
        insuranceId = 1000;

    }

    function addHospital(address _user) public onlyOwner {
        hospitals[_user] = true;
    }

    function addGovernmentAuthority(address _address) public onlyOwner {
        governmentAuthorities[_address] = true;
    }

    function hasValue(uint citizenId) public view returns (bool) {
        // Check if the mapping has a value for the given key
        return bytes(citizenIdToPerson[citizenId].name).length > 0;
    }

    function registerInsuranceCompany(address _wallet,string memory _name,string memory _gstno)public{
        InsuranceCompany memory n = InsuranceCompany({
            wallet: _wallet,
            name: _name,
            gstno: _gstno
        });
        insuranceCompanies[_name] = n;

    }

    function addUser(address _wallet,string memory _name,uint id)public{
        User memory n = User({
            wallet: _wallet,
            name: _name,
            citizenID: id
        });

        citizenIdToUser[id] = n;

    }



    function addMedicalRecord(uint _citizenID,string memory _name,string[] memory diagno,uint _bill,string memory _hospital) public {
        Person storage existingPerson = citizenIdToPerson[_citizenID]; 
        if (existingPerson.citizenID == 0) {
            // If the citizenID is not found, create a new person
            Person memory newPerson = Person({
                citizenID: _citizenID,
                name: _name
            });

            // Store the new person in the mapping
            citizenIdToPerson[_citizenID] = newPerson;
        }
        existingPerson = citizenIdToPerson[_citizenID];
        MedicalRecord memory newMedicalRecord = MedicalRecord({
            mrID: mrId,
            citizenId:_citizenID,
            diagnosis: diagno,
            bill: _bill,
            hospital: _hospital
        }); 

        personMedicalRecords[_citizenID].push(newMedicalRecord);
        idToMedicalRecord[mrId] = newMedicalRecord;
        mrId++;
    }

    function createMedicalInsurance(
        uint _citizenId,
        string[] memory _policies,
        uint _maxAmount
    ) public {
        MedicalInsurance memory newMedicalInsurance = MedicalInsurance({
            insuranceId: insuranceId,
            citizenId: _citizenId,
            insurer: msg.sender,
            policies: _policies,
            maxAmount: _maxAmount
        }); 

        idToMedicalInsurance[insuranceId] = newMedicalInsurance;
        insuranceId++;
    }

    function claimInsurance(
        uint insuranceID,
        uint mrID
    ) public view  returns (uint) {
        MedicalInsurance storage i = idToMedicalInsurance[insuranceID];
        MedicalRecord storage mr = idToMedicalRecord[mrID];
        if(i.insuranceId==0 || mr.mrID==0)return 0;
        if(i.citizenId != mr.citizenId)return 0;

        // address ad = citizenAddress[mr.citizenId];
        // if(ad != msg.sender)return 0;
        for (uint k = 0; k < i.policies.length; k++) {
            for (uint j = 0; j < mr.diagnosis.length; j++) {
                if (keccak256(abi.encodePacked(i.policies[k])) == keccak256(abi.encodePacked(mr.diagnosis[j]))) {
                    if(mr.bill <= i.maxAmount)return mr.bill;
                    return i.maxAmount;
                }
            }
        }
        return 0;

    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyAuthorized() {
        require(hospitals[msg.sender], "Not authorized");
        _;
    }
    // modifier onlyInsuranceCompany() {
    //     require(insuranceCompanies[msg.sender], "Not authorized");
    //     _;
    // }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

}
