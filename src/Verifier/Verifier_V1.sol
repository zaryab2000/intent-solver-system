// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "./BaseVerifier.sol";
import {RLPReader} from "@eth-optimism/libraries/rlp/RLPReader.sol";
import {RLPWriter} from "@eth-optimism/libraries/rlp/RLPWriter.sol";
import {SecureMerkleTrie} from "@eth-optimism/libraries/trie/SecureMerkleTrie.sol";

contract Verifier_V1 is BaseVerifier {
    /**
     * @notice Indicates verification type v1: Storage Proof using SecureMerkleTrie
     */
    VerificationType public constant V_TYPE = VerificationType.v1;

    // Errors
    /**
     * @notice Indicates faliure in proving intent
     */
    error StorageProofFailed(bytes _key, bytes _val, bytes[] _proof, bytes32 _root);

    /**
     * @notice Indicates failure in proving account existence
     */
    error AccountProofFailed(bytes _address, bytes _data, bytes[] _proof, bytes32 _root);

    // HELPERS

    /**
     * @notice Validates a storage proof against a root using SecureMerkleTrie for verification
     */
    function proveStorage(bytes memory _key, bytes memory _val, bytes[] memory _proof, bytes32 _root) public pure {
        if (!SecureMerkleTrie.verifyInclusionProof(_key, _val, _proof, _root)) {
            revert StorageProofFailed(_key, _val, _proof, _root);
        }
    }

    /**
     * @notice Validates a bytes32 storage value against a root using SecureMerkleTrie for verification
     */
    function proveStorageBytes32(bytes memory _key, bytes32 _val, bytes[] memory _proof, bytes32 _root) public pure {
        bytes memory rlpEncodedValue = RLPWriter.writeUint(uint256(_val));
        if (!SecureMerkleTrie.verifyInclusionProof(_key, rlpEncodedValue, _proof, _root)) {
            revert StorageProofFailed(_key, rlpEncodedValue, _proof, _root);
        }
    }

    /**
     * @notice Validates an account proof against a root using SecureMerkleTrie for verification
     */
    function proveAccount(bytes memory _address, bytes memory _data, bytes[] memory _proof, bytes32 _root)
        public
        pure
    {
        if (!SecureMerkleTrie.verifyInclusionProof(_address, _data, _proof, _root)) {
            revert AccountProofFailed(_address, _data, _proof, _root);
        }
    }

    function getVerificationType() external pure override returns (VerificationType) {
        return V_TYPE;
    }

    /// @notice Verifies an intent via storage proof on the destination chain
    /// @param solver The address of the solver
    /// @param _intentId The full hash of the intent
    /// @param proof Merkle proof for storage inclusion of solver in fulfilled[_intentId]
    /// @param storageRoot The state root of the L2 block where intent was fulfilled
    function verifyIntentExecution(address solver, bytes32 _intentId, bytes[] calldata proof, bytes32 storageRoot)
        external
    {
        require(verifiedIntents[_intentId] == address(0), "Intent already proven");

        bytes32 mappingSlot = keccak256(
            abi.encode(
                _intentId,
                uint256(0) // storage slot 1 for fulfilled mapping in PayloadRouter contract
            )
        );

        bytes memory expectedValue = RLPWriter.writeUint(uint256(uint160(solver)));
        bool proofValid =
            SecureMerkleTrie.verifyInclusionProof(abi.encodePacked(mappingSlot), expectedValue, proof, storageRoot);
        if (!proofValid) {
            revert StorageProofFailed(abi.encodePacked(mappingSlot), expectedValue, proof, storageRoot);
        }

        // Mark intent as proven and unlock funds
        verifiedIntents[_intentId] = solver;

        emit IntentVerified(_intentId, solver);
    }
}
