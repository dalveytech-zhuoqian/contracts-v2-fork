// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAccessManaged} from "../ac/IAccessManaged.sol";
import {ReferralHandler} from "../lib/referral/ReferralHandler.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

contract ReferralFacet is IAccessManaged, ReentrancyGuardUpgradeable {
    function setTraderReferralCodeByUser(bytes32 _code) external nonReentrant {
        ReferralHandler._setTraderReferralCode(msg.sender, _code);
    }

    function registerCode(bytes32 _code) external nonReentrant {
        ReferralHandler.registerCode(_code);
    }

    function setCodeOwner(bytes32 _code, address _newAccount) external nonReentrant {
        ReferralHandler.setCodeOwner(_code, _newAccount);
    }

    function govSetCodeOwner(bytes32 _code, address _newAccount) external restricted {
        ReferralHandler.govSetCodeOwner(_code, _newAccount);
    }

    function setTier(uint256 _tierId, uint256 _totalRebate, uint256 _discountShare) external restricted {
        ReferralHandler.setTier(_tierId, _totalRebate, _discountShare);
    }

    function setReferrerTier(address _referrer, uint256 _tierId) external restricted {
        // ReferralHandler.setReferrerTier(_referrer, _tierId);
    }

    function setReferrerDiscountShare(address _account, uint256 _discountShare) external restricted {
        // ReferralHandler.setReferrerDiscountShare(_account, _discountShare);
    }

    function setTraderReferralCode(address _account, bytes32 _code) external restricted {
        // ReferralHandler._setTraderReferralCode(_account, _code);
    }
    //========================================================================
    //      view functions
    //========================================================================

    function getTraderReferralInfo(address _account) internal view returns (bytes32, address) {
        // return ReferralHandler.getTraderReferralInfo(_account);
    }

    function getCodeOwners(bytes32 _code) external view returns (address) {
        // return ReferralHandler.codeOwners(_code);
    }
}
