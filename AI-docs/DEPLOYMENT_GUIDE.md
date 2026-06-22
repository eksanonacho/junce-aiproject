# DEPLOYMENT_GUIDE.md — AI 初诊网站部署说明

> **这个文件是给谁看的**：未来负责上线/部署的人（或 AI）。
> **什么时候用**：部署 AI 初诊网站到服务器时。
> **解决什么问题**：照着它能在本地运行，也能在未来上线时按推荐方案部署。
>
> ✅ Phase 5 完成：Dockerfile ×2 + docker-compose + 打印方案
> **最后更新**：2026-06-22

---

## 一、快速启动（本地开发）

### 1.1 前置环境

- Node.js v24
- pnpm（后端）
- npm（前端）
- PostgreSQL 16（本地运行 `brew services start postgresql@16`）

### 1.2 数据库初始化

```bash
# 创建数据库
psql -d postgres -c "CREATE DATABASE junce_ai_diagnosis;"

# 初始化表结构 + 种子数据
cd ai-diagnosis-server
npx prisma db push --accept-data-loss
npx prisma generate
./node_modules/.bin/tsx prisma/seed.ts
```

### 1.3 启动后端

```bash
cd ai-diagnosis-server
pnpm build
node dist/src/main.js
# → http://localhost:3001
# → GET /health → {"status":"ok"}
```

### 1.4 启动前端

```bash
cd ai-diagnosis-client
npm run dev
# → http://localhost:5173
```

---

## 二、Docker 部署

### 2.1 架构

```
docker-compose:
  postgres:16-alpine     → :5433（不与小程序 5432 冲突）
  ai-diagnosis-server    → :3001
  ai-diagnosis-client    → :8080（nginx serve dist）
```

### 2.2 启动

```bash
# 构建并启动
docker compose build
docker compose up -d

# 验证
curl http://localhost:3001/health
# 预期: {"status":"ok","service":"ai-diagnosis-server"}

curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
# 预期: 200
```

### 2.3 种子数据（Docker 环境）

```bash
docker compose exec server npx prisma db push --accept-data-loss
docker compose exec server ./node_modules/.bin/tsx prisma/seed.ts
```

### 2.4 停止

```bash
docker compose down
docker compose down -v  # 删除数据卷
```

---

## 三、环境变量

| 变量 | 说明 | 默认值 |
|---|---|---|
| `DATABASE_URL` | PostgreSQL 连接串 | `postgresql://a1234@localhost:5432/junce_ai_diagnosis` |
| `JWT_SECRET` | 后台 JWT 签名密钥 | 生产必须更换 |
| `JWT_EXPIRES_IN` | JWT 过期时间 | `7d` |
| `PORT` | 后端端口 | `3001` |
| `AI_POLISH_ENABLED` | AI 润色开关 | `false` |

---

## 四、PDF / 打印说明

**MVP 阶段不使用 Puppeteer（无头 Chrome）**。

原因：
- 与小程序共用服务器，Puppeteer 内存占用高
- 浏览器 `window.print()` 已能满足 MVP 需求

客户使用方式：
1. 打开报告页
2. 点击「打印 / 保存 PDF」按钮
3. 浏览器打印窗口中选择「另存为 PDF」

服务端 PDF（`GET /api/reports/:publicId/pdf`）列为二期增强。

---

## 五、测试账号

| 用户名 | 密码 | 角色 |
|---|---|---|
| `admin` | `Admin@123456` | ADMIN |
| `manager` | `Manager@123456` | MANAGER |
| `accountant` | `Accountant@123456` | ACCOUNTANT |

后台入口：`http://localhost:8080/admin/login`

---

## 六、服务器资源评估

| 容器 | 预计内存 |
|---|---|
| postgres | ~50-100 MB |
| server (NestJS) | ~80-150 MB |
| client (nginx) | ~10-20 MB |
| **总计** | **~150-270 MB** |

无 Puppeteer / Chromium 进程。

---

## 七、常见问题

### Q: 端口被占用
```bash
lsof -ti:3001 | xargs kill -9
lsof -ti:8080 | xargs kill -9
```

### Q: Prisma migration 冲突
```bash
npx prisma db push --accept-data-loss  # 开发环境
npx prisma migrate deploy              # 生产环境
```

### Q: Docker 内连接不上 postgres
确认 DATABASE_URL 中 host 用 `postgres`（容器名），不是 `localhost`。

### Q: 如何确认没有影响小程序
```bash
cd /Users/a1234/cpp/junce-miniprogram && git status
# 预期: clean
```

---

> 参照小程序 DEPLOYMENT_GUIDE.md 结构编写，独立于小程序部署。
