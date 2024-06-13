#!/bin/bash

# Install pnpm globally
npm install -g pnpm@9.0.2

npm install -g spago@next

cd node

# Install dependencies using pnpm
pnpm install

pnpm run seed

cd ../purs

pnpm install 

spago build

pnpm dev