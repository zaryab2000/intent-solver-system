// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/Target.sol";

contract VerifyTarget is Script {
    Target targetContract; // Reference to the deployed Target contract

    address userAddress = vm.envAddress("USER_ADDRESS");
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");
    address targetContractAddress = vm.envAddress("TARGET");

    function setUp() public {
        // Initialize the deployed Target contract
        targetContract = Target(targetContractAddress); // Replace with the deployed contract address
    }

    function run() public {
        vm.startBroadcast();

        // Check the initial value of valueLockedNative for the user
        uint256 initialBalance = targetContract.valueLockedNative(userAddress);
        console.log("Initial valueLockedNative for user:", initialBalance);

        // Call the lockNativeToken() function with 0.1 ETHER
        targetContract.lockNativeToken{value: 0.1 ether}(userAddress);
        targetContract.updateValue(123);

        // Check the updated value of valueLockedNative for the user
        uint256 updatedBalance = targetContract.valueLockedNative(userAddress);
        console.log("Updated valueLockedNative for user:", updatedBalance);

        vm.stopBroadcast();
    }
}
