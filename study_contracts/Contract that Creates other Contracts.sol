// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Car {
    address public owner;
    string public model;
    address public carAddr;
    constructor(address _owner, string memory _model) payable {
        owner = _owner;
        model = _model;
        carAddr = address(this);
    }
}
contract CarFactory{
    Car[] public cars;
    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,1
    function create(address _owner, string memory _model) public {
        Car car = new Car(_owner, _model);
        cars.push(car);
    }
    // 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,3 再加若干wei
     function createAndSendEther(address _owner, string memory _model) public payable {
        Car car = (new Car){value: msg.value}(_owner, _model);
        cars.push(car);
    }
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,2,0x1234567890123456789012345678901234567890123456789012345678901234
    function create2(address _owner, string memory _model, bytes32 _salt) public {
        Car car = (new Car){salt: _salt}(_owner, _model);
        cars.push(car);
    }
    // 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,4,0x1234567890123456789012345678901234567890123456789012345678901234  再加若干wei
    function create2AndSendEther(address _owner, string memory _model, bytes32 _salt) public payable {
        Car car = (new Car){value: msg.value, salt: _salt}(_owner, _model);
        cars.push(car);
    }
    function getCar(uint _index) public view returns (address owner, string memory model, address carAddr, uint balance) {
        Car car = cars[_index];
        return (car.owner(), car.model(), car.carAddr(), address(car).balance);
    }
    function getCarCount() public view returns (uint) {
        return cars.length;
    }
}
