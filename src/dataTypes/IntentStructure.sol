/* -*- c-basic-offset: 4 -*- */
// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../interfaces/IVerifier.sol";

/**
 * @notice Indicates the status of the intent
 */
enum IntentStatus {
    INACTIVE,
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
 * @notice Indicates the tokens involved in Intent Execution
 * @param token The address of the token to transfer
 * @param amount The amount of tokens to transfer
 */
struct TokenData {
    address token;
    uint256 amount;
}

/**
 * @notice Indicates solver's data struct with info of execution
 * @param token The address of the token to transfer
 * @param amount The amount of tokens to transfer
 */
struct SolverData {
    address solverAddress;
    IVerifier.VerificationType v_type;
}

struct IntentData {
    bytes32 salt;
    address caller;
    uint256 source;
    uint256 deadline;
    uint256 destination;
    address fillerAddress;
    TargetCall[] calls;
    TokenData[] tokens;
    IntentStatus status;
}

struct StoredIntentData {
    bytes32 intentId;
    address caller;
    IntentStatus status;
}

struct SystemOrderData {
    IntentData intent;
    address creatorAddress;
    address verifierAddress;
    uint256 nativeTokenValue;
    TokenData[] solverTokens;
}

bytes32 constant SYSTEM_ORDER_TYPE_HASH = keccak256(
    abi.encodePacked(
        "SystemOrderData(",
        "IntentData intent,",
        "address creatorAddress,",
        "address verifierAddress,",
        "uint256 nativeTokenValue,",
        "TokenData[] solverTokens",
        ")",
        "IntentData(",
        "bytes32 salt,",
        "address caller,",
        "uint256 source,",
        "uint256 deadline,",
        "uint256 destination,",
        "address fillerAddress,",
        "TargetCall[] calls,",
        "TokenData[] tokens,",
        "IntentStatus status",
        ")",
        "TargetCall(",
        "address target,",
        "bytes data,",
        "uint256 value",
        ")",
        "TokenData(",
        "address token,",
        "uint256 amount",
        ")"
    )
);
