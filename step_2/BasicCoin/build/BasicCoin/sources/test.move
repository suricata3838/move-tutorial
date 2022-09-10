module 0x1::test {
    struct Example has copy, drop { i: u64 }
    
    // Don't forget to add #[test_only](testing annotation)
    #[test_only]
    use std::debug;

    const ONE: u64 = 1;

    public fun print(x: u64) {
        let sum = x + ONE;
        let example = Example { i: sum };
        debug::print(&sum);
        debug::print(&example);
    }
}
