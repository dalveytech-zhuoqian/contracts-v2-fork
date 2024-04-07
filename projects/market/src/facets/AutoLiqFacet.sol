// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
// import {IPrice} from "../interfaces/IPrice.sol";
// import {IPositionFacet} from "../interfaces/IPositionFacet.sol";
// // import {IMarket} from "../market/interfaces/IMarket.sol";
// // import {IMarketValid} from "./../market/interfaces/IMarketValid.sol";
// import "../lib/types/Types.sol";

// contract AutoLiq is AutomationCompatibleInterface {
//     function getPrice(uint16 market, bool isLong) private view returns (uint256) {
//         return IPrice(address(this)).getPrice(market, !isLong);
//     }

//     function checkUpkeep2(uint16 market, bool isLong) private view returns (address[] memory accountsForLiquidate) {
//         address[] memory accounts = IPositionFacet(address(this)).getPositionKeys(0, 9999, isLong);
//         address[] memory liqList = new address[](accounts.length);
//         uint256 liqCount;
//         uint256 i;
//         for (; i < accounts.length; i++) {
//             LiquidationState liqState =
//                 IPositionFacet(address(this)).isLiquidate(accounts[i], market, isLong, getPrice(market, isLong));
//             if (liqState == LiquidationState.None) continue;
//             liqList[liqCount] = accounts[i];
//             liqCount++;
//         }

//         accountsForLiquidate = new address[](liqCount);
//         for (i = 0; i < liqCount; i++) {
//             accountsForLiquidate[i] = liqList[i];
//         }
//     }

//     function checkUpkeep(bytes memory checkData)
//         external
//         view
//         override
//         returns (bool upkeepNeeded, bytes memory performData)
//     {
//         uint16 market = abi.decode(checkData, (address));
//         address[] memory retLong = checkUpkeep2(market, true);
//         address[] memory retShort = checkUpkeep2(market, false);
//         if (retLong.length + retShort.length == 0) return (false, performData);
//         return (true, abi.encode(market, retLong, retShort));
//     }

//     function performUpkeep(bytes memory performData) external override {
//         (uint16 market, address[] memory retLong, address[] memory retShort) =
//             abi.decode(performData, (address, address[], address[]));
//         if (retLong.length > 0) {
//             IMarket(market).liquidatePositions(retLong, true);
//         }
//         if (retShort.length > 0) {
//             IMarket(market).liquidatePositions(retShort, false);
//         }
//     }
// }
