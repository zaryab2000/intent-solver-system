/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;



/**
 * @notice Indicates the status of the intent
 */
enum IntentStatus{
    OPEN,
    EXPIRED,
    SETTLED
}

/**
 * @notice Indicates a single call to a smart contract contract call with provided calldata and value
 * @param target The contract address to call
 * @param data   calldata to execute
 * @param value  native token required for the call
 */
struct TargetCall {
    address target;
    bytes data;
    uint256 value;
}


/**
 * @notice Indicates solver's data struct with info of execution
 * @param token The address of the token to transfer
 * @param amount The amount of tokens to transfer
 */

struct SolverData {
    bytes32 intentId;
    address verifier;
    uint256 source;
    uint256 destination;
    address solverAddress;
}

struct IntentData {
    bytes32 salt;
    uint256 source;
    uint256 deadline;
    uint256 destination;
    TargetCall[] calls;
    IntentStatus status;
}
