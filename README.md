# Pubbable

a DAO-ish thing for bars

## Token Structure

Pubbable generates 2 kinds of tokens:
* Bar Governance
  
  Each registered bar gets its own fungible governance token, which will allow holders to vote on bar governance.

* Cocktail NFT
  
  Cocktail NFTs represent real-world cocktails on the menu of a bar.

  Cocktails can only be minted by admins of a Bar Governance token, associating them with that bar.

## Bar Governance

Things governance token holders can vote on will include:
* which special ingredients the bar keeps available
* which cocktails stay on the menu
* how many cocktails the bar can have
* how often cocktails can be changed

## Metadata

All strings are kept in metadata JSON files, not on-chain.  This reduces gas costs & is convenient for building front ends.

Files for both Bars and Cocktails have `name` & `image` fields.

### Bars

Bar tokens MAY optionally have an `ingredients` property, which is an array of strings, representing special ingredients they keep on hand.

See the [example Bar metadata](./metadata/barMetadataExample.json) for more details.

  
### Cocktails

Cocktail NFTs MUST have an `ingredients` property which is an array of strings.

See the [example Cocktail metadata](./metadata/cocktailMetadataExample.json) for more details.
