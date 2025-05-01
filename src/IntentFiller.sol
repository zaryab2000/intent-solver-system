// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;


import { OnchainCrossChainOrder, 
         ResolvedCrossChainOrder, 
            GaslessCrossChainOrder, 
                Output, 
                    FillInstruction } from "intents-framework/ERC7683/IERC7683.sol";

import "./interfaces/IVerifier.sol";
import {BaseVerifier} from "./Verifier/BaseVerifier.sol";
import {IDestinationSettler} from "intents-framework/ERC7683/IERC7683.sol";  
import {StoredIntentData, IntentData, SolverData, SystemOrderData, TokenData, TargetCall, IntentStatus, SYSTEM_ORDER_TYPE_HASH} from "./dataTypes/IntentStructure.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/***
 * @title IntentFiller
 * @notice The filler contract that is responsible for fulfilling intents.
 * @dev    This contract is tasked with the following:
 *         It serves as a central point for:
 *                                        1. filling user intents,
 *                                        2. maintain records of whitelisted solvers,
 *                                        3. maintain records of fulfilled intents and their solver,
 *                                        4. adhere to IDestinationSettler interface for cross-chain order settlement.
 */
contract IntentFiller is IDestinationSettler, Ownable{
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    constructor() Ownable(msg.sender) {
        // Initialize the contract

    }

    // ============ Events ============
    event IntentFilled(
        bytes32 indexed orderId,
        address indexed filler,
        address indexed solver,
        bytes originData,
        bytes fillerData
    );

    // ============ Errors ============
    error IntentExpired();
    error InvalidChainId();
    error InvalidAddress();
    error InvalidIntentData();
    error InvalidCallToEOA();
    error CallExecutionFailed();

    // ============ State Variables ============
    mapping(address => bool) public isSolver;
    // @notice Mapping of fulfilled intents to their solvers
    // @dev    This mapping will be used as storage proof during Verification and Settlement.
    mapping(bytes32 => address) public intentSolver;

    // @notice update the solver status
    // @dev    This function will be used to update the solver status.
    function updateSolverStatus(address solver, bool status) external onlyOwner {
        isSolver[solver] = status;
        
    }

    
    function fill(bytes32 orderId, bytes calldata originData, bytes calldata fillerData) external payable{
        // 1. Extract the INTENT Data from originData
           // Check if intent deadline has expired - if yes, revert 

        IntentData memory intentData = abi.decode(originData, (IntentData));
        if (intentData.deadline < block.timestamp) {
            revert IntentExpired();
        }
        
        // 2. extract fillerData to get solver address, v_type and verifier address
        SolverData memory solverData = abi.decode(fillerData, (SolverData));
        IVerifier.VerificationType v_type = solverData.v_type;



        // 3. based on v_type, call the appropriate function to fulfil and record the intent
        if (v_type == IVerifier.VerificationType.v1) {
            // 3.1. Call the function to fulfil the intent
            fulfillIntent_v1(intentData, solverData.solverAddress, orderId);
        } else if (v_type == IVerifier.VerificationType.v2) {
            // 3.2. Call the function to fulfil the intent
            fulfillIntent_v2(intentData, solverData.solverAddress, orderId);
        } else {
            revert("Invalid Verification Type");
        }
    }

    // ============ Internal Functions ============
    function fulfillIntent_v1(
        IntentData memory intentData,
        address solverAddress,
        bytes32 intentId
    ) internal {
       // Check solver is whitelisted
        require(isSolver[solverAddress], "Solver is not whitelisted");
       // Check intent destination is same as the current chain
        if(intentData.destination != block.chainid) {
            revert InvalidChainId();
        }
       // Check filler address is accurate
       if(intentData.fillerAddress != address(this)) {
            revert InvalidAddress();
        }
        // Check intent hash matches accurate intentId
        bytes32 expectedIntentId = getIntenId(intentData, intentData.caller);
        if (expectedIntentId != intentId) {
            revert InvalidIntentData();
        }
        // Check intent status is not already filled
        require(intentSolver[intentId] == address(0), "Intent already filled");

        // CHECK Solver Address is not zero address
        require(solverAddress != address(0), "Solver address is zero");

        // Bring all tokens to the filler address
        uint256 totalTokens = intentData.tokens.length;

        for(uint256 i = 0; i < totalTokens; i++) {
            TokenData memory tokenData = intentData.tokens[i];
            // Transfer the tokens to the filler address
            IERC20(tokenData.token).safeTransferFrom(intentData.caller, address(this), tokenData.amount);
        }

        uint256 totalNativeValue = msg.value;
        
        // Prepare the data for target call
        for(uint256 i = 0; i < intentData.calls.length; i++) {
            TargetCall memory call = intentData.calls[i];

            // Check if the target address is a contract
            if(call.target.code.length == 0 && call.data.length > 0) {
                revert InvalidCallToEOA();
            }else{
                (
                    bool success,
                    bytes memory returnData
                ) = call.target.call{value: call.value}(call.data);

                // Check if the call was successful
                if (!success) {
                    revert CallExecutionFailed();
                }

                totalNativeValue -= call.value;
            }
        }
            // If call is being made to EOA, revert
            // Call the target contract with the data
        
    }

    function fulfillIntent_v2(
        IntentData memory intentData,
        address solverAddress,
        bytes32 orderId
    ) internal {
       
        
    }

    function getIntenId(IntentData memory intent, address caller) public pure returns (bytes32 _intentId) {
        _intentId = keccak256(abi.encodePacked(
            caller,
            intent.salt,
            intent.source,
            intent.deadline,
            intent.destination
        ));
    }

  

  
}