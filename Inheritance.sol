// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/* Graph of inheritance
    A
   / \
  B   C
 / \ /
F  D,E
*/

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}

contract B is A {
    // 重写A的foo()
    function foo() public pure virtual override returns (string memory) {
        return "B";
    }
}

contract C is A {
    // 重写A的foo()
    function foo() public pure virtual override returns (string memory) {
        return "C";
    }
}

contract D is B, C {
    // 在override里面C最靠右,因此返回C的foo()结果
    function foo() public pure override(B, C) returns (string memory) {
        return super.foo();
    }
}

contract E is C, B {
    // 在override里面B最靠右,因此返回B的foo()结果
    function foo() public pure override(C, B) returns (string memory) {
        return super.foo();
    }
}
// 继承必须从“最基准”到“最衍生”排序。交换A和B的顺序会触发编译错误。
contract F is A, B {
    function foo() public pure override(A, B) returns (string memory) {
        return super.foo();
    }
}
