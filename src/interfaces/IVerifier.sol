// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;


/**
 * @title IVerifier
 * @notice Base interface for the verification of Intent Execution
 * @dev This interface defines the core functionality for verifying intent. 
 *      The verification technique can expand to multiple types. 
 *      Currently it supports 2 types: 
 *      v1: Storage Proofs via MPT - Optimism Libs
 *      v2: Storage Proofs via Herodotus Proofs
 */
interface IVerifier {
    /**
     * @notice Types of proofs that can verify the intent execution
     * @param v1 storage proof based verification using SecureMerkleTrie Lib of Optimism
     * @param v12 storage proof based verification using Herodotus Proofs
     */
    enum VerificationType {
        v1, // Storage Proofs via MPT - Optimism Libs
        v2  // Storage Proofs via Herodotus Proofs
    } 

    /**
     * @notice Triggers an even when an intent is proven
     * @param _intentId Hash of the verified intent
     * @param solver Address of solver who is eligible to claim rewards
     */
    event IntentVerified(bytes32 indexed _intentId, address indexed solver);

    /**
     * @notice returns the type of the verification technique for a given intent
     */
    function getVerificationType() external pure returns (VerificationType);

    /**
     * @notice Returns the address of the eligible solver for a given intent
     * @param _intentId Hash of the intent to query
     * @return Address of the claimant - In case  the intent is not proven, it returns zero address
     */
    function getSolverAddress(
        bytes32 _intentId
    ) external view returns (address);
}
