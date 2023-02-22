
const yCache = new Map<string, number[]>();

export async function fetchYears(type: string): Promise<number[]> {
    let cached = yCache.get(type);
    if (cached)
        return cached;
    let response = await fetch('https://api.tna.jurisdatum.com/legislation/years/' + type);
    if (!response.ok) {
        let message = await response.text();
        console.error(message);
        throw message;
    }
    let years = await response.json() as number[];
    years.reverse();
    yCache.set(type, years);
    return years;
}

const dCache = new Map<string, any[]>();

export async function fetchDocs(type: string, year: number): Promise<any[]> {
    const key = type + '-' + year;
    let cached = dCache.get(key);
    if (cached)
        return cached;
    const response = await fetch('https://api.tna.jurisdatum.com/legislation/docs/' + type + '/' + year);
    if (!response.ok) {
        let message = await response.text();
        console.error(message);
        throw message;
    }
    let docs = await response.json();
    dCache.set(key, docs);
    return docs;
}

export async function fetchDoc(id: string, prune: boolean = true): Promise<string | null> {
    const url = 'https://lgu-enriched.s3.eu-west-2.amazonaws.com' + id + '/data.html';
    let response = await fetch(url);
    if (!response.ok)
        return null;
    let html = await response.text();
    if (prune)
        html = extractArticle(html);
    return html;
};

function extractArticle(html: string): string {
    const i1 = html.indexOf('<article');
    const i2 = html.lastIndexOf('</article>');
    if (i1 === -1)
        return html;
    if (i2 === -1)
        return html;
    return html.substring(i1, i2 + 10);
}
