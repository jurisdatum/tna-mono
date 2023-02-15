
import { Suspense, useEffect, useState } from 'react';
import { Link, Outlet, useLoaderData, useParams, Params, Await, defer, useLocation } from 'react-router-dom';

import { fetchYears, fetchDocs } from '../server';
import { Loading } from './shared';

import './browse.css';

export function loadTypes() {
    return ['aep','aip','anaw','aosp','apgb','apni','asc','asp','mnia','mwa','nia','nisi','nisr','nisro','ssi','ukci','ukcm','ukla','ukmo','ukpga','uksi','uksro','wsi'];
}

export function Browse() {

    const params = useParams();
    const types = useLoaderData() as string[];
    const [selectedType, setSelectedType] = useState(params.type);
    const location = useLocation();

    useEffect(() => { setSelectedType(params.type); }, [location]);

    return <div id='browse'>
        <ul>
            { types.map(tp => <li key={ tp } className={ tp === selectedType ? 'selected' : undefined }>
                <Link to={ tp } onClick={ () => setSelectedType(tp) }>{ tp }</Link>
            </li>) }
        </ul>
        <Outlet />
    </div>;

}

export function loadYears({ params }: { params: Params }) {
    const type = params.type as string;
    return defer({ years: fetchYears(type) });
}

export function Years() {

    const params = useParams() as { type: string, year: string };
    const { years } = useLoaderData() as { years: Promise<number[]> };
    const [selectedYear, setSelectedYear] = useState(params.year ? parseInt(params.year) : undefined);
    const location = useLocation();

    useEffect(() => { setSelectedYear(params.year ? parseInt(params.year) : undefined); }, [location]);

    return <Suspense fallback={ <ul><li><Loading/></li></ul> }>
        <Await resolve={ years } errorElement={ <ul><li>error</li></ul> }>
            { (years: number[]) => <>
                <ul>
                    { years.map(yr => <li key={ yr } className={ yr === selectedYear ? 'selected' : undefined }>
                        <Link to={ yr.toString() } onClick={ () => setSelectedYear(yr) }>{ yr }</Link>
                    </li>) }
                </ul>
                <Outlet />
            </> }
        </Await>
    </Suspense>;

}

export function loadDocs({ params }: { params: Params }) {
    const type = params.type as string;
    const year = parseInt(params.year as string);
    return defer({ docs: fetchDocs(type, year) });
}

export function Docs() {

    const data = useLoaderData() as { docs: Promise<any[]> };

    return <Suspense fallback={ <ul><li><Loading/></li></ul> }>
        <Await resolve={ data.docs } errorElement={ <ul><li>error</li></ul> }>
            { (docs: any[]) => <ul>
                { docs.map(doc => <li key={ doc.number }>
                    <Link to={ '/' + doc.id }>
                        <span>{ doc.number }</span>
                        <span>{ doc.title }</span>
                    </Link>
                </li>) }
            </ul>
            }
        </Await>
    </Suspense>;

}
