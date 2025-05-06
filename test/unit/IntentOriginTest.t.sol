// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "forge-std/console.sol";
import "../BaseTest.sol";
import "../../src/IntentOrigin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract IntentOriginTest is BaseTest {

    IntentOrigin public intentOrigin;
    function setUp() public override {
        super.setUp();
        
        // Set chain ID to Arbitrum Sepolia
        vm.chainId(ARB_SEPOLIA_CHAIN_ID);
        
        // Deploy IntentOrigin and Verifiers on Arbitrum Sepolia
        vm.startPrank(owner);
        intentOrigin = new IntentOrigin("IntentOrigin", "1.0");
        verifier_v1 = new Verifier_V1();
        verifier_v2 = new Verifier_V2(factsRegistry);
        vm.stopPrank();
    }
    
    function test_Deployment() public {
        assertEq(intentOrigin.owner(), owner);
    }
    
    function test_Open() public {
        // Set up the user with ETH
        vm.deal(user, 10 ether);
        
        // Create a system order data
        IntentData memory intent = createBasicIntent();
        SystemOrderData memory orderData = createSystemOrderData(intent);
        
        // Encode order data
        bytes memory encodedOrder = abi.encode(orderData);
        
        // Create an OnchainCrossChainOrder
        OnchainCrossChainOrder memory order = OnchainCrossChainOrder({
            fillDeadline: uint32(block.timestamp + 1 days),
            orderDataType: SYSTEM_ORDER_TYPE_HASH,
            orderData: encodedOrder
        });

        // Execute the open function
        vm.startPrank(user);
        intentOrigin.open{value: 1 ether}(order);
        vm.stopPrank();
        
        // Calculate the intent ID
        bytes32 intentId = intentOrigin.getIntenId(intent, user);
        
        // Verify the intent status is stored correctly
        (bytes32 storedId, address storedCaller, IntentStatus status) = intentOrigin.intentData(intentId);
        assertEq(storedId, intentId);
        assertEq(storedCaller, user);
        assertEq(uint8(status), uint8(IntentStatus.OPEN));
    }
    
    function test_OpenFor_WithValidSignature() public {
        // Set up the user with ETH
        vm.deal(user, 10 ether);
        vm.deal(solver, 10 ether);
        
        // Create a system order data
        IntentData memory intent = createBasicIntent();
        SystemOrderData memory orderData = createSystemOrderData(intent);
        
        // Encode order data
        bytes memory encodedOrder = abi.encode(orderData);
        
        // Create a GaslessCrossChainOrder
        GaslessCrossChainOrder memory order = GaslessCrossChainOrder({
            originSettler: address(intentOrigin),
            user: user,
            nonce: 1,
            originChainId: ARB_SEPOLIA_CHAIN_ID,
            openDeadline: uint32(block.timestamp + 1 days),
            fillDeadline: uint32(block.timestamp + 1 days),
            orderDataType: SYSTEM_ORDER_TYPE_HASH,
            orderData: encodedOrder
        });
        
        // Create signature (requires private key, which we'll mock)
        bytes32 messageHash = keccak256(
            abi.encode(
                intentOrigin.GASLESS_CROSSCHAIN_ORDER_TYPEHASH(),
                order.originSettler,
                order.user,
                order.nonce,
                order.originChainId,
                order.openDeadline,
                order.fillDeadline,
                order.orderDataType,
                keccak256(order.orderData)  // Hash the orderData first
            )
        );
        
        // Get the EIP712 hash
        bytes32 typedDataHash = intentOrigin.getTypedHash(messageHash);
        
        // Sign the typed data hash
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, typedDataHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Fund tokens for the user and approve them for the IntentOrigin contract
        vm.startPrank(user);
        // For ETH, we just ensure we have enough
        vm.deal(user, 10 ether);
        vm.stopPrank();
        
        // Execute the openFor function (called by a solver or relayer)
        vm.startPrank(solver);
        intentOrigin.openFor{value: 1 ether}(order, signature, "");
        vm.stopPrank();
        
        // // Calculate the intent ID
        // bytes32 intentId = intentOrigin.getIntenId(intent, user);
        
        // // Verify the intent status is stored correctly
        // (bytes32 storedId, address storedCaller, IntentStatus status) = intentOrigin.intentData(intentId);
        // assertEq(storedId, intentId);
        // assertEq(storedCaller, user);
        // assertEq(uint8(status), uint8(IntentStatus.OPEN));
    }
    
    function test_VerifyGaslessOrder() public {
        // This test would verify the signature verification logic
        // Similar setup to test_OpenFor_WithValidSignature
    }
} 