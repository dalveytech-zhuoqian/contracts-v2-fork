// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibAccessManaged} from "../ac/LibAccessManaged.sol";

contract FeeFacet { /* is IAccessManaged */
    // uint256 public constant FEE_RATE_PRECISION = LibFundFee.PRECISION;

    // FeeRouter for MarketLib: onlyRole(WITHDRAW_ROLE)
    function addSkipTime(uint256 start, uint256 end) external restricted {}

    function feeVaultWithdraw(address token, address to, uint256 amount) external restricted {}

    function setFundingIntervals(uint16 market, uint256 interval) external {
        FeeHandler.Storage().fundingIntervals[market] = interval;
    }

    function setConfigs(uint16 market, uint8 configType, uint256 value) external {
        FeeHandler.Storage().configs[market][configType] = value;
    }

    function setCalIntervals(uint16 market, uint256 interval) external {
        FeeHandler.Storage().calIntervals[market] = interval;
    }

    function setLastCalTimes(uint16 market, uint256 lastCalTime) external {
        FeeHandler.Storage().lastCalTimes[market] = lastCalTime;
    }

    function setCalFundingRates(uint16 market, bool isLong, int256 calFundingRate) external {
        FeeHandler.Storage().calFundingRates[market][isLong] = calFundingRate;
    }

    function setFundFeeLoss(uint16 market, uint256 loss) external {
        FeeHandler.Storage().fundFeeLoss[market] = loss;
    }

    function setFeeAndRates(uint16 market, uint8 feeType, uint256 feeAndRate) external {
        FeeHandler.Storage().feeAndRates[market][feeType] = feeAndRate;
    }
}
