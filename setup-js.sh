#!/bin/bash

# Install pnpm globally
npm install -g pnpm@9.0.2

cd js

# Install dependencies using pnpm
pnpm install

pnpm run seed

pnpm run dev
