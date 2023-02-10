
import { query } from '../helpers/db.mjs';
import { shortTypes } from '../helpers/util.mjs';

export const handler = async(event) => {
    const type = event.pathParameters.type;
    if (!shortTypes.has(type))
        return { statusCode: 400, body: 'bad type parameter' };
    const sql = "SELECT DISTINCT year FROM documents WHERE type = ?;";
    try {
        let result = await query(sql, [ type ]);
        result = result.map(row => row.year);
        return result;
    } catch(err) {
        return { statusCode: 500, headers: { 'content-type': 'application/json' }, body: JSON.stringify(err) };
    }
};
