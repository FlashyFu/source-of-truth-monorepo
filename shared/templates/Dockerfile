# Multi-stage Dockerfile for Node.js apps (16+), production-ready, small image, non-root user
#
# Build stage: installs dependencies and builds assets
# Final stage: runs compiled app in a minimal image

# Choose an LTS build image with npm installed
FROM node:18-bullseye AS build

# Create app directory
WORKDIR /usr/src/app

# Copy package descriptors first for better caching
COPY package*.json ./
# If using yarn: COPY yarn.lock ./

# Install deps (only needed for build)
RUN npm ci --only=production=false

# Copy rest of source
COPY . .

# Example build step (uncomment if using transpilers/bundlers)
# RUN npm run build

# Prune dev deps for smaller final image (optional)
RUN npm prune --production

# Final stage: minimal runtime
FROM node:18-bullseye-slim AS runtime

# Create non-root user
RUN useradd --user-group --create-home --shell /bin/false appuser

WORKDIR /home/appuser/app

# Copy node_modules and dist from build stage
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app ./

# Security: drop capabilities
USER appuser

# Environment variables (set in runtime or orchestrator)
ENV NODE_ENV=production
ENV PORT=3000

# Expose port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD node -e "require('./healthcheck')().then(()=>process.exit(0)).catch(()=>process.exit(1))"

# Start command
CMD ["node", "server.js"]

# Notes:
# - Keep build-time secrets out of Docker by using build args or secret mounts.
# - Consider using distroless or scratch base for even smaller runtime images.
# - Provide a small healthcheck module at ./healthcheck.js returning a Promise.
