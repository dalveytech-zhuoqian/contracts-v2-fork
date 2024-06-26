const addressJson: { [key: string]: AccessManagerAdminConfig } = {
  arbitrum_42161: {
    boss: "0x1B6dCB68Ea6C83993D445E2e26b8BA495A2A3bbD",
    guardian: "0x9b99c75674ae72cd573b7d988a50a1d05b693984",
    scheduler: "0x0909F6Fec8E2CB1Aea67B20Efaf31F91b66E88ca",
    rewardDistributor: "0x54c14Fa76eeD09897F09d06580b3add70793CF19",
    vaultReward: "0xBC1502aF0B7bDD34A9631a9A1F6f7773467d2862",
    accessManager: "0x8A732C47dcd5E8Fbe1693F94F187f4D523c1A9F5",
    proxyAdmin: "0x1A3767384a0C1FaC53c161316Fc398a6cC4819e5",
  },
  ftmTest: {
    boss: "0x1B6dCB68Ea6C83993D445E2e26b8BA495A2A3bbD",
    guardian: "0x3E50Fadf9943282d34F48ACF3E559e690C3022eE",
    scheduler: "0x3E50Fadf9943282d34F48ACF3E559e690C3022eE",
    rewardDistributor: "0xaDA61A37A7F95A8e15510352cA714241558d67a9",
    vaultReward: "0xe12C6aBe5C12eBf29093A8bc8336053FeAdAFFBd",
    accessManager: "0xF6ffa9B61D55A9035Eae14EE572B13dc5e329A55",
    proxyAdmin: "0x84e9B5f2C2830b661f44E6d42fd635b7D1feeC03",
  },
};

type AccessManagerAdminConfig = {
  boss: string;
  guardian: string;
  scheduler: string;
  rewardDistributor: string;
  vaultReward: string;
  accessManager: string;
  proxyAdmin: string;
};

const roleIDJson = {
  admin: "0",
  scheduler: "1",
  guardian: "2",
};
const grantDelayTime = 10 * 60;

export { addressJson, roleIDJson, grantDelayTime };
