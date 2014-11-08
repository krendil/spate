module spate.types;

import std.container;

/**
  * A generic Set type.
  * Really just an alias to std.container.RedBlackTree
  */
alias Set = RedBlackTree;

unittest {
    import std.stdio;

    auto test = new Set!string();
    test.insert("blah");

    assert( ("blah" in test), "Set doesn't retain values!");

    test.insert("blah");
    assert(test.length == 1, "Set allows duplicates!");

    test.removeKey("blah");
    assert( !("blah" in test), "Set doesn't remove values!");
}

