import {starknet} from "hardhat";
import {getAccount} from "./utils/getAccount";

export type NFTDeployment = {
	contractAddress: string;
	projectName: string;
	projectSymbol: string;
	royaltyReceiver: string;
	royaltyFeeBP: string;
	minterAddress: string;
};

export async function deployNFT(): Promise<any> {
	const myAccount = await getAccount();

	// The contract factory is the name of the cairo file your NFT without the .cairo
	console.log("Deploying NFT...");

	// const deployer = await starknet.getContractFactory("Deployer");
	const nftFactory = await starknet.getContractFactory("nft_contract_old");

	const classHash = await myAccount.declare(nftFactory, {maxFee: BigInt("10000000000000000"), nonce: 3});

	console.log(`classHash`, classHash);
}
