FROM node:22-alpine AS runner

WORKDIR /app

# Copy source and install deps inside Docker (Linux binaries)
COPY package.json pnpm-lock.yaml .npmrc ./
RUN npm install -g pnpm && pnpm install --prod --ignore-scripts --no-frozen-lockfile

COPY dist ./dist
COPY generated ./generated
COPY prisma ./prisma
COPY prisma.config.ts ./
COPY .env.example ./

EXPOSE 3001
ENV NODE_ENV=production
CMD ["node", "dist/src/main.js"]
