interface IFactsRegistry {
    function accountField(
        address account,
        uint256 blockNumber,
        uint8 field
    ) external view returns (bytes32);

    function accountStorageSlotValues(
        address account,
        uint256 blockNumber,
        bytes32 slot
    ) external view returns (bytes32);

    function verifyStorage(
        address account,
        uint256 blockNumber,
        bytes32 slot,
        bytes memory storageSlotTrieProof
    ) external view returns (bytes32 slotValue);
}