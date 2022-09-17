// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Accountant} from "../src/Accountant.sol";


contract AccountantTest is Test {

    Accountant hopper;

    function setUp() public logs_gas {

        bytes32[] memory initialProofs = new bytes32[](0);       

        hopper = new Accountant(keccak256(abi.encode(initialProofs)),0,keccak256(type(Accountant).creationCode));
    }

    function testFirstIteration() public {

        vm.deal(msg.sender, 100 ether);

        bytes32 commitment = keccak256(abi.encode("Lets commit"));

        bytes memory accCreationCode = type(Accountant).creationCode;


        address newHopper = hopper.deposit{value: 1 ether}(commitment, accCreationCode);

    }





}
