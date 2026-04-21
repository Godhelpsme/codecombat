FROM node:22.22.1 AS builder

WORKDIR /app

RUN npm install -g bower

COPY package.json package-lock.json* bower.json .bowerrc ./
RUN npm install --maxsockets 10 --ignore-scripts && bower install --allow-root

COPY . .
RUN npm run postinstall && \
    NODE_OPTIONS='--max-old-space-size=8192' npm run build

FROM node:22.22.1-slim

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --omit=dev --maxsockets 10 --ignore-scripts && npm run postinstall

COPY --from=builder /app/public_coco ./public_coco
COPY --from=builder /app/bower_components ./bower_components
COPY server.js server_config.js server_setup.js index.js runWebpack.js setup-aether.js compile-static-templates.js ./
COPY app ./app
COPY vendor ./vendor
COPY development ./development

EXPOSE 3000

USER 10001

CMD ["node", "index.js"]
