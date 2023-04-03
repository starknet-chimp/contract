import {generateMetadata} from "../src/generateMetadata";

generateMetadata()
	.then(() => {
		console.log("finished successfully");
		process.exit(0);
	})
	.catch((x) => {
		console.log(`Failed to run: ${x.toString()}`);
		process.exit(1);
	});
