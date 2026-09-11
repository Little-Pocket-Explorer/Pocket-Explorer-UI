FROM node:24-bookworm-slim
WORKDIR /app/web
COPY web/package*.json ./
RUN npm ci
COPY web ./
COPY shared /app/shared
RUN npm run build && mkdir -p /data && chown node:node /data
USER node
ENV DATABASE_PATH=/data/shares.sqlite LISTEN_HOST=0.0.0.0 PORT=4174
EXPOSE 4174
CMD ["npm", "start"]
