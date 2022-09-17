// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Accountant} from "../src/Accountant.sol";


contract AccountantTest is Test {

    Accountant hopper;

    function setUp() public {

        bytes32[] memory initialProofs = new bytes32[](0);       

        hopper = new Accountant(keccak256(abi.encode(initialProofs)),0,keccak256(type(Accountant).creationCode));
    }

    function testSetup() public {

        emit log_address(address(hopper));

        emit log_uint(uint256(type(Accountant).creationCode.length));

        bytes32 commitment = keccak256(abi.encode("Lets commit"));

        bytes memory accCreationCode = type(Accountant).creationCode;

        vm.deal(msg.sender, 100 ether);

        address newHopper = hopper.deposit{value: 1 ether}(commitment, accCreationCode);

        emit log_address(address(newHopper));

        emit log_uint(address(newHopper).balance);

    }





}
