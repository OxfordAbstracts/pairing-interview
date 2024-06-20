import { server } from "./msw/server";
import { beforeAll, afterEach, afterAll } from "vitest";
import "@testing-library/jest-dom/vitest";

beforeAll(() => {
  server.listen();
});

afterEach(() => {
  server.resetHandlers();
  document.body.innerHTML = "";
});

afterAll(() => {
  server.close();
});
