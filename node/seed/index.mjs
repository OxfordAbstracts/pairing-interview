import "dotenv/config";
import { faker } from "@faker-js/faker";
import _ from "lodash";
import pg from "pg";

console.log('seeding DB')

const pool = new pg.Pool();

faker.seed(583);

const removeApostrophes = (str) => str.replace(/'/g, "''");

const past = () => new Date(faker.date.past()).toISOString();

const users = _.range(10000).map(() => ({
  id: faker.string.uuid(),
  created_at: past(),
  first_name: removeApostrophes(faker.person.firstName()),
  last_name: removeApostrophes(faker.person.lastName()),
  email: faker.internet.email(),
  password: faker.internet.password(),
}));

const abstracts = _.range(10000).map(() => ({
  id: faker.string.uuid(),
  created_at: past(),
  title: faker.lorem.sentence(),
  category: faker.helpers.arrayElement(['science', 'technology', 'engineering', 'mathematics']), 
  body: faker.lorem.paragraphs(),
  user_id: faker.helpers.arrayElement(users).id,
}));

const authors = _.range(100000).map(() => ({
  id: faker.string.uuid(),
  created_at: past(),
  user_id: faker.helpers.arrayElement(users).id,
  abstract_id: faker.helpers.arrayElement(abstracts).id,
  institution: removeApostrophes(faker.company.name()),
}));

const createTablesIfNotExistsSql = `
create table if not exists users (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz not null default NOW(),
    first_name varchar(255),
    last_name varchar(255),
    email varchar(255),
    password varchar(255)
);

create table if not exists abstracts (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz not null default NOW(),
    title varchar(255) not null,
    category varchar(255),
    body text not null,
    user_id uuid references users(id)
);

create table if not exists authors (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz not null default NOW(),
    user_id uuid references users(id),
    abstract_id uuid references abstracts(id),
    institution varchar(255)
);`;

await pool.query(createTablesIfNotExistsSql);

const truncateTablesSql = `
truncate table authors cascade;
truncate table abstracts cascade;
truncate table users cascade;
`;

await pool.query(truncateTablesSql);


const insertUsersSql = `INSERT INTO users 
(id, created_at, first_name, last_name, email, password) 
VALUES ${users
  .map(
    (user) =>
      `(E'${user.id}', E'${user.created_at}', E'${user.first_name}', E'${user.last_name}', E'${user.email}', E'${user.password}')`
  )
  .join(", ")}`;

const insertAbstractsSql = `INSERT INTO abstracts
(id, created_at, title, category, body, user_id)
VALUES ${abstracts
  .map(
    (abstract) =>
      `(E'${abstract.id}', E'${abstract.created_at}', E'${abstract.title}', E'${abstract.category}', E'${abstract.body}', E'${abstract.user_id}')`
  )
  .join(", ")}`;

const insertAuthorsSql = `INSERT INTO authors
(id, created_at, user_id, abstract_id, institution)
VALUES ${authors
  .map(
    (author) =>
      `(E'${author.id}', E'${author.created_at}', E'${author.user_id}', E'${author.abstract_id}', E'${author.institution}')`
  )
  .join(", ")}`;

await pool.query(insertUsersSql);
await pool.query(insertAbstractsSql);
await pool.query(insertAuthorsSql);

console.log('DB seeded successfully')

process.exit(0);