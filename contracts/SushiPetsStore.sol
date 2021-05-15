// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './SushiPetsToken.sol';
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SushiPetsStore {

    address public storeManager;
    SushiPetsToken internal sushiPetsToken;
    uint mintPrice;

    enum Tiers { Common, Rare, Cosmic }
    enum SushiTypes { Nigiri, Maki, Uramaki, Hosomaki }

    struct SushiPet {
        string uri;
        SushiTypes sushiType;
        Tiers tier;
        uint subTypeId;
    }

    struct PetSubType {
        uint subTypeId;

        mapping(Tiers => string) uriByTier;
        mapping(Tiers => uint) supplyCapOfTier;
        mapping(Tiers => uint) totalMintedOfTier;
    }

    struct PetType {
        uint totalSupplyCap;
        uint numOfSubTypes;
        string primaryUri;

        mapping(uint => PetSubType) subTypesById;
        mapping(Tiers => uint) supplyCapOfTier;
        mapping(Tiers => uint) totalMintedOfTier;
    }

    mapping(SushiTypes => PetType) pets;
    mapping(uint => SushiPet) public tokenIdToSushiPet;

    event PetAdded(string primaryUri, uint indexed sushiType);
    event SubTypeDefined(string uri, uint indexed sushiType, uint indexed subtypeId);

    constructor() {
        storeManager = msg.sender;
        mintPrice = 0.1 ether;
    }

    /// @notice Lets store manager set the Sushi pets token address. 
    function setToken(address _tokenAddress) external {
        require(msg.sender == storeManager && address(sushiPetsToken) == address(0), 'The token can only e set by the store manager once.');
        sushiPetsToken = SushiPetsToken(_tokenAddress);
    }

    /// @notice Lets the current store manager set a new store manager.
    function setStoreManager(address _newManager) external {
        require(msg.sender == storeManager, 'Only the store manager can set a new manager.');
        storeManager = _newManager;
    }

    /// @notice Lets the store manager add a pet to the store.
    function addPet(
        string calldata _primaryUri,
        uint _sushiType,
        uint _totalSupplyCap
    ) external {
        require(msg.sender == storeManager, 'Only the store manager can add a pet.');
        require(_sushiType >= uint(SushiTypes.Nigiri) && _sushiType <= uint(SushiTypes.Hosomaki), "Invalid Sushi type provided.");

        SushiTypes sushiType = SushiTypes(_sushiType);

        pets[sushiType].totalSupplyCap = _totalSupplyCap;
        pets[sushiType].primaryUri = _primaryUri;

        emit PetAdded(_primaryUri, uint(sushiType));
    }

    /// @notice Lets store manager define subtypes of a sushi pet of type `_sushiType`.
    function defineSubTypes(
        uint _sushiType,
        uint[] memory _supplyCapByTier,
        string[] calldata _uriByTier 
    ) external {
        require(msg.sender == storeManager, 'Only the store manager can add a pet.');
        require(petTypeExists(_sushiType), "Can only define subtypes of sushi pets that exist.");
        require(_supplyCapByTier.length == _uriByTier.length, "Must provide the same amounts of supply caps and URIs");

        SushiTypes sushiType = SushiTypes(_sushiType);

        for (uint i = 0; i < _uriByTier.length; i++) {
            uint supplyCap = _supplyCapByTier[i];
            string memory uri = _uriByTier[i];
            uint subTypeId = pets[sushiType].numOfSubTypes;

            pets[sushiType].numOfSubTypes += 1;

            PetSubType storage petSubType = pets[sushiType].subTypesById[subTypeId]; 

            petSubType.subTypeId = subTypeId;
            petSubType.uriByTier[Tiers(i)] = uri;
            petSubType.supplyCapOfTier[Tiers(i)] = supplyCap;

            emit SubTypeDefined(uri, uint(sushiType), subTypeId);
        }
    }

    /// @notice Mints a random pet token to msg.sender.
    function drawPet() public payable {
        SushiPet memory sushiPet = getRandomPet();
        require(msg.value >= mintPrice, "Must pay at least the mint price to get a sushi pet.");

        // Adjust mint price on each mint.
        adjustMintPrice();
        // transfer money to gnosis safe.
        transferFunds();

        // Mint sushi pet to msg.sender.
        uint tokenId = sushiPetsToken.mintPet(msg.sender, sushiPet.uri);
        tokenIdToSushiPet[tokenId] = sushiPet;
    }

    /// @notice Fetches a random sushi pet.
    function getRandomPet() internal view returns (SushiPet memory sushiPet) {
        // Not implemented yet.
    }

    /// @notice Updates the price of drawing a pet.
    function adjustMintPrice() internal {
        // Not implemented yet.
    }

    /// @notice Distributes funds to the Sushi Pets org.
    function transferFunds() internal {
        // Not implemented yet.
    }

    function petTypeExists(uint _sushiType) public view returns(bool) {
        SushiTypes sushiType = SushiTypes(_sushiType);

        if(pets[sushiType].totalSupplyCap > 0) {
            return true;
        } else {
            return false;
        }
    }

    // === Getters not implemented ===
}