
import { Handler, APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { XMLParser } from 'fast-xml-parser';

export const handler: Handler<APIGatewayProxyEventV2, APIGatewayProxyResultV2> = async (event, context) => {
	event.queryStringParameters ??= {};
	event.queryStringParameters['indent'] ??= 'false';
	const title = event.queryStringParameters['title'];
	const indent: boolean = event.queryStringParameters['indent'].toLowerCase() === 'true';
	if (!title)
		return { statusCode: 400, body: "missing 'title' parameter" };
	const types: Result[] = await search(title);
	return {
		statusCode: 200,
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(types, null, indent ? 2 : undefined)
	};
};

const parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix : '@' });

export async function search(title: string): Promise<Result[]> {
    const url = 'https://www.legislation.gov.uk/primary+secondary/data.feed?title=' + encodeURIComponent(title);
    const response = await fetch(url);
	if (!response.ok) {
		const message = await response.text();
		console.error(message);
		throw message;
	}
    const xml = await response.text();
    const feed = parser.parse(xml) as Feed;
    return feed.feed.entry.map(convert);
}

function convert(e: Entry): Result {
    const type = e['ukm:DocumentMainType']['@Value'];
    const year = e['ukm:Year']['@Value'];
    return {
        type: type,
        acronym: longToShort.get(type),
        year: /^\d+$/.test(year) ? parseInt(year) : year,
        number: parseInt(e['ukm:Number']['@Value']),
        id: e.id.substring(33),
        title: e.title
    };
}

export type Result = {
	type: string,
	acronym: string,
	year: number | string,
	number: number,
	id: string,
	title: string
};

type Feed = {
    feed: {
        entry: Entry[]
    }
};

type Entry = {
    id: string,
    title: string,
//     updated: string,
//     published: string,
    'ukm:DocumentMainType': { '@Value': string },
    'ukm:Year': { '@Value': string },
    'ukm:Number': { '@Value': string },
//     'ukm:ISBN': { '@Value': string },
//     'ukm:CreationDate': { '@Date': string },
    summary: string
};

const longToShort = new Map([
    [ 'EnglandAct', 'aep' ],
    [ 'EnglandPrivateOrPersonalAct', 'eppa' ],
    [ 'EuropeanUnionDecision', 'eudn' ],
    [ 'EuropeanUnionDirective', 'eudr' ],
    [ 'EuropeanUnionRegulation', 'eur' ],
    [ 'EuropeanUnionTreaty', 'eut' ],
    [ 'GreatBritainAct', 'apgb' ],
    [ 'GreatBritainLocalAct', 'gbla' ],
    [ 'GreatBritainPrivateOrPersonalAct', 'gbppa' ],
    [ 'IrelandAct', 'aip' ],
    [ 'NorthernIrelandAct', 'nia' ],
    [ 'NorthernIrelandAssemblyMeasure', 'mnia' ],
    [ 'NorthernIrelandOrderInCouncil', 'nisi' ],
    [ 'NorthernIrelandParliamentAct', 'apni' ],
    [ 'NorthernIrelandStatutoryRule', 'nisr' ],
    [ 'NorthernIrelandStatutoryRuleOrOrder', 'nisro' ],
    [ 'ScottishAct', 'asp' ],
    [ 'ScottishOldAct', 'aosp' ],
    [ 'ScottishStatutoryInstrument', 'ssi' ],
    [ 'UnitedKingdomChurchInstrument', 'ukci' ],
    [ 'UnitedKingdomChurchMeasure', 'ukcm' ],
    [ 'UnitedKingdomLettersPatent', 'uklp' ],
    [ 'UnitedKingdomLocalAct', 'ukla' ],
    [ 'UnitedKingdomMinisterialDirection', 'ukmd' ],
    [ 'UnitedKingdomMinisterialOrder', 'ukmo' ],
    [ 'UnitedKingdomPrivateOrPersonalAct', 'ukppa' ],
    [ 'UnitedKingdomPublicGeneralAct', 'ukpga' ],
    [ 'UnitedKingdomRoyalCharter', 'ukrc' ],
    [ 'UnitedKingdomRoyalInstructions', 'ukri' ],
    [ 'UnitedKingdomRoyalProclamation', 'ukrp' ],
    [ 'UnitedKingdomStatutoryInstrument', 'uksi' ],
    [ 'UnitedKingdomStatutoryRuleOrOrder', 'uksro' ],
    [ 'WelshAssemblyMeasure', 'mwa' ],
    [ 'WelshNationalAssemblyAct', 'anaw' ],
    [ 'WelshParliamentAct', 'asc' ]
]);

// const shortToLong = new Map(Array.from(longToShort, a => a.reverse()) as [ string, string][]);
