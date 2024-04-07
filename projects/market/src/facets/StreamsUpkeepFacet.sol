// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import {Log} from "chainlink_8_contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
// // import {IMarket} from "../interfaces/market/IMarket.sol";
// import {StreamsUpkeepBase} from "./StreamsUpkeepBase.sol";
// import {AMLib} from "./AMLib.sol";
// import {Order} from "../interfaces/order/OrderStruct.sol";
// import {MarketDataTypes} from "../interfaces/market/MarketDataTypes.sol";
// import {AutomationCompatibleInterface} from
//     "chainlink_8_contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

// contract OrderLiqStreamsUpkeep is StreamsUpkeepBase {
//     // ==================================sepolia checkdata eth==================================
//     // market: 0xd9CD2FEAF3453d8cA9b26E1F17F583b414B4A2b8
//     // checkData: 0x000000000000000000000000d9cd2feaf3453d8ca9b26e1f17f583b414b4a2b8

//     // ==================================Event ABI==================================
//     /**
//      * {
//      *     "anonymous": false,
//      *     "inputs": [
//      *     {
//      *         "indexed": true,
//      *         "internalType": "int256",
//      *         "name": "current",
//      *         "type": "int256"
//      *     },
//      *     {
//      *         "indexed": true,
//      *         "internalType": "uint256",
//      *         "name": "roundId",
//      *         "type": "uint256"
//      *     },
//      *     {
//      *         "indexed": false,
//      *         "internalType": "uint256",
//      *         "name": "updatedAt",
//      *         "type": "uint256"
//      *     }
//      *     ],
//      *     "name": "AnswerUpdated",
//      *     "type": "event"
//      * }
//      */

//     /**
//      * @dev Checks the log for upkeep necessity based on provided data.
//      * @param log The Log struct containing relevant data.(AnswerUpdated(int256 indexed answer, etc...))
//      * @param checkData The data for market address (fill in the market address, isLong, lower, upper).
//      * @return upkeepNeeded A boolean indicating if upkeep is needed.
//      * @return performData The data required for performing upkeep.
//      */
//     function checkLog(Log calldata log, bytes memory checkData)
//         external
//         override
//         returns (bool, /* upkeepNeeded */ bytes memory /* performData */ )
//     {
//         CheckCallbackCache memory c;
//         (c.market) = abi.decode(checkData, (address));
//         if (log.source == address(this)) c.logType = uint8(LogType.MarketLog);
//         else c.logType = logType[log.source];
//         string[] memory _feedIds = new string[](1);
//         _feedIds[0] = feedId[c.market];
//         c.logData = log.data;

//         revert StreamsLookup(
//             DATASTREAMS_FEEDLABEL, //feedParamKey
//             _feedIds, //feeds
//             DATASTREAMS_QUERYLABEL, //timeParamKey
//             log.timestamp, //time
//             abi.encode(c)
//         );
//     }

//     function getPrice(int192 price, address market, bool isMax, bool isUSDT) public view returns (uint256 myPrice) {
//         if (!isUSDT) myPrice = convertToUSDTPrice(market, formatPrice(price, market));
//         else myPrice = formatPrice(price, market);
//         uint256 chainPrice = AMLib.cp(market).getPrice(IMarket(market).indexToken(), isMax);
//         if (isMax == (myPrice < chainPrice)) myPrice = chainPrice;
//     }

//     function _checkCallbackOrders(
//         int192 priceOffChain, // DON 共识中位数价格，保留 8 位小数
//         address market,
//         bool isUSDT
//     ) internal view returns (bool upkeepNeeded, bytes memory results) {
//         for (uint256 isLong = 0; isLong < 2; isLong++) {
//             for (uint256 isIncrease = 0; isIncrease < 2; isIncrease++) {
//                 uint256 myPrice;
//                 myPrice = getPrice(priceOffChain, market, isLong == isIncrease, isUSDT);
//                 Order.Props[] memory execOrders = (
//                     isLong == 1 ? IMarket(market).orderBookLong() : IMarket(market).orderBookShort()
//                 ).getExecutableOrdersByPrice(LOWER, UPPER, isIncrease == 1, myPrice);

//                 if (execOrders.length > 0) {
//                     bytes32[] memory keys = new bytes32[](1);
//                     keys[0] = keccak256(abi.encodePacked(execOrders[0].account, execOrders[0].orderID));
//                     return (true, abi.encode(IMarket(market), isLong == 1, isIncrease == 1, keys));
//                 }
//             }
//         }
//     }

//     function checkCallbackByPrice(int192 priceOffChain, address market)
//         external
//         view
//         returns (bool upkeepNeeded, bytes memory performData)
//     {
//         (upkeepNeeded, performData) = _checkCallbackOrders(priceOffChain, market, true);
//         if (!upkeepNeeded) return _checkCallbackLiq(priceOffChain, market, true);
//     }

