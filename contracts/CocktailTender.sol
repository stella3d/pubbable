pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CocktailTender is ERC721 {

    struct GovernanceParameters {
        uint16 maxCocktailCount;
        uint32 minTimeBetweenChanges;
        uint256 lastCocktailChangeTime;
    }

    // Mapping from token ID ingredients
    mapping(uint256 => bytes32[]) private tokenIngredients;
    mapping(address => GovernanceParameters) private ownerGovernance;

    // bar is an owner address
    // NO INGREDIENT RESTICTIONS ON MINT (too much gas to upload ingredients list probably)
    // NO COCKTAIL CHANGES AFTER MINT
    // DAO governance restricts how many cocktails owner can have per-bar
    // DAO governance restricts frequency of cocktail changes (add/remove)
    // DAO tokens - cloned ERC-20 with variables change
    constructor() ERC721("CocktailTender", "COCKT") { }

    function _isPastMinChangeTime (GovernanceParameters memory govParams) internal view returns(bool) {
        uint elapsed = block.timestamp - govParams.lastCocktailChangeTime;
        return elapsed > govParams.maxCocktailCount;
    }

    function _isUnderMaxCocktailCount (address owner, GovernanceParameters memory govParams) internal view returns(bool) {
        return balanceOf(owner) < govParams.maxCocktailCount;
    }
    
    // called before any token transfer, including minting and burning
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override view {
        if(from == address(0)) {
            GovernanceParameters memory toGov = ownerGovernance[to];
            require(_isPastMinChangeTime(toGov), "Cocktail: minimum change duration has not elapsed");
            require(_isUnderMaxCocktailCount(to, toGov), "Cocktail: mint 'to' address already has max balance");
        }
    }
}