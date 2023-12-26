// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Royalty,
    Ownable
{
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    string public metadataURI;

    address public artist;
    uint96 public royaltyFee;

    /**
     * @dev Constructor for the NFT contract.
     * @param _name Token name.
     * @param _symbol Token symbol.
     * @param _metadataURI Base URI for token metadata.
     * @param _artist Address of the artist receiving royalties.
     * @param _royaltyFee Royalty fee in percentage.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _metadataURI,
        address _artist,
        uint96 _royaltyFee
    ) ERC721(_name, _symbol) {
        metadataURI = _metadataURI;
        artist = _artist;
        royaltyFee = _royaltyFee;
    }

    /**
     * @dev Function to mint new tokens.
     */
    function mint() public {
        uint256 tokenId = _tokenIds.current();

        _safeMint(msg.sender, tokenId);
        _setTokenURI(
            tokenId,
            string(abi.encodePacked(metadataURI, tokenId.toString(), ".json"))
        );
        _setTokenRoyalty(tokenId, artist, royaltyFee);

        _tokenIds.increment();
    }

    function setRoyaltyFee(uint96 _royaltyFee) public onlyOwner {
        // This just updates the royaltyFee state variable, you can alternatively pass in a
        // _tokenId parameter and call _setTokenRoyalty() to update an already minted token
        royaltyFee = _royaltyFee;
    }

    // The following functions are overrides required by Solidity.

    /**
     * @dev Function to burn a token.
     * @param tokenId ID of the token to burn.
     */
    function _burn(
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721URIStorage, ERC721Royalty) {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }

    /**
     * @dev Function to get the URI of a token.
     * @param tokenId ID of the token.
     * @return Token metadata URI.
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Function to handle token transfers.
     * @param from Sender's address.
     * @param to Receiver's address.
     * @param tokenId ID of the token.
     * @param batchSize Batch size of tokens to transfer.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Function to support specific interfaces.
     * @param interfaceId Interface ID to check.
     * @return true if the interface is supported, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
