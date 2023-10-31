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
    accidentDetails[] private allAccidents;

    mapping(string => accidentDetails) public regNoToAccidentDetails;
    mapping(string => address) public companyAddresses;
    mapping(address => accidentDetails[]) public accidentsByAddress;
    mapping(address => bool) public governmentAuthorities;
    

    //events
    // event RecordAccident(uint _id, string regNo,string cause);

    constructor() {
        owner = msg.sender;
        id = 1000;
    }

    function addInsuranceCompany(string memory companyName, address companyAddress) public onlyOwner{
        require(companyAddresses[companyName] == address(0), "Company name already exists");
        companyAddresses[companyName] = companyAddress;
    }

    function getCompanyAddress(string memory companyName) public view returns (address) {
        return companyAddresses[companyName];
    }

    // Function to set a boolean value for a given address
    function addGovernmentAuthority(address _address) public onlyOwner {
        governmentAuthorities[_address] = true;
    }

    // Function to get the boolean value for a given address
    function checkGovernmentAuthority(address _address) public view returns (bool) {
        return governmentAuthorities[_address];
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
        allAccidents.push(newAccident);
    }

    function getAccidentDetails() public view returns (accidentDetails[] memory) {
        address ad = msg.sender;
        // if(ad == 0x0000000000000000000000000000000000000000){
        //      accidentDetails[] memory emptyArray;
        //      return emptyArray;
        // }
        if(governmentAuthorities[ad]==true){
            return allAccidents;
        }
        return accidentsByAddress[ad];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to transfer ownership to a new address
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

}
