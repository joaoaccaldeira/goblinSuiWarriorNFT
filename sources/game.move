module nftGame::GoblinSuiWarriorNFT {
    use std::string;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::hash;
    use std::vector;
    use std::option::{Self, Option};

    /// Structs
    struct Ownership has key {
        id: UID
    }

    struct NFTGlobalData has key {
        id: UID,
        maxWarriorSupply: u64,
        mintedWarriors: u64,
        baseWarriorURL: string::String,
        baseWeaponURL: string::String,
        mintingEnabled: bool,
        owner: address,
        mintedAddresses: vector<address>
    }

    struct GoblinSuiWarriorNFT has key {
        id: UID,
        index: u64,
        name: string::String,
        baseAttackPower: u64,
        baseSpellPower: u64,
        baseHealthPoints: u64,
        experiencePoints: u64,
        url: string::String,
        equippedWeapon: Option<Weapon>
    }

    struct Weapon has key, store {
        id: UID,
        name: string::String,
        attackPower: u64,
        spellPower: u64,
        healthPoints: u64,
        url: string::String
    }

    struct Boss has key {
        id: UID,
        name: string::String,
        attackPower: u64,
        spellPower: u64,
        healthPoints: u64,
        experiencePointsReward: u64,
        url: string::String
    }


    /// Initializer
    fun init(ctx: &mut TxContext) {

        let ownership = Ownership {
            id: object::new(ctx)
        };

        let nftGlobalData = NFTGlobalData {
            id: object::new(ctx),
            maxWarriorSupply: 10000,
            mintedWarriors: 0,
            baseWarriorURL: string::utf8(b"https://ipfs.io/ipfs/QmSrgtDKdUw4a9GVxWH3fSiVnFKX4ivtwvkZZiopWSwLNW/"),
            baseWeaponURL: string::utf8(b"https://ipfs.io/ipfs/QmUPTXn9KrK3x5dD4x2RH3t2fNk7LgUUjVyygR7CsPyk6L/"),
            mintingEnabled: true,
            owner: tx_context::sender(ctx),
            mintedAddresses: vector::empty()
        };

        transfer::share_object(nftGlobalData);
        transfer::transfer(ownership, tx_context::sender(ctx));
    }


    /// Owner Functions
    entry fun changeMintingStatus(flag: bool, globalData: &mut NFTGlobalData, ctx: &mut TxContext) {
        assert!(globalData.owner == tx_context::sender(ctx), 0);
        globalData.mintingEnabled = flag;
    }

    entry fun mintBoss(_ownership: &Ownership, name: vector<u8>, attackPower: u64, spellPower: u64, healthPoints: u64, experiencePointsRewards: u64, url: vector<u8>, ctx: &mut TxContext){
        let boss = Boss {
            id: object::new(ctx),
            name: string::utf8(name),
            attackPower,
            spellPower,
            healthPoints,
            experiencePointsReward: experiencePointsRewards,
            url: string::utf8(url)
        };

        transfer::share_object(boss);
    }


    /// Getters
    public fun name(nft: &GoblinSuiWarriorNFT): &string::String {
        &nft.name
    }

    public fun url(nft: &GoblinSuiWarriorNFT): &string::String {
        &nft.url
    }

    public fun warriorBaseAttackPower(nft: &GoblinSuiWarriorNFT): u64 {
        nft.baseAttackPower
    }

    public fun warriorBaseSpellPower(nft: &GoblinSuiWarriorNFT): u64 {
        nft.baseSpellPower
    }

    public fun warriorBaseHealthPoints(nft: &GoblinSuiWarriorNFT): u64 {
        nft.baseHealthPoints
    }

    public fun weaponAttackPower(weapon: &Weapon): u64 {
        weapon.attackPower
    }

    public fun weaponSpellPower(weapon: &Weapon): u64 {
        weapon.spellPower
    }

    public fun weaponHealthPoints(weapon: &Weapon): u64 {
        weapon.healthPoints
    }


    /// Since blockchains are deterministic there would need to be an oracle
    /// for random number generators such as Chainlink or API3's QRNG
    /// Since none such exist for Sui at the moment, we've implemented two very
    /// basic non random number generators based on the hashing of a seed and in the
    /// current timestamp (epoch is changed once per day and it's the only 
    /// timestamp-like feature usable in Sui at this point)
    /// Note: This is demonstrational only and is not intended to be used
    /// on the mainnet as it is exploitable
    fun randArrayGenerator(seed: vector<u8>) : vector<u8> {
        hash::sha2_256(seed)
    }
    fun randNumber(ctx: &mut TxContext) : u64 {
        tx_context::epoch(ctx)
    }


    /// Minting Functions
    entry fun mintWarrior(globalData: &mut NFTGlobalData, name: vector<u8>, ctx: &mut TxContext) {
        assert!(globalData.mintingEnabled, 0);
        assert!(globalData.mintedWarriors < globalData.maxWarriorSupply, 0);
        assert!(vector::length(&name) >= 3, 0);
        let sender = tx_context::sender(ctx);
        let randArray = randArrayGenerator(name);
        assert!(vector::contains(&globalData.mintedAddresses, &sender) == false, 0);
        assert!(vector::length(&randArray) >= 3, 0);

        let nft = GoblinSuiWarriorNFT {
            id: object::new(ctx),
            index: globalData.mintedWarriors,
            name: string::utf8(name),
            baseAttackPower: (*vector::borrow(&randArray, 0) as u64)*2,
            baseSpellPower: (*vector::borrow(&randArray, 1) as u64)*2,
            baseHealthPoints: (*vector::borrow(&randArray, 2) as u64)*2,
            experiencePoints: 0,
            url: globalData.baseWarriorURL,
            equippedWeapon: option::none(),
        };

        globalData.mintedWarriors = globalData.mintedWarriors + 1;

        vector::push_back(&mut globalData.mintedAddresses, sender);
        transfer::transfer(nft, sender);
    }

    entry fun mintWeapon(globalData: &mut NFTGlobalData, name: vector<u8>, ctx: &mut TxContext) {
        assert!(globalData.mintingEnabled, 0);
        assert!(vector::length(&name) >= 3, 0);
        let sender = tx_context::sender(ctx);
        let randArray = randArrayGenerator(name);
        assert!(vector::length(&randArray) >= 3, 0);

        let weapon = Weapon {
            id: object::new(ctx),
            name: string::utf8(name),
            attackPower: (*vector::borrow(&randArray, 0) as u64)*2,
            spellPower: (*vector::borrow(&randArray, 1) as u64)*2,
            healthPoints: (*vector::borrow(&randArray, 2) as u64)*2,
            url: globalData.baseWeaponURL
        };

        transfer::transfer(weapon, sender);
    }

    
    /// Game Logic
    entry fun battleAgainstBoss(boss: &Boss, nft: &mut GoblinSuiWarriorNFT, ctx: &mut TxContext){
        let playerWon;
        let playerHp = nft.baseHealthPoints;
        let playerAttack = nft.baseAttackPower + nft.baseSpellPower;

        if(option::is_some(&nft.equippedWeapon)) {
            let equippedWeapon = option::borrow(&nft.equippedWeapon);
            playerAttack = playerAttack + equippedWeapon.attackPower + equippedWeapon.spellPower;
            playerHp = playerHp + equippedWeapon.healthPoints;
        };

        let bosshp = boss.healthPoints;
        let bossAttack = boss.attackPower + boss.spellPower;

        if(playerAttack > bosshp - 20){
            bosshp = 20; 
        }
        else {
            bosshp = bosshp - playerAttack;
        };

        if(bossAttack > playerHp - 20){
            playerHp = 20; 
        }
        else {
            playerHp = playerHp - bossAttack;
        };

        let totalHP = bosshp + playerHp;
        let rand = randNumber(ctx);
        let result = rand % totalHP;

        if(bosshp > playerHp){
            if(result <= playerHp){
                playerWon = true;
            }
            else {
                playerWon = false;
            }
        }
        else {
            if(result <= bosshp){
                playerWon = false;
            }
            else {
                playerWon = true;
            }
        };

        if(playerWon){
            nft.experiencePoints = nft.experiencePoints + boss.experiencePointsReward;
        };
    }
    
    entry fun useExperiencePoints(nft: &mut GoblinSuiWarriorNFT, attackPowerPoints: u64, spellPowerPoints: u64, healthPoints: u64) {
        assert!(nft.experiencePoints >= attackPowerPoints + spellPowerPoints + healthPoints, 0);
        nft.experiencePoints = nft.experiencePoints - attackPowerPoints - spellPowerPoints - healthPoints;
        nft.baseHealthPoints = nft.baseHealthPoints + healthPoints;
        nft.baseAttackPower = nft.baseAttackPower + attackPowerPoints;
        nft.baseSpellPower = nft.baseSpellPower + spellPowerPoints;
    }

    entry fun equipWeapon(nft: &mut GoblinSuiWarriorNFT, weapon: Weapon){
        assert!(!option::is_some(&nft.equippedWeapon),0);
        option::fill(&mut nft.equippedWeapon, weapon);
    }

    entry fun unequipWeapon(nft: &mut GoblinSuiWarriorNFT, ctx: &mut TxContext) {
        assert!(option::is_some(&nft.equippedWeapon),0);
        let weapon = option::extract(&mut nft.equippedWeapon);
        transfer::transfer(weapon, tx_context::sender(ctx));
    }


    /// Transfer & Burning Functions
    entry fun transferWarrior(globalData: &NFTGlobalData, nft: GoblinSuiWarriorNFT, recipient: address, _: &mut TxContext) {
        assert!(!vector::contains(&globalData.mintedAddresses, &recipient), 0);
        transfer::transfer(nft, recipient)
    }

    entry fun transferWeapon(weapon: Weapon, recipient: address, _: &mut TxContext) {
        transfer::transfer(weapon, recipient)
    }

    entry fun burnWarrior(nft: GoblinSuiWarriorNFT) {
        let GoblinSuiWarriorNFT { id, index: _, name: _, baseAttackPower: _, baseSpellPower: _, baseHealthPoints: _, experiencePoints: _, url: _, equippedWeapon } = nft;
        object::delete(id);
        let weapon = option::destroy_some(equippedWeapon);
        let Weapon { id, name: _, attackPower: _, spellPower: _, healthPoints: _, url: _ } = weapon;
        object::delete(id);
    }

    entry fun burnWeapon(weapon: Weapon) {
        let Weapon { id, name: _, attackPower: _, spellPower: _, healthPoints: _, url: _ } = weapon;
        object::delete(id)
    }

    entry fun burnBoss(boss: Boss, _ownership: &Ownership) {
        let Boss {
            id,
            name: _,
            attackPower: _,
            spellPower: _,
            healthPoints: _,
            experiencePointsReward: _,
            url: _
        } = boss;

        object::delete(id);
    }

}