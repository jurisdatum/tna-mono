
const url = 'https://www.legislation.gov.uk/sparql';

function makeHeaders() {
	const username = process.env.LINKED_DATA_API_USERNAME;
	const password = process.env.LINKED_DATA_API_PASSWORD;
	const authorization = 'Basic ' + Buffer.from(username + ":" + password).toString('base64');
	return {
		'Authorization': authorization,
		'Content-Type': 'application/x-www-form-urlencoded',
		'Accept': 'application/sparql-results+json'
	};
}

export async function query(query: string): Promise<object[]> {
	const headers = makeHeaders();
	const body = 'query=' + encodeURIComponent(query);
	const response = await fetch(url, { method: 'POST', headers, body });
	if (!response.ok) {
		const message = await response.text();
		console.error(message);
		throw message;
	}
	const results = await response.json() as Results;
	return results.results.bindings;
}

type Results = { results: { bindings: object[] } };
