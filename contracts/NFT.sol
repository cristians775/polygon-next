// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "hardhat/console.sol";

contract NFT is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    CountersUpgradeable.Counter private _tokenIdCounter;
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    address marketAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(address _marketAddress) public initializer {
        __ERC721_init("NFT", "NFT");
        __ERC721URIStorage_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        marketAddress = _marketAddress;
        console.log("Initialized from: ", msg.sender);
        console.log("Market address:", marketAddress);
    }

    /* function createToken(string memory uri) public  onlyRole(MINTER_ROLE)  */
    function createToken(string memory uri) public returns (uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        setApprovalForAll(marketAddress, true);
        console.log("marketAddress", marketAddress);
        return tokenId;
    }

    function getMarketAddress() public view returns (address) {
        return marketAddress;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

contract NFTV2 is NFT {
    uint256 fee;
    struct Struct {
        string name;
    }
    Struct user;
    function version() public pure virtual returns (string memory) {
        return "v2";
    }
}

contract NFTV3 is NFT {
    uint256 fee;
    struct Struct{
        string name;
        string lastname;
    }
    Struct user;
    uint256 counter;

    

    function version() public pure virtual returns (string memory) {
        return "v3";
    }
}

contract NFTV4 is NFTV3 {
    uint256 owner;

    function version() public pure override returns (string memory) {
        return "v4";
    }
}
/* 
contract NFT is ERC721URIStorage, AccessControl, Initializable{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketplaceAddress, address adminRole,address minterRole, address burnerRole) ERC721("Metaverse", "METT") {
        contractAddress = marketplaceAddress;
        _setupRole(ADMIN_ROLE, adminRole);
        _setupRole(MINTER_ROLE, minterRole);
        _setupRole(BURNER_ROLE, burnerRole);
    }

 function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function createToken(string memory tokenURI) public returns (uint) {
        require(hasRole(ADMIN_ROLE,msg.sender) || hasRole(MINTER_ROLE,msg.sender) , "DOES_NOT_HAVE_ADMIN_OR_MINTER_ROLE");
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
} */
