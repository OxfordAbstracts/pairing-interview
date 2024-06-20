import { http, HttpResponse } from "msw";
import { abstracts, users } from "../../../../../js/seed/fixture";

const usersById = Object.fromEntries(users.map((user) => [user.id, user]));

export const mappedAbstracts = abstracts.map((abstract) => {
  const user = usersById[abstract.user_id];
  return {
    id: abstract.id,
    title: abstract.title,
    category: abstract.category,
    first_name: user.first_name,
    last_name: user.last_name,
    email: user.email,
  };
});

// provides a mock of the API for tests, which returns similar data
export const handlers = [
  http.get("http://localhost:3000/abstracts", () => {
    return HttpResponse.json(mappedAbstracts);
  }),
];
