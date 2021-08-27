pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Pubbable is ERC1155 {

    struct Cocktail {
        string name;
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
    // assuming 1 gov token => 1 managing address for now, this moves complexity out - 
    // 1 person can have multiple addresses, 1 address can be multi-sig, etc.
    mapping(address => uint256) private addrToManagedGovToken;

    // NFT cocktail token IDs must have LSB=1 (odds)
    uint256 public cocktailIdCounter = 1;
    // fungible per-bar gov tokens must have LSB=0 (evens)
    uint256 public barIdCounter = 2;

    // TODO - real metadata url / learn how metadata standard works
    constructor() ERC1155("https://fake.metadata.com/replace_me") {

    }

    // call this to create a new token type for a new bar
    function addNewBar(bytes memory name, uint32 initialSupply) external payable {
        require(addrToManagedGovToken[msg.sender] == 0, "address already manages a token");
        
        barIdCounter += 2;  // to keep LSB the same, increment by 2
        addrToManagedGovToken[msg.sender] = barIdCounter;
        _mint(msg.sender, barIdCounter, initialSupply, name);
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

    function _beforeCocktailMint(uint256 minterGovTokenId) internal {
            GovernanceParameters memory gov = ownerGovernance[minterGovTokenId];
            _requireMintAllowedByGov(gov);
            // set last cocktail change time for this owner
            gov.lastCocktailChangeTime = block.timestamp;
            ownerGovernance[minterGovTokenId] = gov;
    }
}