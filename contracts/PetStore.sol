// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import './Warehouse.sol';

contract PetStore {

    address public storeManager;
    Warehouse internal warehouse;

    mapping (string => uint) public alreadyMinted;
    mapping (string => uint) public supplyCap;

    mapping (string => uint) public petPrice;
    mapping (address => string) public authorized;

    struct Pets {
        uint totalPets;
        mapping (uint => string) pet;
    }

    Pets pets;

    constructor() {
        storeManager = msg.sender;
    }

    function setWarehouse(address _warehouse) external {
        require(msg.sender == storeManager, 'Only the store manager can set the warehouse.');
        warehouse = Warehouse(_warehouse);
    }

    function addPet(string calldata _URI, uint _supplyCap) external {
        require(msg.sender == storeManager, 'Only the store manager can add a pet.');

        uint index = pets.totalPets;
        pets.pet[index] = _URI;
        pets.totalPets += 1;

        supplyCap[_URI] = _supplyCap;
    }

    function getRandomPet() internal view returns (string memory URI) {
        uint randomIndex = (block.timestamp + block.number) % pets.totalPets;
        string memory petURI = pets.pet[randomIndex];

        while (alreadyMinted[petURI] >= supplyCap[petURI]) {
            randomIndex = (block.timestamp + block.number + randomIndex) % pets.totalPets;
            petURI = pets.pet[randomIndex];
        }

        return petURI;
    }

    function drawPet() public {
        string memory petURI = getRandomPet();
        authorized[msg.sender] = petURI;
    }

    function buyPet() public payable {
        string memory petURI = authorized[msg.sender];
        require(supplyCap[petURI] > 0, 'This pet does not exist.');

        warehouse.mintPet(msg.sender, petURI);
    }
}