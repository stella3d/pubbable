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
        uint32 minTimeBetweenChanges;
        uint256 lastCocktailChangeTime;
    }

    // map from bar's fungible token ID to bar's governance params
    mapping(uint256 => GovernanceParameters) private ownerGovernance;

    // assuming 1 gov token => 1 managing address for now,
    // kicks complexity of multiple managers to multi-sig wallets etc.
    mapping(address => uint256) private govTokenOwners;

    uint256 public constant BASE_COCKTAIL_TID = 0;

    uint256 public barCount;
    uint128 public cocktailCount;

    // TODO - real metadata url / learn how metadata standard works
    constructor() ERC1155("https://fake.metadata.com/replace_me") { 
    }

    // call this to create a new token type for a new bar
    function addNewBar(bytes memory name, uint32 initialSupply) external payable {
        uint256 newBarTokenId = barCount++;
        govTokenOwners[msg.sender] = newBarTokenId;
        _mint(msg.sender, newBarTokenId, initialSupply, name);
    }

    // makes all pre-mint checks required of governance
    function _requireMintAllowedByGov(address owner, GovernanceParameters memory gov) internal view {
        // check if owner has made a change too recently
        uint sinceChange = block.timestamp - gov.lastCocktailChangeTime;
        require(
            sinceChange > gov.minTimeBetweenChanges, 
            "Cocktail: minimum change duration has not elapsed"
        );
        // check if owner already has max cocktails
        require(
            balanceOf(owner, BASE_COCKTAIL_TID) < gov.maxCocktailCount, 
            "Cocktail: mint 'to' address already has max cocktail NFT balance"
        );
    }

    function _beforeCocktailMint(address mintTo, uint256 minterGovTokenId) internal {
            GovernanceParameters memory gov = ownerGovernance[minterGovTokenId];
            _requireMintAllowedByGov(mintTo, gov);
            // set last cocktail change time for this owner
            gov.lastCocktailChangeTime = block.timestamp;
            ownerGovernance[minterGovTokenId] = gov;
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
            /*
            uint256 minterGovTokenId = 
            for (uint256 i = 0; i < ids.length; i++) {
                uint256 tokenId = ids[i];
                if(tokenId == BASE_COCKTAIL_TID) {
                    //before minting new cocktail NFT, check if allowed by owner's governance rules
                    _beforeCocktailMint(to, );
                }
            }
            */

        }
    }
}