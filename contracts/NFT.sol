//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721("NFT", "Non Fungible Token") {
    uint256 public nextTokenId = 1;

    function mint() external {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(_msgSender(), tokenId);
    }
}
