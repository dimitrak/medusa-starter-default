FROM node:20-alpine AS base

WORKDIR /app

# FIX 1: Install system tools required to build Medusa dependencies
RUN apk add --no-cache python3 make g++ git

COPY package.json yarn.lock ./

# FIX 2: Removed '--frozen-lockfile' so it can auto-correct dependency errors
RUN yarn install

COPY . .

RUN yarn build

FROM node:20-alpine

WORKDIR /app

# Re-install simple production dependencies
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/package.json ./package.json
COPY --from=base /app/.medusa/server ./build

EXPOSE 9000

CMD ["yarn", "start"]
