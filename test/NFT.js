const { expect } = require("chai");
const { ethers } = require("hardhat");

// Describe the test suite for the NFT contract
describe("NFT", () => {
  const NAME = "Famous Paintings";
  const SYMBOL = "PAINT";
  const METADATA_URL = "ipfs://CID/";
  const ROYALTY_FEE = 500; // 5%

  let deployer, artist, minter;
  let nft;

  // Set up variables and deploy the NFT contract before each test
  beforeEach(async () => {
    [deployer, artist, minter] = await ethers.getSigners();

    // Get the contract factory and deploy the NFT contract
    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy(NAME, SYMBOL, METADATA_URL, artist.address, ROYALTY_FEE);
  });

  // Test suite for deployment-related functionality
  describe("Deployment", () => {
    // Test that the contract returns the correct name
    it("Returns the name", async () => {
      const result = await nft.name();
      expect(result).to.equal(NAME);
    });

    // Test that the contract returns the correct symbol
    it("Returns the symbol", async () => {
      const result = await nft.symbol();
      expect(result).to.equal(SYMBOL);
    });

    // Test that the contract returns the correct royalty fee
    it("Returns the royalty fee", async () => {
      const result = await nft.royaltyFee();
      expect(result).to.equal(ROYALTY_FEE);
    });

    // Test that the contract returns the correct artist address
    it("Returns the artist", async () => {
      const result = await nft.artist();
      expect(result).to.equal(artist.address);
    });
  });

  // Test suite for minting and royalty information functionality
  describe("Minting & Royalty Info", () => {
    // Perform minting before each test in this suite
    beforeEach(async () => {
      const transaction = await nft.connect(minter).mint();
      await transaction.wait();
    });

    // Test that royalty information is set correctly after minting
    it("Sets royalty info", async () => {
      const COST = ethers.utils.parseUnits("1", "ether"); // Assume selling NFT for 1 ETH

      const result = await nft.royaltyInfo(0, COST);
      expect(result[0]).to.equal(artist.address);
      expect(result[1]).to.equal("50000000000000000"); // Expect royalty to be 0.05 ETH (5%)
    });

    // Test that totalSupply is updated after minting
    it("Updates totalSupply", async () => {
      const result = await nft.totalSupply();
      expect(result).to.equal(1);
    });

    // Test that ownership is updated after minting
    it("Updates ownership", async () => {
      const result = await nft.ownerOf(0);
      expect(result).to.equal(minter.address);
    });
  });
});
