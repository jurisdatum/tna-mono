
import { Suspense } from 'react';
import { Await, useLocation } from 'react-router-dom';

import { Loading } from '../comp/shared';

import './scss/primary.scss';
import './scss/secondary.scss';
import './scss/euretained.scss';

export default function Document() {

    const location = useLocation();

    const fetchDoc = async () => {
        const url = 'https://lgu-enriched.s3.eu-west-2.amazonaws.com' + location.pathname + '/data.html';
        let response = await fetch(url);
        if (!response.ok)
            return null;
        let html = await response.text();
        html = extractArticle(html);
        return html;
    }

    const html = fetchDoc();

    return <Suspense fallback={ <p>loading <Loading/></p> }>
        <Await resolve={ html } errorElement={ <p>There was an error</p> }>
            { (html: string | null) =>
                html ? <div id="legislation" dangerouslySetInnerHTML={ { __html: html } }></div> : <p>Not found</p>
            }
        </Await>
    </Suspense>;
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
