
import { Handler, APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from 'aws-lambda';
import { query } from './sparql';

export const handler: Handler<APIGatewayProxyEventV2, APIGatewayProxyResultV2> = async (event, context) => {
	event.queryStringParameters ??= {};
	event.queryStringParameters['indent'] ??= 'false';
	const indent: boolean = event.queryStringParameters['indent'].toLowerCase() === 'true';
	const types: Result[] = await get();
	return {
		statusCode: 200,
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(types, null, indent ? 2 : undefined)
	};
};

const q = `PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX leg: <http://www.legislation.gov.uk/def/legislation/>
select ?type ?acronym ?label ?class ?comment
where {
	?item a leg:Legislation , ?type .
	?type leg:acronym ?acronym .
	?type rdfs:label ?label .
	?type rdfs:subClassOf ?class .
	?type rdfs:comment ?comment .
	filter( ?type!=leg:Item && ?type!=leg:CompositeItem && ?type!=leg:Legislation &&
		( ?class=leg:Primary || ?class=leg:Secondary || ?class=leg:EuropeanUnionLegislation ) )
}
group by ?type
order by ?type
`;

export async function get(): Promise<Result[]> {
	const raw = await query(q) as RawResult[];
	return raw.map(simplify);
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
	label: {
		type: 'literal',
		value: string
	},
	class: {
		type: 'uri',
		value: string
	},
	comment: {
		type: 'literal',
		value: string
	}
};

export type Result = {
	type: string,
	acronym: string,
	label: string,
	class: string,
	comment: string
};

function simplify(result: RawResult): Result {
	return {
		type: result.type.value.substring(46),
		acronym: result.acronym.value,
		label: result.label.value,
		class: result.class.value.substring(46),
		comment: result.comment.value
	};
}

// var cache: Map<string, string>;

// export async function shortToLong(short: string): Promise<string | undefined> {
// 	if (!cache) {
// 		const types = await get();
// 		const mappings = types.map(t => [ t.acronym, t.type ]) as [ string, string ][];
// 		cache = new Map(mappings);
// 	}
// 	return cache.get(short);
// }
