const { expect } = require("chai");
const { ethers } = require("hardhat");

// Describe the test suite for the Marketplace contract
describe("Marketplace", () => {
  const NAME = "Famous Paintings";
  const SYMBOL = "PAINT";
  const METADATA_URL = "ipfs://CID/";
  const ROYALTY_FEE = 500; // 5%
  const COST = ethers.utils.parseUnits("1", "ether");

  let deployer, artist, minter, buyer;
  let nft, marketplace;

  // Set up variables and deploy the NFT and Marketplace contracts before each test
  beforeEach(async () => {
    [deployer, artist, minter, buyer] = await ethers.getSigners();

    // Deploy NFT contract
    const NFT = await ethers.getContractFactory("NFT");
    nft = await NFT.deploy(NAME, SYMBOL, METADATA_URL, artist.address, ROYALTY_FEE);

    // Deploy Marketplace contract
    const Marketplace = await ethers.getContractFactory("Marketplace");
    marketplace = await Marketplace.deploy(nft.address);

    // Mint an NFT, approve it for the marketplace, and list it for sale
    let transaction = await nft.connect(minter).mint();
    await transaction.wait();

    transaction = await nft.connect(minter).approve(marketplace.address, 0);
    await transaction.wait();

    transaction = await marketplace.connect(minter).list(0, COST);
    await transaction.wait();
  });

  // Test suite for deployment-related functionality
  describe("Deployment", () => {
    // Test that the contract returns the correct NFT address
    it("Returns the NFT address", async () => {
      const result = await marketplace.nft();
      expect(result).to.equal(nft.address);
    });
  });

  // Test suite for buying and royalty-related functionality
  describe("Buying & Royalty", () => {
    let minterBalanceBefore, buyerBalanceBefore, artistBalanceBefore;

    // Perform buying and setup balance checks before each test in this suite
    beforeEach(async () => {
      minterBalanceBefore = await ethers.provider.getBalance(minter.address);
      buyerBalanceBefore = await ethers.provider.getBalance(buyer.address);
      artistBalanceBefore = await ethers.provider.getBalance(artist.address);

      const transaction = await marketplace.connect(buyer).buy(0, { value: COST });
      await transaction.wait();
    });

    // Test that the royalty fee is sent to the artist
    it("Sends royalty fee to artist", async () => {
      const result = await ethers.provider.getBalance(artist.address);
      expect(result).to.be.equal("10000050000000000000000"); // 0.05 ETH (5% of 1 ETH)
    });

    // Test that the original minter's balance is updated
    it("Updates the original minter's balance", async () => {
      const result = await ethers.provider.getBalance(minter.address);
      expect(result).to.be.greaterThan(minterBalanceBefore);
    });

    // Test that the buyer's balance is updated
    it("Updates the buyer's balance", async () => {
      const result = await ethers.provider.getBalance(buyer.address);
      expect(result).to.be.lessThan(buyerBalanceBefore);
    });

    // Test that ownership of the NFT is updated to the buyer
    it("Updates ownership", async () => {
      const result = await nft.ownerOf(0);
      expect(result).to.equal(buyer.address);
    });
  });
});
