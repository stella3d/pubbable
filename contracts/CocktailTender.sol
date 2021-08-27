pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CocktailTender is ERC721 {

    struct GovernanceParameters {
        uint16 maxCocktailCount;
        uint32 minTimeBetweenChanges;
        uint256 lastCocktailChangeTime;
    }

    // map from token ID to cocktail ingredients list
    mapping(uint256 => bytes32[]) private tokenIngredients;
    // map from minter address to governance params
    mapping(address => GovernanceParameters) private ownerGovernance;

    // bar is an owner address
    // NO INGREDIENT RESTICTIONS ON MINT (too much gas to upload ingredients list probably)
    // NO COCKTAIL CHANGES AFTER MINT
    // DAO governance restricts how many cocktails owner can have per-bar
    // DAO governance restricts frequency of cocktail changes (add/remove)
    // DAO tokens - cloned ERC-20 with variables change
    constructor() ERC721("CocktailTender", "COCKT") { }

    // makes all pre-mint checks required of governance
    function _requireMintAllowedByGov(address owner, GovernanceParameters memory gov) internal view {
        // check if owner has made a change too recently
        uint sinceChange = block.timestamp - gov.lastCocktailChangeTime;
        require(sinceChange > gov.minTimeBetweenChanges, "Cocktail: minimum change duration has not elapsed");
        // check if owner already has max cocktails
        require(balanceOf(owner) < gov.maxCocktailCount, "Cocktail: mint 'to' address already has max balance");
    }

    function _beforeMint(address mintTo) internal {
            GovernanceParameters memory gov = ownerGovernance[mintTo];
            _requireMintAllowedByGov(mintTo, gov);
            // set last cocktail change time for this owner
            gov.lastCocktailChangeTime = block.timestamp;
            ownerGovernance[mintTo] = gov;
    }

    function isMintAllowed(address mintTo) public view returns(bool) {
        _requireMintAllowedByGov(mintTo, ownerGovernance[mintTo]);
        return true;
    }
    
    // called before any token transfer, including minting and burning
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if(from == address(0)) {
            // we're trying to mint a new token - check if allowed by owner's governance rules
            _beforeMint(to);
        }
    }
}