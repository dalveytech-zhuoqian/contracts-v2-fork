// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library MarketHandler { /* is IOrderBook, Ac */
    bytes32 constant STORAGE_POSITION = keccak256("blex.market.storage");

    using EnumerableSet for EnumerableSet.UintSet;

    struct Props {
        bool isSuspended;
        bool allowOpen;
        bool allowClose;
        bool validDecrease;
        uint16 minSlippage;
        uint16 maxSlippage;
        uint16 minLeverage;
        uint16 maxLeverage;
        uint16 minPayment;
        uint16 minCollateral;
        uint16 decreaseNumLimit; //default: 10
        uint32 maxTradeAmount;
    }

    struct StorageStruct {
        mapping(uint16 => Props) config;
        mapping(uint16 => string) name;
        mapping(uint16 => address) vault;
        mapping(uint16 => address) token;
        mapping(uint16 => uint256) balance;
        mapping(address vault => EnumerableSet.UintSet) marketIds;
        uint16 marketIdAutoIncrease;
    }

    function vault(uint16 market) internal view returns (address) {
        return MarketHandler.Storage().vault[market];
    }

    function Storage() internal pure returns (StorageStruct storage fs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function collateralToken(uint16 market) internal view returns (address) {
        return Storage().token[market];
    }

    function getDecreaseOrderValidation(uint16 market, uint256 decrOrderCount) internal view returns (bool isValid) {
        Props storage conf = Storage().config[market];
        return conf.decreaseNumLimit >= decrOrderCount + 1;
    }
}
