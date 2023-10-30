//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract AccidentInfo {
    struct accidentDetails {
        uint accidentId;
        string vehicleRegNo;
        uint accidentTimestamp;
        string accidentCause;
        string location;
        string insuranceCompany;
    }
    uint public id;
    address public owner;
    mapping(string => accidentDetails) public regNoToAccidentDetails;
    mapping(string => address) public companyAddresses;
    mapping(address => accidentDetails[]) public accidentsByAddress;

    //events
    // event RecordAccident(uint _id, string regNo,string cause);

    constructor() {
        owner = msg.sender;
        id = 1000;
    }

    function addInsuranceCompany(string memory companyName, address companyAddress) public {
        require(companyAddresses[companyName] == address(0), "Company name already exists");
        companyAddresses[companyName] = companyAddress;
    }

    function getCompanyAddress(string memory companyName) public view returns (address) {
        return companyAddresses[companyName];
    }

    function addAccident(
        string memory _vehicleRegNo,
        uint _accidentTimestamp,
        string memory _accidentCause,
        string memory _location,
        string memory _insuranceCompany
    ) public {
        accidentDetails memory newAccident = accidentDetails({
            accidentId: id,
            vehicleRegNo: _vehicleRegNo,
            accidentTimestamp: _accidentTimestamp,
            accidentCause: _accidentCause,
            location: _location,
            insuranceCompany: _insuranceCompany
        });
        id++;
        address ad = companyAddresses[_insuranceCompany];
        accidentsByAddress[ad].push(newAccident);
    }

    function getAccidentDetailsByAddress(string memory companyName) public view returns (accidentDetails[] memory) {
        address ad = companyAddresses[companyName];
        if(ad == 0x0000000000000000000000000000000000000000){
             accidentDetails[] memory emptyArray;
             return emptyArray;
        }
        return accidentsByAddress[ad];
    }

    

}
