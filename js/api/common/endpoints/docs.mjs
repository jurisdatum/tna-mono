
import { query } from '../helpers/db.mjs';
import { shortTypes } from '../helpers/util.mjs';

export const handler = async(event) => {
    const type = event.pathParameters.type;
    if (!shortTypes.has(type))
        return { statusCode: 400, body: 'bad type parameter' };
    if (!/^\d{4}$/.test(event.pathParameters.year))
        return { statusCode: 400, body: 'bad year parameter' };
    const year = parseInt(event.pathParameters.year);

    const sql = "SELECT d.id, d.year, d.number, d.title, JSON_ARRAYAGG(JSON_OBJECT('name', v.name)) AS `versions` FROM documents d LEFT JOIN versions v ON d.id = v.doc_id WHERE type = ? AND year = ? GROUP BY d.id ORDER BY d.number;";
    try {
        const result = await query(sql, [ type, year ]);
        result.forEach(row => { row.versions = JSON.parse(row.versions); });
        return result;
    } catch(err) {
        return { statusCode: 500, headers: { 'content-type': 'application/json' }, body: JSON.stringify(err) };
    }
};
