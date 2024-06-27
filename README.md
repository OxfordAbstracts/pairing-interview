# OA Abstract table

## Setup

Before reading the rest of this, you can setup the project with the following steps:

In your terminal run `docker-compose up` to start the database.

In a separate terminal, run the setup script.

If you plan to work in JS/React this is `setup-js.sh`. If you plan to work in Purescript this is `setup-purs.sh`.

## Intro

The goal of this exercise is to create a table that displays a list of abstracts.

To start with, we have added a simple server and the scaffolding for a web app.

Full designs for the table can be viewed here https://www.figma.com/design/ikljIg7RZRNNvJFkHRgFJa/coding-challenge?node-id=0-1&t=fvDJDqYVn2Sjdzge-1.

These designs are just a guideline and the implementation does not need to be pixel perfect. For this exercise, we are more interested in functionality than styling. If we have time at the end, styling can be improved.

Other than styling, please work as you would in a regular work setting.

If there are any requirements that need clarification or you are unsure of anything, please ask.

Don't worry if you do not complete all of the requirements. We would prefer that you don't rush.

## Testing
There are some tests using Vitest (like Jest) and Testing Library for requirements 1 and 2 below.
You can run `pnpm test` in a separate terminal to continually run the tests while working on the implementation.

3 has no test, but there is a TODO in the test file if you feel comfortable adding one.
It is possible to do this in a TDD fashion if that's how you prefer to work.

## Requirements

1. Show a basic table. It should display the first 100 abstracts with the headers: Title, Category, Submitter name, Submitter email and the abstract ID.
2. Add sorting to the table. When clicking on a header it should be possible to sort the rows based on that column, both ascending and descending.
3. Add a search to the table. When the user types in the search input, the rows should be filtered based on whether they contain the text in the search input.

## Stretch Goals

1. When a user clicks on a row, open a sidebar or modal that displays the authors and body of the abstract.
2. Add paging to the table.
3. Add virtual scrolling to the table.
