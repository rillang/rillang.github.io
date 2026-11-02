pub fn hello(_ name: String) -> String = "${prefix()}, $name"

// not pub: only this module can call it
fn prefix() -> String = "hello"
