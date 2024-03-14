// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarket {
    //================================================================================================
    // fee
    //================================================================================================

    function collectFees(bytes memory data) external;
    function payoutFees(bytes memory data) external;
    function updateCumulativeFundingRate(bytes memory data) external;
    function addSkipTime(uint256 start, uint256 end) external;
    function feeVaultWithdraw(address token, address to, uint256 amount) external;

    //================================================================================================
    // market
    //================================================================================================
    function increasePosition(bytes calldata) external;
    function decreasePosition(bytes calldata) external;
    function liquidatePositions(bytes calldata) external;
    function execOrderKey(bytes calldata) external;
    function isLiquidate(uint16 market, address account, bool isLong) external view;
    function getGlobalPnl() external view returns (int256);

    //================================================================================================
    // position
    //================================================================================================
    function getMarketSizes(uint16 market) external view returns (uint256, uint256);
    function getAccountSize(uint16 market, address account) external view returns (uint256, uint256);
    function getPosition(uint16 market, address account, uint256 markPrice, bool isLong)
        external
        view
        returns (bytes memory);
    function getPositions(uint16 market, address account) external view returns (bytes memory);
    function getPNL(bytes calldata data) external view returns (int256);

    //================================================================================================
    // order
    //================================================================================================
    function addOrder(bytes calldata data) external returns (bytes memory returnData);
    function updateOrder(bytes calldata data) external returns (bytes memory returnData);
    function removeOrder(bytes calldata data) external returns (bytes memory returnData);

    //================================================================================================
    function getOrderByAccount(address account) external view returns (bytes memory returnData);
    function getByIndex(uint256 index) external view returns (bytes memory returnData);
    function containsKey(bytes32 key) external view returns (bool);
    function getCount() external view returns (uint256);
    function getKey(bytes calldata data) external view returns (bytes32);
    function getKeys(bytes calldata data) external view returns (bytes32[] memory);
    function getExecutableOrdersByPrice(bytes calldata data) external view returns (bytes memory returnData);

    // =================================================================================
    // read only fee
    // =================================================================================
    function cumulativeFundingRates(uint16 market, bool isLong) external view returns (int256);
    function feeAndRates(bytes calldata data) external view returns (bytes memory returnData);
    function getExecFee(uint16 market) external view returns (uint256);
    function getFees(bytes memory data) external view returns (int256[] memory fees);
    function getFundingRate(uint16 market, bool isLong) external view returns (int256);
    function getOrderFees(bytes memory data) external view returns (int256 fees);
    function getGlobalOpenInterest() external view returns (uint256 _globalSize);
}
