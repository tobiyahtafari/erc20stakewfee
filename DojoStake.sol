// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/Staking20Base.sol";

contract DojoStake is Staking20Base {
    // Withdraw Fee and Fee Recipient
    uint256 public withdrawFee;
    address public withdrawFeeRecipient;

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
        if (withdrawFee > 0) {
            uint256 feeAmount = (_rewards * withdrawFee) / 10000;
            uint256 actualRewards = _rewards - feeAmount;

            // Mint or transfer reward tokens to the staker
            // Use a mintable ERC20 or transfer directly, based on your reward token type
            // For example: TokenERC20(rewardToken).mintTo(_staker, actualRewards);
            // or IERC20(rewardToken).transfer(_staker, actualRewards);

            // Transfer the fee to the fee recipient
            // Use a mintable ERC20 or transfer directly, based on your reward token type
            // For example: TokenERC20(rewardToken).mintTo(withdrawFeeRecipient, feeAmount);
            // or IERC20(rewardToken).transfer(withdrawFeeRecipient, feeAmount);
        } else {
            // If no withdraw fee, simply mint or transfer the reward tokens to the staker
            // Use a mintable ERC20 or transfer directly, based on your reward token type
            // For example: TokenERC20(rewardToken).mintTo(_staker, _rewards);
            // or IERC20(rewardToken).transfer(_staker, _rewards);
        }
    }
}
