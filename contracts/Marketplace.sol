// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "./NFT.sol";

contract Marketplace {
    NFT public nft;

    // Mapping to track whether a token is listed for sale
    mapping(uint256 => bool) public isListed;

    // Mapping to store the cost of each listed token
    mapping(uint256 => uint256) public cost;

    // Mapping to store the address of the user who listed each token
    mapping(uint256 => address) public lister;

    /**
     * @dev Constructor to initialize the Marketplace contract with the NFT contract address.
     * @param _nft Address of the NFT contract.
     */
    constructor(address _nft) {
        nft = NFT(_nft);
    }

    /**
     * @dev List a token for sale in the marketplace.
     * @param _tokenId ID of the token to list.
     * @param _cost Sale price of the token.
     */
    function list(uint256 _tokenId, uint256 _cost) public {
        require(!isListed[_tokenId]);

        // Transfer the token to the marketplace contract
        nft.transferFrom(msg.sender, address(this), _tokenId);

        // Record the lister, listing status, and cost of the token
        lister[_tokenId] = msg.sender;
        isListed[_tokenId] = true;
        cost[_tokenId] = _cost;
    }

    /**
     * @dev Purchase a listed token from the marketplace.
     * @param _tokenId ID of the token to purchase.
     */
    function buy(uint256 _tokenId) public payable {
        require(isListed[_tokenId]);
        require(msg.value >= cost[_tokenId]);

        // Mark the token as no longer listed
        isListed[_tokenId] = false;

        // Get royalty information from the NFT contract
        (address artist, uint256 fee) = nft.royaltyInfo(
            _tokenId,
            cost[_tokenId]
        );

        // Pay the artist their royalty fee
        (bool sent, ) = artist.call{value: fee}("");
        require(sent);

        // Pay the lister the remaining amount after deducting the royalty fee
        (sent, ) = lister[_tokenId].call{value: msg.value - fee}("");
        require(sent);

        // Transfer NFT to the buyer
        nft.transferFrom(address(this), msg.sender, _tokenId);
    }
}
