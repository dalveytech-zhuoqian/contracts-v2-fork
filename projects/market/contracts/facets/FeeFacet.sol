// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {FeeHandler} from "../lib/fee/FeeHandler.sol";
import {BalanceHandler} from "../lib/balance/BalanceHandler.sol";
import {MarketHandler} from "../lib/market/MarketHandler.sol";

contract FeeFacet is IAccessManaged {
    // uint256 public constant FEE_RATE_PRECISION = LibFundFee.PRECISION;

    function initFeeFacet(uint16 market) external restricted {
        FeeHandler.initialize(market);
    }

    function collectFees(bytes calldata _data) external restricted {
        (address account, address token, int256[] memory fees, uint256 fundfeeLoss, uint16 market) =
            abi.decode(_data, (address, address, int256[], uint256, uint16));
        FeeHandler.collectFees(market, account, token, fees, fundfeeLoss);
    }

    function addSkipTime(uint16 market, uint256 start, uint256 end) external restricted {
        // FeeHandler.addSkipTime(market, start, end);
    }

    function feeVaultWithdraw(uint16 market, address to, uint256 amount) external restricted {
        address token = MarketHandler.Storage().token[market];
        BalanceHandler.feeToReward(token, market, to, amount);
    }

    function setFundingIntervals(uint16 market, uint256 interval) external restricted {
        FeeHandler.Storage().fundingIntervals[market] = interval;
    }

    function setConfigs(uint16 market, uint8 configType, uint256 value) external restricted {
        FeeHandler.Storage().configs[market][configType] = value;
    }

    function setCalIntervals(uint16 market, uint256 interval) external restricted {
        FeeHandler.Storage().calIntervals[market] = interval;
    }

    function setLastCalTimes(uint16 market, uint256 lastCalTime) external restricted {
        FeeHandler.Storage().lastCalTimes[market] = lastCalTime;
    }

    function setCalFundingRates(uint16 market, bool isLong, int256 calFundingRate) external restricted {
        FeeHandler.Storage().calFundingRates[market][isLong] = calFundingRate;
    }

    function setFundFeeLoss(uint16 market, uint256 loss) external restricted {
        FeeHandler.Storage().fundFeeLoss[market] = loss;
    }

    function setFeeAndRates(uint16 market, uint8 feeType, uint256 feeAndRate) external restricted {
        FeeHandler.Storage().feeAndRates[market][feeType] = feeAndRate;
    }
}
