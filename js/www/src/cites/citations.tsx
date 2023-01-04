
import { useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';

import { Server } from './server';
import * as Cites from './cites';
import * as Util from './util';

import './citations.css';

function Citations() {

    const re = useMemo(() => /^[a-z]{3,5}\/\d{4}\/\d+$/, []);

    const [searchParams, setSearchParams] = useSearchParams();

    const [input, setInput] = useState('');
    const [docId, setDocId] = useState('');
    const [data, setData] = useState(null as Cites.Cite[] | null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [from, setFrom] = useState(null as boolean | null);
    const [grouped, setGrouped] = useState(false);

    useEffect(() => {
        document.title = 'Citations';
        const to = searchParams.get('to');
        const from = searchParams.get('from');
        var x;
        if (to && re.test(to)) {
            setFrom(false);
            x = to;
        } else if (from && re.test(from)) {
            setFrom(true);
            x = from;
        } else {
            setSearchParams({});
            return;
        }
        setInput(x);
        setDocId(x);
        setData(null);
        setError(null);
        setLoading(true);
        (from ? Server.getCitesFrom(x) : Server.getCitesTo(x))
            .then(setData).catch(setError).finally(() => setLoading(false));
    }, [ searchParams, re, setSearchParams ]);

    function toFromDidChange(frm: boolean) {
        if (!re.test(input)) {
            setFrom(frm);
            setDocId('');
            setData(null);
            setError(null);
            return;
        }
        if (frm)
            setSearchParams({ from: input });
        else
            setSearchParams({ to: input });
    }

    function handleKeyDown(event: React.KeyboardEvent<HTMLInputElement>) {
        if (event.key !== 'Enter')
            return;
        if (!re.test(input))
            return;
        if (from)
            setSearchParams({ from: input });
        else
            setSearchParams({ to: input });
    }

    function handleSearchButtonClick(event: React.MouseEvent<HTMLButtonElement>) {
        if (from)
            setSearchParams({ from: input });
        else
            setSearchParams({ to: input });
    }

    return (
        <>
            <header>
                <h1>Citations</h1>
                <p>
                        <span>Search for citations </span>
                        <select value={ from ? 'within' : 'to' } onChange={ e => toFromDidChange(e.target.value === 'within') }>
                            <option value="within">within</option>
                            <option value="to">to</option>
                        </select>
                        <span> document: </span>
                        <input type="text" disabled={ loading } placeholder="type/year/num" pattern="[a-z]{3,5}/\d{4}/\d+" value={ input } onChange={ e => setInput(e.target.value) } onKeyDown={ handleKeyDown } />
                        <span> </span>
                        <button disabled={ loading || !re.test(input) } onClick={ handleSearchButtonClick }>Search</button>
                </p>
            </header>
            { loading ? <p id="loading">loading citations...</p> :
                ( error ? <ErrorMessage error={ error } /> :
                    ( from ? <FromTable from={ docId } cites={ data } grouped={ grouped } setGrouped={ setGrouped } /> :
                            <GroupedToTable to={ docId } cites={ data } />
            ))}
        </>
    );

}

function ErrorMessage(props: { error: any }) {
    console.log(props.error);
    return <>
        <div className="error">The server returned an error:</div>
        <div className="error">{ props.error.status }: { props.error.message }</div>
    </>;
}

function FromTable(props: { from: string, cites: Cites.Cite[] | null, grouped: boolean, setGrouped: (g: boolean) => void }) {
    if (props.grouped)
        return <GroupedFromTable from={ props.from } cites={ props.cites } grouped={ props.grouped } setGrouped={ props.setGrouped } />
    else
        return <RawFromTable from={ props.from } cites={ props.cites } grouped={ props.grouped } setGrouped={ props.setGrouped } />
}

function GroupedFromTable(props: { from: string, cites: Cites.Cite[] | null, grouped: boolean, setGrouped: (g: boolean) => void }) {
    if (!props.cites)
        return null;
    if (!props.cites.length)
        return <p>There are no citations within document { props.from }.</p>
    const groups = Cites.groupCitesByDocumentCited(props.cites);
    return <>
        <OrderSelectionDiv grouped={ props.grouped } setGrouped={ props.setGrouped } />
        <DownloadLink cites={ groups.flatMap(group => group.cites) } from={ true } id={ props.from } />
        <table className="within sorted">
            <caption>Citations within document { props.from }</caption>
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
                        { j === 0 ? <CountCell count={ group.count } /> : <></> }
                        <CiteCell cite={ cite } />
                        <SourceSectionCell cite={ cite } />
                    </tr>
                )) }
                </tbody>
            )) }
        </table>
    </>;
}

