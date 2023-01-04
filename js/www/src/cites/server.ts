
import { Cite } from './cites';

export class Server {

    static readonly host = 'https://api.tna.jurisdatum.com';

    static getCitesTo(docId: string): Promise<Cite[]> {
        const url = Server.host + '/cites?to=' + docId;
        return this.getCites(url);
    }
    static getCitesFrom(docId: string): Promise<Cite[]> {
        const url = Server.host + '/cites?from=' + docId;
        return this.getCites(url);
    }
    private static getCites(url: string): Promise<Cite[]> {
        return new Promise(function(resolve, reject) {
            fetch(url).then((response) => {
                if (response.status === 200) {
                    response.json().then(resolve);
                } else {
                    response.text().then(text => { reject({ status: response.status, statusText: response.statusText, message: text }); });
                }
            }).catch(reject);
        });
    }

}
