# AGENTS.md

> Last updated: 2026-06-26

This is the project-level operating guide for Codex and other coding agents working on the 君册财税 AI 初诊网站.

It follows the project rules in `CLAUDE.md`. If this file conflicts with `CLAUDE.md`, use `CLAUDE.md` as the higher-priority project source of truth unless the project owner gives a newer explicit instruction.

---

## 1. Project Identity

Project name: 君册财税 AI 初诊网站

Project type: independent H5 responsive web application.

Product positioning:

客户填写企业资料 -> 系统基于规则进行初步分析 -> 生成初诊报告 -> 标记是否需要人工复核 -> 推荐相关君册服务 -> 内部人员查看、复核、跟进

This is not a generic AI chatbot. The core value is to structure 君册财税's business experience into questionnaire fields, diagnosis dimensions, rules, risk levels, review rules, report templates, disclaimers, forbidden wording, service recommendations, and internal follow-up workflow.

---

## 2. Hard Boundary With Mini-Program

The AI diagnosis website is independent from the internal mini-program.

Do not modify:

`/Users/a1234/cpp/junce-miniprogram/`

Forbidden unless explicitly requested by the project owner:

- Do not change mini-program backend, frontend, Prisma schema, migrations, or Docker config.
- Do not add AI diagnosis APIs to the mini-program backend.
- Do not merge this AI diagnosis website into the mini-program.
- Do not use chat history as an API contract.

Future integration is allowed only as a later phase through explicit approval. MVP must remain independently runnable.

---

## 3. Source Of Truth Priority

When information conflicts, use this order:

1. `CLAUDE.md`
2. `AGENTS.md`
3. `AI-docs/AI_DIAGNOSIS_MVP_DEV_PLAN.md`
4. `AI-docs/PROJECT_STATE_SNAPSHOT.md`
5. `AI-docs/API_CONTRACT.md`
6. `AI-docs/DATABASE_GUIDE.md`
7. Current code in this AI project
8. Copied mini-program docs under `docs/`
9. Conversation context

For frontend or UI work, also read:

- `AI-docs/FRONTEND_HANDOFF.md`
- `AI-docs/V2_BUSINESS_DIAGNOSIS_MODEL.md`
- Current Vue pages and components under `ai-diagnosis-client/src/`

---

## 4. Codex Current Responsibility

The current project has already reached a functional closed loop. Codex should focus on frontend pages and UI polish unless the project owner explicitly expands the scope.

Primary responsibility:

- Improve customer-facing pages and admin pages visually and ergonomically.
- Make the V2 flow feel professional, trustworthy, and suitable for client demonstration.
- Preserve existing backend API contracts.
- Preserve the rule-first diagnosis model.
- Avoid changing database schema, seed rules, diagnosis logic, or backend behavior unless a UI task exposes a clear frontend-blocking bug.

Default frontend areas:

- `ai-diagnosis-client/src/pages/HomePage.vue`
- `ai-diagnosis-client/src/pages/DiagnosisStartPage.vue`
- `ai-diagnosis-client/src/pages/DocumentUploadPage.vue`
- `ai-diagnosis-client/src/pages/QuestionnairePage.vue`
- `ai-diagnosis-client/src/pages/SuccessPage.vue`
- `ai-diagnosis-client/src/pages/ReportPage.vue`
- `ai-diagnosis-client/src/admin/*.vue`
- `ai-diagnosis-client/src/components/report/*.vue`
- `ai-diagnosis-client/src/style.css`

---

## 5. Product Scope

The MVP core loop must remain:

客户打开网站 -> 填写/上传资料 -> 提交联系方式 -> 系统规则诊断 -> 生成结构化报告 -> 判断是否需要人工复核 -> 客户查看允许展示的报告 -> 内部人员查看提交记录 -> 内部人员复核敏感/高风险报告

Do not add unless explicitly requested:

- Visual rule editor
- Visual questionnaire editor
- Real SMS provider
- OCR
- LLM-driven risk judgment
- Mini-program synchronization
- Customer account system
- Automatic quotation
- Complex CRM workflow
- Full field-level encryption

---

## 6. Technical Stack

Backend:

- NestJS
- TypeScript
- Prisma
- PostgreSQL
- JWT for admin authentication
- bcrypt for password and token hashing
- class-validator / class-transformer
- pnpm

Frontend:

- Vue 3
- Vite
- TypeScript
- Pinia
- Vue Router
- Tailwind CSS
- ECharts / vue-echarts where currently used
- lucide-vue-next where icon coverage fits

