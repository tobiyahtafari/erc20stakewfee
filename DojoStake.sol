// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@thirdweb-dev/contracts/base/Staking20Base.sol";
import "@thirdweb-dev/contracts/eip/interface/IERC20.sol";  // Import the IERC20 interface

contract DojoStake is Staking20Base {
    using SafeMath for uint256;

    // Withdraw Fee and Fee Recipient
    uint256 public withdrawFee;
    address public withdrawFeeRecipient;

    // Mapping to track total staked amount for each user
    mapping(address => uint256) public totalStakedByUser;

    // Event emitters
    event Withdrawal(address indexed staker, uint256 amount);
    event FeePaid(address indexed staker, uint256 feeAmount);
    event RewardsMinted(address indexed staker, uint256 rewards);

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
        require(_withdrawFeeRecipient != address(0), "Invalid address");
        withdrawFeeRecipient = _withdrawFeeRecipient;
    }

    function initializeWithdrawFee(uint256 _withdrawFee) external onlyOwner {
        // Ensure the withdrawal fee is within a reasonable range
        require(_withdrawFee <= 10000, "Invalid withdrawal fee");
        withdrawFee = _withdrawFee;
    }

    // Override the _mintRewards function to implement the withdraw fee logic
    function _mintRewards(address _staker, uint256 _rewards) internal virtual override {
        address stakingTokenAddress = stakingToken;
        address rewardTokenAddress = rewardToken;

        if (withdrawFee > 0) {
            // Calculate the fee on the staked amount using SafeMath
            uint256 feeAmount = totalStakedByUser[_staker].mul(withdrawFee).div(10000);
            uint256 actualStakedAmount = totalStakedByUser[_staker].sub(feeAmount);

            // Transfer the actual staked amount to the staker
            require(IERC20(stakingTokenAddress).transfer(_staker, actualStakedAmount), "Staked amount transfer failed");
            emit Withdrawal(_staker, actualStakedAmount);

            // Transfer the fee to the fee recipient
            require(IERC20(stakingTokenAddress).transfer(withdrawFeeRecipient, feeAmount), "Fee transfer failed");
            emit FeePaid(_staker, feeAmount);

            // Mint or transfer reward tokens to the staker
            require(IERC20(rewardTokenAddress).transfer(_staker, _rewards), "Reward transfer failed");
            emit RewardsMinted(_staker, _rewards);
        } else {
            // If no withdraw fee, simply transfer the staked amount and rewards to the staker
            require(IERC20(stakingTokenAddress).transfer(_staker, totalStakedByUser[_staker]), "Staked amount transfer failed");
            emit Withdrawal(_staker, totalStakedByUser[_staker]);

            // Mint or transfer reward tokens to the staker
            require(IERC20(rewardTokenAddress).transfer(_staker, _rewards), "Reward transfer failed");
            emit RewardsMinted(_staker, _rewards);
        }

        // Reset the staked amount for the user
        totalStakedByUser[_staker] = 0;
    }
}
