// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarket {
    //================================================================================================
    // market
    //================================================================================================
    function increasePosition(bytes calldata) external;
    function decreasePosition(bytes calldata) external;
    function liquidatePositions(bytes calldata) external;
    function execOrderKey(bytes calldata) external;
    function isLiquidate(uint16 market, address account, bool isLong) external view;

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
}
