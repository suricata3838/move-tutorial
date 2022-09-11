module 0xC0FFEE::DebugTest {
    struct Example has copy, drop {
        i: u64
    }
    use std::debug;

    const ONE: u64 = 1;

    public fun print(){
        debug::print(&ONE);        
    }

    // Declare unit test with function param
    #[test]
    fun test_print_one() {
        print();
    }

    // MEMO: arguments musy be address.
    #[test]
    fun test_print() {
        let sum = 1 + ONE;
        let example = Example { i: sum };
        debug::print(&sum);
        debug::print(&example);

        let expected_output = Example{i:2};
        assert!(example == expected_output, 0);
    }
}
