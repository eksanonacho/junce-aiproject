FROM node:22-alpine AS runner

# Create non-root user
RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

# Copy source and install deps inside Docker (Linux binaries)
COPY package.json pnpm-lock.yaml .npmrc ./
RUN npm install -g pnpm && pnpm install --prod --ignore-scripts --no-frozen-lockfile

COPY dist ./dist
COPY generated ./generated
COPY prisma ./prisma
COPY prisma.config.ts ./
COPY .env.example ./

# Create uploads directory with correct ownership
RUN mkdir -p uploads && chown -R app:app /app

USER app

EXPOSE 3001
ENV NODE_ENV=production
CMD ["node", "dist/src/main.js"]
