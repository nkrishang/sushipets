// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract Warehouse is ERC721PresetMinterPauserAutoId {

    uint public totalPetsMinted;

    mapping (uint => string) public pets;

    constructor(
        string memory name,
        string memory symbol,
        address _petstore
    ) ERC721PresetMinterPauserAutoId(name, symbol, '') {
        grantRole(MINTER_ROLE, _petstore);
    }
    
    function mintPet(address _to, string calldata _URI) external payable {
        hasRole(MINTER_ROLE, _msgSender());

        pets[totalPetsMinted] = _URI;
        totalPetsMinted += 1;

        mint(_to);
    }

    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return pets[tokenId];
    }
}