import { useState } from 'react';

import { convertClmlToHtml, enrich } from './server';
import { Loading } from '../comp/shared';

export default function CiteTest() {

    const [docId, setDocId] = useState('');
    const [state, setState] = useState(0);
    const [enrichedDataURL, setEnrichedDataURL] = useState('');
    const [enrichedHtml, setEnrichedHtml] = useState('');

    const load = async () => {
        if (!docId)
            return;
        setState(1);
        try {
            const enriched = await enrich(docId);
            const blob = new Blob([ enriched ], { type: 'application/xml' });
            const url = URL.createObjectURL(blob);
            setEnrichedDataURL(url);
            setState(2);
            try {
                const html = await convertClmlToHtml(enriched);
                setEnrichedHtml(extractArticle(html));
                setState(3);
            } catch {
                setState(-2);
                return;
            }
        } catch {
            setState(-1);
            return;
        }
    };

    return <div className="citetest">
        <h1 style={ { textAlign: 'center' } }>Test Citations</h1>
        <p style={ { textAlign: 'center' } }>
            <label>Enter an id: </label>
            <input type="text" value={ docId } style={ { width: '32ch' } }
                title="can be a document id, such as ukpga/2023/1 or a fragment id, such as ukpga/2023/1/section/1"
                placeholder='ukpga/2023/1 or ukpga/2023/1/section/1'
                onChange={ e => { setDocId(e.target.value); setState(0); } }
                onKeyDown={ (e) => { if (e.key === 'Enter') load(); } } />
            <span> </span>
            <button disabled={ state === 1 } onClick={ load }>Test</button>
        </p>
        <div style={ { textAlign: 'center' } }>
            <ul style={ { display: 'inline-block', textAlign: 'left' } }>
                { state === 1 || state === -1 ? <>
                    <li>enriching { docId } <Loading/></li>
                </> : <></> }
                { state === -1 ? <>
                    <li style={ { color: 'red' } }>there was an error</li>
                </> : <></> }
                { state >= 2 || state === -2 ? <>
                    <li>link to <a target="_blank" href={ 'https://www.legislation.gov.uk/' + docId + '/data.xml' }>original CLML</a></li>
                    <li>link to <a target="_blank" href={ enrichedDataURL }>newly enriched CLML</a></li>
                </> : <></> }
                { state === 2 || state === -2 ? <>
                    <li>converting to HTML <Loading/></li>
                </> : <></> }
                { state === -2 ? <>
                    <li style={ { color: 'red' } }>there was an error</li>
                </> : <></> }
            </ul>
        </div>
        { state === 3 ? <><hr/><div dangerouslySetInnerHTML={ { __html: enrichedHtml } } /></> : <></> }
    </div>;

}

function extractArticle(html: string): string {
    const i1 = html.indexOf('<article');
    const i2 = html.lastIndexOf('</article>');
    if (i1 === -1)
        return html;
    if (i2 === -1)
        return html;
    return html.substring(i1, i2 + 10);
}
