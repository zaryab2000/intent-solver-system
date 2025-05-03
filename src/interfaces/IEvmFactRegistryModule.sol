interface IEvmFactRegistryModule {
    /// @notice Returns nonce, balance, storage root or code hash of a given account, at a given block number and chainId
    //function accountField(uint256 chainId, address account, uint256 blockNumber, AccountField field) external view returns (bytes32);

    /// @notice Returns value of a given storage slot of a given account, at a given block number and chainId
    function storageSlot(uint256 chainId, address account, uint256 blockNumber, bytes32 slot)
        external
        view
        returns (bytes32);

    /// @notice Returns block number of the closest block with timestamp less than or equal to the given timestamp
    function timestamp(uint256 chainId, uint256 timestamp) external view returns (uint256);
}
