// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// 继承
contract InheritanceParent {
    // 通过virtual声明的函数才可以被继承的子类override
    function foo() public pure virtual returns (string memory) {
        return "foo";
    }

    function bar() public pure virtual returns (string memory) {
        return "bar";
    }

    function baz() public pure returns (string memory) {
        return "baz";
    }
}

contract InheritanceSub is InheritanceParent {
    // 使用override重写
    function foo() public pure override returns (string memory) {
        return "override foo";
    }

    function bar() public pure virtual override returns (string memory) {
        return "override bar";
    }
}

contract InheritanceSubSub is InheritanceSub {
    // 使用override重写
    function bar() public pure override returns (string memory) {
        return "override * 2 bar";
    }
}

// 多继承
// 继承顺序：最上层的最优先:
// Z继承X和Y，Y继承X，继承顺序：XYZ
// Z继承B和Y，Y继承X，B继承A，A继承X，继承顺序：XYABZ
contract X {
    function foo() public pure virtual returns (string memory) {
        return "foo X";
    }

    function bar() public pure virtual returns (string memory) {
        return "bar X";
    }

    function x() public pure returns (string memory) {
        return "baz X";
    }
}

contract Y is X {
    function foo() public pure virtual override returns (string memory) {
        return "foo Y";
    }

    function bar() public pure virtual override returns (string memory) {
        return "bar Y";
    }
}

contract Z is X, Y {
    function foo() public pure override(X, Y) returns (string memory) {
        return "foo Z";
    }

    function bar() public pure override(X, Y) returns (string memory) {
        return "bar Z";
    }
}

//
// 调用父类构造函数
contract S {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract T {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

// 方式一：在合约初始化已知构造函数参数的情况下使用
contract U is S("name"), T("text") {

}

// 方式二：在子类的构造函数上调用父类的构造函数，两种方式可以混合使用
contract V is S, T {
    constructor(string memory _name, string memory _text) S(_name) T(_text) {}
}

// *** 构造函数执行顺序按照继承类的顺序执行，如contract V is R, S, T，执行顺序为：R() -> S() -> T() -> V()

//
// 两种调用父类函数的方法
contract E {
    event Log(string message);

    function foo() public virtual {
        emit Log("E.foo");
    }

    function bar() public virtual {
        emit Log("E.bar");
    }
}

contract F is E {
    function foo() public virtual override {
        emit Log("F.foo");
        // 通过合约名直接调用
        E.foo();
    }

    function bar() public virtual override {
        emit Log("F.bar");
        // 通过super调用
        super.bar();
    }
}

contract G is E {
    function foo() public virtual override {
        emit Log("G.foo");
        E.foo();
    }

    function bar() public virtual override {
        emit Log("G.bar");
        super.bar();
    }
}

contract H is F, G {
    function foo() public override(F, G) {
        // 使用父类直接调用，只会调用该父类的函数
        F.foo();
    }

    function bar() public override(F, G) {
        // 使用super调用，在多继承时，如果多个父类都包含了该函数，会调用每个父类中的该函数
        super.bar();
    }
}
