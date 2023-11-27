
import { Handler, APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { query } from './sparql';

export const handler: Handler<APIGatewayProxyEventV2, APIGatewayProxyResultV2> = async (event, context) => {
	event.pathParameters ??= {};
	event.queryStringParameters ??= {};
	event.queryStringParameters['indent'] ??= 'false';
	const type = event.pathParameters['type'] || event.queryStringParameters['type'];;
	const year = event.pathParameters['year'] || event.queryStringParameters['year'];;
	const indent: boolean = event.queryStringParameters['indent'].toLowerCase() === 'true';
	if (!type)
		return { statusCode: 400, body: "missing 'type' parameter" };
	if (!/^[A-Za-z]+$/.test(type))
		return { statusCode: 400, body: "invalid 'type' parameter" };
	if (!year)
		return { statusCode: 400, body: "missing 'year' parameter" };
	if (!/^\d{4}$/.test(year))
		return { statusCode: 400, body: "invalid 'year' parameter" };
	const docs = await get(type, year);
	return {
		statusCode: 200,
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(docs, null, indent ? 2 : undefined)
	};
};

export async function get(type: string, year: number | string): Promise<Result[]> {
	const q = /^[a-z]{3,5}$/.test(type) ? makeQuery2(type, year) : makeQuery1(type, year);
	const raw = await query(q) as RawResult[];
	return raw.map(simplify);
}

function makeQuery1(type: string, year: number | string): string {
	return `PREFIX leg: <http://www.legislation.gov.uk/def/legislation/>
SELECT (<http://www.legislation.gov.uk/def/legislation/${type}> as ?type) ?acronym ?year ?number ?id ?title {
	leg:${type} leg:acronym ?acronym .
	?id a leg:${type} ;
	leg:year ${year} ;
	leg:calendarYear ?year ;
	leg:number ?number ;
	leg:title ?title .
}
ORDER BY ?number
`;
}

function makeQuery2(acronym: string, year: number | string): string {
	return `PREFIX leg: <http://www.legislation.gov.uk/def/legislation/>
SELECT ?type ('${acronym}' as ?acronym) ?year ?number ?id ?title {
	?id a ?type ;
	leg:year ${year} ;
	leg:calendarYear ?year ;
	leg:number ?number ;
	leg:title ?title .
	{ SELECT ?type WHERE { ?type leg:acronym '${acronym}' } }
}
ORDER BY ?number
`;
}

type RawResult = {
	type: {
		type: 'uri',
		value: string
	},
	acronym: {
		type: 'literal',
		value: string
	},
	year: {
		type: 'uri',
		value: string  // 'http://www.legislation.gov.uk/id/year/2020'
	},
	number: {
		type: 'typed-literal',
		datatype: 'http://www.w3.org/2001/XMLSchema#integer',
		value: string
	},
	id: {
		type: 'uri',
		value: string
	},
	title: {
		type: 'literal',
		'xml:lang': 'en',
		value: string
	}
};

export type Result = {
	type: string,
	acronym: string,
	year: number,
	number: number,
	id: string,
	title: string
};

function simplify(result: RawResult): Result {
	return {
		type: result.type.value.substring(46),
		acronym: result.acronym.value,
		year: parseInt(result.year.value.substring(38)),
		number: parseInt(result.number.value),
		id: result.id.value.substring(33),
		title: result.title.value,
	};
}
