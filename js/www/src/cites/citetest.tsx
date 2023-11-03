import { useState } from 'react';

import { enrich } from './server';

export default function CiteTest() {

    const [docId, setDocId] = useState('');
    const [state, setState] = useState(0);
    const [enrichedDataURL, setEnrichedDataURL] = useState('');


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
        } catch {
            setState(-1);
            return;
        }
    };

    return <div className="citetest">
        <h1 style={ { textAlign: 'center' } }>Cite Test</h1>
        <p style={ { textAlign: 'center' } }>
            <label>Enter a document id: </label>
            <input type="test" value={ docId } onChange={ e => { setDocId(e.target.value); setState(0); } } onKeyDown={ (e) => { if (e.key === 'Enter') load(); } }></input>
            <span> </span>
            <button disabled={ state === 1 } onClick={ load }>Test</button>
        </p>
        <div style={ { textAlign: 'center' } }>
            <ul style={ { display: 'inline-block', textAlign: 'left' } }>
                { state !== 0 ? <>
                    <li>enriching { docId } ...</li>
                </> : <></> }
                { state === -1 ? <>
                    <li style={ { color: 'red' } }>there was an error</li>
                </> : <></> }
                { state === 2 ? <>
                    <li>link to <a target="_blank" href={ 'https://www.legislation.gov.uk/' + docId + '/data.xml' }>original CLML</a></li>
                    <li>link to <a target="_blank" href={ enrichedDataURL }>newly enriched CLML</a></li>
                </> : <></> }
            </ul>
        </div>
    </div>;

}
