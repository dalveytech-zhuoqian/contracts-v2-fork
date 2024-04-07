// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ReferralType} from "../types/ReferralType.sol";
import {FeeType} from "../types/Types.sol";

library ReferralHandler {
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
    event SetTraderReferralCodeWithInviter(address account, address inviter, bytes32 code);
    event SetTier(uint256 tierId, uint256 totalRebate, uint256 discountShare);
    event SetReferrerTier(address referrer, uint256 tierId);
    event SetReferrerDiscountShare(address referrer, uint256 discountShare);
    event RegisterCode(address account, bytes32 code);
    event SetCodeOwner(address account, address newAccount, bytes32 code);
    event GovSetCodeOwner(bytes32 code, address newAccount);

    event IncreasePositionReferral(
        address account, uint256 sizeDelta, uint256 marginFeeBP, bytes32 referralCode, address referrer
    );

    event DecreasePositionReferral(
        address account, uint256 sizeDelta, uint256 marginFeeBP, bytes32 referralCode, address referrer
    );

    function Storage() internal pure returns (StorageStruct storage fs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function setTier(uint256 _tierId, uint256 _totalRebate, uint256 _discountShare) internal {
        require(_totalRebate <= BASIS_POINTS, "Referral: invalid totalRebate");
        require(_discountShare <= BASIS_POINTS, "Referral: invalid discountShare");

        Tier memory tier = Storage().tiers[_tierId];
        tier.totalRebate = _totalRebate;
        tier.discountShare = _discountShare;
        Storage().tiers[_tierId] = tier;
        emit SetTier(_tierId, _totalRebate, _discountShare);
    }

    function setReferrerTier(address _referrer, uint256 _tierId) internal {
        Storage().referrerTiers[_referrer] = _tierId;
        emit SetReferrerTier(_referrer, _tierId);
    }

    function setReferrerDiscountShare(address _account, uint256 _discountShare) internal {
        require(_discountShare <= BASIS_POINTS, "Referral: invalid discountShare");

        Storage().referrerDiscountShares[_account] = _discountShare;
        emit SetReferrerDiscountShare(_account, _discountShare);
    }

    function registerCode(bytes32 _code) internal {
        require(_code != bytes32(0), "Referral: invalid _code");
        require(Storage().codeOwners[_code] == address(0), "Referral: code already exists");

        Storage().codeOwners[_code] = msg.sender;
        emit RegisterCode(msg.sender, _code);
    }

    modifier onlyCodeOwner(bytes32 _code) {
        address account = Storage().codeOwners[_code];
        require(msg.sender == account, "Referral: forbidden");
        _;
    }

    /**
     * This function is designed to change the owner address of a specific code.
     * Only the original owner of the code has the authority to change the owner
     * address of the code.
     */
    function setCodeOwner(bytes32 _code, address _newAccount) internal onlyCodeOwner(_code) {
        require(_code != bytes32(0), "Referral: invalid _code");
        Storage().codeOwners[_code] = _newAccount;
        emit SetCodeOwner(msg.sender, _newAccount, _code);
    }

    function govSetCodeOwner(bytes32 _code, address _newAccount) internal {
        require(_code != bytes32(0), "Referral: invalid _code");
        Storage().codeOwners[_code] = _newAccount;
        emit GovSetCodeOwner(_code, _newAccount);
    }

    function getTraderReferralInfo(address _account) internal view returns (bytes32, address) {
        bytes32 code = Storage().traderReferralCodes[_account];
        address referrer;
        if (code != bytes32(0)) {
            referrer = Storage().codeOwners[code];
        }
        return (code, referrer);
    }

    function _setTraderReferralCode(address _account, bytes32 _code) internal {
        Storage().traderReferralCodes[_account] = _code;
        emit SetTraderReferralCode(_account, _code);
        emit SetTraderReferralCodeWithInviter(_account, Storage().codeOwners[_code], _code);
    }

    function getCodeOwners(bytes32[] memory _codes) internal view returns (address[] memory) {
        address[] memory owners = new address[](_codes.length);

        for (uint256 i = 0; i < _codes.length; i++) {
            bytes32 code = _codes[i];
            owners[i] = Storage().codeOwners[code];
        }

        return owners;
    }

    function updatePositionCallback(ReferralType.UpdatePositionEvent calldata _event) internal {
        (bytes32 referralCode, address referrer) = getTraderReferralInfo(_event.inputs.account);

        if (referralCode == bytes32(0)) {
            referrer = Storage().codeOwners[_event.inputs.refCode];
            if (referrer == address(0)) return;
            _setTraderReferralCode(_event.inputs.account, _event.inputs.refCode);
            referralCode = _event.inputs.refCode;
        }

        if (_event.inputs.isOpen) {
            emit IncreasePositionReferral(
                _event.inputs.account,
                _event.inputs.sizeDelta,
                uint256(_event.fees[uint8(FeeType.OpenFee)]),
                referralCode,
                referrer
            );
        } else {
            emit DecreasePositionReferral(
                _event.inputs.account,
                _event.inputs.sizeDelta,
                uint256(_event.fees[uint8(FeeType.CloseFee)]),
                referralCode,
                referrer
            );
        }
    }
}
