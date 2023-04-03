import "@shardlabs/starknet-hardhat-plugin";
import {HardhatUserConfig} from "hardhat/types";

const config: HardhatUserConfig = {
	starknet: {
		venv: "active",
		network: "alpha-mainnet", // change to "alpha-mainnet" for mainnet
	},
};

module.exports = config;
