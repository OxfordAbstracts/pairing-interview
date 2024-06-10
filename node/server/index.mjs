import "dotenv/config";
import express from "express";
import db from "./db.mjs";

const app = express();
const port = 3000;

app.get("/", (_req, res) => {
  res.send("Hello World!");
});

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

app.post('/sign-in', async (req, res) => {
  const { email, password } = req.body;

  const users = await db.query('SELECT * FROM users');

  const user = users.find(user => user.email === email && user.password === password);

  if (user) {
    res.send(user);
  } else {
    res.status(401).send();
  }
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
