import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';

import { Cite } from './cites';
import { convertClmlToHtml, enrich } from './server';
import { Loading } from '../comp/shared';
import { extractCites } from './extractor';

export default function CiteTest() {

    const [ searchParams ] = useSearchParams();

    const [ docId, setDocId ] = useState(searchParams.get('id') || '');
    const [ state, setState ] = useState(0);
    const [ clmlUrl, setClmlUrl ] = useState('');
    const [ cites, setCites ] = useState([] as Cite[]);
    const [ htmlUrl, setHtmlUrl ] = useState('');

    const load = async () => {
        if (!docId)
            return;
        setState(1);
        setClmlUrl('');
        setCites([]);
        setHtmlUrl('');
        try {
            const enriched = await enrich(docId);
            const blob = new Blob([ enriched ], { type: 'application/xml' });
            const url = URL.createObjectURL(blob);
            setClmlUrl(url);
            setState(2);

            const p = convertClmlToHtml(enriched);
            setCites(extractCites(enriched));
            try {
                const html = await p;
                const blob2 = new Blob([ html ], { type: 'text/html' });
                const url2 = URL.createObjectURL(blob2);
                setHtmlUrl(url2);
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

    useEffect(() => { load(); }, [ ]);

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
            <button disabled={ state === 1 || state === 2 } onClick={ load }>Test</button>
        </p>
        <div style={ { textAlign: 'center' } }>
            <ul style={ { display: 'inline-block', textAlign: 'left' } }>
                { state === 1 || state === -1 ? <>
                    <li>enriching { docId } { state === 1 ? <Loading/> : <></> }</li>
                </> : <></> }
                { state === -1 ? <>
                    <li style={ { color: 'red' } }>there was an error</li>
                </> : <></> }
                { state >= 2 || state === -2 ? <>
                    <li>
                        <span>original CLML: </span>
                        <a target="_blank" rel="noreferrer" href={ 'https://www.legislation.gov.uk/' + docId + '/data.xml' }>open</a>
                    </li>
                    <li>
                        <span>newly enriched CLML: </span>
                        <a target="_blank" rel="noreferrer" href={ clmlUrl }>open</a>
                        <span> or </span>
                        <a download={ docId.replaceAll('/', '_') + '.xml' } href={ clmlUrl }>download</a>
                    </li>
                </> : <></> }
                { (state === 2) && <li>converting to HTML <Loading/></li> }
                { (state === -2) && <li>There was an error converting to HTML</li> }
                { (state === 3) && <li>
                    <span>newly enriched HTML: </span>
                    <a target="_blank" rel="noreferrer" href={ htmlUrl }>open</a>
                    <span> or </span>
                    <a download={ docId.replaceAll('/', '_') + '.html' } href={ htmlUrl }>download</a>
                </li> }
            </ul>
        </div>
        { (state >= 2 || state === -2) && <List cites={ cites } htmlUrl={ htmlUrl } /> }
    </div>;

}


function List(props: { cites: Cite[], htmlUrl: string }) {

    const left = { padding: '3pt 6pt', textAlign: 'left' } as React.CSSProperties;
    const center = { padding: '3pt 6pt', textAlign: 'center' } as React.CSSProperties;

    const hasSeries = props.cites.some(cite => cite.series);
    const hasAltNum = props.cites.some(cite => cite.altNumber);
    const hasDate = props.cites.some(cite => cite.date);
    const hasStartPage = props.cites.some(cite => cite.startPage);

    if (props.cites.length === 0)
        return <>
            <hr style={ { margin: '1em 2em 2em' } }/>
            <p style={ { textAlign: 'center' } }>There are no citations in this document.</p>
        </>;

    return <>
    <hr style={ { margin: '1em 2em 2em' } }/>
    <table style={ { margin: '0 auto' } }>
        <thead>
            <tr>
                <th style={ left }>text</th>
                <th style={ center }>Class</th>
                <th style={ center }>Year</th>
                <th style={ center }>Number</th>
                { hasAltNum && <th style={ center }>Alternative<br/>Number</th> }
                { hasDate && <th style={ center }>Date</th> }
                { hasSeries && <th style={ center }>Series</th> }
                { hasStartPage && <th style={ center }>Start<br/>Page</th> }
                <th style={ left }>URI</th>
            </tr>
        </thead>
        <tbody>
            { props.cites.map((cite, i) => <>
                <tr key={ i }>
                    <td style={ left }>
                        { (props.htmlUrl && cite.section) ? <a href={ props.htmlUrl + '#' + cite.section } title="click to view in document" target="_blank" rel="noreferrer">{ cite.text }</a>
                            : <span>{ cite.text }</span> }
                    </td>
                    <td style={ center }>{ cite.type }</td>
                    <td style={ center }>{ cite.year }</td>
                    { hasSeries && <td style={ center }>{ cite.series }</td> }
                    <td style={ center }>{ cite.number }</td>
                    { hasAltNum && <td style={ center }>{ cite.altNumber }</td> }
                    { hasDate && <td style={ center }>{ cite.date }</td> }
                    { hasStartPage && <td style={ center }>{ cite.startPage }</td> }
                    <td style={ left }>{ cite.uri && <a href={ cite.uri } target="_blank" rel="noreferrer">{ cite.uri }</a> }</td>
                </tr>
            </>) }
        </tbody>
    </table>
    </>;

}
