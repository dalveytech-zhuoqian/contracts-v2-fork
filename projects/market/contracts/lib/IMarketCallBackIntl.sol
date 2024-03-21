// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface MarketCallBackIntl {
    struct Calls {
        bool updatePosition;
        bool updateOrder;
        bool deleteOrder;
    }

    function getHooksCalls() external pure returns (Calls memory);
}

interface MarketPositionCallBackIntl is MarketCallBackIntl {
    function updatePositionCallback(bytes calldata) external;
}

interface MarketOrderCallBackIntl is MarketCallBackIntl {
    //=====================================
    //      UPDATE ORDER
    //=====================================
    function updateOrderCallback(bytes calldata) external;
    function deleteOrderCallback(bytes calldata) external;
}
