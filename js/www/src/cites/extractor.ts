
import { Cite } from './cites';

export function extractCites(clml: string): Cite[] {
    const doc = new DOMParser().parseFromString(clml, 'application/xml') as XMLDocument;
    return parseElement(doc.documentElement);
}

function parseElement(e: Element): Cite[] {
    if (e.tagName === 'Citation')
        return [ convert(e) ];
    return Array.prototype.flatMap.call(e.children, parseElement) as Cite[];
}

function convert(citation: Element): Cite {
    const id = '';
    const section = getIdOrParentId(citation.parentElement!) || 'unknown';
    const type = citation.getAttribute('Class')!;
    const year = parseInt(citation.getAttribute('Year')!);
    const number = citation.getAttribute('Number') ? parseInt(citation.getAttribute('Number')!) : 0;
    const altNumber = getAltNumber(citation);
    const date = citation.getAttribute('Date') || undefined;
    const series = citation.getAttribute('Series') || undefined;
    const startPage = citation.hasAttribute('StartPage') ? parseInt(citation.getAttribute('StartPage')!) : undefined;
    const uri = citation.getAttribute('URI') || undefined;
    const text = citation.textContent!;
    return { id, section, type, year, number, altNumber, date, series, startPage, uri, text };
}

function getIdOrParentId(e: Element): string | null {
    const id = e.getAttribute('id');
    if (id)
        return id;
    if (!e.parentElement)
        return null;
    return getIdOrParentId(e.parentElement);
}

function getAltNumber(cite: Element): string | undefined {
    if (cite.hasAttribute('AlternativeNumber'))
        return cite.getAttribute('AlternativeNumber')!;
    if (cite.hasAttribute('NorthernIrishNumber'))
        return 'N.I. ' + cite.getAttribute('NorthernIrishNumber')!;

}
