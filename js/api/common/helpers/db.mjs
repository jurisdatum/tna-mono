
import mysql from 'mysql';

import { getSecret } from './secret.mjs';

var pool;

function getDatabaseConnection() {
	return new Promise(function(resolve, reject) {
		const callback = (err, connection) => { if (err) return reject(err); resolve(connection); }
		if (pool)
			return pool.getConnection(callback);
		getSecret().then(function(secret) {
			pool = mysql.createPool({
				host     : secret.host,
				user     : secret.username,
				password : secret.password,
				database : 'legislation'
			});
			return pool.getConnection(callback);
		})
		.catch(reject);
	});
};

export function query(sql, params) {
	return new Promise(function(resolve, reject) {
		getDatabaseConnection().then(conn => {
			conn.query(sql, params, function(err, result) {
				if (err)
					return reject(err);
				resolve(result);
			});
		}).catch(reject);
	});
}
