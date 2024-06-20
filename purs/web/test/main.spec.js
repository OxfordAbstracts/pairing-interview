import { expect, it, beforeEach } from "vitest";
import { main } from "../../output/Web.Main/index.js";
import { screen, waitFor, within } from "@testing-library/dom";
import userEvent from "@testing-library/user-event";
import { mappedAbstracts } from "./msw/mocks/handlers.js";

beforeEach(main);

async function expectLoaded() {
  await waitFor(() =>
    expect(screen.queryByText("Loading...")).not.toBeInTheDocument(),
  );
}

it("renders data returned by the API in the table", async () => {
  await screen.findByRole("table");
  await expectLoaded();

  const rows = await screen.findAllByRole("row");
  expect(rows).toHaveLength(101); // 100 rows and a header

  const cols = screen
    .getAllByRole("columnheader")
    .map((cell) => cell.textContent);
  expect(cols).toEqual([
    "Abstract ID",
    "Title",
    "Category",
    "Submitter Name",
    "Submitter Email",
  ]);

  const [firstAbstract] = mappedAbstracts;
  const [, firstRow] = screen.getAllByRole("row");
  const rowCells = within(firstRow).getAllByRole("cell");
  expect(rowCells[0]).toHaveTextContent(firstAbstract.id);
  expect(rowCells[1]).toHaveTextContent(firstAbstract.title);
  expect(rowCells[2]).toHaveTextContent(firstAbstract.category);
  expect(rowCells[3]).toHaveTextContent(
    `${firstAbstract.first_name} ${firstAbstract.last_name}`,
  );
  expect(rowCells[4]).toHaveTextContent(firstAbstract.email);
});

it("should allow sorting by clicking the column header", async () => {
  await expectLoaded();

  const titleCol = await screen.findByRole("columnheader", { name: "Title" });
  const categoryCol = await screen.findByRole("columnheader", {
    name: "Category",
  });
  const submitterNameCol = await screen.findByRole("columnheader", {
    name: "Submitter Name",
  });

  let [, firstRow] = await screen.findAllByRole("row");
  const [, initialTitle, initialCategory] = within(firstRow)
    .getAllByRole("cell")
    .map((cell) => cell.textContent);
  expect(firstRow).toHaveTextContent("science");

  // sort by category
  await userEvent.click(categoryCol);
  expect(firstRow).toHaveTextContent("engineering");

  // change sort order to desc
  await userEvent.click(categoryCol);
  expect(firstRow).toHaveTextContent("technology");

  // sort by title
  await userEvent.click(titleCol);
  expect(firstRow).toHaveTextContent(
    "A alo iure aetas caelestis aeneus rerum creber",
  );

  // change sort order to desc
  await userEvent.click(titleCol);
  expect(firstRow).toHaveTextContent(
    "Xiphias volup super textilis artificiose triumphus saepe chirographum vindico clarus",
  );

  // sort by submitter name
  await userEvent.click(submitterNameCol);
  expect(firstRow).toHaveTextContent("Aaliyah Prohaska");

  // change sort order to desc
  await userEvent.click(submitterNameCol);
  expect(firstRow).toHaveTextContent("Zora Graham");

  // remove sort
  await userEvent.click(submitterNameCol);
  expect(firstRow).toHaveTextContent(initialTitle);
  expect(firstRow).toHaveTextContent(initialCategory);
});

it.skip("TODO: test search functionality", () => {});
