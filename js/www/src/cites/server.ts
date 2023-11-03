
import { Cite } from './cites';

export async function getCitesTo(docId: string): Promise<Cite[]> {
    const url = 'https://api.tna.jurisdatum.com/cites?to=' + docId;
    const response = await fetch(url);
    if (!response.ok) {
        let message = await response.text();
        console.error(message);
        throw message;
    }
    return await response.json();
}

export async function getCitesFrom(docId: string): Promise<Cite[]> {
    const url = 'https://api.tna.jurisdatum.com/cites?from=' + docId;
    const response = await fetch(url);
    if (!response.ok) {
        let message = await response.text();
        console.error(message);
        throw message;
    }
    return await response.json();
}

export async function enrich(docId: string): Promise<string> {
    const url = 'https://api.tna.jurisdatum.com/legislation/citations/enrich?id=' + docId;
    const response = await fetch(url);
    if (!response.ok) {
        let message = await response.text();
        console.error(message);
        throw message;
    }
    return await response.text();
}
