module NamedAddr::BasicCoin {
    struct Coin has store {
        value: u64
    }

    struct Balance has key {
        coin: Coin
    }

    /// Publish an empty balance resource under `account`'s address. This function must be called before
    /// minting or transferring to the account.
    public fun publish_balance(account: &signer) { .. }

    /// > Signer and address
    /// Adress represents locations in global storage.
    /// Signer is ability to act on beharf of other a paticlar address.
    /// - struct signer has drop { a:address }.
    /// - UID, a user authenticated by code (only created by Move VM)
    /// - fun move_to<T>(&signer, T):to publish recouse<T> under signer.address account.

    /// > "acquires" annotation
    /// functions including move_from<T>, borrow_brobal-mut<T>, and borrow_global<T>.


    /// Mint `amount` tokens to `mint_addr`. Mint must be approved by the module owner.
    public fun mint(module_owner: &signer, mint_addr: address, amount: u64) acquires Balance { .. }

    /// Returns the balance of `owner`.
    public fun balance_of(owner: address): u64 acquires Balance { .. }

    /// Transfers `amount` of tokens from `from` to `to`.
    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance { .. }
}
