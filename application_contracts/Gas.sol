// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Gas1 {
    uint public total;
    // [1,2,3,4,5,100]
    // 49730 gas
    function sumIfEvenAndLessThan99(uint[] memory nums) external {
        for (uint i; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool lessThan99 = nums[i] < 99;
            if (isEven && lessThan99) {
                total += nums[i];
            }
        }
    }
}
contract Gas2 {
    uint public total;
    // [1,2,3,4,5,100]
    // 48000 gas
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        for (uint i; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool lessThan99 = nums[i] < 99;
            if (isEven && lessThan99) {
                total += nums[i];
            }
        }
    }
}
contract Gas3 {
    uint public total;
    // [1,2,3,4,5,100]
    // 47790 gas
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        for (uint i; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool lessThan99 = nums[i] < 99;
            if (isEven && lessThan99) {
                _total += nums[i];
            }
        }
        total = _total;
    }
}
contract Gas4 {
    uint public total;
    // [1,2,3,4,5,100]
    // 47484 gas
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        for (uint i; i < nums.length; i++) {
            if (nums[i] % 2 == 0 && nums[i] < 99) {
                _total += nums[i];
            }
        }
        total = _total;
    }
}
contract Gas5 {
    uint public total;
    // [1,2,3,4,5,100]
    // 47454 gas
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        for (uint i; i < nums.length; ++i) {
            if (nums[i] % 2 == 0 && nums[i] < 99) {
                _total += nums[i];
            }
        }
        total = _total;
    }
}
contract Gas6 {
    uint public total;
    // [1,2,3,4,5,100]
    // 47418 gas
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        uint length = nums.length;
        for (uint i; i < length; ++i) {
            if (nums[i] % 2 == 0 && nums[i] < 99) {
                _total += nums[i];
            }
        }
        total = _total;
    }
}
contract Gas7 {
    uint public total;
    // [1,2,3,4,5,100]
    // 47250 gas
    function sumIfEvenAndLessThan99(uint[] calldata nums) external {
        uint _total = total;
        uint length = nums.length;
        for (uint i; i < length; ++i) {
            uint nums = nums[i];
            if (nums % 2 == 0 && nums < 99) {
                _total += nums;
            }
        }
        total = _total;
    }
}