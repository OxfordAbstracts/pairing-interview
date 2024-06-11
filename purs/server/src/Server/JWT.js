import jwt from "jsonwebtoken";

export const signImpl = (payload) => () =>
  jwt.sign(payload, secret, { expiresIn: "1h" });

export const verifyImpl = (token) => () =>
  jwt.verify(token, secret);

export const secret = "my-secret"