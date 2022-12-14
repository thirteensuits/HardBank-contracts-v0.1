// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.10;

import "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol";
import "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol";

contract CurrencyToken is ERC20 {
    ERC721 internal immutable nft;
    uint256 public immutable tokensPerClaim;

    event Claimed(uint256 indexed tokenId, address indexed claimer);

    error NotOwner();
    error AlreadyRedeemed();

    mapping(uint256 => bool) public hasClaimed;

    constructor(
        ERC721 _nft,
        uint256 _tokensPerClaim,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol, 18) {
        nft = _nft;
        tokensPerClaim = _tokensPerClaim;
    }

    function claim(uint256 tokenId) external payable {
        if (hasClaimed[tokenId]) revert AlreadyRedeemed();
        if (nft.ownerOf(tokenId) != msg.sender) revert NotOwner();

        hasClaimed[tokenId] = true;
        emit Claimed(tokenId, msg.sender);

        _mint(msg.sender, tokensPerClaim);

    }

    function batchClaim(uint256[] memory tokenIds) external payable {
        for (uint256 index = 0; index < tokenIds.length; index++) {
            uint256 tokenId = tokenIds[index];

            if (hasClaimed[tokenId]) revert AlreadyRedeemed();
            if (nft.ownerOf(tokenId) != msg.sender) revert NotOwner();

            hasClaimed[tokenId] = true;
            emit Claimed(tokenId, msg.sender);
        }

        _mint(msg.sender, tokensPerClaim * tokenIds.length);
    }
}
