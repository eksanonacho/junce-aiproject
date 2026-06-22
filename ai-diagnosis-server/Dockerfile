FROM node:22-alpine AS builder

WORKDIR /app
COPY package.json pnpm-lock.yaml .npmrc ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile

COPY prisma/ prisma/
COPY prisma.config.ts ./
RUN npx prisma generate

COPY . .
RUN pnpm build

FROM node:22-alpine AS runner
WORKDIR /app

RUN npm install -g pnpm
COPY --from=builder /app/package.json /app/pnpm-lock.yaml /app/.npmrc ./
RUN pnpm install --frozen-lockfile --prod

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/generated ./generated
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/prisma.config.ts ./

EXPOSE 3001
ENV NODE_ENV=production
CMD ["node", "dist/src/main.js"]
