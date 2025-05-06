// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {IntentOrigin} from "../src/IntentOrigin.sol";
import {IntentFiller} from "../src/IntentFiller.sol";
import {Verifier_V1} from "../src/Verifier/Verifier_V1.sol";
import {Verifier_V2} from "../src/Verifier/Verifier_V2.sol";
import {Target} from "../src/Target.sol";

import {
    StoredIntentData,
    IntentData,
    SolverData,
    SystemOrderData,
    TokenData,
    TargetCall,
    IntentStatus,
    SYSTEM_ORDER_TYPE_HASH
} from "../src/dataTypes/IntentStructure.sol";

import {IVerifier} from "../src/interfaces/IVerifier.sol";

import {
    OnchainCrossChainOrder,
    ResolvedCrossChainOrder,
    GaslessCrossChainOrder,
    Output,
    FillInstruction
} from "intents-framework/ERC7683/IERC7683.sol";

contract BaseTest is Test {
    // Contracts
    IntentFiller public intentFiller;
    Verifier_V1 public verifier_v1;
    Verifier_V2 public verifier_v2;
    Target public target;
    
    // Test accounts
    address public user;
    address public solver;
    address public owner;
    uint256 userPrivateKey;
    // Chain IDs
    address public factsRegistry;

    // Chain IDs
    uint256 constant ARB_SEPOLIA_CHAIN_ID = 421614;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    
    function setUp() public virtual {
        // make accounts
        owner = makeAddr("owner");
        (user, userPrivateKey) = makeAddrAndKey("user");
        solver = makeAddr("solver");
        factsRegistry = makeAddr("factsRegistry");
        // Deploy contracts
        vm.startPrank(owner);        
        // Deploy IntentFiller
        intentFiller = new IntentFiller();
        
        // Deploy Target
        target = new Target();
        
        // Deploy Verifiers
        verifier_v1 = new Verifier_V1();
        verifier_v2 = new Verifier_V2(address(factsRegistry));
        
        vm.stopPrank();
    }
    
    // Helper function to create a basic intent for testing
    function createBasicIntent() internal view returns (IntentData memory) {
        TokenData[] memory tokens = new TokenData[](1);
        tokens[0] = TokenData({
            token: address(0), // Native token (ETH)
            amount: 1 ether
        });
        
        TargetCall[] memory calls = new TargetCall[](1);
        calls[0] = TargetCall({
            target: address(target),
            value: 0.5 ether,
            data: abi.encodeWithSignature("lockNativeToken(address)", user)
        });
        
        return IntentData({
            salt: bytes32(uint256(1)),
            caller: user,
            source: ARB_SEPOLIA_CHAIN_ID,
            deadline: uint32(block.timestamp + 1 days),
            destination: ETH_SEPOLIA_CHAIN_ID,
            fillerAddress: address(intentFiller),
            calls: calls,
            tokens: tokens,
            status: IntentStatus.INACTIVE
        });
    }
    
    // Helper function to create system order data
    function createSystemOrderData(IntentData memory intent) internal view returns (SystemOrderData memory) {
        TokenData[] memory solverTokens = new TokenData[](1);
        solverTokens[0] = TokenData({
            token: address(0),
            amount: 0.8 ether
        });
        
        return SystemOrderData({
            intent: intent,
            creatorAddress: user,
            verifierAddress: address(verifier_v1),
            nativeTokenValue: 0.2 ether,
            solverTokens: solverTokens
        });
    }
} 