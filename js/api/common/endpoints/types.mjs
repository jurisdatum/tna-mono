
import { query } from '../helpers/db.mjs';

export const handler = async(event) => {
    const sql = "SELECT DISTINCT type FROM documents;";
    try {
        let result = await query(sql, []);
        result = result.map(row => row.type);
        return result;
    } catch(err) {
        return { statusCode: 500, headers: { 'content-type': 'application/json' }, body: JSON.stringify(err) };
    }
};
