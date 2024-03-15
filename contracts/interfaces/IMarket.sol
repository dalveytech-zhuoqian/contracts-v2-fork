// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarket {
    //================================================================================================
    // market view only
    //================================================================================================

    function getGlobalPnl(uint16[] memory markets) external view returns (int256);
    function getGlobalOpenInterest() external view returns (uint256 _globalSize);
    function availableLiquidity(address market, address account, bool isLong) external view returns (uint256);

    // =================================================================================
    // fee view only
    // =================================================================================

    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256);
    function feeAndRates(bytes calldata data) external view returns (bytes memory returnData);
    function getExecFee(uint16 market) external view returns (uint256);
    function getFees(bytes memory data) external view returns (int256[] memory fees);
    function getFundingRate(uint16 market, bool isLong) external view returns (int256);
    function getOrderFees(bytes memory data) external view returns (int256 fees);

    //================================================================================================
    // position view only
    //================================================================================================

    function getAccountSize(uint16 market, address account) external view returns (uint256, uint256);
    function getPositionsWithFees(address account) external view returns (bytes memory);
    function getPositions() external view returns (bytes memory);
    function getPositions(uint16 market) external view returns (bytes memory);
    function getPositions(address account) external view returns (bytes memory);
    function getPositions(uint16 market, address account) external view returns (bytes memory);
    function getPosition(uint16 market, address account, bool isLong, uint256 markPrice)
        external
        view
        returns (bytes memory);
    function getPositionCount(uint16 market, bool isLong) external view returns (uint256);
    function getPositionKeys(uint16 market, uint256 start, uint256 end, bool isLong) external view returns (uint256);
    function getPNL(uint16 market, address account, uint256 sizeDelta, uint256 markPrice, bool isLong)
        external
        view
        returns (int256);

    // TODO 不明确
    function getMarketPNL(uint16 market, uint256 longPrice, uint256 shortPrice) external view returns (int256);
    function getMarketSizes(uint16 market) external view returns (uint256, uint256);

    //================================================================================================
    // order view only
    //================================================================================================

    function getOrderByAccount(address account) external view returns (bytes memory returnData);
    function getByIndex(uint256 index) external view returns (bytes memory returnData);
    function containsKey(bytes32 key) external view returns (bool);
    function getCount() external view returns (uint256);
    function getKey(bytes calldata data) external view returns (bytes32);
    function getKeys(bytes calldata data) external view returns (bytes32[] memory);
    function getExecutableOrdersByPrice(bytes calldata data) external view returns (bytes memory returnData);

    //================================================================================================
    // order actions
    //================================================================================================

    function addOrder(bytes calldata data) external returns (bytes memory returnData);
    function updateOrder(bytes calldata data) external returns (bytes memory returnData);
    function removeOrder(bytes calldata data) external returns (bytes memory returnData);

    //================================================================================================
    // fee actions
    //================================================================================================

    function addSkipTime(uint256 start, uint256 end) external;
    function feeVaultWithdraw(address token, address to, uint256 amount) external;

    //================================================================================================
    // market actions
    //================================================================================================

    function liquidatePositions(bytes calldata) external;
    function execOrder(bytes calldata) external;
    function isLiquidate(uint16 market, address account, bool isLong) external view;
}
