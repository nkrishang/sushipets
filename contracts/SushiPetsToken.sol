// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/presets//ERC721PresetMinterPauserAutoId.sol";

contract SushiPetsToken is ERC721PresetMinterPauserAutoId {

    uint public totalPetsMinted;
    mapping (uint => string) public pets;

    constructor(
        string memory name,
        string memory symbol,
        address _petstore,
        address _petMarket
    ) ERC721PresetMinterPauserAutoId(name, symbol, '') {
        grantRole(MINTER_ROLE, _petstore);
        grantRole(DEFAULT_ADMIN_ROLE, _petMarket);
    }


    /// @notice Grants minter role to `_addr`
    function grantMinterRole(address _addr) external {
        grantRole(MINTER_ROLE, _addr);
    }

    /// @notice Returns the URI associated with `tokenId`
    function tokenURI(uint tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return pets[tokenId];
    }

    /// @notice Mints a token having URI `_URI` to address `_to`.
    function mintPet(address _to, string calldata _URI) external payable {
        hasRole(MINTER_ROLE, _msgSender());

        pets[totalPetsMinted] = _URI;
        totalPetsMinted += 1;

        mint(_to);
    }
}