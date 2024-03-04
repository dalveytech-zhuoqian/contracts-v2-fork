// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract FundFeeFacet /* is IAccessManaged */ {

    // uint256 public constant FEE_RATE_PRECISION = LibFundFee.PRECISION;

    // FundFee
    event UpdateFundInterval(address indexed market, uint256 interval);
    event UpdateCalInterval(address indexed market, uint256 interval);
    event AddSkipTime(uint256 indexed startTime, uint256 indexed endTime);
    event UpdateConfig(uint256 index, uint256 oldFRate, uint256 newFRate);

    // FeeRouter
    event UpdateFee(address indexed account, address indexed market, int256[] fees, uint256 amount);
    event UpdateFeeAndRates(address indexed market, uint8 kind, uint256 oldFeeOrRate, uint256 feeOrRate);

    function collectFees(
        address account,
        address token,
        int256[] memory fees
    ) external restricted {
    }

    function collectFees(
        address account,
        address token,
        int256[] memory fees,
        uint256 fundfeeLoss
    ) external restricted {
    }
 
    function cumulativeFundingRates(
        address market,
        bool isLong
    ) external view returns (int256) {
    }

    function feeAndRates(address market, uint8 feeType) external view returns (uint256 feeAndRate){
    }

 
    function getExecFee(address market) external view returns (uint256) {
    }
 
    function getFees(
        MarketDataTypes.UpdatePositionInputs memory params,
        Position.Props memory position
    ) external view returns (int256[] memory fees) {
    } 

    function getFundingRate(
        address market,
        bool isLong
    ) external view returns (int256) {
    }

 
    function getOrderFees(
        MarketDataTypes.UpdateOrderInputs memory params
    ) external view returns (int256 fees) {
    }

    // FeeRouter for PositionSubMgr
    function payoutFees(
        address account,
        address token,
        int256[] memory fees,
        int256 feesTotal
    ) external restricted {
    }
 
    function updateCumulativeFundingRate(
        address market,
        uint256 longSize,
        uint256 shortSize
    ) external restricted {
    }

    // FeeRouter for MarketLib: onlyRole(WITHDRAW_ROLE)
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external restricted {
    }
  
    function addSkipTime(uint256 start, uint256 end) external restricted {
    }

    function getGlobalOpenInterest() public view returns (uint256 _globalSize) {
    }

    //================================================================================
    // 原来的 feevault
    //================================================================================
    event FeeVaultWithdraw(address indexed token, address indexed to, uint256 amount);
    event UpdateCumulativeFundRate(
        address indexed market,
        int256 longRate,
        int256 shortRate
    );
    event UpdateFundRate(
        address indexed market,
        int256 longRate,
        int256 shortRate
    );
    event UpdateLastFundTime(address indexed market, uint256 timestamp);
    function feeVaultWithdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyRole(WITHDRAW_ROLE) {
    }
    function updateGlobalFundingRate(
        address market,
        int256 longRate,
        int256 shortRate,
        int256 nextLongRate,
        int256 nextShortRate,
        uint256 timestamp
    ) internal { 
    }

}
 