import "dotenv/config";
import express from "express";
import db from "./db.mjs";
import cors from "cors";

const app = express();
app.use(cors());
const port = 3000;

app.get("/healthcheck", async (_req, res) => {
  const healthcheck = {
    uptime: process.uptime(),
    message: "OK",
    timestamp: Date.now(),
  };
  try {
    res.send(healthcheck);
  } catch (error) {
    healthcheck.message = error;
    res.status(503).send();
  }
});

app.get("/abstracts", async (_req, res) => {
  const abstracts = await db.query(`
  select title, category, first_name, last_name, email
  from abstracts
  inner join users on abstracts.user_id = users.id`);

  res.json(abstracts.rows);
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