Do not switch the frontend to React unless explicitly requested.

---

## 7. Rule And AI Boundary

Rules decide:

- Findings
- Risk levels
- Overall risk
- Manual review requirement
- Service recommendations
- Customer visibility

AI, if ever enabled, may only polish already-structured content. It must not create risks, change risk levels, remove findings, add services, change review status, remove disclaimers, or invent facts.

MVP must work with:

`AI_POLISH_ENABLED=false`

---

## 8. Compliance And Wording

Customer-visible content must stay cautious and professional.

Forbidden wording includes:

- 违法了
- 必须补税
- 一定会被罚
- 保证解决
- 保证通过
- 一定没有风险
- 可以避税
- 走私人账户
- 税局不会查
- 肯定能注销成功
- 一定能省多少钱

Use safer wording:

- 可能存在合规风险
- 建议进一步核查
- 建议由专业人员复核
- 根据目前信息暂未发现明显高风险项
- 具体情况需结合完整资料判断

Every customer-visible report must include a disclaimer and make clear that the result is preliminary screening only.

---

## 9. Frontend Design Direction

The UI should feel like a professional business diagnosis product, not a generic landing page or simple questionnaire.

Customer-facing goals:

- Mobile-first, but polished on desktop.
- Strong first impression for client demos.
- Clear step progression: start -> upload -> questionnaire -> report/review.
- Avoid overwhelming the user.
- Make data confidence and manual review understandable.
- Use restrained, credible business visual language.
- Make report pages feel like a useful executive dashboard.

Admin-facing goals:

- Desktop-first.
- Prioritize scanning, filtering, review decisions, risk level, document completeness, and review history.
- Surface V2 data already available from the API: dashboard, uploaded documents, dimension rule hits, document completeness.
- Keep interactions efficient for repeated internal use.

UI constraints:

- Keep the existing Vue/Tailwind structure.
- Prefer local components over introducing a new UI framework.
- Do not nest cards inside cards.
- Keep text fitting cleanly on mobile and desktop.
- Use real assets already in `public/` where appropriate.
- Avoid fake claims about SMS, OCR, AI precision, or automatic parsing.

---

## 10. Security And Privacy Rules

Minimum requirements:

- No secrets in Git.
- `.env.example` must not contain real secrets.
- Customer-facing URLs must use `publicId`, not numeric IDs.
- Report access must be tokenized.
- Store report tokens and submission tokens as hashes only.
- Do not expose `storagePath` to frontend.
- Phone numbers should be masked in admin lists.
- Admin APIs require JWT.
- Customer-visible report details must respect `customerVisible`.
- No real customer data in seed or demo files.

---

## 11. Development Rules

Before making changes:

- Check current directory is `/Users/a1234/Desktop/junce-aiproject/`.
- Read relevant docs and current code.
- Preserve existing user changes.
- Keep edits scoped.

For frontend work:

- Inspect the current page/component before editing.
- Follow existing API shapes.
- Keep copy compliant.
- Build realistic empty, loading, error, pending-review, and success states where the page needs them.
- Do not hide failures.

After changes:

- Run relevant checks when feasible.
- For frontend changes, at minimum run `pnpm build` in `ai-diagnosis-client` when dependencies are available.
- If testing was not run, say so clearly.

---

## 12. Documentation

If an interface, behavior, page flow, deployment step, or test process changes, update the corresponding `AI-docs/` file.

Common mappings:

- API changes -> `AI-docs/API_CONTRACT.md`
- DB/schema changes -> `AI-docs/DATABASE_GUIDE.md`
- Page handoff changes -> `AI-docs/FRONTEND_HANDOFF.md`
- Test changes/results -> `AI-docs/TESTING_GUIDE.md` / `AI-docs/TEST_RESULTS.md`
- Current status -> `AI-docs/PROJECT_STATE_SNAPSHOT.md`

For pure visual polish that does not change contracts, a short final summary is usually enough.

---

## 13. Current Best Next Steps

Based on the current project state, the most valuable frontend work is:

1. Upgrade the admin report detail page to actually visualize V2 dashboard, uploaded documents, completeness, and dimension rule hits.
2. Polish the customer start/upload/questionnaire flow into a consistent premium product experience.
3. Improve report page hierarchy, mobile readability, and print/PDF styling.
4. Reduce visual inconsistency between the marketing home page, V2 workflow pages, and admin pages.
5. Run browser-level walkthroughs for QUICK/STANDARD/DEEP demos and record the remaining UI friction.
