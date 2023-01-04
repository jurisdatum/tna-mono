
export type Cite = {
    id: string,
    section: string,
    type: string,
    year: number,
    number: number
    text: string
};

export type Group = {
    key: string,
    count: number
    cites: Cite[]
}

export function groupCitesByDocumentCited(cites: Cite[]): Group[] {
    return groupCitesBy(cites, cite => cite.type + cite.year + cite.number);
}

export function groupCitesBySource(cites: Cite[]): Group[] {
    return groupCitesBy(cites, cite => cite.id);
}

function groupCitesBy(cites: Cite[], keyFn: (cite: Cite) => string): Group[] {
    if (!cites)
        return [];
    const map = new Map();
    cites.forEach(cite => {
        const key = keyFn(cite);
        if (!map.has(key))
            map.set(key, []);
        map.get(key).push(cite);
    });
    var arr = Array.from(map, ([key, cites]) => ({ key, count: cites.length, cites }));
    arr.sort((a, b) => b.count - a.count);
    return arr;
}
