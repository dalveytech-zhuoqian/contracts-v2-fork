// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.16;

// import {Common} from "chainlink_8_contracts/src/v0.8/libraries/Common.sol";
// import {StreamsLookupCompatibleInterface} from
//     "chainlink_8_contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
// import {ILogAutomation, Log} from "chainlink_8_contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
// import {IRewardManager} from "chainlink_8_contracts/src/v0.8/llo-feeds/interfaces/IRewardManager.sol";
// import {IERC20} from
//     "chainlink_8_contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/interfaces/IERC20.sol";
// import {SafeERC20} from
//     "chainlink_8_contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/utils/SafeERC20.sol";
// import "../interfaces/IVerifierProxy.sol";
// import "../interfaces/IPriceFeed.sol";
// import {IAccessManaged} from "../ac/IAccessManaged.sol";

// abstract contract StreamsUpkeepBase is ILogAutomation, StreamsLookupCompatibleInterface, IAccessManaged {
//     using SafeERC20 for IERC20;

//     struct CheckCallbackCache {
//         address market;
//         uint8 logType;
//         bytes logData;
//     }

//     struct BasicReport {
//         bytes32 feedId; // 报告所包含数据的数据流 ID
//         uint32 validFromTimestamp; // 价格适用的最早时间戳
//         uint32 observationsTimestamp; // 价格适用的最新时间戳
//         uint192 nativeFee; // 使用报告验证交易的基本成本，以链上本地代币（WETH/ETH）计价
//         uint192 linkFee; // 使用报告验证交易的基本成本，以 LINK 计价
//         uint32 expiresAt; // 报告可在链上验证的最新时间戳
//         int192 price; // DON 共识中位数价格，保留 8 位小数
//     }

//     enum LogType {
//         DefaultLog,
//         ChainlinkLog,
//         UniswapLog,
//         MarketLog
//     }

//     uint256 constant LOWER = 0;
//     uint256 constant UPPER = 9999;
//     string public constant DATASTREAMS_FEEDLABEL = "feedIDs";
//     string public constant DATASTREAMS_QUERYLABEL = "timestamp";

//     mapping(address => string) public feedId; // market => feedId
//     mapping(address => uint8) public logType; // source => logType

//     bool public shouldExec = true;
//     mapping(address => IVerifierProxy) public verifier; // market => feedId

//     // 此示例读取 Arbitrum Sepolia 上基本 ETH/USD 价格报告的 ID。
//     // 在 https://docs.chain.link/data-streams/stream-ids 找到完整的 ID 列表

//     event UpdateShouldExec(bool b);
//     event UpdateVerifier(address market, address verifier);

//     function setShouldExec(bool b) external restricted {
//         shouldExec = b;
//         emit UpdateShouldExec(b);
//     }

//     function setVerifier(address market, address _verifier) external restricted {
//         verifier[market] = IVerifierProxy(_verifier);
//         emit UpdateVerifier(market, _verifier);
//     }

//     event UpdateAutoOrder(address autoOrder);

//     function setAutoOrder(address _autoOrder) external restricted {
//         autoOrder = _autoOrder;
//         emit UpdateAutoOrder(_autoOrder);
//     }

//     function withdraw(address token, address receiver, uint256 amount) external restricted {
//         IERC20(token).safeTransfer(receiver, amount);
//     }

//     function withdrawETH(address receiver, uint256 amount) external restricted {
//         payable(receiver).transfer(amount);
//     }

//     event UpdateFeedId(address market, string feedId);

//     function setFeedId(address market, string memory fid) external restricted {
//         feedId[market] = fid;
//         emit UpdateFeedId(market, fid);
//     }

//     event UpdateLogType(address source, uint8 typee);

//     function setLogType(address source, uint8 _t) external restricted {
//         logType[source] = _t;
//         emit UpdateLogType(source, _t);
//     }

//     function sendETH() external payable {}

//     // 此函数使用 revert 来传达调用信息。
//     // 有关详细信息，请参阅 https://eips.ethereum.org/EIPS/eip-3668#rationale
//     /**
//      * @notice 由keeper模拟执行以查看是否实际上需要执行任何工作的方法。该方法实际上不需要可执行，并且由于它只是模拟，因此可能消耗大量 gas。
//      * @dev 为确保它永远不被调用，您可能希望将 cannotExecute 修饰符从 KeeperBase 添加到此方法的实现中。
//      * @param log 匹配此合约已注册为触发器的原始日志数据
//      * @param checkData 用户指定的额外数据，为此维护提供上下文
//      * @return upkeepNeeded 布尔值，指示keeper是否应调用 performUpkeep。
//      * @return performData 如果需要维护，则keeper应该使用的字节，用于调用 performUpkeep。如果您想要编码数据以供以后解码，请尝试 `abi.encode`。
//      */
//     function checkLog(Log calldata log, bytes memory checkData)
//         external
//         virtual
//         returns (bool upkeepNeeded, bytes memory performData)
//     {}

