// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/Staking20Base.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";  // Import the IERC20 interface

contract DojoStake is Staking20Base {
    // Withdraw Fee and Fee Recipient
    uint256 public withdrawFee;
    address public withdrawFeeRecipient;

    // Mapping to track total staked amount for each user
    mapping(address => uint256) public totalStaked;

    constructor(
        uint80 _timeUnit,
        uint256 _rewardRatioNumerator,
        uint256 _rewardRatioDenominator,
        address _stakingToken,
        address _rewardToken,
        uint256 _withdrawFee,
        address _withdrawFeeRecipient
    )
        Staking20Base(
            _timeUnit,
            _rewardToken,
            _rewardRatioNumerator,
            _rewardRatioDenominator,
            _stakingToken,
            _rewardToken,
            _withdrawFeeRecipient
        )
    {
        // Set withdrawFee during initialization
        withdrawFee = _withdrawFee;
    }

    function initializeWithdrawFeeRecipient(address _withdrawFeeRecipient) external onlyOwner {
        withdrawFeeRecipient = _withdrawFeeRecipient;
    }

    function initializeWithdrawFee(uint256 _withdrawFee) external onlyOwner {
        withdrawFee = _withdrawFee;
    }

    // Override the _mintRewards function to implement the withdraw fee logic
    function _mintRewards(address _staker, uint256 _rewards) internal virtual override {
        address stakingTokenAddress = stakingToken;
        address rewardTokenAddress = rewardToken;

        if (withdrawFee > 0) {
            // Calculate the fee on the staked amount
            uint256 feeAmount = (totalStaked[_staker] * withdrawFee) / 10000;
            uint256 actualStakedAmount = totalStaked[_staker] - feeAmount;

            // Transfer the actual staked amount to the staker
            require(IERC20(stakingTokenAddress).transfer(_staker, actualStakedAmount), "Staked amount transfer failed");

            // Transfer the fee to the fee recipient
            require(IERC20(stakingTokenAddress).transfer(withdrawFeeRecipient, feeAmount), "Fee transfer failed");

            // Mint or transfer reward tokens to the staker
            require(IERC20(rewardTokenAddress).transfer(_staker, _rewards), "Reward transfer failed");
        } else {
            // If no withdraw fee, simply transfer the staked amount and rewards to the staker
            require(IERC20(stakingTokenAddress).transfer(_staker, totalStaked[_staker]), "Staked amount transfer failed");

            // Mint or transfer reward tokens to the staker
            require(IERC20(rewardTokenAddress).transfer(_staker, _rewards), "Reward transfer failed");
        }

        // Reset the staked amount for the user
        totalStaked[_staker] = 0;
    }
}
