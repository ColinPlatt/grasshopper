// SPDX-License-Identifier: The Unlicense
pragma solidity 0.8.15;

import {CREATE3} from "solmate/utils/CREATE3.sol";
import {Verifier} from "./Verifier.sol";

contract Accountant {

    bool invalidated;
    bytes32 immutable depHash;

    bytes32 immutable commitmentHash;
    bytes32 immutable nullifierHash;

    event Deposit(address NewLocation, bytes32 Commitment);
    event Withdrawal(address NewLocation, address to, bytes32 nullifierHash);

    /**
        @dev Deposit funds into the contract. The caller must send (for ETH) value equal to `denomination` of this instance (1 ETH).
        @param _commitment the note commitment, which is PedersenHash(nullifier + secret)
    */
    function deposit(bytes32 _commitment, bytes calldata depCode) external payable returns (address newLocation) {
        // we check that this contract is the last in the chain to ensure that this contract cannot be called after it's used
        require(!invalidated, "STALE CONTRACT");
        require(depHash == keccak256(depCode), "INVALID DEPLOYMENT CODE");
        require(msg.value == 1 ether, "INVALID AMOUNT: 1 ETH");

        bytes32 newCommitmentHash = keccak256(abi.encodePacked(commitmentHash, _commitment));

        newLocation = CREATE3.deploy(
            newCommitmentHash,
            abi.encodePacked(depCode, abi.encode(newCommitmentHash, nullifierHash, depHash)),
            0
        );

        (bool success, ) = payable(newLocation).call{ value: (address(this).balance) }("");
        require(success, "payment to newLocation did not go thru");

        invalidated = true;
        
        emit Deposit(newLocation, _commitment);
    }

    function _verifyNullifer(bytes32[] calldata proofs, bytes32 _newNullifier) public view returns (bool success, bytes32 newNullifierHash) {
        uint256 len = proofs.length;
        
        //will need to expose this to a variable to control deposits
        require(len < 256, "EXCEEDS MAX SIZE");

        require(nullifierHash == keccak256(abi.encode(proofs)), "INVALID PROOF");

        bytes32[] memory newProofs = new bytes32[](len+1);

        unchecked{
            for(uint i = 0; i<len; i++) {
                newProofs[i] = proofs[i];
            }
        }

        newProofs[len] = _newNullifier;

        newNullifierHash = keccak256(abi.encode(newProofs));
        success = true;

    }

    function _processWithdraw(
        address payable _recipient
    ) internal {
        // sanity checks
        require(msg.value == 0, "Message value is supposed to be zero for ETH instance");

        (bool success, ) = _recipient.call{ value: 1 ether }("");
        require(success, "payment to _recipient did not go thru");
    }

    function withdraw(
        bytes calldata _proof,
        bytes32[] calldata nullifierProofs, 
        bytes32 _newNullifier,
        address payable _recipient,
        bytes calldata depCode
    ) public returns (
        address newLocation
    ) {
        require(!invalidated, "STALE CONTRACT");
        require(depHash == keccak256(depCode), "INVALID DEPLOYMENT CODE");
        (bool success, bytes32 newNullifierHash) = _verifyNullifer(nullifierProofs, _newNullifier);

        require(success, "ERROR IN NULLIFIER CONTROL");

        require(
            Verifier.verifyProof(
                _proof,
                [uint256(uint160(address(this))), uint256(_newNullifier), uint256(uint160(address(_recipient)))]
            ),
            "Invalid withdraw proof"
        );

        newLocation = CREATE3.deploy(
            newNullifierHash,
            abi.encodePacked(depCode, abi.encode(commitmentHash, newNullifierHash, depHash)),
            address(this).balance - 1 ether
        );

        _processWithdraw(_recipient);

        invalidated = true;
        
        emit Withdrawal(newLocation, _recipient, _newNullifier);

    }

    receive() external payable {
        require(!invalidated, "NOT LATEST CONTRACT");
    }
    

    constructor(bytes32 _commitmentHash, bytes32 _nullifierHash, bytes32 _depHash) {
        commitmentHash = _commitmentHash;
        nullifierHash = _nullifierHash;
        depHash = _depHash;
    }

}
