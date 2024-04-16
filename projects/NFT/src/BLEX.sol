// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {AccessManagedUpgradeable} from "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract BLEX is AccessManagedUpgradeable, ERC721Upgradeable {
    uint256 private _currentTokenId;
    string public baseURI;

    function initialize(address _auth) public initializer {
        __AccessManaged_init(_auth);
        __ERC721_init("BLEX BitCoin Halving Competition Winner 2024", "BLEX");
    }

    function mint(address[] calldata tos) external restricted {
        uint256 tokenId = _currentTokenId + 1;
        for (uint256 i = 0; i < tos.length; i++) {
            _safeMint(tos[i], tokenId);
            tokenId += 1;
        }
        _currentTokenId = tokenId;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory __baseURI) external restricted {
        baseURI = __baseURI;
    }
}
