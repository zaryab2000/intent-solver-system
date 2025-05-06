// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.25;

// import "../BaseTest.sol";
// import "../../src/IntentFiller.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// contract IntentFillerTest is BaseTest {
//     function setUp() public override {
//         super.setUp();
        
//         // Set chain ID to ETH Sepolia
//         vm.chainId(ETH_SEPOLIA_CHAIN_ID);
        
//         // Deploy IntentFiller and Target on ETH Sepolia
//         vm.startPrank(owner);
//         intentFiller = new IntentFiller();
//         target = new Target();
        
//         // Whitelist the solver
//         intentFiller.updateSolverStatus(solver, true);
//         vm.stopPrank();
//     }
    
//     function test_Deployment() public {
//         assertEq(intentFiller.owner(), owner);
//         assertTrue(intentFiller.isSolver(solver));
//         assertFalse(intentFiller.isSolver(user));
//     }
    
//     function test_UpdateSolverStatus() public {
//         vm.startPrank(owner);
        
//         // Update a new solver status
//         address newSolver = makeAddr("newSolver");
//         intentFiller.updateSolverStatus(newSolver, true);
//         assertTrue(intentFiller.isSolver(newSolver));
        
//         // Update existing solver status
//         intentFiller.updateSolverStatus(solver, false);
//         assertFalse(intentFiller.isSolver(solver));
        
//         vm.stopPrank();
//     }
    
//     function test_Fill_V1() public {
//         // Create intent data
//         IntentData memory intent = createBasicIntent();
        
//         // Make sure target destination is current chain
//         intent.destination = ETH_SEPOLIA_CHAIN_ID;
        
//         // Calculate intent ID
//         bytes32 intentId = intentFiller.getIntenId(intent, user);
        
//         // Prepare SolverData
//         SolverData memory solverData = SolverData({
//             solverAddress: solver,
//             v_type: IVerifier.VerificationType.v1,
//             verifierAddress: address(verifier_v1)
//         });
        
//         // Encode data
//         bytes memory originData = abi.encode(intent);
//         bytes memory fillerData = abi.encode(solverData);
        
//         // Execute the fill function
//         vm.startPrank(solver);
//         vm.deal(solver, 10 ether);
//         intentFiller.fill{value: 1 ether}(intentId, originData, fillerData);
//         vm.stopPrank();
        
//         // Verify intent was filled and recorded
//         assertEq(intentFiller.intentSolver(intentId), solver);
//     }
    
//     function testFail_Fill_ExpiredIntent() public {
//         // Create intent data with expired deadline
//         IntentData memory intent = createBasicIntent();
//         intent.deadline = uint32(block.timestamp - 1 days); // Expired
//         intent.destination = ETH_SEPOLIA_CHAIN_ID;
        
//         // Calculate intent ID
//         bytes32 intentId = intentFiller.getIntenId(intent, user);
        
//         // Prepare SolverData
//         SolverData memory solverData = SolverData({
//             solverAddress: solver,
//             v_type: IVerifier.VerificationType.v1,
//             verifierAddress: address(verifier_v1)
//         });
        
//         // Encode data
//         bytes memory originData = abi.encode(intent);
//         bytes memory fillerData = abi.encode(solverData);
        
//         // Execute the fill function (should fail due to expired intent)
//         vm.startPrank(solver);
//         vm.deal(solver, 10 ether);
//         intentFiller.fill{value: 1 ether}(intentId, originData, fillerData);
//         vm.stopPrank();
//     }
    
//     function testFail_Fill_NonWhitelistedSolver() public {
//         // Create intent data
//         IntentData memory intent = createBasicIntent();
//         intent.destination = ETH_SEPOLIA_CHAIN_ID;
        
//         // Calculate intent ID
//         bytes32 intentId = intentFiller.getIntenId(intent, user);
        
//         // Create a non-whitelisted solver
//         address nonWhitelistedSolver = makeAddr("nonWhitelistedSolver");
        
//         // Prepare SolverData with non-whitelisted solver
//         SolverData memory solverData = SolverData({
//             solverAddress: nonWhitelistedSolver,
//             v_type: IVerifier.VerificationType.v1,
//             verifierAddress: address(verifier_v1)
//         });
        
//         // Encode data
//         bytes memory originData = abi.encode(intent);
//         bytes memory fillerData = abi.encode(solverData);
        
//         // Execute the fill function (should fail due to non-whitelisted solver)
//         vm.startPrank(nonWhitelistedSolver);
//         vm.deal(nonWhitelistedSolver, 10 ether);
//         intentFiller.fill{value: 1 ether}(intentId, originData, fillerData);
//         vm.stopPrank();
//     }
    
//     function testFail_Fill_WrongChain() public {
//         // Create intent data with wrong destination chain
//         IntentData memory intent = createBasicIntent();
//         intent.destination = ARB_SEPOLIA_CHAIN_ID; // Wrong chain for the filler
        
//         // Calculate intent ID
//         bytes32 intentId = intentFiller.getIntenId(intent, user);
        
//         // Prepare SolverData
//         SolverData memory solverData = SolverData({
//             solverAddress: solver,
//             v_type: IVerifier.VerificationType.v1,
//             verifierAddress: address(verifier_v1)
//         });
        
//         // Encode data
//         bytes memory originData = abi.encode(intent);
//         bytes memory fillerData = abi.encode(solverData);
        
//         // Execute the fill function (should fail due to wrong chain)
//         vm.startPrank(solver);
//         vm.deal(solver, 10 ether);
//         intentFiller.fill{value: 1 ether}(intentId, originData, fillerData);
//         vm.stopPrank();
//     }
// } 