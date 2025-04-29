// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;


import { OnchainCrossChainOrder, 
         ResolvedCrossChainOrder, 
            GaslessCrossChainOrder, 
                Output, 
                    FillInstruction } from "intents-framework/ERC7683/IERC7683.sol";

import {BaseVerifier} from "./Verifier/BaseVerifier.sol";
import {IOriginSettler} from "intents-framework/ERC7683/IERC7683.sol";  
import {IntentData, SolverData} from "./dataTypes/IntentStructure.sol";

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
 *                                        1. creating intents,
 *                                        2. locking funds for intents,
 *                                        3. adhering to IERC7683 OriginSettler
 *                                        4. allowing solver settlement based on verification from BaseVerifiers.
 */
contract IntentOrigin is Ownable{
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    // STATES
    address public verifier; 
    mapping(bytes32 => IntentData) public intentData;


    // TODO: Check the need for other STATES and Constructor
    constructor() Ownable(msg.sender) {}
}