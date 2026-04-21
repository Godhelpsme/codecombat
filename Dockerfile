FROM node:22.22.1-bookworm-slim AS build

WORKDIR /app

ENV BOWER_ALLOW_ROOT=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends git python3 make g++ && \
    rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json bower.json .bowerrc ./
COPY patches ./patches

RUN npm ci

COPY . .

RUN npm run build

FROM node:22.22.1-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8080

COPY --from=build /app /app

RUN npm prune --omit=dev && npm cache clean --force

EXPOSE 8080

USER node

CMD ["npm", "start"]
