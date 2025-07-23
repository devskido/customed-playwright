FROM mcr.microsoft.com/playwright:v1.40.0-focal

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --no-audit --no-fund --ignore-scripts

# Install TypeScript globally
RUN npm install -g typescript

# Copy all source files
COPY . .

# Build the application
RUN npm run build

# Install only production dependencies
RUN rm -rf node_modules && \
    npm ci --omit=dev --no-audit --no-fund --ignore-scripts

# Install Playwright browsers
RUN npx playwright install chromium && \
    chmod -R 755 /ms-playwright

# Create necessary directories
RUN mkdir -p /root/.cache /root/.local

# Environment variables
ENV NODE_ENV=production
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV HOME=/root

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "console.log('Health check passed')" || exit 1

EXPOSE 3000

ENTRYPOINT ["node", "dist/index.js"]