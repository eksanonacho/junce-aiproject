# DEPLOYMENT_GUIDE.md — AI 初诊网站部署说明

> **这个文件是给谁看的**：未来负责上线/部署的人（或 AI）。
> **什么时候用**：部署 AI 初诊网站到服务器时。
> **解决什么问题**：照着它能在本地运行，也能在未来上线时按推荐方案部署。
>
> ⚠️ AI 初诊项目尚未进入开发阶段。以下为基于小程序部署经验的预编方案，实际部署时可能调整。
> 最后更新：2026-06-21。

---

## 一、部署架构（与小程序共享服务器）

> 来源：小程序 DEPLOYMENT_GUIDE.md、PROJECT_CONTEXT.md

```
        用户（浏览器/微信）
              │  HTTPS
              ▼
    ┌───────────────────┐
    │   Nginx 反向代理    │  HTTPS 证书 / 域名 / 转发
    └─────────┬─────────┘
              │
    ┌─────────┴──────────────┐
    ▼                        ▼
┌──────────┐  ┌──────────┐  ┌──────────────┐
│ 小程序 API │  │ AI 初诊  │  │ AI 初诊 H5   │
│ (容器)    │  │ API(容器) │  │ 静态文件      │
│ :3000     │  │ :3001     │  │ (Nginx 托管) │
└─────┬─────┘  └─────┬────┘  └──────────────┘
      │              │
      └──────┬───────┘
             ▼
    ┌──────────────┐
    │ PostgreSQL   │ (容器 + 数据卷)
    │ 小程序库 +   │
    │ AI 初诊库    │
    └──────────────┘
```

要点：
- **同一台云服务器**，三个容器（小程序 API、AI 初诊 API、PostgreSQL），Nginx 统一入口
- **两个项目不同数据库**：小程序 `junce_miniprogram` / AI 初诊 `junce_ai_diagnosis`
- **数据打通**：如需客户数据互通，通过 API 调用，不跨库直连
- **服务器以君册名义注册**，开发方代管；首年费用含在合同总价内，第二年起客户自续

---

## 二、环境变量（预编，实际以开发时为准）

```bash
# 数据库连接
DATABASE_URL="postgresql://用户名:密码@postgres:5432/junce_ai_diagnosis?schema=public"

# JWT 签名密钥（内部后台用）
JWT_SECRET="替换成一段足够长的随机字符串"
JWT_EXPIRES_IN="7d"

# 后端端口
PORT=3001

# LLM API（如使用大模型）
# LLM_API_KEY=""
# LLM_API_BASE_URL=""
# LLM_MODEL=""

# 文件上传（报告附件等）
# FILE_STORAGE_DRIVER="local"  # 或 oss
# UPLOAD_MAX_SIZE=10485760     # 10MB

# 客户侧网站地址
# PUBLIC_URL="https://ai.juncecaishui.com"

# 小程序 API 地址（如需数据互通）
# MINIPROGRAM_API_URL="http://miniprogram-api:3000"
```

---

## 三、Docker 化计划

AI 初诊需准备：

- **Dockerfile.api**：把后端打包成镜像
- **Dockerfile.frontend**：前端 H5 构建 + Nginx 托管静态文件
- **docker-compose.yml**：在小程序已有的 docker-compose 基础上，新增：
  - `ai-api` 容器（后端 API）
  - `ai-frontend` 容器（前端 H5 静态文件）
  - 数据库不新增容器（共用 PostgreSQL 容器，新增数据库）
- **Nginx 配置更新**：新增 AI 初诊域名/路径的反向代理规则

### docker-compose.yml 新增部分（示例）

```yaml
  ai-api:
    build:
      context: ./ai-diagnosis/server
      dockerfile: Dockerfile
    ports:
      - "3001:3001"
    environment:
      - DATABASE_URL=postgresql://...
      - JWT_SECRET=...
    depends_on:
      - postgres
    restart: unless-stopped

  ai-frontend:
    build:
      context: ./ai-diagnosis/client
      dockerfile: Dockerfile
    volumes:
      - ai_static:/usr/share/nginx/html
    restart: unless-stopped
```

---

## 四、数据库

- **共用 PostgreSQL 实例**：不新建数据库容器，在小程序已有的 PostgreSQL 容器中新增 `junce_ai_diagnosis` 数据库
- **数据隔离**：小程序和 AI 初诊的数据表在不同数据库中，互不干扰
- **备份**：随小程序数据库一起备份（pg_dump）

---

## 五、微信小程序对接预留

如果后续需要在微信小程序中嵌入 AI 初诊：

- **webview 嵌入**：小程序通过 `<web-view>` 组件加载 AI 初诊 H5 页面
- **客户数据同步**：AI 初诊提供 API，小程序后端定时/手动拉取留资客户数据
- **免填基础信息**：从小程序跳转 AI 初诊时，通过 URL 参数传递已有客户信息

---

## 六、部署 checklist（将来部署时逐项打勾）

- [ ] 云服务器以君册名义注册、实名、（如需）备案完成
- [ ] 域名解析、SSL 证书配好（AI 初诊独立域名或子域名）
- [ ] .env 生产变量齐全，JWT_SECRET 为强随机值
- [ ] Docker 镜像构建通过
- [ ] docker-compose 编排验证（新容器 + 现有多容器协调）
- [ ] PostgreSQL 新数据库 `junce_ai_diagnosis` 创建
- [ ] Nginx 反向代理 + HTTPS 配置验证（新增 AI 初诊路由）
- [ ] 接口在生产环境冒烟测试通过
- [ ] 客户侧网站可正常访问
- [ ] 数据库已备份

---

> 参照小程序 docs/DEPLOYMENT_GUIDE.md 结构编写。具体部署配置以实际开发时的技术选型为准。
