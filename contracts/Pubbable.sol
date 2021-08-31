// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Pubbable is ERC1155 {

    struct GovernanceParameters {
        uint16 maxCocktailCount;
        uint16 currentCocktailCount;
        uint32 minTimeBetweenChanges;
        uint256 lastCocktailChangeTime;
    }

    // map from fungible token ID to governance rules
    mapping(uint256 => GovernanceParameters) private tokenGovernance;
    // 1 gov token => 1 or more managing addresses, but only 1 token per address
    mapping(address => uint256) private addrToManagedGovToken;
    
    // NFT cocktail token IDs must have LSB=1 (odds)
    uint256 public cocktailIdCounter = 1;
    // fungible per-bar gov tokens must have LSB=0 (evens)
    uint256 public barIdCounter = 2;

    // URI must follow ERC-1155 metadata format, contain "{id}"
    constructor(string memory metadataUri) ERC1155(metadataUri) { }

    // call this to create a new fungible governance token type for a new bar
    function mintBar(uint32 initialTokenSupply) 
        external payable 
    {
        // only mint to 'msg.sender', to ensure that the receiver wants to manage the token
        require(addrToManagedGovToken[msg.sender] == 0, "address already manages a token");
        
        barIdCounter += 2;  // incrementing by 2 keeps LSB the same
        addrToManagedGovToken[msg.sender] = barIdCounter;

        _mint(msg.sender, barIdCounter, initialTokenSupply, "");
    }

    // call this to create a cocktail NFT for a bar
    function mintCocktail(address to, uint256 minterTokenId) 
        external payable 
    {
        _requireSenderManagesToken(minterTokenId);

        GovernanceParameters memory gov = tokenGovernance[minterTokenId];
        // check if minting bar has made a change too recently
        uint sinceChange = block.timestamp - gov.lastCocktailChangeTime;
        require(
            sinceChange > gov.minTimeBetweenChanges, 
            "minimum change duration not elapsed"
        );
        // check if minting bar already has max cocktails
        require(
            gov.maxCocktailCount == 0 ||    // if no max has been set, allow mint
            gov.currentCocktailCount < gov.maxCocktailCount, 
            "mint address has max cocktail balance"
        );

        // update minting bar's cocktail governance data
        gov.currentCocktailCount += 1;
        gov.lastCocktailChangeTime = block.timestamp;
        tokenGovernance[minterTokenId] = gov;

        cocktailIdCounter += 2;
        // cocktails having a supply of 1 is what makes them NFTs
        _mint(to, cocktailIdCounter, 1, "");
    }

    // TODO - consider if we need a more advanced permission model for token managers
    // use to allow additional addresses to mint on behalf of a bar / governance token
    function addBarTokenManager(uint256 token, address manager) external payable {
        _requireSenderManagesToken(token);
        addrToManagedGovToken[manager] = token;
    }
    // TODO - removeBarTokenManager() function

    // TODO - this should be removed when we find another way for tests to check this
    function getLastCocktailMintTime(uint256 barTokenId) 
        external view returns(uint256) 
    {
        return tokenGovernance[barTokenId].lastCocktailChangeTime;
    }

    // TODO - this should be removed when we find another way for tests to check this
    function getCurrentCocktailCount(uint256 barTokenId) 
        external view returns(uint16) 
    {
        return tokenGovernance[barTokenId].currentCocktailCount;
    }

    function _requireSenderManagesToken(uint256 token) internal view {
        require(addrToManagedGovToken[msg.sender] == token, "sender does not manage token");
    }
}