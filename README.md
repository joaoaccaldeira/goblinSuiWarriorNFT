#GoblinSuiWarriorNFT

## Functionalities
* Mint a Warrior NFT
* Mint weapon NFTs that you can equip/unequip
* Battle against bosses with your warrior
* Earn experience points for each win
* Use those same experience points to skill up your health points / attack-power / spell-power.

## Architecture
* Ownership is an object that belongs only to the publisher of the module. With it, only the owner can mint new bosses that users can fight against.
* NFTGlobalData is a shared object that contains data regarding the state of the whole GoblinSuiNFT ecosystem.
* Equipped weapons are wrapped within the warrior NFT struct.

## Note
* Switch dependencies path according to your own local Sui folder directory.
