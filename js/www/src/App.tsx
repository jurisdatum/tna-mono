
import { createBrowserRouter, Link, RouterProvider } from 'react-router-dom';

import { Browse, Docs, loadDocs, loadTypes, loadYears, Years } from './comp/browse';
import Citations, { loadCitations } from './cites/citations';
import Document from './docs/document';

import './App.css';

const router = createBrowserRouter([
  {
    path: "/",
    element: <div id='browse'><ul><li><Link to='browse'>Browse legislation</Link></li><li><Link to='citations'>Search citations</Link></li></ul></div>,
  }, {
    path: "/citations",
    element: <Citations />,
    loader: loadCitations
  }, {
    path: "/browse",
    element: <Browse />,
    loader: loadTypes,
    children: [
      {
        path: "/browse/:type",
        element: <Years />,
        loader: loadYears,
        children: [
          {
            path: "/browse/:type/:year",
            element: <Docs />,
            loader: loadDocs
          }
        ]
      }
    ]
  }, {
    path: "*",
    element: <Document />
  }
]);

export default function App() {
  return <RouterProvider router={ router } />;
}
