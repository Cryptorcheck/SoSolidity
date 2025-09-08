// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// 数据类型-值类型
contract DataTypeValues {
    bool public boolean = true;

    uint public integer = 1; // uint256
    uint8 public u8 = 255;
    int8 public i8 = 127;
    int public min = type(int).min;
    int public max = type(int).max;

    address public addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    bytes32 public b32 =
        0x89c58ced8a9078bdef2bb60f22e58eeff7dbfed6c2dff3e7c508b629295926fa; // 使用场景：keecak256算法

    // 高精度加法取模运算，防溢出
    function addmodFunc(uint x, uint y, uint m) external pure returns (uint) {
        return addmod(x, y, m);
    }

    // 高精度乘法取模运算，防溢出
    function mulmodFunc(uint x, uint y, uint m) external pure returns (uint) {
        return mulmod(x, y, m);
    }
}

// 数组 - 动态长度和固定长度
// 初始化
// Insert(Push) get update delete pop length
contract Array {
    uint[] public nums = [1, 2, 3];
    uint[3] public numsFixed;

    function examples() external {
        numsFixed = [1, 2, 3];
        nums.push(4); // [1,2,3,4]
        nums[1]; // 2
        nums[2] = 777; // [1,2,777,4]
        // delete 把对应的下标元素删除，不改变数组长度，将元素恢复默认值
        delete nums[1]; // [1,0,777,4]
        nums.pop(); // [1,0,777]

        // 在内存中创建数组的连续内存，只能创建固定长度的数组
        // 固定长度数组不能pop和push，只能get和update
        uint[] memory a = new uint[](5);
        a[0] = 1;
    }

    // 返回数组时需要加memory关键字
    function returnArray() external view returns (uint[] memory) {
        // 不建议返回数组，可能会大量消耗gas
        return nums;
    }

    uint[] testArr = [1, 2, 3, 4, 5];

    // 因为delete删除元素只是将元素设置为默认值，无法改变数组长度
    // 因此需要通过一定的方法删除数组元素
    // 方法：将被删除元素的后续元素全部向左复制一位，例如要删除_index为2的元素 [1,2,3,4,5,6] -> remove(2) -> [1,2,4,5,6,6]，再pop
    // !!!gas花费高，如果想要节省gas，就将要删除项和数组最后一位交换后pop，但这种方式会打乱数组顺序
    function remove(uint _index) public {
        require(_index < testArr.length, "index out of bound");
        for (uint i = _index; i < testArr.length - 1; i++) {
            testArr[i] = testArr[i + 1];
        }

        testArr.pop();
    }

    function test() external {
        remove(2);
    }
}

// 映射
// 不可迭代
contract Mapping {
    mapping(address => uint) public balance;

    function test() external {
        balance[msg.sender] = 123;
        uint a = balance[msg.sender];
        require(a == 123, "error");

        // 在map中取一个没有被赋值的元素，不会报错，而是会返回这个map的值的类型默认值
        balance[address(1)];

        // 使用delete，不会删除map中的元素，而是把该元素的值设置为该类型的默认值
        delete balance[msg.sender];
    }
}

contract IterableMapping {
    mapping(address => uint) public balances;
    mapping(address => bool) public inserted;
    address[] public keys;

    function set(address _key, uint _val) external {
        balances[_key] = _val;

        if (!inserted[_key]) {
            inserted[_key] = true;
            keys.push(_key);
        }
    }

    function getSize() external view returns (uint) {
        return keys.length;
    }
}

contract Struct {
    struct Car {
        string model;
        uint year;
        address owner;
    }

    Car public car;
    Car[] public cars;
    mapping(address => Car[]) public carsByOwner;

    function examples() external {
        Car memory toyota = Car("Toyota", 1990, msg.sender);
        Car memory lambo = Car({
            year: 1980,
            model: "Lamborghini",
            owner: msg.sender
        });
        Car memory tesla;
        tesla.model = "Tesla";
        tesla.year = 2010;
        tesla.owner = msg.sender;

        cars.push(toyota);
        cars.push(lambo);
        cars.push(tesla);

        cars.push(Car("Ferrari", 2020, msg.sender));

        Car storage _car = cars[0];
        _car.year = 1999;

        // 使用delete删除struct，只是将struct中的每个属性还原回默认值
        delete cars[1];
    }
}

contract Enum {
    enum Status {
        None,
        Pending,
        Completed,
        Rejected,
        Canceled
    }

    Status public status;

    struct Order {
        address buyer;
        Status status;
    }

    Order[] public orders;

    function get() external view returns (Status) {
        return status;
    }

    function set(Status _status) external {
        status = _status;
    }

    function reset() external {
        // 回到默认值，默认值为enum定义的第一个值
        delete status;
    }
}

contract StructArray {
    struct Todo {
        string text;
        bool completed;
    }

    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo({text: _text, completed: false}));
    }

    function updateText(uint _index, string calldata _text) external {
        // 当只有一个字段时，这个方式比较节省gas。
        // 因为这种写法每次更细都需要通过索引查找到属性
        todos[_index].text = _text;

        // 等价写法
        // 多个字段时，这个写法更省gas
        // Todo storage todo = todos[_index];
        // todo.text = _text;
    }

    function get(uint _index) external view returns (string memory, bool) {
        Todo memory todo = todos[_index];
        return (todo.text, todo.completed);
    }

    function toggleCompleted(uint _index) external {
        todos[_index].completed = !todos[_index].completed;
    }
}
