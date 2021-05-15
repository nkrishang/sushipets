// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import './SushiPetsToken.sol';
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SushiPetsStore {

    address public storeManager;
    Warehouse internal warehouse;

    uint public constant totalAvailable = 4554;
    uint public totalMinted;
    uint public mintPrice;

    struct Pets {
        uint totalPets;
        mapping (uint => string) pet;
    }
    enum Tiers { Common, Rare, Cosmic }

    mapping(Tiers => Pets) public pets;
    mapping (string => uint) public circulatingSupply;
    mapping (string => uint) public supplyCap;

    constructor() public {
        storeManager = msg.sender;
        mintPrice = 0.1 ether;
    }

    /// Lets store manager set the Sushi pets warehouse. 
    function setWarehouse(address _warehouse) external {
        require(msg.sender == storeManager, 'Only the store manager can set the warehouse.');
        warehouse = Warehouse(_warehouse);
    }

    /// Lets the current store manager set a new store manager.
    function setStoreManager(address _newManager) external {
        require(msg.sender == storeManager, 'Only the store manager can set a new manager.');
        storeManager = _newManager;
    }

    /// Lets the store manager add a pet to the store.
    function addPet(string calldata _URI, uint _supplyCap, uint _tier) external {
        require(msg.sender == storeManager, 'Only the store manager can add a pet.');
        require(_tier >= uint(Tiers.Common) && _tier <= uint(Tiers.Cosmic), "Invalid tier provided.");

        Tiers tier = Tiers(_tier);

        uint index = pets[tier].totalPets;
        pets[tier].pet[index] = _URI;
        pets[tier].totalPets += 1;

        supplyCap[_URI] = _supplyCap;
    }


    function buyPet() public payable {
        string memory petURI = getRandomPet();
        require(msg.value >= mintPrice, "Must pay at least the mint price to get a sushi pet.");

        // Adjust mint price on each mint.
        adjustMintPrice();
        // transfer money to gnosis safe.

        // Mint sushi pet to msg.sender.
        warehouse.mintPet(msg.sender, petURI);
    }

    function adjustMintPrice() internal {
        // 4554 has 10 factors greater than 100. The final price will be 1.1 ether.
        if(totalMinted > 100 && (totalAvailable % totalMinted == 0)) {
            mintPrice += 0.1 ether;
        }
    }

    function getRandomPet() internal view returns (string memory URI) {
        // Not implemented yet.
    }

    function getEthPrice(IUniswapV2Pair exchange, address denominationToken, uint8 minBlocksBack, uint8 maxBlocksBack, UniswapOracle.ProofData memory proofData) public returns (uint256 price, uint256 blockNumber) {
		(price, blockNumber) = getPrice(exchange, denominationToken, minBlocksBack, maxBlocksBack, proofData);
	}

    function executeBid(uint _tokenId, address _bidder) external {
        require(msg.sender == address(warehouse), "Only a registered NFT factory can execute a bid.");

        address owner = IERC721(msg.sender).ownerOf(_tokenId);
        IERC721(msg.sender).safeTransferFrom(owner, _bidder, _tokenId, "");
    }
}