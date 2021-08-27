pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Pubbable is ERC1155 {

    struct Cocktail {
        bytes32 name;
        bytes32[] ingredients;
    }

    // map from non-fungible token ID to cocktail data
    mapping(uint256 => Cocktail) public cocktails;
        
    struct GovernanceParameters {
        uint16 maxCocktailCount;
        uint16 currentCocktailCount;
        uint32 minTimeBetweenChanges;
        uint256 lastCocktailChangeTime;
    }

    // map from fungible token ID to governance rules
    mapping(uint256 => GovernanceParameters) private ownerGovernance;
    // 1 gov token => 1 or more managing addresses, but only 1 token per address
    mapping(address => uint256) private addrToManagedGovToken;

    // NFT cocktail token IDs must have LSB=1 (odds)
    uint256 public cocktailIdCounter = 1;
    // fungible per-bar gov tokens must have LSB=0 (evens)
    uint256 public barIdCounter = 2;

    // TODO - real metadata url / learn how metadata standard works
    constructor() ERC1155("https://fake.metadata.com/replace_me") { }

    // call this to create a new fungible governance token type for a new bar
    function newBar(uint32 initialTokenSupply) 
        external payable 
    {
        require(addrToManagedGovToken[msg.sender] == 0, "address already manages a token");
        
        barIdCounter += 2;  // incrementing by 2 keeps LSB the same
        addrToManagedGovToken[msg.sender] = barIdCounter;
        _mint(msg.sender, barIdCounter, initialTokenSupply, "");
    }

    // call this to create a cocktail for a bar
    function newCocktail(address to, uint256 minterTokenId, bytes32 _name, bytes32[] calldata _ingredients) 
        external payable 
    {
        require(
            addrToManagedGovToken[msg.sender] == minterTokenId, 
            "sender does not manage minting token"
        );

        GovernanceParameters memory gov = ownerGovernance[minterTokenId];
        _requireMintAllowedByGov(gov);
        // set last cocktail change time for this minter
        gov.lastCocktailChangeTime = block.timestamp;
        ownerGovernance[minterTokenId] = gov;

        // incrementing by 2 keeps LSB the same
        cocktailIdCounter += 2;
        // store text data for this cocktail  
        cocktails[cocktailIdCounter] = Cocktail(_name, _ingredients);
        // each cocktail has a unique token ID (an odd number) & supply of 1
        _mint(to, cocktailIdCounter, 1, "");
    }

    // makes all pre-mint checks required of governance
    function _requireMintAllowedByGov(GovernanceParameters memory gov) internal view {
        // check if owner has made a change too recently
        uint sinceChange = block.timestamp - gov.lastCocktailChangeTime;
        require(
            sinceChange > gov.minTimeBetweenChanges, 
            "minimum change duration not elapsed"
        );
        // check if owner already has max cocktails
        require(
            gov.currentCocktailCount < gov.maxCocktailCount, 
            "mint address has max cocktail balance"
        );
    }
}