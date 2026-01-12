# STAGE 1: Build the app
FROM node:20-bullseye-slim AS builder

WORKDIR /app

# Install tools required for compiling Medusa dependencies (Python, C++, etc.)
RUN apt-get update && apt-get install -y python3 make g++ git

COPY package.json yarn.lock ./

# Install all dependencies (including dev ones needed for building)
RUN yarn install

COPY . .

# Build the Medusa application (creates .medusa/server folder)
RUN yarn build

# Install production-only dependencies INSIDE the build folder
WORKDIR /app/.medusa/server
RUN npm install --omit=dev

# STAGE 2: Run the app
FROM node:20-bullseye-slim

WORKDIR /app

# Copy only the built application from the builder stage
COPY --from=builder /app/.medusa/server /app

# Expose port 9000
EXPOSE 9000

# Medusa v2 production command
CMD ["npm", "start"]
