// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Target {
    uint256 public value;
    mapping(address => uint256) public valueLockedNative;
    mapping(address => uint256) public valueLockedToken;

    // events
    event ValueUpdate(uint256 oldValue, uint256 newValue);
    event ValueLockedNative(address indexed user, uint256 amount);
    event ValueLockedToken(address indexed user, uint256 amount);

    function updateValue(uint256 _val) external {
        uint256 _oldValue = value;
        value = _val;

        emit ValueUpdate(_oldValue, value);
    }

    function lockNativeToken(address _user) external payable {
        require(_user != address(0), "User address cannot be zero");
        require(msg.value > 0, "Value must be greater than 0");
        valueLockedNative[_user] += msg.value;

        emit ValueLockedNative(_user, msg.value);
    }

    function lockToken(address _user, uint256 _amount, address _token) external {
        require(_user != address(0), "User address cannot be zero");
        require(_amount > 0, "Value must be greater than 0");
        require(_token != address(0), "Token address cannot be zero");

        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), _amount);
        valueLockedNative[_user] += _amount;

        emit ValueLockedToken(_user, _amount);
    }
}
