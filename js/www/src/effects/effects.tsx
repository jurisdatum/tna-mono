
import { useState } from 'react';
import { Loading } from '../comp/shared';

const pwKey = 'JURIS_DATUM_PASSWORD';

export default function Effects() {

    const [ state, setState ] = useState(0);
    const [ password, setPassword ] = useState(localStorage.getItem(pwKey) || '');
    const [ showPassword, setShowPassword ] = useState(false);
    const [ provision, setProvision ] = useState(sample);
    const [ effects, setEffects ] = useState([] as any[]);

    const start = async () => {
        if (!password)
            return;
        setState(1);
        const url = 'https://api.tna.jurisdatum.com/ai/effects?password=' + password;
        const response = await fetch(url, { method: 'POST', body: provision });
        if (!response.ok) {
            localStorage.removeItem(pwKey);
            setState(-1);
            let message = await response.text();
            console.error(message);
            throw message;
        }
        localStorage.setItem(pwKey, password);
        setState(2);
        const data = await response.json() as { thread: string, run: string };
        setTimeout(() => { check(data); }, 5000);
    };

    const check = async (tr: { thread: string, run: string }) => {
        const url = `https://api.tna.jurisdatum.com/ai/effects?password=${password}&thread=${tr.thread}&run=${tr.run}`;
        const response = await fetch(url);
        if (response.status === 204) {
            setTimeout(() => { check(tr); }, 5000);
            return;
        }
        if (!response.ok) {
            setState(-1);
            let message = await response.text();
            console.error(message);
            throw message;
        }
        setState(3);
        const data = await response.json();
        setEffects(data);
    }

    return <div>
        <h1 style={ { textAlign: 'center' } }>Extract Effects</h1>
        <p style={ { position: 'absolute', top: '0', right: '1em', textAlign: 'right' } }>
            <span>password: </span>
            <input type={ showPassword ? 'text' : 'password' } value={ password } onChange={ (e) => { setPassword(e.target.value); } } style={ { width: '24ch' } }></input>
            <span> </span>
            { showPassword ?
                <span style={ { verticalAlign: 'text-top' } } onClick={ () => { setShowPassword(false); } }><Visibilty/></span> :
                <span style={ { verticalAlign: 'text-top' } } onClick={ () => { setShowPassword(true); } }><VisibiltyOff/></span> }
        </p>
        <div id="effects">
            <div style={ { position: 'absolute', width: '40vw' } }>
                <p style={ { textAlign: 'center' } }>
                    <span>Amending Provision </span>
                    <button disabled={ !password || state === 1 || state === 2 } onClick={ start }>Extract</button>
                </p>
                <textarea style={ { width: 'calc(40vw - 15pt)', marginLeft: '9pt', height: '50vh', resize: 'vertical' } } value={ provision } onChange={ (e) => { setProvision(e.target.value); } }></textarea>
            </div>
            <div style={ { position: 'absolute', left: 'calc(40vw + 1em)', width: 'calc(60vw - 2em)' } }>
                <p style={ { textAlign: 'center' } }>
                    <span>Effects</span>
                </p>
                { state === 1 && <p style={ { textAlign: 'center' } }><span>Extracting <Loading /></span></p> }
                { state === -1 && <p style={ { textAlign: 'center' } }><span>There was an error</span></p> }
                { state === 2 && <p style={ { textAlign: 'center' } }><span>Extracting <Loading /></span></p> }
                { state === 3 && <table style={ { border: 'thin dotted', borderCollapse: 'collapse', fontSize: 'small' } }>
                    <thead>
                        <tr>
                            <th style={ { border: 'thin dotted', textAlign: 'left', padding: '3pt', verticalAlign: 'top' } }>Target Act</th>
                            <th style={ { border: 'thin dotted', textAlign: 'left', padding: '3pt', verticalAlign: 'top' } }>Target Provision</th>
                            {/* <th style={ { textAlign: 'left', verticalAlign: 'top' } }>Target Location</th> */}
                            <th style={ { border: 'thin dotted', textAlign: 'left', padding: '3pt', verticalAlign: 'top' } }>Change Type</th>
                            <th style={ { border: 'thin dotted', textAlign: 'left', padding: '3pt', verticalAlign: 'top' } }>Text Removed</th>
                            <th style={ { border: 'thin dotted', textAlign: 'left', padding: '3pt', verticalAlign: 'top' } }>Text Inserted</th>
                        </tr>
                    </thead>
                    <tbody>
                        { effects.map(effect => <tr>
                            <td style={ { border: 'thin dotted', padding: '3pt', verticalAlign: 'top' } }>{ effect['target_act'] }</td>
                            <td style={ { border: 'thin dotted', padding: '3pt', verticalAlign: 'top' } }>{ effect['target_provision'] }</td>
                            {/* <td> style={ { verticalAlign: 'top' } }{ effect['target_location'] }</td> */}
                            <td style={ { border: 'thin dotted', padding: '3pt', verticalAlign: 'top' } }>{ effect['change_type'] }</td>
                            <td style={ { border: 'thin dotted', padding: '3pt', verticalAlign: 'top' } }>{ effect['removed'] }</td>
                            <td style={ { border: 'thin dotted', padding: '3pt', verticalAlign: 'top' } }>{ effect['inserted'] }</td>
                        </tr>) }
                    </tbody>
                </table> }
            </div>
        </div>
    </div>;

}

