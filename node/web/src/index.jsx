import * as React from "react";
import { createRoot } from "react-dom/client";
import {
  createBrowserRouter,
  RouterProvider,
  Route,
  Link,
} from "react-router-dom";
import Home from "./pages/home";
import "./index.css";
import SignIn from "./pages/sign-in";

const router = createBrowserRouter([
  {
    path: "/",
    element: Home(),
  },
  {
    path: "sign-in",
    element: SignIn(),
  },
  {
    path: "about",
    element: <div>About</div>,
  },
]);

createRoot(document.getElementById("root")).render(
  <RouterProvider router={router} />
);