//     function checkCallbackLiq(
//         uint256 priceOffChain, // DON 共识中位数价格，保留 8 位小数
//         address market
//     ) public view returns (bool upkeepNeeded, bytes memory performData) {
//         (upkeepNeeded, performData) = _checkCallbackOrders(int192(uint192(priceOffChain)), market, true);
//         if (!upkeepNeeded) return _checkCallbackLiq(int192(uint192(priceOffChain)), market, true);
//         // return _checkCallbackLiq(int192(uint192(priceOffChain)), market);
//     }

//     function _checkCallbackLiq(int192 priceOffChain, address market, bool isUSDT)
//         internal
//         view
//         returns (bool upkeepNeeded, bytes memory)
//     {
//         address[] memory empty = new address[](0);
//         address[] memory _keysOut = new address[](1);
//         for (uint256 isLong = 0; isLong < 2; isLong++) {
//             // Get the position keys from the market
//             address[] memory _keys = IPositionFacet(address(this)).getPositionKeys(LOWER, UPPER, isLong == 1);
//             uint256 price = getPrice(priceOffChain, market, isLong == 0, isUSDT);
//             // Iterate through the position keys to check liquidation status
//             for (uint256 i; i < _keys.length; i++) {
//                 // Check if the position should be liquidated
//                 uint256 state = _isLiquidate(_keys[i], market, isLong == 1, price);
//                 if (state != 0) {
//                     _keysOut[0] = _keys[i];
//                     if (isLong == 1) return (true, abi.encode(market, _keysOut, empty));
//                     else return (true, abi.encode(market, empty, _keys[i]));
//                 }
//             }
//         }
//     }

//     /**
//      * @dev Function to check callback data and trigger upkeep.
//      * @param signedReports Array of signed reports.
//      * @param extraData Extra data from checkLog.
//      * @return upkeepNeeded Boolean indicating if upkeep is needed.
//      * @return performData Bytes containing perform data if upkeep is needed.
//      */
//     function checkCallback(
//         bytes[] calldata signedReports, //signedReports
//         bytes calldata extraData //extraData from checkLog
//     ) external view override returns (bool upkeepNeeded, bytes memory performData) {
//         BasicReport memory mockVerifiedReport = abi.decode(
//             mockVerify(signedReports[0]), // Verify the first signed report
//             (BasicReport)
//         );
//         CheckCallbackCache memory c = abi.decode(
//             extraData, // Decode extraData
//             (CheckCallbackCache)
//         );

//         bytes memory r;
//         address target = address(0);
//         if (c.logType == uint8(LogType.MarketLog)) {
//             MarketDataTypes.UpdateOrderInputs memory ip = abi.decode(
//                 c.logData,
//                 (MarketDataTypes.UpdateOrderInputs) //params
//             );

//             upkeepNeeded = MarketDataTypes.isFromMarket(ip);
//             if (upkeepNeeded) {
//                 IMarket.OrderExec[] memory _l = new IMarket.OrderExec[](1);
//                 _l[0] = IMarket.OrderExec(ip._market, ip._order.account, ip._order.orderID, ip.isOpen, ip._isLong);
//                 r = abi.encode(_l);
//             }
//         } else {
//             target = autoLiq;
//             (upkeepNeeded, r) = _checkCallbackOrders(mockVerifiedReport.price, c.market, false);
//             if (!upkeepNeeded) {
//                 (upkeepNeeded, r) = _checkCallbackLiq(mockVerifiedReport.price, c.market, false);
//             } else {
//                 target = autoOrder;
//             }
//         }
//         performData = abi.encode(signedReports, c.market, c.logType, r, target);
//     }

//     function performUpkeep(bytes calldata performData) external override {
//         (bytes[] memory signedReports, address market, uint8 lType, bytes memory r, address target) =
//             abi.decode(performData, (bytes[], address, uint8, bytes, address));

//         bytes memory unverifiedReport = signedReports[0];
//         BasicReport memory verifiedReport = verifyReport(unverifiedReport, verifier[market]);
//         // BasicReport memory verifiedReport = abi.decode(mockVerify(unverifiedReport), (BasicReport));

//         if (lType == uint8(LogType.MarketLog)) {
//             if (shouldExec) {
//                 //mkt odr
//                 IMarket.OrderExec[] memory ol = abi.decode(r, (IMarket.OrderExec[]));
//                 try AMLib.fp(market).setPricesAndExecute(
//                     IMarket(market).indexToken(),
//                     getPriceWithUSDT(market, verifiedReport),
//                     uint256(verifiedReport.observationsTimestamp),
//                     ol
//                 ) {} catch {}
//             } else {
//                 setPriceWithUSDT(market, verifiedReport);
//             }
//         } else {
//             setPriceWithUSDT(market, verifiedReport);
//             if (shouldExec) try AutomationCompatibleInterface(target).performUpkeep(r) {} catch {}
//         }
//     }
// }
