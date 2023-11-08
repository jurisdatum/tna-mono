import { useState } from 'react';
import { useSearchParams } from 'react-router-dom';

import { Cite } from './cites';
import { convertClmlToHtml, enrich } from './server';
import { Loading } from '../comp/shared';
import { extractCites } from './extractor';

enum ListDocToggle { List, Doc };

export default function CiteTest() {

    const [ searchParams ] = useSearchParams();

    const [docId, setDocId] = useState(searchParams.get('id') || '');
    const [state, setState] = useState(0);
    const [enrichedDataURL, setEnrichedDataURL] = useState('');
    const [toggle, setToggle] = useState(searchParams.get('show') === 'text' ? ListDocToggle.Doc : ListDocToggle.List);
    const [cites, setCites] = useState([] as Cite[]);
    const [enrichedHtml, setEnrichedHtml] = useState('');

    const load = async () => {
        if (!docId)
            return;
        setState(1);
        setCites([]);
        try {
            const enriched = await enrich(docId);
            const blob = new Blob([ enriched ], { type: 'application/xml' });
            const url = URL.createObjectURL(blob);
            setEnrichedDataURL(url);
            setState(2);

            const p = convertClmlToHtml(enriched);
            setCites(extractCites(enriched));
            try {
                const html = await p;
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

    // console.log('cites', cites);

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
                        <a target="_blank" rel="noreferrer" href={ enrichedDataURL }>open</a>
                        <span> or </span>
                        <a download={ docId.replaceAll('/', '_') + '.xml' } href={ enrichedDataURL }>download</a>
                    </li>
                </> : <></> }
            </ul>
        </div>
        { (state >= 2 || state === -2) && <ToggleView state={ state } toggle={ toggle } setToggle={ setToggle } cites={ cites } html={ enrichedHtml } /> }
    </div>;

}

function ToggleView(props: { state: number, toggle: ListDocToggle, setToggle: (t: ListDocToggle) => void, cites: Cite[], html: string }) {

    return <div>
        <hr />
        <p style={ { textAlign: 'center' } }>
            <button style={ { backgroundColor: props.toggle === ListDocToggle.List ? 'lavender' : undefined } } onClick={ () => { props.setToggle(ListDocToggle.List); } }>List of Cites</button>
            <button style={ { backgroundColor: props.toggle === ListDocToggle.Doc ? 'lavender' : undefined } } onClick={ () => { props.setToggle(ListDocToggle.Doc); } }>Document Text</button>
        </p>
        { props.toggle === ListDocToggle.List ?
            <List cites={ props.cites } setToggle={ props.setToggle } /> :
            <DocText state={ props.state } html={ props.html } /> }
    </div>;

}

function List(props: { cites: Cite[], setToggle: (t: ListDocToggle) => void }) {

    const left = { padding: '3pt 6pt', textAlign: 'left' } as React.CSSProperties;
    const center = { padding: '3pt 6pt', textAlign: 'center' } as React.CSSProperties;

    const hasSeries = props.cites.some(cite => cite.series);
    const hasAltNum = props.cites.some(cite => cite.altNumber);
    const hasDate = props.cites.some(cite => cite.date);
    const hasStartPage = props.cites.some(cite => cite.startPage);

    const shortenURI = (uri: string | undefined) => {
        if (!uri)
            return uri;
        if (uri.startsWith('http://www.legislation.gov.uk/id/'))
            return uri.substring('http://www.legislation.gov.uk/id/'.length);
    };

    const goToSection = (id: string) => {
        props.setToggle(ListDocToggle.Doc);
        setTimeout(() => {
            const e = document.getElementById(id);
            if (e)
                e.scrollIntoView();
        }, 500);
    };

    return <table style={ { margin: '0 auto' } }>
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
                    <td style={ { ...left, textDecoration: 'underline', cursor: 'pointer' } } title="click to view in document" onClick={ () => { goToSection(cite.section); } }>{ cite.text }</td>
                    <td style={ center }>{ cite.type }</td>
                    <td style={ center }>{ cite.year }</td>
                    { hasSeries && <td style={ center }>{ cite.series }</td> }
                    <td style={ center }>{ cite.number }</td>
                    { hasAltNum && <td style={ center }>{ cite.altNumber }</td> }
                    { hasDate && <td style={ center }>{ cite.date }</td> }
                    { hasStartPage && <td style={ center }>{ cite.startPage }</td> }
                    <td style={ left }>{ cite.uri && <a href={ cite.uri } target="_blank" rel="noreferrer">{ shortenURI(cite.uri) }</a> }</td>
                </tr>
            </>) }
        </tbody>
    </table>;

}

function DocText(props: { state: number, html: string }) {

    if (props.state === 2)
        return <p style={ { textAlign: 'center' } }>converting to HTML <Loading/></p>

    if (props.state === -2)
        return <p style={ { textAlign: 'center', color: 'red' } }>There was an error converting to HTML</p>

    return <div dangerouslySetInnerHTML={ { __html: props.html } } />;

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
