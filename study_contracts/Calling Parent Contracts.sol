// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/* Inheritance tree
   A
 /  \
B   C
 \ /
  D
*/

contract A {
    event Log(string message);
    function foo() public virtual {
        emit Log("A.foo called");
    }
    function bar() public virtual {
        emit Log("A.bar called");
    }
}
contract B is A {
    function foo() public virtual override {
        emit Log("B.foo called");
        A.foo();
    }
    function bar() public virtual override {
        emit Log("B.bar called");
        super.bar();
    }
}
contract C is A {
    function foo() public virtual override {
        emit Log("C.foo called");
        A.foo();
    }
    function bar() public virtual override {
        emit Log("C.bar called");
        super.bar();
    }
}
contract D is B, C {
    //执行顺序C A
    function foo() public override(B, C) {
        super.foo();
    }
    //执行顺序C B A
    function bar() public override(B, C) {
        super.bar();
    }
}
