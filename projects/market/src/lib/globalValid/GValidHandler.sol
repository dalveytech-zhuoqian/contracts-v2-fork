// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "../types/GDataTypes.sol";

library LibGlobalValid {
    uint256 public constant BASIS_POINTS_DIVISOR = 10 ** 18;

    bytes32 constant STORAGE_POSITION = keccak256("blex.globalvalid.storage");

    struct StorageStruct {
        uint256 maxSizeLimit;
        uint256 maxNetSizeLimit;
        uint256 maxUserNetSizeLimit;
        mapping(uint16 => uint256) maxMarketSizeLimit;
    }

    function Storage() internal pure returns (StorageStruct storage fs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function setMaxSizeLimit(uint256 limit) external {
        require(limit > 0 && limit <= BASIS_POINTS_DIVISOR, "GlobalValid:!params");
        Storage().maxSizeLimit = limit;
    }

    function setMaxNetSizeLimit(uint256 limit) external {
        require(limit > 0 && limit <= BASIS_POINTS_DIVISOR, "GlobalValid:!params");
        Storage().maxNetSizeLimit = limit;
    }

    function setMaxUserNetSizeLimit(uint256 limit) external {
        require(limit > 0 && limit <= BASIS_POINTS_DIVISOR, "GlobalValid:!params");
        Storage().maxUserNetSizeLimit = limit;
    }

    function setMaxMarketSizeLimit(uint16 market, uint256 limit) external {
        Storage().maxMarketSizeLimit[market] = limit;
    }

    function maxSizeLimit() internal view returns (uint256) {
        uint256 m = Storage().maxSizeLimit;
        return m == 0 ? BASIS_POINTS_DIVISOR : m;
    }

    function maxNetSizeLimit() internal view returns (uint256) {
        uint256 m = Storage().maxNetSizeLimit;
        return m == 0 ? BASIS_POINTS_DIVISOR : m;
    }

    function maxUserNetSizeLimit() internal view returns (uint256) {
        uint256 m = Storage().maxUserNetSizeLimit;
        return m == 0 ? BASIS_POINTS_DIVISOR : m;
    }

    function maxMarketSizeLimit(uint16 market) internal view returns (uint256) {
        uint256 m = Storage().maxMarketSizeLimit[market];
        return m == 0 ? BASIS_POINTS_DIVISOR : m;
    }

    /**
     * @dev Checks if the position should be increased.
     * @param params The ValidParams struct containing the valid parameters.
     * @return A boolean indicating whether the position should be increased.
     */
    function isIncreasePosition(GlobalDataTypes.ValidParams memory params) internal view returns (bool) {
        if (params.sizeDelta == 0) {
            return true;
        }

        uint256 _max = _getMaxIncreasePositionSize(params);

        /**
         * @dev Checks if the maximum increase in position size is greater than or equal to sizeDelta.
         * @return A boolean indicating whether the maximum increase in position size is satisfied.
         */
        return (_max >= params.sizeDelta);
    }

    /**
     * @dev Retrieves the maximum increase in position size.
     * @param params The ValidParams struct containing the valid parameters.
     * @return The maximum increase in position size as a uint256 value.
     */
    function getMaxIncreasePositionSize(GlobalDataTypes.ValidParams memory params) internal view returns (uint256) {
        return _getMaxIncreasePositionSize(params);
    }

    /**
     * @dev Retrieves the maximum increase in position size based on the provided parameters.
     * @param params The ValidParams struct containing the valid parameters.
     * @return The maximum increase in position size as a uint256 value.
     */
    function _getMaxIncreasePositionSize(GlobalDataTypes.ValidParams memory params) private view returns (uint256) {
        uint256 _min =
            _getMaxUseableGlobalSize(params.globalLongSizes, params.globalShortSizes, params.aum, params.isLong);
        if (_min == 0) return 0;

        uint256 _tmp = _getMaxUseableNetSize(params.globalLongSizes, params.globalShortSizes, params.aum, params.isLong);
        if (_tmp == 0) return 0;

        if (_tmp < _min) _min = _tmp;

        _tmp = _getMaxUseableUserNetSize(params.userLongSizes, params.userShortSizes, params.aum, params.isLong);
        if (_tmp == 0) return 0;

        if (_tmp < _min) _min = _tmp;

        _tmp = _getMaxUseableMarketSize(params.market, params.isLong, params.marketLongSizes, params.marketShortSizes);
        if (_tmp < _min) _min = _tmp;

        return _min;
    }

    /**
     * @dev Calculates the maximum usable global position size based on the provided parameters.
     * @param longSize The current long position size.
     * @param shortSize The current short position size.
     * @param isLong A boolean indicating whether the position is long (true) or short (false).
     * @return The maximum usable global position size as a uint256 value.
     */
    function _getMaxUseableGlobalSize(uint256 longSize, uint256 shortSize, uint256 aum, bool isLong)
        private
        view
        returns (uint256)
    {
        uint256 _size = isLong ? longSize : shortSize;
        uint256 _limit = (aum * maxSizeLimit()) / BASIS_POINTS_DIVISOR;
        if (_size >= _limit) return 0;
        return (_limit - _size);
    }

    /**
     * @dev Calculates the maximum usable net position size based on the provided parameters.
     * @param longSize The current long position size.
     * @param shortSize The current short position size.
     * @return The maximum usable net position size as a uint256 value.
     */
    function _getMaxUseableNetSize(uint256 longSize, uint256 shortSize, uint256 aum, bool isLong)
        private
        view
        returns (uint256)
    {
        uint256 _size = isLong ? longSize : shortSize;

        uint256 _limit = (aum * maxNetSizeLimit()) / BASIS_POINTS_DIVISOR;
        _limit = isLong ? _limit + shortSize : _limit + longSize;

        if (_size >= _limit) return 0;
        return (_limit - _size);
    }

    /**
     * @dev Calculates the maximum usable net position size for the user based on the provided parameters.
     * @param longSize The user's current long position size.
     * @param shortSize The user's current short position size.
     * @return The maximum usable net position size for the user as a uint256 value.
     */
    function _getMaxUseableUserNetSize(uint256 longSize, uint256 shortSize, uint256 aum, bool isLong)
        private
        view
        returns (uint256)
    {
        uint256 _size = isLong ? longSize : shortSize;

        uint256 _limit = (aum * maxUserNetSizeLimit()) / BASIS_POINTS_DIVISOR;
        _limit = isLong ? _limit + shortSize : _limit + longSize;

        if (_size >= _limit) return 0;
        return (_limit - _size);
    }

    /**
     * @dev Calculates the maximum usable market position size based on the provided parameters.
     * @param market The address of the market.
     * @param isLong A boolean indicating whether the position is long (true) or short (false).
     * @param longSize The current long position size.
     * @param shortSize The current short position size.
     * @return The maximum usable market position size as a uint256 value.
     */
    function _getMaxUseableMarketSize(uint16 market, bool isLong, uint256 longSize, uint256 shortSize)
        private
        view
        returns (uint256)
    {
        uint256 _limit = maxMarketSizeLimit(market);
        uint256 _size = isLong ? longSize : shortSize;

        if (_size >= _limit) return 0;

        return (_limit - _size);
    }
}
