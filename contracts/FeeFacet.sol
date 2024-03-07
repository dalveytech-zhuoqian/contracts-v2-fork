// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundFeeFacet { /* is IAccessManaged */
    // uint256 public constant FEE_RATE_PRECISION = LibFundFee.PRECISION;

    // FundFee
    event UpdateFundInterval(address indexed market, uint256 interval);
    event UpdateCalInterval(address indexed market, uint256 interval);
    event AddSkipTime(uint256 indexed startTime, uint256 indexed endTime);
    event UpdateConfig(uint256 index, uint256 oldFRate, uint256 newFRate);

    // FeeRouter
    event UpdateFee(address indexed account, address indexed market, int256[] fees, uint256 amount);
    event UpdateFeeAndRates(address indexed market, uint8 kind, uint256 oldFeeOrRate, uint256 feeOrRate);
    //================================================================================
    // feevault
    //================================================================================
    event FeeVaultWithdraw(address indexed token, address indexed to, uint256 amount);
    event UpdateCumulativeFundRate(address indexed market, int256 longRate, int256 shortRate);
    event UpdateFundRate(address indexed market, int256 longRate, int256 shortRate);
    event UpdateLastFundTime(address indexed market, uint256 timestamp);
    //================================================================================

    function collectFees(bytes memory data) external restricted {
        // address account,
        // address token,
        // int256[] memory fees
        // uint256 fundfeeLoss
    }
    // FeeRouter for PositionSubMgr
    function payoutFees(bytes memory data) external restricted {
        // address account,
        // address token,
        // int256[] memory fees,
        // int256 feesTotal
    }

    function updateCumulativeFundingRate(bytes memory data) external restricted {
        // uint16 market,
        // uint256 longSize,
        // uint256 shortSize
    }

    // FeeRouter for MarketLib: onlyRole(WITHDRAW_ROLE)
    function addSkipTime(uint256 start, uint256 end) external restricted {}

    function feeVaultWithdraw(address token, address to, uint256 amount) external restricted {}

    // =================================================================================
    // read only
    // =================================================================================

    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256) {}

    function feeAndRates(bytes calldata data) external view returns (bytes memory returnData) {
        // uint16 market, uint8 feeType
        // return uint256 feeAndRate
    }

    function getExecFee(uint16 market) external view returns (uint256) {}

    function getFees(bytes memory data) external view returns (int256[] memory fees) {
        // MarketDataTypes.UpdatePositionInputs memory params,
        // Position.Props memory position
    }

    function getFundingRate(uint16 market, bool isLong) external view returns (int256) {}

    function getOrderFees(bytes memory data) external view returns (int256 fees) {
        // MarketDataTypes.UpdateOrderInputs memory params
    }

    function getGlobalOpenInterest() public view returns (uint256 _globalSize) {}

    //================================================================================
    //  feevault
    //================================================================================
    function updateGlobalFundingRate(
        uint16 market,
        int256 longRate,
        int256 shortRate,
        int256 nextLongRate,
        int256 nextShortRate,
        uint256 timestamp
    ) internal {}
}
