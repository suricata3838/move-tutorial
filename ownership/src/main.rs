fn main() {
    // String is allocated on the heap.
    // Pointer of allocated string goes back to str.
    let mut str = String::from("hello, world");

    // Borrow the mutable ptr(&mut str) in function mut_str()
    let str2 = mut_str(&mut str); 

    // Copy the ptr on stack
    // both str2 and str3 points to str.
    let str3 = str2; 
    println!("{}", str2); //override!
    println!("{}", str3); //override!
}

fn mut_str(s: &mut String) -> &String{
    //
    *s = String::from("override!");
    s
}