function RawFromTable(props: { from: string, cites: Cites.Cite[] | null, grouped: boolean, setGrouped: (g: boolean) => void }) {
    if (!props.cites)
        return null;
    if (!props.cites.length)
        return <p>There are no citations within document { props.from }.</p>
    return <>
        <OrderSelectionDiv grouped={ props.grouped } setGrouped={ props.setGrouped } />
        <DownloadLink cites={ props.cites } from={ true } id={ props.from } />
        <table className="within raw">
            <caption>Citations within document { props.from }</caption>
            <thead>
                <tr>
                    <th>Citation Text</th>
                    <th>Location in Source Doc</th>
                </tr>
            </thead>
            <tbody>
                { props.cites.map((cite, i) => (
                <tr key={ i }>
                    <CiteCell cite={ cite } />
                    <SourceSectionCell cite={ cite } />
                </tr>
                )) }
            </tbody>
        </table>;
    </>;
}

function OrderSelectionDiv(props: { grouped: boolean, setGrouped: (g: boolean) => void }) {
    const grouped = props.grouped;
    const setGrouped = props.setGrouped;
    return <p>
        <span>Order by</span>
        <label>
            <input type="radio" name="grouped" checked={ !grouped } onChange={ e => setGrouped(!e.target.checked) } />
            <span>position in source doc</span>
        </label>
        <label>
            <input type="radio" name="grouped" checked={ grouped } onChange={ e => setGrouped(e.target.checked) } />
            <span>frequency of doc cited</span>
        </label>
    </p>;
}

function DownloadLink(props: { cites: Cites.Cite[], from: boolean, id: string }) {
    const url = makeDataURLForCSV(props.cites as Cites.Cite[]);
    const filename = "cites_" + (props.from ? 'within' : 'to') + "_" + props.id.replaceAll('/', '_') + ".csv";
    return <p className="right">
        <a href={ url } download={ filename }>download as csv</a>
    </p>;
}

function GroupedToTable(props: { to: string, cites: Cites.Cite[] | null }) {
    if (!props.cites)
        return null;
    if (!props.cites.length)
        return <p>There are no citations to document { props.to }.</p>
    const groups = Cites.groupCitesBySource(props.cites);
    return <>
        <p>Ordered by frequency of source doc</p>
        <DownloadLink cites={ groups.flatMap(group => group.cites) } from={ false } id={ props.to } />
        <table className="to">
            <>
            <caption>Citations to document { props.to }</caption>
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
                    { group.cites.map((cite: Cites.Cite, j: number) => (
                        <tr key={ i + '.' + j }>
                            { j === 0 ? <>
                                <CountCell count={ group.count } />
                                <SourceDocCell id={ cite.id } count={ group.count } />
                            </> : <></> }
                            <SourceSectionCell cite={ cite } />
                            <CiteCell cite={ cite } />
                        </tr>
                    )) }
                </tbody>
            )) }
            </>
        </table>;
    </>;
}

function CountCell(props: { count: number }) {
    const count = props.count;
    return <td rowSpan={ count }>
        <span>{ count }</span>
    </td>;
}

function SourceDocCell(props: { id: string, count: number }) {
    return <td rowSpan={ props.count }>
        <a target="_blank" rel="noreferrer" href={ Util.makeLinkToDoc(props.id, null) }>{ props.id }</a>
    </td>;
}

function SourceSectionCell(props: { cite: Cites.Cite }) {
    const cite = props.cite;
    const link = Util.makeLinkToDoc(cite.id, cite.section);
    const label = Util.makeSectionLabelFromSectionId(cite.section);
    return <td data-section={ cite.section }>
        <a target="_blank" rel="noreferrer" href={ link }>
            { label }
        </a>
    </td>;
}

function CiteCell(props: { cite: Cites.Cite }) {
    const cite = props.cite;
    const link = Util.makeLinkToCite(cite);
    return <td data-type="{ cite.type }" data-year="{ cite.year }" data-number="{ cite.number }">
        { link ? <a target="_blank" rel="noreferrer" href={ link }>{ cite.text }</a> : <span>{ cite.text }</span> }
    </td>;
}

function makeDataURLForCSV( cites: Cites.Cite[] ): string {
    var data = 'source id,source section,citation text,cite type,cite year,cite number\n';
    cites.forEach(cite => {
        data += cite.id + ',' + cite.section + ',"' + cite.text.replaceAll('"', '"') +
            '",' + cite.type + ',' + cite.year + ',' + cite.number + '\n';
    });
    const blob = new Blob([data], { type: 'text/csv' });
    return URL.createObjectURL(blob);
}

export default Citations;
