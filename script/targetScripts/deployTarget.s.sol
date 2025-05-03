// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/Target.sol";

contract DeployTarget is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_KEY");

        vm.startBroadcast();

        // Deploy the Target contract
        Target target = new Target();

        vm.stopBroadcast();

        // Log the deployed contract address
        console.log("Target contract deployed at:", address(target));
    }
}
