
import mysql from 'mysql';

import { getSecret } from './secret.mjs';

var pool;

export function getDatabaseConnection(callback) {
	if (pool) {
		pool.getConnection(callback);
		return;
	}
	getSecret().then(function(secret) {
		pool = mysql.createPool({
			host     : secret.host,
			user     : secret.username,
			password : secret.password,
			database : 'legislation'
		});
		pool.getConnection(callback);
	})
	.catch(function(err) {
		callback(err);
	});
};
