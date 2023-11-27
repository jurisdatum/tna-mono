
import { Handler, APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { query } from './sparql';


export const handler: Handler<APIGatewayProxyEventV2, APIGatewayProxyResultV2> = async (event, context) => {
	event.pathParameters ??= {};
	event.queryStringParameters ??= {};
	event.queryStringParameters['indent'] ??= 'false';
	const type = event.pathParameters['type'] || event.queryStringParameters['type'];
	const indent: boolean = event.queryStringParameters['indent'].toLowerCase() === 'true';
	if (!type)
		return { statusCode: 400, body: "missing 'type' parameter" };
	if (!/^[A-Za-z]+$/.test(type))
		return { statusCode: 400, body: "invalid 'type' parameter" };
	const years: Result[] = await get(type);
	return {
		statusCode: 200,
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(years, null, indent ? 2 : undefined)
	};
};

export async function get(type: string): Promise<Result[]> {
	const q = /^[a-z]{3,5}$/.test(type) ? makeQuery2(type) : makeQuery1(type);
	const raw = await query(q) as RawResult[];
	return raw.map(simplify);
}

// function makeQuery(type: string): string {
// 	return `PREFIX leg: <http://www.legislation.gov.uk/def/legislation/>
// select ('${type}' as ?type) ?year (count(?item) as ?documents)
// where { ?item a leg:${type} ; leg:year ?year . }
// group by ?year
// order by desc(?year)
// `;
// }

function makeQuery1(type: string): string {
	return `PREFIX leg: <http://www.legislation.gov.uk/def/legislation/>
SELECT (<http://www.legislation.gov.uk/def/legislation/${type}> as ?type) ?acronym ?year ?documents
WHERE {
	leg:${type} leg:acronym ?acronym .
	{   SELECT ?year (count(?item) as ?documents)
		WHERE { ?item a leg:${type} ; leg:year ?year . }
	}
}
GROUP BY ?year
ORDER BY desc(?year)
`;
}

function makeQuery2(acronym: string): string {
	return `PREFIX leg: <http://www.legislation.gov.uk/def/legislation/>
SELECT ?type ('${acronym}' as ?acronym) ?year (count(?item) as ?documents) {
SELECT ?item ?type ?year WHERE {
	?item a ?type ; leg:year ?year .
	{ SELECT ?type WHERE { ?type leg:acronym '${acronym}' } }
}
GROUP BY ?year
}
ORDER BY desc(?year)
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
		type: 'typed-literal',
		datatype: 'http://www.w3.org/2001/XMLSchema#integer',
		value: string
	},
	documents: {
		type: 'typed-literal',
		datatype: 'http://www.w3.org/2001/XMLSchema#integer',
		value: string
	}
};

export type Result = {
	type: string,
	acronym: string,
	year: number,
	documents: number
};

function simplify(result: RawResult): Result {
	return {
		type: result.type.value.substring(46),
		acronym: result.acronym.value,
		year: parseInt(result.year.value),
		documents: parseInt(result.documents.value)
	};
}