//     // Data Streams 报告字节传递到此处。
//     // extraData 是来自数据流查找过程的上下文数据。
//     // 您的合约可能包含进一步处理此数据的逻辑。
//     // 此方法仅打算由 Automation 在链下模拟。
//     // 然后 Automation 将返回的数据传递到 performUpkeep
//     ///////////////////////////////////////////////////
//     // 这个函数是用来接收数据流返回的数据和额外的上下文信息，并判断是否需要执行维护操作的。
//     // 如果需要维护，函数会返回一个布尔值和一个字节数据，作为执行维护的参数。
//     // 这个函数是为了使用数据流查询功能的合约所必须实现的接口之一，另一个是自动化兼容接口。
//     // 数据流查询功能可以让合约从数据流引擎获取签名的报告，包含了实时的数据和验证信息。这个函数的参数和返回值的含义如下：
//     /**
//      * @param signedReports 一个字节数组，包含了数据流端点返回的数据，例如价格、买卖价差等。
//      * @param extraData 一个字节数据，包含了数据流查询过程中的上下文信息，例如查询的时间戳、数据流的ID等。
//      * @return upkeepNeeded 一个布尔值，表示是否需要执行维护操作。如果为真，表示合约需要根据数据流返回的数据进行一些逻辑处理，例如更新状态、触发事件等。
//      * @return performData 一个字节数据，作为执行performUpkeep操作的参数。可以使用`abi.encode`函数来编码一些数据，以便在维护操作中解码使用。
//      */
//     function checkCallback(
//         bytes[] calldata signedReports, //signedReports
//         bytes calldata extraData //extraData from checkLog
//     ) external view virtual returns (bool upkeepNeeded, bytes memory performData) {}

//     // 函数将在链上执行
//     // 被 chainlink automation 调用(Log trigger event)
//     function performUpkeep(bytes calldata performData) external virtual {}

//     function verifyReport(bytes memory unverifiedReport, IVerifierProxy _verifier)
//         internal
//         returns (BasicReport memory verifiedReport)
//     {
//         (, /* bytes32[3] reportContextData */ bytes memory reportData) =
//             abi.decode(unverifiedReport, (bytes32[3], bytes));
//         // 报告验证费用
//         IFeeManager feeManager = IFeeManager(address(_verifier.s_feeManager()));
//         IRewardManager rewardManager = IRewardManager(address(feeManager.i_rewardManager()));
//         address feeTokenAddress = feeManager.i_linkAddress();
//         (Common.Asset memory fee,,) = feeManager.getFeeAndReward(address(this), reportData, feeTokenAddress);

//         if (IERC20(feeTokenAddress).balanceOf(address(this)) < fee.amount) {
//             return verifiedReport;
//         }

//         // 授权 rewardManager 消耗此合约在费用方面的余额
//         IERC20(feeTokenAddress).approve(address(rewardManager), fee.amount);
//         // 验证报告
//         try _verifier.verify(unverifiedReport, abi.encode(feeTokenAddress)) returns (bytes memory verifiedReportData) {
//             verifiedReport = abi.decode(verifiedReportData, (BasicReport));
//         } catch {}
//     }

//     function mockVerify(bytes memory payload) internal pure returns (bytes memory) {
//         (, bytes memory reportData,,,) = abi.decode(payload, (bytes32[3], bytes, bytes32[], bytes32[], bytes32));
//         return reportData;
//     }

//     function formatPrice(int192 price, address market) internal view returns (uint256) {
//         IPriceFeed pf = IPriceFeed(IPrice(address(this)).priceFeeds(market));
//         return uint256(uint192(price)) * 10 ** (30 - pf.decimals());
//     }

//     event UDSTPrice(address);

//     function convertToUSDTPrice(address market, uint256 price) internal view returns (uint256) {
//         address usdt = AMLib.cp(market).USDT();
//         IPriceFeed USDTPriceFeed = IPriceFeed(IPrice(address(this)).usdtFeed());
//         uint256 xxx = uint256(USDTPriceFeed.latestAnswer());
//         return (price * 10 ** USDTPriceFeed.decimals()) / xxx; // 8
//     }

//     function _isLiquidate(address account, address market, bool isLong, uint256 price)
//         internal
//         view
//         returns (uint256 _state)
//     {
//         _state = AMLib.mv(market).isLiquidate(
//             account, market, isLong, IMarket(market).positionBook(), IMarket(market).feeRouter(), price
//         );
//     }

//     function setPriceWithUSDT(address _market, BasicReport memory verifiedReport) internal {
//         address[] memory tokens = new address[](1);
//         tokens[0] = IMarket(_market).indexToken();

//         uint256[] memory prices = new uint256[](1);

//         prices[0] = convertToUSDTPrice(_market, formatPrice(verifiedReport.price, _market));

//         try AMLib.fp(_market).setPrices(tokens, prices, uint256(verifiedReport.observationsTimestamp)) {} catch {}
//     }

//     function getPriceWithUSDT(address _market, BasicReport memory verifiedReport) internal view returns (uint256) {
//         address[] memory tokens = new address[](1);
//         tokens[0] = IMarket(_market).indexToken();
//         uint256[] memory prices = new uint256[](1);
//         return convertToUSDTPrice(_market, formatPrice(verifiedReport.price, _market));
//     }
// }
