
const yCache = new Map<string, number[]>();

export function fetchYears(type: string): Promise<number[]> {
    let cached = yCache.get(type);
    if (cached)
        return Promise.resolve(cached);
    return new Promise(async (resolve, reject) => {
        let response = await fetch('https://api.tna.jurisdatum.com/legislation/years/' + type);
        if (response.ok) {
            let years = await response.json() as number[];
            years.reverse();
            yCache.set(type, years);
            resolve(years);
        } else {
            let message = await response.text();
            console.error(message);
            reject(message);
        }
    });
}

const dCache = new Map<string, any[]>();

export function fetchDocs(type: string, year: number): Promise<any[]> {
    const key = type + '-' + year;
    let cached = dCache.get(key);
    if (cached)
        return Promise.resolve(cached);
    return new Promise(async (resolve, reject) => {
        const response = await fetch('https://api.tna.jurisdatum.com/legislation/docs/' + type + '/' + year);
        if (response.ok) {
            let docs = await response.json();
            dCache.set(key, docs);
            resolve(docs);
        } else {
            let message = await response.text();
            console.error(message);
            reject(message);
        }
    });
}
