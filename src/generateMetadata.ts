import fs from "fs";
import path from "path";

const count = 100;
const metadata: Array<[number, any]> = [
	[
		10,
		{
			image: "ipfs://bafkreiawbfxoxkpkpx7u4eqe6foln54cske6siuqfgd6gosnxxb2jybs4e",
			attributes: [
				{trait_type: "Rare", value: "Rare"},
				{trait_type: "Earring", value: "Silver Hoop"},
				{trait_type: "Background", value: "Orange"},
				{trait_type: "Fur", value: "Robot"},
				{trait_type: "Clothes", value: "Striped Tee"},
				{trait_type: "Mouth", value: "Discomfort"},
				{trait_type: "Eyes", value: "X Eyes"},
			],
		},
	],
	[
		90,
		{
			image: "ipfs://bafkreiawbfxoxkpkpx7u4eqe6foln54cske6siuqfgd6gosnxxb2jybs4e",
			attributes: [
				{trait_type: "Rare", value: "Medium"},
				{trait_type: "Earring", value: "Silver Hoop"},
				{trait_type: "Background", value: "Orange"},
				{trait_type: "Fur", value: "Robot"},
				{trait_type: "Clothes", value: "Striped Tee"},
				{trait_type: "Mouth", value: "Discomfort"},
				{trait_type: "Eyes", value: "X Eyes"},
			],
		},
	],
];

export const generateMetadata = async () => {
	let prev = 0;
	metadata.forEach((item) => {
		item[0] += prev;
		prev = item[0];
	});

	for (let i = 1; i <= count; i++) {
		const fileName = `${i}`;
		const number = Math.random() * 100;
		for (const metadataItem of metadata) {
			if (metadataItem[0] >= number) {
				fs.writeFileSync(path.join(__dirname, "..", "metadata", fileName), JSON.stringify(metadataItem[1]));
				break;
			}
		}
	}
};
