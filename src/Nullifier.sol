// SPDX-License-Identifier: The Unlicense
pragma solidity 0.8.15;

import {CREATE3} from "solmate/utils/CREATE3.sol";

contract Nullifier {

    bytes32 immutable nullifierHash;
    bytes32 immutable depHash;

    function verifyNullifer(bytes32[] calldata proofs, bytes32 _newNullifier, bytes calldata depCode) public returns (address newLocation) {
        require(depHash == keccak256(depCode), "INVALID DEPLOYMENT");
        uint len = proofs.length;
        
        require(len < 256, "EXCEEDS MAX SIZE");

        require(nullifierHash == keccak256(abi.encode(proofs)), "INVALID PROOF");

        bytes32[] memory newProofs = new bytes32[](len+1);

        unchecked{
            for(uint i = 0; i<len; i++) {
                newProofs[i] = proofs[i];
            }
        }

        newProofs[len] = _newNullifier;

        bytes32 salt = keccak256(abi.encode(newProofs));

        newLocation = CREATE3.deploy(
            salt,
            abi.encodePacked(depCode, abi.encode(salt, depHash)),
            0
        );

        //require(keccak256(newLocation.code) == keccak256(address(this).code), "INVALID_LAUNCH");

    }

    constructor(bytes32 _nullifierHash, bytes32 _depHash) {
        nullifierHash = _nullifierHash;
        depHash = _depHash;

    }

}