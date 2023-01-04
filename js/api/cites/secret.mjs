
import { SecretsManager } from "@aws-sdk/client-secrets-manager";

const manager = new SecretsManager();

export function getSecret() {
    return new Promise(function(resolve, reject) {
		manager.getSecretValue({ SecretId: 'mysql1-credentials-java' }, function(err, data) {
			if (err) {
				reject(err);
				return;
			}
			const secret = JSON.parse(data['SecretString']);
            resolve(secret);
		});
    });
}
