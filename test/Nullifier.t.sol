// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Nullifier} from "../src/Nullifier.sol";
import {NullifierInit} from "../src/NullifierInit.sol";


contract NullifierTest is Test {

    Nullifier nul;

    function setUp() public {

        bytes32[] memory initialProofs = new bytes32[](0);

        nul = new Nullifier(keccak256(abi.encode(initialProofs)), keccak256(type(Nullifier).creationCode));


    }

    function _testHashing() public {

        bytes32[] memory testArray = new bytes32[](5);

        for(uint i = 0; i< 5; i++){
            testArray[i] = keccak256(abi.encodePacked(i));
        }

        emit log_bytes(abi.encodePacked(testArray));

        bytes32[] memory testArray1 = new bytes32[](6);

        for(uint i = 0; i< 6; i++){
            testArray1[i] = keccak256(abi.encodePacked(i));
        }

        emit log_bytes(abi.encodePacked(testArray1));

        assertEq(abi.encodePacked(testArray, testArray1[5]), abi.encodePacked(testArray1));

        assertEq(keccak256(abi.encodePacked(testArray, testArray1[5])), keccak256(abi.encodePacked(testArray1)));


    }

    function testNewValidDeployment() public {

        bytes32[] memory oldProofs = new bytes32[](0);
        
        bytes32 nullifier = keccak256(abi.encode("Lets nullify"));

        bytes memory nulCreationCode = type(Nullifier).creationCode;

        address newNullifier = nul.verifyNullifer(oldProofs, nullifier, nulCreationCode);

        emit log_address(newNullifier);

    }

    function testFailNewValidDeploymentInvalid() public {

        bytes32[] memory oldProofs = new bytes32[](0);
        
        bytes32 nullifier = keccak256(abi.encode("Lets nullify"));
        
        //Will fail to create a new deployment of the dummy contract
        bytes memory nulCreationCode = type(NullifierInit).creationCode;

        address newNullifier = nul.verifyNullifer(oldProofs, nullifier, nulCreationCode);

        emit log_address(newNullifier);

    }

    function testNewValidDeploymentSecondary() public {

        // Do first round

        bytes32[] memory oldProofs = new bytes32[](0);
        
        bytes32 nullifier = keccak256(abi.encode("Lets nullify"));

        bytes memory nulCreationCode = type(Nullifier).creationCode;

        address newNullifier = nul.verifyNullifer(oldProofs, nullifier, nulCreationCode);

        // Do second round

        bytes32[] memory oldProofs1 = new bytes32[](1);
        
        // oldProofs1[0] = keccak256(abi.encode(nullifier));
        oldProofs1[0] = nullifier;

        bytes32 nullifier1 = keccak256(abi.encode("Do it again"));

        //0x7814b7a66dc8213675e5bde30b7d7f1f3bbfed035ffc3ffc55b389cec1e1fb59
        emit log_bytes32(keccak256(abi.encode(oldProofs1, nullifier1)));

        address newNullifier1 = Nullifier(newNullifier).verifyNullifer(oldProofs1, nullifier1, nulCreationCode);

        emit log_address(newNullifier1);


    }



}
