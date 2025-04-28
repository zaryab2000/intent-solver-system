// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./interfaces/IFactsRegistry.sol";
/**
 * @title Settlement 
*/ 

contract Settlement {

    uint256 public resultValue;
    address public targetContract;
    IFactsRegistry public factsRegistry;


    constructor(address _factsRegistry, address _targetContract) {
        factsRegistry = IFactsRegistry(_factsRegistry);
        targetContract = _targetContract;
    }

    function verifyBalance(address account, uint256 blockNumber) public view returns (uint256) {
        bytes32 balanceField = factsRegistry.accountField(account, blockNumber, 1); // 1 represents BALANCE
        return uint256(balanceField);
}

    function verifyStorageSlot(address account, uint256 blockNumber, bytes32 slot) public view returns (bytes32) {
        return factsRegistry.accountStorageSlotValues(account, blockNumber, slot);
    }

    function checkVerification(
        address userAddress,
        uint256 blockNumber,
        bytes32 slotIndex,
        bytes memory storageSlotTrieProof
    ) external {
        bytes32 slot = keccak256(abi.encode(userAddress, uint256(slotIndex))); // Assuming transfers mapping is at slot 5
        
        bytes32 slotValue = factsRegistry.verifyStorage(
            targetContract,
            blockNumber,
            slot,
            storageSlotTrieProof
        );

        (address recipient, uint256 amount) = decodeSlotValue(slotValue);

        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");

        resultValue = 200; // Assuming 200 is the success code
    }

    function decodeSlotValue(bytes32 slotValue) internal pure returns (address recipient, uint256 amount) {
        // Implement decoding logic based on your data structure
        // This is a simplified example
        recipient = address(uint160(uint256(slotValue)));
        amount = uint256(slotValue) >> 160;
    }
}
