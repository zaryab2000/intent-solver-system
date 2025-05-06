// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.25;

// import "../BaseTest.sol";
// import "../../src/Verifier/Verifier_V1.sol";
// import "../../src/Verifier/Verifier_V2.sol";
// import "../../src/IntentFiller.sol"; // For intent solver mapping

// contract VerifierTest is BaseTest {
//     // Mock storage proof data for testing
//     bytes32 public constant MOCK_SLOT = bytes32(uint256(1));
//     bytes32 public constant MOCK_VALUE = bytes32(uint256(2));
//     bytes public mockProof;
    
//     function setUp() public override {
//         super.setUp();
        
//         // Deploy verifiers
//         vm.startPrank(owner);
//         verifier_v1 = new Verifier_V1();
//         verifier_v2 = new Verifier_V2();
        
//         // Deploy IntentFiller to test against
//         intentFiller = new IntentFiller();
//         intentFiller.updateSolverStatus(solver, true);
//         vm.stopPrank();
        
//         // Create mock proof data (just a placeholder for now)
//         mockProof = abi.encodePacked(MOCK_SLOT, MOCK_VALUE);
//     }
    
//     function test_Deployment() public {
//         // Verify that the verifiers are properly deployed
//         assertTrue(address(verifier_v1) != address(0));
//         assertTrue(address(verifier_v2) != address(0));
//     }
    
//     function test_GetSolverAddress() public {
//         // Set up a verified intent
//         bytes32 intentId = bytes32(uint256(1));
//         vm.startPrank(owner);
        
//         // Use assembly to directly write to the storage slot for testing
//         // This simulates a successful verification
//         address verifier = address(verifier_v1);
//         bytes32 slot = keccak256(abi.encode(intentId, uint256(0))); // slot for verifiedIntents[intentId]
//         vm.store(verifier, slot, bytes32(uint256(uint160(solver))));
        
//         vm.stopPrank();
        
//         // Verify that we can retrieve the solver address
//         assertEq(verifier_v1.getSolverAddress(intentId), solver);
//     }
    
//     function test_Verify_V1() public {
//         // This would test the V1 verification method (Optimism Storage Proofs)
//         // For now, we'll mock the verification logic since actual proof generation
//         // would require external components
        
//         // Create intent data
//         IntentData memory intent = createBasicIntent();
//         bytes32 intentId = intentFiller.getIntenId(intent, user);
        
//         // Set up the solver in the IntentFiller contract
//         vm.startPrank(owner);
//         // Directly set the mapping for testing
//         // In a real test, this would be done via the fill function
//         address fillerContract = address(intentFiller);
//         bytes32 slot = keccak256(abi.encode(intentId, uint256(0))); // slot for intentSolver[intentId]
//         vm.store(fillerContract, slot, bytes32(uint256(uint160(solver))));
//         vm.stopPrank();
        
//         // Verify the solver is set in IntentFiller
//         assertEq(intentFiller.intentSolver(intentId), solver);
        
//         // Note: An actual implementation would now generate and verify Optimism storage proofs
//         // For now, we'll just note that this would be the place to test those proofs
//     }
    
//     function test_Verify_V2() public {
//         // This would test the V2 verification method (Generic Storage Proofs)
//         // Similar to V1, but using a different verification mechanism
        
//         // Create intent data
//         IntentData memory intent = createBasicIntent();
//         bytes32 intentId = intentFiller.getIntenId(intent, user);
        
//         // Set up the solver in the IntentFiller contract
//         vm.startPrank(owner);
//         // Directly set the mapping for testing
//         address fillerContract = address(intentFiller);
//         bytes32 slot = keccak256(abi.encode(intentId, uint256(0))); // slot for intentSolver[intentId]
//         vm.store(fillerContract, slot, bytes32(uint256(uint160(solver))));
//         vm.stopPrank();
        
//         // Verify the solver is set in IntentFiller
//         assertEq(intentFiller.intentSolver(intentId), solver);
        
//         // Note: An actual implementation would verify with V2 proof mechanism
//     }
// } 