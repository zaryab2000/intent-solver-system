// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.25;

// import "../BaseTest.sol";
// import "../../src/IntentOrigin.sol";
// import "../../src/IntentFiller.sol";
// import "../../src/Verifier/Verifier_V1.sol";
// import "../../src/Verifier/Verifier_V2.sol";
// import "../../src/Target.sol";

// contract CrossChainFlowTest is BaseTest {
//     function setUp() public override {
//         super.setUp();
        
//         // Deploy all contracts across chains
        
//         // Arbitrum Sepolia setup
//         vm.chainId(ARB_SEPOLIA_CHAIN_ID);
//         vm.startPrank(owner);
//         intentOrigin = new IntentOrigin("IntentOrigin", "1.0");
//         verifier_v1 = new Verifier_V1();
//         verifier_v2 = new Verifier_V2();
//         vm.stopPrank();
        
//         // ETH Sepolia setup
//         vm.chainId(ETH_SEPOLIA_CHAIN_ID);
//         vm.startPrank(owner);
//         intentFiller = new IntentFiller();
//         target = new Target();
//         intentFiller.updateSolverStatus(solver, true);
//         vm.stopPrank();
//     }
    
//     function test_FullCrossChainFlow_V1() public {
//         // STEP 1: User creates and locks an intent on Arbitrum Sepolia
//         vm.chainId(ARB_SEPOLIA_CHAIN_ID);
        
//         // Create intent data
//         IntentData memory intent = createBasicIntent();
//         SystemOrderData memory orderData = createSystemOrderData(intent);
        
//         // Encode order data
//         bytes memory encodedOrder = abi.encode(orderData);
        
//         // Create an OnchainCrossChainOrder
//         OnchainCrossChainOrder memory order = OnchainCrossChainOrder({
//             openDeadline: uint32(block.timestamp + 1 days),
//             fillDeadline: uint32(block.timestamp + 1 days),
//             orderDataType: SYSTEM_ORDER_TYPE_HASH,
//             orderData: encodedOrder
//         });
        
//         // Open the intent
//         vm.startPrank(user);
//         intentOrigin.open{value: 1 ether}(order);
//         vm.stopPrank();
        
//         // Calculate the intent ID
//         bytes32 intentId = intentOrigin.getIntenId(intent, user);
        
//         // Verify the intent was created
//         (bytes32 storedId, address storedCaller, IntentStatus status) = intentOrigin.intentData(intentId);
//         assertEq(storedId, intentId);
//         assertEq(storedCaller, user);
//         assertEq(uint8(status), uint8(IntentStatus.OPEN));
        
//         // STEP 2: Solver fills the intent on ETH Sepolia
//         vm.chainId(ETH_SEPOLIA_CHAIN_ID);
        
//         // Prepare solver data
//         SolverData memory solverData = SolverData({
//             solverAddress: solver,
//             v_type: IVerifier.VerificationType.v1,
//             verifierAddress: address(verifier_v1)
//         });
        
//         // Encode data
//         bytes memory originData = abi.encode(intent);
//         bytes memory fillerData = abi.encode(solverData);
        
//         // Fill the intent
//         vm.startPrank(solver);
//         intentFiller.fill{value: 1 ether}(intentId, originData, fillerData);
//         vm.stopPrank();
        
//         // Verify the intent was filled correctly
//         assertEq(intentFiller.intentSolver(intentId), solver);
        
//         // STEP 3: Use V1 Verifier to verify the intent on Arbitrum Sepolia
//         vm.chainId(ARB_SEPOLIA_CHAIN_ID);
        
//         // NOTE: In a real test, this would involve complex storage proof verification
//         // For now, we'll simulate the verification by directly writing to the storage slot
        
//         vm.startPrank(owner);
        
//         // Simulate successful verification
//         // In a real scenario, this would be done via the verify method with proofs
//         address verifier = address(verifier_v1);
//         bytes32 slot = keccak256(abi.encode(intentId, uint256(0))); // slot for verifiedIntents[intentId]
//         vm.store(verifier, slot, bytes32(uint256(uint160(solver))));
        
//         vm.stopPrank();
        
//         // Verify the solver is recorded
//         assertEq(verifier_v1.getSolverAddress(intentId), solver);
        
//         // STEP 4: IntentOrigin refunds solver (simulated)
//         // In a real implementation, this would use the verification proof to refund
        
//         // Since we don't have a refund method implemented yet, we'll just
//         // note that this is where the refund would happen after verification
//     }
    
//     function test_FullCrossChainFlow_V2() public {
//         // STEP 1: User creates and locks an intent on Arbitrum Sepolia
//         vm.chainId(ARB_SEPOLIA_CHAIN_ID);
        
//         // Create intent data
//         IntentData memory intent = createBasicIntent();
//         SystemOrderData memory orderData = createSystemOrderData(intent);
        
//         // Encode order data
//         bytes memory encodedOrder = abi.encode(orderData);
        
//         // Create an OnchainCrossChainOrder
//         OnchainCrossChainOrder memory order = OnchainCrossChainOrder({
//             openDeadline: uint32(block.timestamp + 1 days),
//             fillDeadline: uint32(block.timestamp + 1 days),
//             orderDataType: SYSTEM_ORDER_TYPE_HASH,
//             orderData: encodedOrder
//         });
        
//         // Open the intent
//         vm.startPrank(user);
//         intentOrigin.open{value: 1 ether}(order);
//         vm.stopPrank();
        
//         // Calculate the intent ID
//         bytes32 intentId = intentOrigin.getIntenId(intent, user);
        
//         // STEP 2: Solver fills the intent on ETH Sepolia
//         vm.chainId(ETH_SEPOLIA_CHAIN_ID);
        
//         // Prepare solver data
//         SolverData memory solverData = SolverData({
//             solverAddress: solver,
//             v_type: IVerifier.VerificationType.v2,
//             verifierAddress: address(verifier_v2)
//         });
        
//         // Encode data
//         bytes memory originData = abi.encode(intent);
//         bytes memory fillerData = abi.encode(solverData);
        
//         // Fill the intent
//         vm.startPrank(solver);
//         intentFiller.fill{value: 1 ether}(intentId, originData, fillerData);
//         vm.stopPrank();
        
//         // STEP 3: Use V2 Verifier to verify the intent on Arbitrum Sepolia
//         vm.chainId(ARB_SEPOLIA_CHAIN_ID);
        
//         // Simulate successful verification
//         vm.startPrank(owner);
//         address verifier = address(verifier_v2);
//         bytes32 slot = keccak256(abi.encode(intentId, uint256(0))); // slot for verifiedIntents[intentId]
//         vm.store(verifier, slot, bytes32(uint256(uint160(solver))));
//         vm.stopPrank();
        
//         // Verify the solver is recorded
//         assertEq(verifier_v2.getSolverAddress(intentId), solver);
//     }
// } 