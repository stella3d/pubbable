pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Pubbable is ERC1155 {

    struct Cocktail {
        string name;
        bytes32[] ingredients;
    }

    // map from token ID to cocktail data
    mapping(uint256 => Cocktail) public cocktails;
        
    struct GovernanceParameters {
        uint16 maxCocktailCount;
        uint32 minTimeBetweenChanges;
        uint256 lastCocktailChangeTime;
    }

    // map from mint address to governance params
    mapping(address => GovernanceParameters) private ownerGovernance;

    uint256 public constant COCKTAIL_TOKEN_ID = 1;

    // TODO - real metadata url / learn how metadata standard works
    constructor() ERC1155("https://fake.metadata.com/replace_me") { 

    }

    // makes all pre-mint checks required of governance
    function _requireMintAllowedByGov(address owner, GovernanceParameters memory gov) internal view {
        // check if owner has made a change too recently
        uint sinceChange = block.timestamp - gov.lastCocktailChangeTime;
        require(sinceChange > gov.minTimeBetweenChanges, "Cocktail: minimum change duration has not elapsed");
        // check if owner already has max cocktails
        require(
            balanceOf(owner, COCKTAIL_TOKEN_ID) < gov.maxCocktailCount, 
            "Cocktail: mint 'to' address already has max cocktail NFT balance"
        );
    }

    function _beforeCocktailMint(address mintTo) internal {
            GovernanceParameters memory gov = ownerGovernance[mintTo];
            _requireMintAllowedByGov(mintTo, gov);
            // set last cocktail change time for this owner
            gov.lastCocktailChangeTime = block.timestamp;
            ownerGovernance[mintTo] = gov;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        if(from == address(0)) {
            // we're trying to mint something
            
            for (uint256 i = 0; i < ids.length; i++) {
                uint256 tokenId = ids[i];
                if(tokenId == COCKTAIL_TOKEN_ID) {
                    //before minting new cocktail NFT, check if allowed by owner's governance rules
                    _beforeCocktailMint(to);
                }
            }

        }
    }
}