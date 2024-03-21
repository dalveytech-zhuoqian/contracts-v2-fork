// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {IPositionBook} from "../position/IPositionBook.sol";
import {IFeeRouter} from "../fee/IFeeRouter.sol";
import {IOrderBook} from "../order/IOrderBook.sol";

interface IMarket {
    struct OrderExec {
        address market;
        address account;
        uint64 orderID;
        bool isIncrease;
        bool isLong;
    }

    function updateCumulativeFundingRate() external;

    function marketValid() external view returns (address);

    function globalValid() external view returns (address);

    function marketRouter() external view returns (address);

    function indexToken() external view returns (address);

    function positionBook() external view returns (IPositionBook); // slot 2

    function collateralToken() external view returns (address);

    function feeRouter() external view returns (IFeeRouter); // slot 2

    function priceFeed() external view returns (address); // slot 2

    function positionStoreLong() external view returns (address); // slot 2

    function positionStoreShort() external view returns (address); // slot 2

    function vaultRouter() external view returns (address); // slot 2

    function orderBookLong() external view returns (IOrderBook); // slot 2

    function orderBookShort() external view returns (IOrderBook); // slot 2

    function cancelOrderList(
        address _account,
        bool[] memory _isIncreaseList,
        uint256[] memory _orderIDList,
        bool[] memory _isLongList
    ) external;
}
