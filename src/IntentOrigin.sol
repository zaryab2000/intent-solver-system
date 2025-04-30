// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;


import { OnchainCrossChainOrder, 
         ResolvedCrossChainOrder, 
            GaslessCrossChainOrder, 
                Output, 
                    FillInstruction } from "intents-framework/ERC7683/IERC7683.sol";

import {BaseVerifier} from "./Verifier/BaseVerifier.sol";
import {IOriginSettler} from "intents-framework/ERC7683/IERC7683.sol";  
import {StoredIntentData, IntentData, SolverData, SystemOrderData, TokenData, TargetCall, IntentStatus, SYSTEM_ORDER_TYPE_HASH} from "./dataTypes/IntentStructure.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/***
 * @title IntentOrigin
 * @notice The origin and locker contract for user intents.
 * @dev    This contract is responsible for managing the intents of users and their associated data.
 *         It serves as a central point for:
 *                                        1. creating intent id and recording intent data,
 *                                        2. locking funds for intents,
 *                                        3. adhering to IERC7683 OriginSettler
 *                                        4. allowing solver settlement based on verification from BaseVerifiers.
 */
contract IntentOrigin is Ownable, IOriginSettler {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    // STATES
    address public verifier; 
    mapping(bytes32 => StoredIntentData) public intentData;


    // TODO: Check the need for other STATES and Constructor
    constructor() Ownable(msg.sender) {}

    // ERROR 
    error InvalidIntentData();
    error InvalidTypeDataHash();
    error SourceChainMismatch();

    /** FUNCTIONS **/

    /// @notice Opens a cross-chain order
    /// @dev To be called by the user
    /// @dev This method must emit the Open event
    /// @param order The OnchainCrossChainOrder definition
    function open(OnchainCrossChainOrder calldata order) external payable override{
        
        if(order.orderDataType != SYSTEM_ORDER_TYPE_HASH){
            revert InvalidTypeDataHash();
        }

        SystemOrderData memory systemOrderData = abi.decode(order.orderData, (SystemOrderData));

        if(systemOrderData.intent.source != block.chainid){
            revert SourceChainMismatch();
        }

        IntentData memory intent = systemOrderData.intent;

        // 4. callDepostAndLock() function to transfer required amount into the contract
        bytes32 intentId = _depositAndLock(intent, msg.sender);

        // 5. Emit Open event with the intentId and resolved order
        emit Open(intentId, resolve(order));



    }

    // TODO: COMPLETE ALGO 

     /// @notice Opens a gasless cross-chain order on behalf of a user.
    /// @dev To be called by the filler.
    /// @dev This method must emit the Open event
    /// @param order The GaslessCrossChainOrder definition
    /// @param signature The user's signature over the order
    /// @param originFillerData Any filler-defined data required by the settler
    function openFor(
        GaslessCrossChainOrder calldata order,
        bytes calldata signature,
        bytes calldata originFillerData
    )
        external override{

    }

    // TODO: COMPLETE ALGO 

    /// @notice Resolves a specific GaslessCrossChainOrder into a generic ResolvedCrossChainOrder
    /// @dev Intended to improve standardized integration of various order types and settlement contracts
    /// @param order The GaslessCrossChainOrder definition
    /// @param originFillerData Any filler-defined data required by the settler
    /// @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
    function resolveFor(
        GaslessCrossChainOrder calldata order,
        bytes calldata originFillerData
    )
        public
        view
        override
        returns (ResolvedCrossChainOrder memory){

        }

    // TODO: COMPLETE ALGO 

    /// @notice Resolves a specific OnchainCrossChainOrder into a generic ResolvedCrossChainOrder
    /// @dev Intended to improve standardized integration of various order types and settlement contracts
    /// @param order The OnchainCrossChainOrder definition
    /// @return ResolvedCrossChainOrder hydrated order data including the inputs and outputs of the order
    function resolve(OnchainCrossChainOrder calldata order) public view override returns (ResolvedCrossChainOrder memory){
        // 1. Check the typehash of the order
        if(order.orderDataType != SYSTEM_ORDER_TYPE_HASH){
            revert InvalidTypeDataHash();
        }
        // 2. Decode the order data into the intent data
        SystemOrderData memory systemOrderData = abi.decode(order.orderData, (SystemOrderData));

        // 3. Prepare the fields for ResolvedCrossChainOrder
            // 3.a Create Output[] maxSpent
        uint256 totalTokens_intentData = systemOrderData.intent.tokens.length;
        Output[] memory maxSpent = new Output[](totalTokens_intentData);

        for(uint256 i = 0; i < totalTokens_intentData; i++){
            maxSpent[i] = Output(
                bytes32(uint256(uint160(systemOrderData.intent.tokens[i].token))),
                systemOrderData.intent.tokens[i].amount,
                bytes32(uint256(uint160(address(0)))),
                systemOrderData.intent.destination
            );
        }
        // 3.b Create Output[] minReceived
        uint256 totalTokens_solverData = systemOrderData.solverTokens.length;
        Output[] memory minReceived = new Output[](totalTokens_solverData);

        for(uint256 i = 0; i < totalTokens_solverData; i++){
            minReceived[i] = Output(
                bytes32(uint256(uint160(systemOrderData.solverTokens[i].token))),
                systemOrderData.solverTokens[i].amount,
                bytes32(uint256(uint160(address(0)))),
                systemOrderData.intent.destination
            );
        }

        if(systemOrderData.nativeTokenValue > 0){
            minReceived[totalTokens_solverData] = Output(
                bytes32(uint256(uint160(address(0)))),
                systemOrderData.nativeTokenValue,
                bytes32(uint256(uint160(address(0)))),
                systemOrderData.intent.destination
            );
        }
        IntentData memory intent = systemOrderData.intent;

        FillInstruction[] memory instructions = new FillInstruction[](1);
        instructions[0] = FillInstruction(
            systemOrderData.intent.destination,
            bytes32(uint256(uint160(systemOrderData.intent.source))),
            abi.encode(intent)
        );

        bytes32 intentId = getIntenId(intent, msg.sender);

        return ResolvedCrossChainOrder(
            systemOrderData.creatorAddress,
            systemOrderData.intent.source,
            order.fillDeadline,
            order.fillDeadline,
            intentId,
            maxSpent,
            minReceived,
            instructions
        );

    }

    /** INTERNAL FUNCTIONS **/

    function getIntenId(IntentData memory intent, address caller) public pure returns (bytes32 _intentId) {
        _intentId = keccak256(abi.encodePacked(
            caller,
            intent.salt,
            intent.source,
            intent.deadline,
            intent.destination
        ));
    }

    /// @notice Deposits and locks the required amount of tokens for the intent
    /// @param intent The intent data containing the tokens and amounts to lock
    function _depositAndLock(IntentData memory intent, address _caller) internal returns (bytes32 intentId) {

        intentId = getIntenId(intent, _caller);
        require(intentData[intentId].status == IntentStatus.INACTIVE, "Intent already exists");

        uint256 totalNativeValue;
        // 1. Transfer the tokens from the caller to this contract
        for (uint256 i = 0; i < intent.tokens.length; i++) {
            TokenData memory tokenData = intent.tokens[i];
            if(tokenData.token == address(0)){
                totalNativeValue += tokenData.amount;
            } else {
                IERC20(tokenData.token).transferFrom(msg.sender, address(this), tokenData.amount);
            }
        }
        require(msg.value >= totalNativeValue, "Insufficient native token value sent");

        intentData[intentId] = StoredIntentData(
            intentId,
            _caller,
            IntentStatus.OPEN
        ); 
    }
}