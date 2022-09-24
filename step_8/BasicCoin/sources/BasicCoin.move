/// This module defines a minimal and generic Coin and Balance.
module NamedAddr::BasicCoin {
    use std::signer;

    /// Error codes
    const ENOT_MODULE_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;
    const EEQUAL_ADDR: u64 = 4;

    struct Coin<phantom CoinType> has store {
        value: u64
    }

    struct Balance<phantom CoinType> has key {
        coin: Coin<CoinType>
    }

    /// Publish an empty balance resource under `account`'s address. This function must be called before
    /// minting or transferring to the account.
    public fun publish_balance<CoinType>(account: &signer) {
        let empty_coin = Coin<CoinType> { value: 0 };
        assert!(!exists<Balance<CoinType>>(signer::address_of(account)), EALREADY_HAS_BALANCE);
        move_to(account, Balance<CoinType> { coin: empty_coin });
    }

    spec publish_balance {
        let addr = signer::address_of(account);
        aborts_if exists<Balance<CoinType>>(addr);

        ensures exists<Balance<CoinType>>(addr);
        let post balance_post = global<Balance<CoinType>>(addr).coin.value;
        ensures balance_post == 0;
    }

    /// Mint `amount` tokens to `mint_addr`. This method requires a witness with `CoinType` so that the
    /// module that owns `CoinType` can decide the minting policy.
    public fun mint<CoinType: drop>(mint_addr: address, amount: u64, _witness: CoinType) acquires Balance {
        // Deposit `total_value` amount of tokens to mint_addr's balance
        deposit(mint_addr, Coin<CoinType> { value: amount });
    }

    spec mint {
        aborts_if !exists<Balance<CoinType>>(mint_addr);

        let balance = global<Balance<CoinType>>(mint_addr).coin.value;
        let post balance_post = global<Balance<CoinType>>(mint_addr).coin.value;

        aborts_if balance + amount > MAX_U64;
        ensures balance_post == balance + amount;
    }

    public fun balance_of<CoinType>(owner: address): u64 acquires Balance {
        borrow_global<Balance<CoinType>>(owner).coin.value
    }

    spec balance_of {
        // aborts_is is strict: every aborts_if condisiton must be false.
        pragma aborts_if_is_strict;
        // Balance resource doesn't exist at address `owner`.
        aborts_if !exists<Balance<CoinType>>(owner);
    }

    /// Transfers `amount` of tokens from `from` to `to`. This method requires a witness with `CoinType` so that the
    /// module that owns `CoinType` can decide the transferring policy.
    public fun transfer<CoinType: drop>(from: &signer, to: address, amount: u64, _witness: CoinType) acquires Balance {
        let from_addr = signer::address_of(from);
        assert!(from_addr != to, EEQUAL_ADDR);
        let check = withdraw<CoinType>(from_addr, amount);
        deposit<CoinType>(to, check);
    }

    spec transfer {
        let addr_from = signer::address_of(from);

        aborts_if !exists<Balance<CoinType>>(addr_from);
        aborts_if !exists<Balance<CoinType>>(to);
        aborts_if addr_from == to;

        let balance_from = global<Balance<CoinType>>(addr_from).coin.value;
        let balance_to = global<Balance<CoinType>>(to).coin.value;
        // let post balance_from_post = global<Balance<CoinType>>(addr_from).coin.value;
        let post balance_to_post = global<Balance<CoinType>>(to).coin.value;

        aborts_if balance_from < amount;
        aborts_if balance_to + amount > MAX_U64;

        ensures global<Balance<CoinType>>(addr_from).coin.value == old(global<Balance<CoinType>>(addr_from).coin.value) - amount;
        ensures balance_to_post == balance_to + amount;
    }

    fun withdraw<CoinType>(addr: address, amount: u64) : Coin<CoinType> acquires Balance {
        let balance = balance_of<CoinType>(addr);
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin<CoinType> { value: amount }
    }

    spec withdraw {
        // 1) Abort condition
        // global<T>(address): T is a built-in function that returns the resource value at addr.
        let balance = global<Balance<CoinType>>(addr).coin.value;
        aborts_if !exists<Balance<CoinType>>(addr);
        // NOT: aborts_if balance >= amount;
        aborts_if balance < amount;

        // 2) Propeties
        let post balance_post =  global<Balance<CoinType>>(addr).coin.value;
        ensures balance_post == balance - amount;
        // result is the return value of function.
        ensures result == Coin<CoinType>{ value:amount };
    }

    fun deposit<CoinType>(addr: address, check: Coin<CoinType>) acquires Balance{
        let balance = balance_of<CoinType>(addr);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        let Coin { value } = check;
        *balance_ref = balance + value;
    }

    spec schema DepositSchema {
        let balance = global<Balance<CoinType>>(addr).coin.value;
        let check_value = check.value;

        // 1) Abort condition
        aborts_if !exists<Balance<CoinType>>(addr);
        aborts_if balance + check_value > MAX_U64;// checking overflow doesn't occur.

        // 2) Propeties
        let post balance_post = global<Balance<CoinType>>(addr).coin.value;
        ensures balance_post == balance + check_value;
    }
}
