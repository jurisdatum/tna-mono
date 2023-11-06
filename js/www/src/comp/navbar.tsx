
import { NavLink } from 'react-router-dom';

export default function NavBar() {

    return <nav>
        <NavLink to='/browse'>Browse documents</NavLink>
        <NavLink to='/citations'>Search citations</NavLink>
        <NavLink to='/citetest'>Test citations</NavLink>
    </nav>;

}
