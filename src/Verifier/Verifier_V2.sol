// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "./BaseVerifier.sol";
import "../interfaces/IEvmFactRegistryModule.sol";

contract Verifier_V2 is BaseVerifier {
    /**
     * @notice Indicates verification type v1: Storage Proof using Herodotus API
     */
    VerificationType public constant V_TYPE = VerificationType.v2;

    IEvmFactRegistryModule public factsRegistry;

    constructor(address _factsRegistry) {
        factsRegistry = IEvmFactRegistryModule(_factsRegistry);
    }
    // HELPERS

    /**
     * @notice Validates a storage proof against a root using SecureMerkleTrie for verification
     */
    function verifyStorageSlot(uint256 chainId, address targetAccount, uint256 blockNumber, bytes32 slot)
        public
        view
        returns (bytes32)
    {
        return factsRegistry.storageSlot(chainId, targetAccount, blockNumber, slot);
    }

    function getVerificationType() external pure override returns (VerificationType) {
        return V_TYPE;
    }

    function verifyIntentExecution(address solver, bytes32 _intentId, address fillerContract, uint256 blockNumber)
        external
    {
        require(verifiedIntents[_intentId] == address(0), "Intent already proven");

        bytes32 mappingSlot = keccak256(
            abi.encode(
                _intentId,
                uint256(0) // storage slot 1 for fulfilled mapping in PayloadRouter contract
            )
        );

        bytes32 slotValue = verifyStorageSlot(getChainId(), fillerContract, blockNumber, mappingSlot);

        (address _solver) = decodeSlotValue(slotValue);
        require(_solver == solver, "Solver does not match");

        // Mark intent as proven and unlock funds
        verifiedIntents[_intentId] = solver;

        emit IntentVerified(_intentId, solver);
    }

    function decodeSlotValue(bytes32 slotValue) internal pure returns (address recipient) {
        recipient = address(uint160(uint256(slotValue)));
    }

    function getChainId() public view returns (uint256) {
        return block.chainid;
    }
}
