import { faker } from "@faker-js/faker";
import _ from "lodash";

faker.seed(583);

const removeApostrophes = (str) => str.replace(/'/g, "''");

const past = () => new Date(faker.date.past()).toISOString();

export const users = _.range(10000).map(() => ({
  id: faker.string.uuid(),
  created_at: past(),
  first_name: removeApostrophes(faker.person.firstName()),
  last_name: removeApostrophes(faker.person.lastName()),
  email: faker.internet.email(),
  password: faker.internet.password(),
}));

export const abstracts = _.range(10000).map(() => ({
  id: faker.string.uuid(),
  created_at: past(),
  title: faker.lorem.sentence(),
  category: faker.helpers.arrayElement([
    "science",
    "technology",
    "engineering",
    "mathematics",
  ]),
  body: faker.lorem.paragraphs(),
  user_id: faker.helpers.arrayElement(users).id,
}));

export const authors = _.range(100000).map(() => ({
  id: faker.string.uuid(),
  created_at: past(),
  user_id: faker.helpers.arrayElement(users).id,
  abstract_id: faker.helpers.arrayElement(abstracts).id,
  institution: removeApostrophes(faker.company.name()),
}));
