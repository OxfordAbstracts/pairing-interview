# OA Abstract table 

## Setup

Before reading the rest of this, you can setup the project with the following steps: 

In your terminal run `docker-compose up` to start the database.

In a separate terminal, run the setup script. 

If you plan to work in node/react this is `setup-node.sh`. If you plan to work in puresript this is `setup-purs.sh`.

## Intro

The goal of this exercise is to create a table that displays a list of abstracts.

To start with, we have added a simple server and the scaffolding for a web app. 

Full designs for the table can be viewed here https://www.figma.com/design/ikljIg7RZRNNvJFkHRgFJa/coding-challenge?node-id=0-1&t=fvDJDqYVn2Sjdzge-1. 

These designs are just a guideline and the implementation does not need to be pixel perfect. For this exercise, we are more interested in functionality than styling. If we have time at the end, styling can be improved. 

Other than styling, please work as you would in a regular work setting. 

If there are any requirements that need clarification or you are unsure of anything, please ask.

Don't worry if you do not complete all of the requirements. We would prefer that you don't rush. 

## Requirements

1. Show a basic table. It should display the first 100 abstracts with the headers: Title, Category, Submitter name, submitter email and when the abstracts was created.
2. Add sorting to the table. When clicking on a header it should be possible to sort the rows based on that column, both ascending and descending.
3. Add a search to the table. When the user types in the search input, the rows should be filtered based on whether they contain the text in the search input.
4. When a user clicks on a row, open a sidebar or modal that displays the authors and body of the abstract.
5. Add paging to the table. 

## Stretch Goals

1. Add the ability to edit the category from the table.
2. Add virtual scrolling to the table.
3. Add category filtering.
