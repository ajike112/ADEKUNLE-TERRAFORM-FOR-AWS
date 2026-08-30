##############################
# Stage 1 — Build environment
##############################
FROM node:18-alpine AS builder

# Create app directory
WORKDIR /usr/src/app

# Install dependencies first (better caching)
COPY package.json package-lock.json* ./
RUN npm ci

# Copy full source
COPY . .

# Build step (if you add React or bundling later)
# For now, this is a placeholder
RUN echo "Build stage complete"


##############################
# Stage 2 — Production image
##############################
FROM node:18-alpine AS production

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /usr/src/app

# Copy only necessary files from builder
COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/server.js ./server.js
COPY --from=builder /usr/src/app/routes ./routes
COPY --from=builder /usr/src/app/public ./public

# Environment variables
ENV NODE_ENV=production \
    PORT=3000

# Expose port
EXPOSE 3000

# Healthcheck for container orchestration (EKS, ECS, Docker)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/ || exit 1

# Switch to non-root user
USER appuser

# Start the app
CMD ["node", "server.js"]
