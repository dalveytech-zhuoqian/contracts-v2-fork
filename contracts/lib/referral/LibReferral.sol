// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "./interfaces/IReferral.sol";
// import "./../ac/AcUpgradable.sol";
// import {MarketPositionCallBackIntl, MarketCallBackIntl} from "../market/interfaces/IMarketCallBackIntl.sol";
// import "../fee/lib/FeeRouterLib.sol";

library LibReferral {
    bytes32 constant STORAGE_POSITION = keccak256("blex.referral.storage");

    struct Tier {
        uint256 totalRebate; // e.g. 2400 for 24%
        uint256 discountShare; // 5000 for 50%/50%, 7000 for 30% rebates/70% discount
    }

    uint256 constant BASIS_POINTS = 10000;
    bytes32 constant DEFAULT_CODE = bytes32("dei");

    struct StorageStruct {
        mapping(address => uint256) referrerDiscountShares; // to  default value in tier
        mapping(address => uint256) referrerTiers; // link between user <> tier
        mapping(uint256 => Tier) tiers;
        mapping(bytes32 => address) codeOwners;
        mapping(address => bytes32) traderReferralCodes;
    }

    event SetTraderReferralCode(address account, bytes32 code);
    event SetTraderReferralCode(address account, address inviter, bytes32 code);
    event SetTier(uint256 tierId, uint256 totalRebate, uint256 discountShare);
    event SetReferrerTier(address referrer, uint256 tierId);
    event SetReferrerDiscountShare(address referrer, uint256 discountShare);
    event RegisterCode(address account, bytes32 code);
    event SetCodeOwner(address account, address newAccount, bytes32 code);
    event GovSetCodeOwner(bytes32 code, address newAccount);

    event IncreasePositionReferral(
        address account, uint256 sizeDelta, uint256 marginFeeBasisPoints, bytes32 referralCode, address referrer
    );

    event DecreasePositionReferral(
        address account, uint256 sizeDelta, uint256 marginFeeBasisPoints, bytes32 referralCode, address referrer
    );

    function Storage() public {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function setTier(uint256 _tierId, uint256 _totalRebate, uint256 _discountShare) external {
        require(_totalRebate <= BASIS_POINTS, "Referral: invalid totalRebate");
        require(_discountShare <= BASIS_POINTS, "Referral: invalid discountShare");

        Tier memory tier = tiers[_tierId];
        tier.totalRebate = _totalRebate;
        tier.discountShare = _discountShare;
        tiers[_tierId] = tier;
        emit SetTier(_tierId, _totalRebate, _discountShare);
    }

    function setReferrerTier(address _referrer, uint256 _tierId) external {
        referrerTiers[_referrer] = _tierId;
        emit SetReferrerTier(_referrer, _tierId);
    }

    function setReferrerDiscountShare(address _account, uint256 _discountShare) external {
        require(_discountShare <= BASIS_POINTS, "Referral: invalid discountShare");

        referrerDiscountShares[_account] = _discountShare;
        emit SetReferrerDiscountShare(_account, _discountShare);
    }

    function registerCode(bytes32 _code) external {
        require(_code != bytes32(0), "Referral: invalid _code");
        require(codeOwners[_code] == address(0), "Referral: code already exists");

        codeOwners[_code] = msg.sender;
        emit RegisterCode(msg.sender, _code);
    }

    modifier onlyCodeOwner(bytes32 _code) {
        address account = codeOwners[_code];
        require(msg.sender == account, "Referral: forbidden");
        _;
    }

    /**
     * This function is designed to change the owner address of a specific code.
     * Only the original owner of the code has the authority to change the owner
     * address of the code.
     */
    function setCodeOwner(bytes32 _code, address _newAccount) external onlyCodeOwner(_code) {
        require(_code != bytes32(0), "Referral: invalid _code");

        codeOwners[_code] = _newAccount;
        emit SetCodeOwner(msg.sender, _newAccount, _code);
    }

    // TODO only Gov
    function govSetCodeOwner(bytes32 _code, address _newAccount) external {
        require(_code != bytes32(0), "Referral: invalid _code");

        codeOwners[_code] = _newAccount;
        emit GovSetCodeOwner(_code, _newAccount);
    }

    function getTraderReferralInfo(address _account) internal view returns (bytes32, address) {
        bytes32 code = traderReferralCodes[_account];
        address referrer;
        if (code != bytes32(0)) {
            referrer = codeOwners[code];
        }
        return (code, referrer);
    }

    function _setTraderReferralCode(address _account, bytes32 _code) internal {
        traderReferralCodes[_account] = _code;
        emit SetTraderReferralCode(_account, _code);
        emit SetTraderReferralCode(_account, codeOwners[_code], _code);
    }

    function getCodeOwners(bytes32[] memory _codes) internal view returns (address[] memory) {
        address[] memory owners = new address[](_codes.length);

        for (uint256 i = 0; i < _codes.length; i++) {
            bytes32 code = _codes[i];
            owners[i] = codeOwners[code];
        }

        return owners;
    }

    function updatePositionCallback(MarketPositionCallBackIntl.UpdatePositionEvent memory _event) external {
        (bytes32 referralCode, address referrer) = getTraderReferralInfo(_event.inputs._account);
        if (referralCode == bytes32(0)) {
            referrer = codeOwners[_event.inputs._refCode];
            if (referrer == address(0)) return;
            _setTraderReferralCode(_event.inputs._account, _event.inputs._refCode);
            referralCode = _event.inputs._refCode;
        }

        if (_event.inputs.isOpen) {
            emit IncreasePositionReferral(
                _event.inputs._account,
                _event.inputs._sizeDelta,
                uint256(_event.fees[uint8(FeeRouterLib.FeeType.OpenFee)]),
                referralCode,
                referrer
            );
        } else {
            emit DecreasePositionReferral(
                _event.inputs._account,
                _event.inputs._sizeDelta,
                uint256(_event.fees[uint8(FeeRouterLib.FeeType.CloseFee)]),
                referralCode,
                referrer
            );
        }
    }

    function getHooksCalls() external pure override returns (MarketCallBackIntl.Calls memory) {
        return MarketCallBackIntl.Calls({updatePosition: true, updateOrder: false, deleteOrder: false});
    }
}
