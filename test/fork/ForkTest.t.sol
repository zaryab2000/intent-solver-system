// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.25;

// import "../BaseTest.sol";
// import "../../src/IntentOrigin.sol";
// import "../../src/IntentFiller.sol";
// import "../../src/Verifier/Verifier_V1.sol";
// import "../../src/Verifier/Verifier_V2.sol";
// import "../../src/Target.sol";

// contract ForkTest is BaseTest {
//     uint256 arbSepoliaFork;
//     uint256 ethSepoliaFork;
    
//     function setUp() public override {
//         super.setUp();
        
//         // Create forks
//         // Note: You would need to replace the URLs with your own API keys
//         arbSepoliaFork = vm.createFork("https://arb-sepolia.g.alchemy.com/v2/REPLACE_WITH_YOUR_KEY");
//         ethSepoliaFork = vm.createFork("https://eth-sepolia.g.alchemy.com/v2/REPLACE_WITH_YOUR_KEY");
        
//         // Initialize on Arbitrum Sepolia
//         vm.selectFork(arbSepoliaFork);
//         vm.startPrank(owner);
//         intentOrigin = new IntentOrigin("IntentOrigin", "1.0");
//         verifier_v1 = new Verifier_V1();
//         verifier_v2 = new Verifier_V2();
//         vm.stopPrank();
        
//         // Initialize on ETH Sepolia
//         vm.selectFork(ethSepoliaFork);
//         vm.startPrank(owner);
//         intentFiller = new IntentFiller();
//         target = new Target();
//         intentFiller.updateSolverStatus(solver, true);
//         vm.stopPrank();
//     }
    
//     function test_ForkCrossChainFlow() public {
//         // Test full flow on actual forks
        
//         // STEP 1: User creates intent on Arbitrum Sepolia
//         vm.selectFork(arbSepoliaFork);
        
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
//         vm.deal(user, 10 ether); // Ensure user has ETH on the fork
//         intentOrigin.open{value: 1 ether}(order);
//         vm.stopPrank();
        
//         // Calculate the intent ID
//         bytes32 intentId = intentOrigin.getIntenId(intent, user);
        
//         // STEP 2: Solver fills the intent on ETH Sepolia
//         vm.selectFork(ethSepoliaFork);
        
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
//         vm.deal(solver, 10 ether); // Ensure solver has ETH on the fork
//         intentFiller.fill{value: 1 ether}(intentId, originData, fillerData);
//         vm.stopPrank();
        
//         // STEP 3: Verify using storage proofs
//         vm.selectFork(arbSepoliaFork);
        
//         // In a real implementation, this would involve generating actual storage proofs
//         // from the ETH Sepolia fork and submitting them to the verifier on Arbitrum Sepolia
        
//         // For now, we'll simulate verification like in the integration tests
//         vm.startPrank(owner);
//         address verifier = address(verifier_v1);
//         bytes32 slot = keccak256(abi.encode(intentId, uint256(0))); // slot for verifiedIntents[intentId]
//         vm.store(verifier, slot, bytes32(uint256(uint160(solver))));
//         vm.stopPrank();
        
//         // Verify the solver is recorded
//         assertEq(verifier_v1.getSolverAddress(intentId), solver);
//     }
// } 