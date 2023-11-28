
import { createBrowserRouter, Navigate, Outlet, RouterProvider } from 'react-router-dom';

import { Browse, Docs, loadDocs, loadTypes, loadYears, Years } from './comp/browse';
import Citations, { loadCitations } from './cites/citations';
import Document, { loadDocument } from './docs/document';

import './App.css';
import NavBar from './comp/navbar';
import CiteTest from './cites/citetest';
import Effects from './effects/effects';

const router = createBrowserRouter([
  {
    path: "/",
    element: <><NavBar /><div><Outlet /></div></>,
    children: [
      {
        path: "/",
        element: <Navigate to="/citetest" />
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
      }
    ]
  }, {
    path: "/citetest",
    element: <CiteTest />
  }, {
    path: "/effects",
    element: <Effects />
  }, {
    path: "*",
    loader: loadDocument,
    element: <Document />
  }
]);

export default function App() {
  return <RouterProvider router={ router } />;
}
