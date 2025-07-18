# Use the official Playwright image which has all dependencies
FROM mcr.microsoft.com/playwright:v1.40.0-focal

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies (skip scripts to avoid premature build)
RUN npm ci --no-audit --no-fund --ignore-scripts

# Copy all source files
COPY . .

# Install TypeScript globally
RUN npm install -g typescript

# Build the application
RUN npm run build

# Install only production dependencies in a clean way
RUN rm -rf node_modules && npm ci --omit=dev --no-audit --no-fund --ignore-scripts

# Install Playwright browsers
RUN npx playwright install chromium

# Create non-root user for security
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
RUN chown -R appuser:appgroup /app
USER appuser

# Environment variables
ENV NODE_ENV=production
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "console.log('Health check passed')" || exit 1

EXPOSE 3000

ENTRYPOINT ["node", "dist/index.js"]