import jwt from "jsonwebtoken";

export const signImpl = (payload) => () =>
  jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: "1h" });
