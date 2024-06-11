import jwt from "jsonwebtoken";

export const signImpl = (payload) => () =>
  jwt.sign(payload, secret, { expiresIn: "1h" });


export const secret = "my-secret"