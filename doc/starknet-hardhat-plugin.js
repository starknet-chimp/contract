// node_modules/@shardlabs/starknet-hardhat-plugin/dist/src/account.js
static getAccountFromAddress(address, privateKey, hre) {
	return __awaiter(this, void 0, void 0, function* () {
		const contractPath = yield (0, account_utils_1.handleAccountContractArtifacts)(ArgentAccount.ACCOUNT_TYPE_NAME, ArgentAccount.ACCOUNT_ARTIFACTS_NAME, ArgentAccount.VERSION, hre);
		const contractFactory = yield hre.starknet.getContractFactory(contractPath);
		const contract = contractFactory.getContractAt(address);
		const keyPair = ellipticCurve.getKeyPair((0, number_1.toBN)(privateKey.substring(2), "hex"));
		const publicKey = ellipticCurve.getStarkKey(keyPair);
		const account = new ArgentAccount(contract, privateKey, hre);
		return account;
	});
}

// node_modules/@shardlabs/starknet-hardhat-plugin/dist/src/types.js
deploy(constructorArguments, options = {}) {
	return __awaiter(this, void 0, void 0, function* () {
		const executed = yield this.starknetWrapper.deploy({
			contract: this.metadataPath,
			inputs: this.handleConstructorArguments(constructorArguments),
			gatewayUrl: this.gatewayUrl,
			salt: options.salt,
			token: options.token
		});
		// Log here
		console.log(executed);
		if (executed.statusCode) {
			const msg = `Could not deploy contract: ${executed.stderr.toString()}`;
			throw new starknet_plugin_error_1.StarknetPluginError(msg);
		}
		const executedOutput = executed.stdout.toString();
		const address = extractAddress(executedOutput);
		const txHash = extractTxHash(executedOutput);
		const contract = new StarknetContract({
			abiPath: this.abiPath,
			starknetWrapper: this.starknetWrapper,
			networkID: this.networkID,
			chainID: this.chainID,
			feederGatewayUrl: this.feederGatewayUrl,
			gatewayUrl: this.gatewayUrl
		});
		contract.address = address;
		contract.deployTxHash = txHash;
		return new Promise((resolve, reject) => {
			iterativelyCheckStatus(txHash, this.starknetWrapper, this.gatewayUrl, this.feederGatewayUrl, () => resolve(contract), reject);
		});
	});
}