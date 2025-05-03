// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IVerifier} from "../interfaces/IVerifier.sol";

/**
 * @title BaseVerifier
 * @notice Base contract for intent verification logic
 */
abstract contract BaseVerifier is IVerifier {
    /**
     * @notice Mapping to track verified intents mapped to the address of the solver
     * @dev Maps _intentId to the address of the claimant
     */
    mapping(bytes32 => address) public verifiedIntents;

    function getSolverAddress(bytes32 _intentId) external view override returns (address) {
        return verifiedIntents[_intentId];
    }
}