const sample = `Amendment of the Customs (Import Duty) (EU Exit) Regulations 2018
2.—(1) The Customs (Import Duty) (EU Exit) Regulations 2018 are amended as follows.
(2) In regulation 2 (interpretation) after the definition of “the UCC”, insert—
““the UK sector of the continental shelf” means the areas designated by Order in Council under section 1(7) of the Continental Shelf Act 1964;”.
(3) In regulation 4 (notification of importation)—
(a) in paragraph (1) for “and (3AC)” substitute “, (3AC), (6A) and (6C)”;
(b) in paragraph (3)(c) for “and (6)” substitute “, (6), (6A) and (6B)”;
(c) in paragraph (3A)—
(i) at the end of sub-paragraph (b) omit “and”;
(ii) at the end of sub-paragraph (c) for “regulation,” insert “regulation; and”;”.`;

function Visibilty() {
    return <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 -960 960 960" width="24">
        <path d="M480-320q75 0 127.5-52.5T660-500q0-75-52.5-127.5T480-680q-75 0-127.5 52.5T300-500q0 75 52.5 127.5T480-320Zm0-72q-45 0-76.5-31.5T372-500q0-45 31.5-76.5T480-608q45 0 76.5 31.5T588-500q0 45-31.5 76.5T480-392Zm0 192q-146 0-266-81.5T40-500q54-137 174-218.5T480-800q146 0 266 81.5T920-500q-54 137-174 218.5T480-200Zm0-300Zm0 220q113 0 207.5-59.5T832-500q-50-101-144.5-160.5T480-720q-113 0-207.5 59.5T128-500q50 101 144.5 160.5T480-280Z"/>
    </svg>;
}
function VisibiltyOff() {
    return <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 -960 960 960" width="24">
        <path d="m644-428-58-58q9-47-27-88t-93-32l-58-58q17-8 34.5-12t37.5-4q75 0 127.5 52.5T660-500q0 20-4 37.5T644-428Zm128 126-58-56q38-29 67.5-63.5T832-500q-50-101-143.5-160.5T480-720q-29 0-57 4t-55 12l-62-62q41-17 84-25.5t90-8.5q151 0 269 83.5T920-500q-23 59-60.5 109.5T772-302Zm20 246L624-222q-35 11-70.5 16.5T480-200q-151 0-269-83.5T40-500q21-53 53-98.5t73-81.5L56-792l56-56 736 736-56 56ZM222-624q-29 26-53 57t-41 67q50 101 143.5 160.5T480-280q20 0 39-2.5t39-5.5l-36-38q-11 3-21 4.5t-21 1.5q-75 0-127.5-52.5T300-500q0-11 1.5-21t4.5-21l-84-82Zm319 93Zm-151 75Z"/>
    </svg>;
}
