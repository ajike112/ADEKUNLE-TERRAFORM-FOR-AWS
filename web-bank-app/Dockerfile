##############################
# Stage 1 — Build environment
##############################
FROM node:18-slim AS builder

WORKDIR /usr/src/app

# Copy dependency manifests
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy full source
COPY . .

RUN echo "Build stage complete"

##############################
# Stage 2 — Production image
##############################
FROM node:18-slim AS production

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/server.js ./server.js
COPY --from=builder /usr/src/app/routes ./routes
COPY --from=builder /usr/src/app/public ./public

ENV NODE_ENV=production \
    PORT=3000

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

USER appuser

CMD ["node", "server.js"]
