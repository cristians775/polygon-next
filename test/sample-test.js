const assert = require("assert");

describe("Test contract upgradeable", () => {
  it("Should create and execute market sales", async function () {
    const [owner] = await ethers.getSigners();
    console.log("Owner address: ", owner.address);    

    
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await upgrades.deployProxy(NFT,[market.address], {
      kind: "uups",
    });
  
    await nft.deployed();
    
    nft.setContractAddress(marketAddress);
    /* const MINTER_ROLE = ethers.utils.solidityKeccak256(
      ["string"],
      ["MINTER_ROLE"]
    ); */

    const nftContractAddress = nft.address;

    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits("1", "ether");
      
    await nft.createToken("https://www.mytokenlocation.com");
    await nft.createToken("https://www.mytokenlocation2.com");

   
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    const [_, buyerAddress] = await ethers.getSigners();

    await market
      .connect(buyerAddress)
      .createMarketSale(nftContractAddress, 1, { value: auctionPrice });

    items = await market.fetchMarketItems();
    items = await Promise.all(
      items.map(async (i) => {
        const tokenUri = await nft.tokenURI(i.tokenId);
        let item = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri,
        };
        return item;
      })
    );
    console.log("items: ", items);
  });

   it("Upgrade contract", async () => {

    const [account] = await ethers.getSigners();
    const NFTV1 = await ethers.getContractFactory("NFT");
    const NFTV2 = await ethers.getContractFactory("NFTV2");
    const NFTV3 = await ethers.getContractFactory("NFTV3");
  
    const nft = await upgrades.deployProxy(NFTV1,[account.address],{ kind: "uups" });
    assert((await nft.name()) === "NFT");

    const nftv2 = await upgrades.upgradeProxy(nft.address, NFTV2);
    

    const nftv3 = await upgrades.upgradeProxy(nft.address, NFTV3);
   
    
    //import { getImplementationAddress } from '@openzeppelin/upgrades-core';
    //const currentImplAddress = await getImplementationAddress(provider, proxyAddress);
  });
});
