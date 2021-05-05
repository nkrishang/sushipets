// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import './Warehouse.sol';

contract PetStore {

    address public storeManager;
    Warehouse internal warehouse;

    mapping (string => uint) public alreadyMinted;
    mapping (string => uint) public supplyCap;

    struct Pets {
        uint totalPets;
        mapping (uint => string) pet;
    }

    Pets pets;

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
        return pets.pet[randomIndex];
    }

    function buyPet() public payable {
        string memory petURI = getRandomPet();
        warehouse.mintPet(msg.sender, petURI);
    }
}