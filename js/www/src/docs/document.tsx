
import { Suspense, useEffect } from 'react';
import { Await, useLoaderData, useLocation } from 'react-router-dom';

import { fetchDoc } from '../server';
import { Loading } from '../comp/shared';

import './scss/legislation.scss';

export function loadDocument({ request }: { request: Request }) {
    const path = new URL(request.url).pathname;
    return { html: fetchDoc(path) };
}

export default function Document() {

    const { html } = useLoaderData() as { html: Promise<string | null> };

    const location = useLocation();

    useEffect(() => {
        const target = document.getElementById(location.hash.substring(1));
        if (!target)
            return;
        setTimeout(() => { target.scrollIntoView(); }, 100);
    }, [ location ]);

    return <Suspense fallback={ <p>loading <Loading/></p> }>
        <Await resolve={ html } errorElement={ <p>There was an error</p> }>
            { (html: string | null) =>
                html ? <div>
                    <div id="panel">
                        <p>
                            <a href={ 'https://lgu-enriched.s3.eu-west-2.amazonaws.com' + location.pathname + '/data.xml' } target="_blank" rel="noreferrer">CLML</a>
                        </p>
                        <p>
                            <a href={ 'https://lgu-enriched.s3.eu-west-2.amazonaws.com' + location.pathname + '/data.akn' } target="_blank" rel="noreferrer">AKN</a>
                        </p>
                    </div>
                    <div id="legislation" dangerouslySetInnerHTML={ { __html: html } }></div>
                </div> : <p>Not found</p>
            }
        </Await>
    </Suspense>;
}
