
import { Suspense, useState } from 'react';
import { Await, defer, Link, useLoaderData, useNavigate, useSearchParams } from 'react-router-dom';

import { Server } from './server';
import { Cite, groupCitesByDocumentCited, groupCitesBySource } from './cites';
import * as Util from './util';
import { Loading } from '../comp/shared';

import './citations.scss';

const re = /^[a-z]{3,5}\/\d{4}\/\d+$/;

export function loadCitations({ request }: { request: Request }) {
    const url = new URL(request.url);
    const to = url.searchParams.get('to');
    if (to && re.test(to))
        return defer({ cites: Server.getCitesTo(to) });
    const from = url.searchParams.get('from');
    if (from && re.test(from))
        return defer({ cites: Server.getCitesFrom(from) });
    return defer({ cites: Promise.resolve([]) });
}

export default function Citations() {

    const data = useLoaderData() as { cites: Promise<Cite[]> };

    const [ searchParams ] = useSearchParams();
    let docId: string | null;
    let from: boolean;

    if (searchParams.has('to') && re.test(searchParams.get('to') as string)) {
        docId = searchParams.get('to');
        from = false;
    } else if (searchParams.has('from') && re.test(searchParams.get('from') as string)) {
        docId = searchParams.get('from');
        from = true;
    } else {
        docId = null;
        from = false;
    }

    return (
        <div className="citations">
            <SearchBar docId={ docId } from={ from } />
            { docId ? <SearchResults cites={ data.cites } docId={ docId } from={ from } /> : <></> }
        </div>
    );

}

function SearchBar(props: { docId: string | null, from: boolean }) {

    const navigate = useNavigate();

    const [input, setInput] = useState(props.docId || '');
    const [from, setFrom] = useState(props.from);

    return <header>
        <h1>Citations</h1>
        <p>
            <span>Search for citations </span>
            <select value={ from ? 'within' : 'to' } onChange={ e => setFrom(e.target.value === 'within') }>
                <option value="within">within</option>
                <option value="to">to</option>
            </select>
            <span> document: </span>
            <input type="text" placeholder="type/year/num" pattern="[a-z]{3,5}/\d{4}/\d+" value={ input } onChange={ e => setInput(e.target.value) } />
            <span> </span>
            <button disabled={ !re.test(input) } onClick={ () => { const p = from ? 'from' : 'to'; navigate('/citations?' + p + '=' + input) } }>Search</button>
        </p>
    </header>;
}

function SearchResults({ cites, docId, from }: { cites: Promise<Cite[]>, docId: string, from: boolean }) {

    return <Suspense fallback={ <p>loading citations <Loading /></p> }>
        <Await resolve={ cites } errorElement={ <p>error</p> }>
            { (cites) => from ? <FromTable cites={ cites } docId={ docId } /> : <ToTable cites={ cites } docId={ docId } /> }
        </Await>
    </Suspense>;
}

// function FromTable({ cites, docId }: { cites: Cites.Cite[], docId: string }) {
//     return <table className="within">
//         <caption>Citations within document { docId }</caption>
//         <thead>
//             <tr>
//                 <th>Citation Text</th>
//                 <th>Location in Source Doc</th>
//             </tr>
//         </thead>
//         <tbody>
//             { cites.map((cite, i) => (
//                 <tr key={ i }>
//                     <td>{ cite.text }</td>
//                     <td>{ cite.section }</td>
//                 </tr>
//                 )) }
//         </tbody>
//     </table>;
// }
function FromTable({ cites, docId }: { cites: Cite[], docId: string }) {
    const groups = groupCitesByDocumentCited(cites);
    return <table className="within">
        <caption>Citations within document { docId }</caption>
        <thead>
            <tr>
                <th>Count</th>
                <th>Citation Text</th>
                <th>Location in Source Doc</th>
            </tr>
        </thead>
        { groups.map((group, i) => (
            <tbody key={ i } className={ i % 2 ? 'odd' : 'even' }>
                { group.cites.map((cite, j) => (
                    <tr key={ i + '.' + j }>
                        { j === 0 ? <td rowSpan={ group.count }>{ group.count }</td> : <></> }
                        <td>{ cite.text }</td>
                        <td>{ Util.makeSectionLabelFromSectionId(cite.section) }</td>
                    </tr>
                )) }
            </tbody>
            )) }
    </table>;
}

function ToTable({ cites, docId }: { cites: Cite[], docId: string }) {
    const groups = groupCitesBySource(cites);
    return <table className="to">
        <caption>Citations to document { docId }</caption>
        <thead>
            <tr>
                <th>Count</th>
                <th>Source Document</th>
                <th>Location in Source Doc</th>
                <th>Citation Text</th>
            </tr>
        </thead>
        { groups.map((group, i) => (
            <tbody key={ i } className={ i % 2 ? 'odd' : 'even' }>
                { group.cites.map((cite: Cite, j: number) => (
                    <tr key={ i + '.' + j }>
                        { j === 0 ? <>
                            <td rowSpan={ group.count }>{ group.count }</td>
                            <td rowSpan={ group.count }>
                                <Link to={ '/' + cite.id }>{ cite.id }</Link>
                            </td>
                        </> : <></> }
                        <td>{ Util.makeSectionLabelFromSectionId(cite.section) }</td>
                        <td>{ cite.text }</td>
                    </tr>
                )) }
            </tbody>
        )) }
    </table>;
}
