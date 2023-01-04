
import { createBrowserRouter, Navigate, RouterProvider } from 'react-router-dom';

import './App.css';

import Citations from './cites/citations';

const router = createBrowserRouter([
  {
    path: "/citations",
    element: <Citations />,
  },
  {
    path: "*",
    element: <Navigate replace to="/citations" />,
  }
]);

function App() {
  return <div className="App">
    <RouterProvider router={ router } />
  </div>;
}

export default App;
