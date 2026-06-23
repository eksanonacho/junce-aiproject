--
-- PostgreSQL database dump
--

\restrict gYWKXfbLZ1BMz32Q1dtcpWiu3JfcP5nGCofWAuqrmhBYTcZShlPr3jiTQGc6W4E

-- Dumped from database version 16.14 (Homebrew)
-- Dumped by pg_dump version 16.14 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: AdminRole; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."AdminRole" AS ENUM (
    'ACCOUNTANT',
    'MANAGER',
    'ADMIN'
);


ALTER TYPE public."AdminRole" OWNER TO a1234;

--
-- Name: DiagnosisMode; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."DiagnosisMode" AS ENUM (
    'QUICK',
    'STANDARD',
    'DEEP'
);


ALTER TYPE public."DiagnosisMode" OWNER TO a1234;

--
-- Name: QuestionType; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."QuestionType" AS ENUM (
    'SINGLE_CHOICE',
    'MULTI_CHOICE',
    'RANGE',
    'YES_NO'
);


ALTER TYPE public."QuestionType" OWNER TO a1234;

--
-- Name: RecommendPriority; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."RecommendPriority" AS ENUM (
    'STRONG',
    'SUGGEST',
    'INFO'
);


ALTER TYPE public."RecommendPriority" OWNER TO a1234;

--
-- Name: ReviewAction; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."ReviewAction" AS ENUM (
    'APPROVE',
    'REJECT',
    'MODIFY'
);


ALTER TYPE public."ReviewAction" OWNER TO a1234;

--
-- Name: ReviewStatus; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."ReviewStatus" AS ENUM (
    'NEED_REVIEW',
    'AUTO_RELEASED',
    'REVIEWED',
    'REJECTED'
);


ALTER TYPE public."ReviewStatus" OWNER TO a1234;

--
-- Name: RiskLevel; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."RiskLevel" AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'UNKNOWN'
);


ALTER TYPE public."RiskLevel" OWNER TO a1234;

--
-- Name: SubmissionSource; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."SubmissionSource" AS ENUM (
    'WEB',
    'MINIPROGRAM',
    'STAFF'
);


ALTER TYPE public."SubmissionSource" OWNER TO a1234;

--
-- Name: SubmissionStatus; Type: TYPE; Schema: public; Owner: a1234
--

CREATE TYPE public."SubmissionStatus" AS ENUM (
    'PENDING',
    'SUBMITTED',
    'DIAGNOSING',
    'COMPLETED',
    'FAILED',
    'DRAFT',
    'DOCUMENT_UPLOADING',
    'QUESTIONNAIRE_COMPLETED'
);


ALTER TYPE public."SubmissionStatus" OWNER TO a1234;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: AdminUser; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."AdminUser" (
    id integer NOT NULL,
    username text NOT NULL,
    "passwordHash" text NOT NULL,
    "realName" text NOT NULL,
    role public."AdminRole" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."AdminUser" OWNER TO a1234;

--
-- Name: AdminUser_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."AdminUser_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."AdminUser_id_seq" OWNER TO a1234;

--
-- Name: AdminUser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."AdminUser_id_seq" OWNED BY public."AdminUser".id;


--
-- Name: Answer; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."Answer" (
    id integer NOT NULL,
    "submissionId" integer NOT NULL,
    "questionId" integer NOT NULL,
    "answerValue" jsonb NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."Answer" OWNER TO a1234;

--
-- Name: Answer_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."Answer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Answer_id_seq" OWNER TO a1234;

--
-- Name: Answer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."Answer_id_seq" OWNED BY public."Answer".id;


--
-- Name: DiagnosisResult; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."DiagnosisResult" (
    id integer NOT NULL,
    "submissionId" integer NOT NULL,
    "overallRiskLevel" public."RiskLevel" NOT NULL,
    summary text,
    "dimensionResults" jsonb NOT NULL,
    "needReview" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "dashboardData" jsonb
);


ALTER TABLE public."DiagnosisResult" OWNER TO a1234;

--
-- Name: DiagnosisResult_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."DiagnosisResult_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DiagnosisResult_id_seq" OWNER TO a1234;

--
-- Name: DiagnosisResult_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."DiagnosisResult_id_seq" OWNED BY public."DiagnosisResult".id;


--
-- Name: DiagnosisRule; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."DiagnosisRule" (
    id integer NOT NULL,
    "ruleCode" text NOT NULL,
    dimension text NOT NULL,
    "questionId" integer,
    "triggerCondition" jsonb NOT NULL,
    "compositeCondition" jsonb,
    "riskLevel" public."RiskLevel" NOT NULL,
    "riskTitle" text NOT NULL,
    "riskDescription" text NOT NULL,
    suggestion text NOT NULL,
    "needReview" boolean DEFAULT false NOT NULL,
    "recommendServices" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "conditionMode" text DEFAULT 'SIMPLE'::text NOT NULL
);


ALTER TABLE public."DiagnosisRule" OWNER TO a1234;

--
-- Name: DiagnosisRule_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."DiagnosisRule_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DiagnosisRule_id_seq" OWNER TO a1234;

--
-- Name: DiagnosisRule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."DiagnosisRule_id_seq" OWNED BY public."DiagnosisRule".id;


--
-- Name: Disclaimer; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."Disclaimer" (
    id integer NOT NULL,
    version text NOT NULL,
    content text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


ALTER TABLE public."Disclaimer" OWNER TO a1234;

--
-- Name: Disclaimer_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."Disclaimer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Disclaimer_id_seq" OWNER TO a1234;

--
-- Name: Disclaimer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."Disclaimer_id_seq" OWNED BY public."Disclaimer".id;


--
-- Name: DocumentRequirement; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."DocumentRequirement" (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    category text NOT NULL,
    "requiredForQuick" boolean DEFAULT false NOT NULL,
    "requiredForStandard" boolean DEFAULT false NOT NULL,
    "requiredForDeep" boolean DEFAULT false NOT NULL,
    "affectsDimensions" jsonb,
    description text,
    "sortOrder" integer DEFAULT 0 NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."DocumentRequirement" OWNER TO a1234;

--
-- Name: DocumentRequirement_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."DocumentRequirement_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DocumentRequirement_id_seq" OWNER TO a1234;

--
-- Name: DocumentRequirement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."DocumentRequirement_id_seq" OWNED BY public."DocumentRequirement".id;


--
-- Name: ForbiddenPhrase; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."ForbiddenPhrase" (
    id integer NOT NULL,
    phrase text NOT NULL,
    "safeAlternative" text NOT NULL,
    category text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL
);


ALTER TABLE public."ForbiddenPhrase" OWNER TO a1234;

--
-- Name: ForbiddenPhrase_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."ForbiddenPhrase_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ForbiddenPhrase_id_seq" OWNER TO a1234;

--
-- Name: ForbiddenPhrase_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."ForbiddenPhrase_id_seq" OWNED BY public."ForbiddenPhrase".id;


--
-- Name: Question; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."Question" (
    id integer NOT NULL,
    "questionnaireId" integer NOT NULL,
    "groupLabel" text NOT NULL,
    "groupOrder" integer NOT NULL,
    "orderInGroup" integer NOT NULL,
    "questionText" text NOT NULL,
    "questionType" public."QuestionType" NOT NULL,
    options jsonb NOT NULL,
    "isRequired" boolean DEFAULT false NOT NULL,
    "riskDimension" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "publicId" text,
    "skipLogic" jsonb
);


ALTER TABLE public."Question" OWNER TO a1234;

--
-- Name: Question_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."Question_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Question_id_seq" OWNER TO a1234;

--
-- Name: Question_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."Question_id_seq" OWNED BY public."Question".id;


--
-- Name: Questionnaire; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."Questionnaire" (
    id integer NOT NULL,
    version text NOT NULL,
    title text NOT NULL,
    description text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Questionnaire" OWNER TO a1234;

--
-- Name: Questionnaire_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."Questionnaire_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Questionnaire_id_seq" OWNER TO a1234;

--
-- Name: Questionnaire_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."Questionnaire_id_seq" OWNED BY public."Questionnaire".id;


--
-- Name: Report; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."Report" (
    id integer NOT NULL,
    "publicId" text NOT NULL,
    "diagnosisResultId" integer NOT NULL,
    "reportNumber" text NOT NULL,
    title text NOT NULL,
    "riskLevel" public."RiskLevel" NOT NULL,
    "reviewStatus" public."ReviewStatus" DEFAULT 'NEED_REVIEW'::public."ReviewStatus" NOT NULL,
    "customerVisible" boolean DEFAULT false NOT NULL,
    "htmlContent" text,
    "disclaimerText" text NOT NULL,
    "reviewedById" integer,
    "reviewedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."Report" OWNER TO a1234;

--
-- Name: ReportAccessToken; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."ReportAccessToken" (
    id integer NOT NULL,
    "reportId" integer NOT NULL,
    "tokenHash" text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "usedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ReportAccessToken" OWNER TO a1234;

--
-- Name: ReportAccessToken_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."ReportAccessToken_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ReportAccessToken_id_seq" OWNER TO a1234;

--
-- Name: ReportAccessToken_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."ReportAccessToken_id_seq" OWNED BY public."ReportAccessToken".id;


--
-- Name: Report_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."Report_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Report_id_seq" OWNER TO a1234;

--
-- Name: Report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."Report_id_seq" OWNED BY public."Report".id;


--
-- Name: ReviewRecord; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."ReviewRecord" (
    id integer NOT NULL,
    "reportId" integer NOT NULL,
    "reviewerId" integer NOT NULL,
    action public."ReviewAction" NOT NULL,
    changes jsonb,
    comment text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ReviewRecord" OWNER TO a1234;

--
-- Name: ReviewRecord_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."ReviewRecord_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ReviewRecord_id_seq" OWNER TO a1234;

--
-- Name: ReviewRecord_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."ReviewRecord_id_seq" OWNED BY public."ReviewRecord".id;


--
-- Name: RiskFinding; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."RiskFinding" (
    id integer NOT NULL,
    "diagnosisResultId" integer NOT NULL,
    "ruleId" integer,
    "scenarioId" integer,
    "riskLevel" public."RiskLevel" NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    suggestion text NOT NULL,
    "recommendServices" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."RiskFinding" OWNER TO a1234;

--
-- Name: RiskFinding_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."RiskFinding_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."RiskFinding_id_seq" OWNER TO a1234;

--
-- Name: RiskFinding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."RiskFinding_id_seq" OWNED BY public."RiskFinding".id;


--
-- Name: RiskScenario; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."RiskScenario" (
    id integer NOT NULL,
    "scenarioName" text NOT NULL,
    "scenarioCode" text NOT NULL,
    description text NOT NULL,
    "riskLevel" public."RiskLevel" NOT NULL,
    "triggerRules" jsonb NOT NULL,
    "safeExplanation" text NOT NULL,
    "forbiddenPhrases" text[],
    suggestion text NOT NULL,
    "recommendServices" jsonb,
    "needManualReview" boolean DEFAULT false NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."RiskScenario" OWNER TO a1234;

--
-- Name: RiskScenario_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."RiskScenario_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."RiskScenario_id_seq" OWNER TO a1234;

--
-- Name: RiskScenario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."RiskScenario_id_seq" OWNED BY public."RiskScenario".id;


--
-- Name: ServiceRecommendation; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."ServiceRecommendation" (
    id integer NOT NULL,
    "diagnosisResultId" integer NOT NULL,
    "serviceType" text NOT NULL,
    reason text NOT NULL,
    priority public."RecommendPriority" NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."ServiceRecommendation" OWNER TO a1234;

--
-- Name: ServiceRecommendation_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."ServiceRecommendation_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ServiceRecommendation_id_seq" OWNER TO a1234;

--
-- Name: ServiceRecommendation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."ServiceRecommendation_id_seq" OWNED BY public."ServiceRecommendation".id;


--
-- Name: SmsVerificationCode; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."SmsVerificationCode" (
    id integer NOT NULL,
    phone text NOT NULL,
    "codeHash" text NOT NULL,
    scene text NOT NULL,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "verifiedAt" timestamp(3) without time zone,
    attempts integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public."SmsVerificationCode" OWNER TO a1234;

--
-- Name: SmsVerificationCode_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."SmsVerificationCode_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."SmsVerificationCode_id_seq" OWNER TO a1234;

--
-- Name: SmsVerificationCode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."SmsVerificationCode_id_seq" OWNED BY public."SmsVerificationCode".id;


--
-- Name: Submission; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."Submission" (
    id integer NOT NULL,
    "publicId" text NOT NULL,
    "questionnaireId" integer NOT NULL,
    status public."SubmissionStatus" DEFAULT 'PENDING'::public."SubmissionStatus" NOT NULL,
    phone text,
    "phoneVerified" boolean DEFAULT false NOT NULL,
    source public."SubmissionSource" DEFAULT 'WEB'::public."SubmissionSource" NOT NULL,
    "miniProgramCustomerId" integer,
    "submittedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "accessTokenCreatedAt" timestamp(3) without time zone,
    "accessTokenHash" text,
    "documentCompletenessDetail" jsonb,
    "documentCompletenessScore" integer,
    mode public."DiagnosisMode"
);


ALTER TABLE public."Submission" OWNER TO a1234;

--
-- Name: Submission_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."Submission_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Submission_id_seq" OWNER TO a1234;

--
-- Name: Submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."Submission_id_seq" OWNED BY public."Submission".id;


--
-- Name: UploadedDocument; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public."UploadedDocument" (
    id integer NOT NULL,
    "publicId" text NOT NULL,
    "submissionId" integer NOT NULL,
    "docType" text NOT NULL,
    "originalName" text NOT NULL,
    "mimeType" text NOT NULL,
    "sizeBytes" integer NOT NULL,
    "storagePath" text NOT NULL,
    "uploadStatus" text DEFAULT 'UPLOADED'::text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public."UploadedDocument" OWNER TO a1234;

--
-- Name: UploadedDocument_id_seq; Type: SEQUENCE; Schema: public; Owner: a1234
--

CREATE SEQUENCE public."UploadedDocument_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."UploadedDocument_id_seq" OWNER TO a1234;

--
-- Name: UploadedDocument_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: a1234
--

ALTER SEQUENCE public."UploadedDocument_id_seq" OWNED BY public."UploadedDocument".id;


--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: a1234
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO a1234;

--
-- Name: AdminUser id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."AdminUser" ALTER COLUMN id SET DEFAULT nextval('public."AdminUser_id_seq"'::regclass);


--
-- Name: Answer id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Answer" ALTER COLUMN id SET DEFAULT nextval('public."Answer_id_seq"'::regclass);


--
-- Name: DiagnosisResult id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DiagnosisResult" ALTER COLUMN id SET DEFAULT nextval('public."DiagnosisResult_id_seq"'::regclass);


--
-- Name: DiagnosisRule id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DiagnosisRule" ALTER COLUMN id SET DEFAULT nextval('public."DiagnosisRule_id_seq"'::regclass);


--
-- Name: Disclaimer id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Disclaimer" ALTER COLUMN id SET DEFAULT nextval('public."Disclaimer_id_seq"'::regclass);


--
-- Name: DocumentRequirement id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DocumentRequirement" ALTER COLUMN id SET DEFAULT nextval('public."DocumentRequirement_id_seq"'::regclass);


--
-- Name: ForbiddenPhrase id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ForbiddenPhrase" ALTER COLUMN id SET DEFAULT nextval('public."ForbiddenPhrase_id_seq"'::regclass);


--
-- Name: Question id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Question" ALTER COLUMN id SET DEFAULT nextval('public."Question_id_seq"'::regclass);


--
-- Name: Questionnaire id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Questionnaire" ALTER COLUMN id SET DEFAULT nextval('public."Questionnaire_id_seq"'::regclass);


--
-- Name: Report id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Report" ALTER COLUMN id SET DEFAULT nextval('public."Report_id_seq"'::regclass);


--
-- Name: ReportAccessToken id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ReportAccessToken" ALTER COLUMN id SET DEFAULT nextval('public."ReportAccessToken_id_seq"'::regclass);


--
-- Name: ReviewRecord id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ReviewRecord" ALTER COLUMN id SET DEFAULT nextval('public."ReviewRecord_id_seq"'::regclass);


--
-- Name: RiskFinding id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."RiskFinding" ALTER COLUMN id SET DEFAULT nextval('public."RiskFinding_id_seq"'::regclass);


--
-- Name: RiskScenario id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."RiskScenario" ALTER COLUMN id SET DEFAULT nextval('public."RiskScenario_id_seq"'::regclass);


--
-- Name: ServiceRecommendation id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ServiceRecommendation" ALTER COLUMN id SET DEFAULT nextval('public."ServiceRecommendation_id_seq"'::regclass);


--
-- Name: SmsVerificationCode id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."SmsVerificationCode" ALTER COLUMN id SET DEFAULT nextval('public."SmsVerificationCode_id_seq"'::regclass);


--
-- Name: Submission id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Submission" ALTER COLUMN id SET DEFAULT nextval('public."Submission_id_seq"'::regclass);


--
-- Name: UploadedDocument id; Type: DEFAULT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."UploadedDocument" ALTER COLUMN id SET DEFAULT nextval('public."UploadedDocument_id_seq"'::regclass);


--
-- Data for Name: AdminUser; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."AdminUser" (id, username, "passwordHash", "realName", role, "createdAt", "updatedAt") FROM stdin;
4	admin	$2b$10$A.bDqZLPbUoS6C/89uygWejwRNImeSh/Rjbk6CAl3n/Lpi/qwk96S	管理员	ADMIN	2026-06-22 08:57:56.885	2026-06-22 08:57:56.885
5	accountant	$2b$10$oATQ6gt4oUarNECmWSILBuTELerY6eqKdHgzn/f5UkzBdo7t6gbSu	会计测试	ACCOUNTANT	2026-06-22 18:18:29.487	2026-06-22 18:18:29.487
6	manager	$2b$10$FkB5XY1Av/aJV9Y7Dcjju.gx237FLfNXnMNaEiANrmgFUKU3.Ny3K	主管测试	MANAGER	2026-06-22 18:18:29.487	2026-06-22 18:18:29.487
\.


--
-- Data for Name: Answer; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Answer" (id, "submissionId", "questionId", "answerValue", "createdAt") FROM stdin;
101	11	51	"互联网"	2026-06-22 09:00:33.456
102	11	52	"3-5年"	2026-06-22 09:00:33.456
103	11	53	"多股东"	2026-06-22 09:00:33.456
104	11	54	"50-100万"	2026-06-22 09:00:33.456
105	11	55	"1-5人"	2026-06-22 09:00:33.456
106	11	56	"是"	2026-06-22 09:00:33.456
107	11	57	"否"	2026-06-22 09:00:33.456
108	11	58	"是"	2026-06-22 09:00:33.456
109	11	59	"是"	2026-06-22 09:00:33.456
110	11	60	"否"	2026-06-22 09:00:33.456
111	12	51	"餐饮"	2026-06-22 09:00:34.572
112	12	52	"1-3年"	2026-06-22 09:00:34.572
113	12	53	"个体户"	2026-06-22 09:00:34.572
114	12	54	"10-50万"	2026-06-22 09:00:34.572
115	12	55	"1-5人"	2026-06-22 09:00:34.572
116	12	56	"是"	2026-06-22 09:00:34.572
117	12	57	"是"	2026-06-22 09:00:34.572
118	12	58	"是"	2026-06-22 09:00:34.572
119	12	59	"是"	2026-06-22 09:00:34.572
120	12	60	"否"	2026-06-22 09:00:34.572
121	13	51	"运输"	2026-06-22 09:00:35.696
122	13	52	"1-3年"	2026-06-22 09:00:35.696
123	13	53	"一人公司"	2026-06-22 09:00:35.696
124	13	54	"100-500万"	2026-06-22 09:00:35.696
125	13	55	"5-10人"	2026-06-22 09:00:35.696
126	13	56	"否"	2026-06-22 09:00:35.696
127	13	57	"否"	2026-06-22 09:00:35.696
128	13	58	"是"	2026-06-22 09:00:35.696
129	13	59	"是"	2026-06-22 09:00:35.696
130	13	60	"否"	2026-06-22 09:00:35.696
131	14	51	"贸易"	2026-06-22 09:00:36.809
132	14	52	"5年以上"	2026-06-22 09:00:36.809
133	14	53	"多股东"	2026-06-22 09:00:36.809
134	14	54	"500万以上"	2026-06-22 09:00:36.809
135	14	55	"10-50人"	2026-06-22 09:00:36.809
136	14	56	"是"	2026-06-22 09:00:36.809
137	14	57	"否"	2026-06-22 09:00:36.809
138	14	58	"是"	2026-06-22 09:00:36.809
139	14	59	"是"	2026-06-22 09:00:36.809
140	14	60	"是"	2026-06-22 09:00:36.809
141	15	51	"互联网"	2026-06-22 09:00:37.919
142	15	52	"不到1年"	2026-06-22 09:00:37.919
143	15	53	"一人公司"	2026-06-22 09:00:37.919
144	15	54	"10-50万"	2026-06-22 09:00:37.919
145	15	55	"1-5人"	2026-06-22 09:00:37.919
146	15	56	"是"	2026-06-22 09:00:37.919
147	15	57	"是"	2026-06-22 09:00:37.919
148	15	58	"无员工"	2026-06-22 09:00:37.919
149	15	59	"否"	2026-06-22 09:00:37.919
150	15	60	"否"	2026-06-22 09:00:37.919
151	16	51	"互联网"	2026-06-22 09:20:26.974
152	16	52	"3-5年"	2026-06-22 09:20:26.974
153	16	53	"多股东"	2026-06-22 09:20:26.974
154	16	54	"50-100万"	2026-06-22 09:20:26.974
155	16	55	"1-5人"	2026-06-22 09:20:26.974
156	16	56	"是"	2026-06-22 09:20:26.974
157	16	57	"否"	2026-06-22 09:20:26.974
158	16	58	"是"	2026-06-22 09:20:26.974
159	16	59	"是"	2026-06-22 09:20:26.974
160	16	60	"否"	2026-06-22 09:20:26.974
161	17	51	"互联网"	2026-06-22 09:20:54.281
162	17	52	"5年以上"	2026-06-22 09:20:54.281
163	17	53	"多股东"	2026-06-22 09:20:54.281
164	17	54	"50-100万"	2026-06-22 09:20:54.281
165	17	55	"1-5人"	2026-06-22 09:20:54.281
166	17	56	"是"	2026-06-22 09:20:54.281
167	17	57	"否"	2026-06-22 09:20:54.281
168	17	58	"是"	2026-06-22 09:20:54.281
169	17	59	"是"	2026-06-22 09:20:54.281
170	17	60	"否"	2026-06-22 09:20:54.281
171	18	51	"运输"	2026-06-22 09:21:58.258
172	18	52	"1-3年"	2026-06-22 09:21:58.258
173	18	53	"一人公司"	2026-06-22 09:21:58.258
174	18	54	"100-500万"	2026-06-22 09:21:58.258
175	18	55	"5-10人"	2026-06-22 09:21:58.258
176	18	56	"否"	2026-06-22 09:21:58.258
177	18	57	"否"	2026-06-22 09:21:58.258
178	18	58	"是"	2026-06-22 09:21:58.258
179	18	59	"是"	2026-06-22 09:21:58.258
180	18	60	"否"	2026-06-22 09:21:58.258
181	19	51	"餐饮"	2026-06-22 09:21:58.569
182	19	52	"1-3年"	2026-06-22 09:21:58.569
183	19	53	"个体户"	2026-06-22 09:21:58.569
184	19	54	"10-50万"	2026-06-22 09:21:58.569
185	19	55	"1-5人"	2026-06-22 09:21:58.569
186	19	56	"是"	2026-06-22 09:21:58.569
187	19	57	"是"	2026-06-22 09:21:58.569
188	19	58	"是"	2026-06-22 09:21:58.569
189	19	59	"是"	2026-06-22 09:21:58.569
190	19	60	"否"	2026-06-22 09:21:58.569
191	20	51	"餐饮"	2026-06-22 09:23:00.644
192	20	52	"1-3年"	2026-06-22 09:23:00.644
193	20	53	"个体户"	2026-06-22 09:23:00.644
194	20	54	"10-50万"	2026-06-22 09:23:00.644
195	20	55	"1-5人"	2026-06-22 09:23:00.644
196	20	56	"是"	2026-06-22 09:23:00.644
197	20	57	"是"	2026-06-22 09:23:00.644
198	20	58	"是"	2026-06-22 09:23:00.644
199	20	59	"是"	2026-06-22 09:23:00.644
200	20	60	"否"	2026-06-22 09:23:00.644
201	21	51	"互联网"	2026-06-22 09:38:37.186
202	21	52	"5年以上"	2026-06-22 09:38:37.186
203	21	53	"多股东"	2026-06-22 09:38:37.186
204	21	54	"50-100万"	2026-06-22 09:38:37.186
205	21	55	"1-5人"	2026-06-22 09:38:37.186
206	21	56	"是"	2026-06-22 09:38:37.186
207	21	57	"否"	2026-06-22 09:38:37.186
208	21	58	"是"	2026-06-22 09:38:37.186
209	21	59	"是"	2026-06-22 09:38:37.186
210	21	60	"否"	2026-06-22 09:38:37.186
211	22	51	"互联网"	2026-06-22 09:39:02.662
212	22	52	"5年以上"	2026-06-22 09:39:02.662
213	22	53	"多股东"	2026-06-22 09:39:02.662
214	22	54	"50-100万"	2026-06-22 09:39:02.662
215	22	55	"1-5人"	2026-06-22 09:39:02.662
216	22	56	"是"	2026-06-22 09:39:02.662
217	22	57	"否"	2026-06-22 09:39:02.662
218	22	58	"是"	2026-06-22 09:39:02.662
219	22	59	"是"	2026-06-22 09:39:02.662
220	22	60	"否"	2026-06-22 09:39:02.662
221	23	51	"贸易"	2026-06-22 09:41:58.125
222	23	52	"5年以上"	2026-06-22 09:41:58.125
223	23	53	"多股东"	2026-06-22 09:41:58.125
224	23	54	"50-100万"	2026-06-22 09:41:58.125
225	23	55	"1-5人"	2026-06-22 09:41:58.125
226	23	56	"是"	2026-06-22 09:41:58.125
227	23	57	"否"	2026-06-22 09:41:58.125
228	23	58	"是"	2026-06-22 09:41:58.125
229	23	59	"是"	2026-06-22 09:41:58.125
230	23	60	"否"	2026-06-22 09:41:58.125
231	24	51	"餐饮"	2026-06-22 09:41:58.326
232	24	52	"1-3年"	2026-06-22 09:41:58.326
233	24	53	"个体户"	2026-06-22 09:41:58.326
234	24	54	"10-50万"	2026-06-22 09:41:58.326
235	24	55	"1-5人"	2026-06-22 09:41:58.326
236	24	56	"是"	2026-06-22 09:41:58.326
237	24	57	"是"	2026-06-22 09:41:58.326
238	24	58	"是"	2026-06-22 09:41:58.326
239	24	59	"是"	2026-06-22 09:41:58.326
240	24	60	"否"	2026-06-22 09:41:58.326
241	25	51	"运输"	2026-06-22 09:41:58.479
242	25	52	"1-3年"	2026-06-22 09:41:58.479
243	25	53	"一人公司"	2026-06-22 09:41:58.479
244	25	54	"100-500万"	2026-06-22 09:41:58.479
245	25	55	"5-10人"	2026-06-22 09:41:58.479
246	25	56	"否"	2026-06-22 09:41:58.479
247	25	57	"否"	2026-06-22 09:41:58.479
248	25	58	"是"	2026-06-22 09:41:58.479
249	25	59	"是"	2026-06-22 09:41:58.479
250	25	60	"否"	2026-06-22 09:41:58.479
251	26	51	"贸易"	2026-06-22 10:48:28.743
252	26	52	"5年以上"	2026-06-22 10:48:28.743
253	26	53	"多股东"	2026-06-22 10:48:28.743
254	26	54	"50-100万"	2026-06-22 10:48:28.743
255	26	55	"1-5人"	2026-06-22 10:48:28.743
256	26	56	"是"	2026-06-22 10:48:28.743
257	26	57	"否"	2026-06-22 10:48:28.743
258	26	58	"是"	2026-06-22 10:48:28.743
259	26	59	"是"	2026-06-22 10:48:28.743
260	26	60	"否"	2026-06-22 10:48:28.743
261	27	51	"运输"	2026-06-22 10:48:28.943
262	27	52	"1-3年"	2026-06-22 10:48:28.943
263	27	53	"一人公司"	2026-06-22 10:48:28.943
264	27	54	"100-500万"	2026-06-22 10:48:28.943
265	27	55	"5-10人"	2026-06-22 10:48:28.943
266	27	56	"否"	2026-06-22 10:48:28.943
267	27	57	"否"	2026-06-22 10:48:28.943
268	27	58	"是"	2026-06-22 10:48:28.943
269	27	59	"是"	2026-06-22 10:48:28.943
270	27	60	"否"	2026-06-22 10:48:28.943
\.


--
-- Data for Name: DiagnosisResult; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DiagnosisResult" (id, "submissionId", "overallRiskLevel", summary, "dimensionResults", "needReview", "createdAt", "updatedAt", "dashboardData") FROM stdin;
9	11	LOW	\N	[]	f	2026-06-22 09:00:33.471	2026-06-22 09:00:33.471	\N
10	12	MEDIUM	\N	[{"findings": [{"title": "长期零申报", "riskLevel": "MEDIUM", "suggestion": "建议规范账务处理，确保每期申报真实准确反映经营状况。", "description": "长期零申报可能引起税务关注，尤其是存在实际经营的情况下。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "MEDIUM"}]	f	2026-06-22 09:00:34.585	2026-06-22 09:00:34.585	\N
11	13	HIGH	\N	[{"findings": [{"title": "未正常报税", "riskLevel": "HIGH", "suggestion": "建议立即联系专业人员，核查申报状态并补报。", "description": "未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "HIGH"}]	t	2026-06-22 09:00:35.704	2026-06-22 09:00:35.704	\N
12	14	HIGH	\N	[{"findings": [{"title": "公私账户混用", "riskLevel": "HIGH", "suggestion": "建议尽快开立对公账户，所有经营收入通过公司账户管理。", "description": "公司款项通过个人账户收取可能导致税务风险和管理混乱。", "recommendServices": ["开户", "财务外包", "合规项目"]}], "dimension": "资金维度", "riskLevel": "HIGH"}]	t	2026-06-22 09:00:36.818	2026-06-22 09:00:36.818	\N
13	15	HIGH	\N	[{"findings": [{"title": "长期零申报", "riskLevel": "MEDIUM", "suggestion": "建议规范账务处理，确保每期申报真实准确反映经营状况。", "description": "长期零申报可能引起税务关注，尤其是存在实际经营的情况下。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "MEDIUM"}, {"findings": [{"title": "[测试]新注册公司", "riskLevel": "MEDIUM", "suggestion": "建议尽快开立对公账户并建立账务体系。", "description": "新注册公司需要关注初期合规建设。", "recommendServices": ["开户", "代理记账"]}], "dimension": "工商维度", "riskLevel": "MEDIUM"}, {"findings": [{"title": "[测试]未缴纳社保", "riskLevel": "MEDIUM", "suggestion": "建议依法为员工缴纳社保，规范用工管理。", "description": "有员工但未依法缴纳社保可能存在用工合规风险。", "recommendServices": ["社保", "合规项目"]}], "dimension": "社保维度", "riskLevel": "MEDIUM"}]	t	2026-06-22 09:00:37.927	2026-06-22 09:00:37.927	\N
14	16	LOW	\N	[]	f	2026-06-22 09:20:26.997	2026-06-22 09:20:26.997	\N
15	17	LOW	\N	[]	f	2026-06-22 09:20:54.295	2026-06-22 09:20:54.295	\N
16	18	HIGH	\N	[{"findings": [{"title": "未正常报税", "riskLevel": "HIGH", "suggestion": "建议立即联系专业人员，核查申报状态并补报。", "description": "未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "HIGH"}]	t	2026-06-22 09:21:58.272	2026-06-22 09:21:58.272	\N
17	19	MEDIUM	\N	[{"findings": [{"title": "长期零申报", "riskLevel": "MEDIUM", "suggestion": "建议规范账务处理，确保每期申报真实准确反映经营状况。", "description": "长期零申报可能引起税务关注，尤其是存在实际经营的情况下。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "MEDIUM"}]	f	2026-06-22 09:21:58.578	2026-06-22 09:21:58.578	\N
18	20	MEDIUM	\N	[{"findings": [{"title": "长期零申报", "riskLevel": "MEDIUM", "suggestion": "建议规范账务处理，确保每期申报真实准确反映经营状况。", "description": "长期零申报可能引起税务关注，尤其是存在实际经营的情况下。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "MEDIUM"}]	f	2026-06-22 09:23:00.663	2026-06-22 09:23:00.663	\N
19	21	LOW	\N	[]	f	2026-06-22 09:38:37.207	2026-06-22 09:38:37.207	\N
20	22	MEDIUM	\N	[{"findings": [{"title": "禁用词测试", "riskLevel": "MEDIUM", "suggestion": "可以避税，税局不会查", "description": "您的公司违法了，必须补税，保证帮您解决", "recommendServices": ["代理记账"]}], "dimension": "税务维度", "riskLevel": "MEDIUM"}]	f	2026-06-22 09:39:02.675	2026-06-22 09:39:02.675	\N
21	23	LOW	\N	[]	f	2026-06-22 09:41:58.136	2026-06-22 09:41:58.136	\N
22	24	MEDIUM	\N	[{"findings": [{"title": "长期零申报", "riskLevel": "MEDIUM", "suggestion": "建议规范账务处理，确保每期申报真实准确反映经营状况。", "description": "长期零申报可能引起税务关注，尤其是存在实际经营的情况下。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "MEDIUM"}]	f	2026-06-22 09:41:58.334	2026-06-22 09:41:58.334	\N
23	25	HIGH	\N	[{"findings": [{"title": "未正常报税", "riskLevel": "HIGH", "suggestion": "建议立即联系专业人员，核查申报状态并补报。", "description": "未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "HIGH"}]	t	2026-06-22 09:41:58.488	2026-06-22 09:41:58.488	\N
24	26	LOW	\N	[]	f	2026-06-22 10:48:28.765	2026-06-22 10:48:28.765	\N
25	27	HIGH	\N	[{"findings": [{"title": "未正常报税", "riskLevel": "HIGH", "suggestion": "建议立即联系专业人员，核查申报状态并补报。", "description": "未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "HIGH"}]	t	2026-06-22 10:48:28.955	2026-06-22 10:48:28.955	\N
\.


--
-- Data for Name: DiagnosisRule; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DiagnosisRule" (id, "ruleCode", dimension, "questionId", "triggerCondition", "compositeCondition", "riskLevel", "riskTitle", "riskDescription", suggestion, "needReview", "recommendServices", "isActive", "createdAt", "updatedAt", "conditionMode") FROM stdin;
22	TAX_001	税务维度	57	{"value": "是", "operator": "equals"}	\N	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	f	["代理记账", "合规项目"]	t	2026-06-22 08:57:56.914	2026-06-22 08:57:56.914	SIMPLE
23	TAX_002	税务维度	56	{"value": "否", "operator": "equals"}	\N	HIGH	未正常报税	未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员，核查申报状态并补报。	t	["代理记账", "合规项目"]	t	2026-06-22 08:57:56.914	2026-06-22 08:57:56.914	SIMPLE
24	FUND_001	资金维度	60	{"value": "是", "operator": "equals"}	\N	HIGH	公私账户混用	公司款项通过个人账户收取可能导致税务风险和管理混乱。	建议尽快开立对公账户，所有经营收入通过公司账户管理。	t	["开户", "财务外包", "合规项目"]	t	2026-06-22 08:57:56.914	2026-06-22 08:57:56.914	SIMPLE
25	TEST_M001	工商维度	52	{"value": "不到1年", "operator": "equals"}	\N	MEDIUM	[测试]新注册公司	新注册公司需要关注初期合规建设。	建议尽快开立对公账户并建立账务体系。	f	["开户", "代理记账"]	t	2026-06-22 08:57:56.914	2026-06-22 08:57:56.914	SIMPLE
26	TEST_M002	社保维度	59	{"value": "否", "operator": "equals"}	\N	MEDIUM	[测试]未缴纳社保	有员工但未依法缴纳社保可能存在用工合规风险。	建议依法为员工缴纳社保，规范用工管理。	f	["社保", "合规项目"]	t	2026-06-22 08:57:56.914	2026-06-22 08:57:56.914	SIMPLE
\.


--
-- Data for Name: Disclaimer; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Disclaimer" (id, version, content, "isActive") FROM stdin;
2	v1	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	t
\.


--
-- Data for Name: DocumentRequirement; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DocumentRequirement" (id, code, name, category, "requiredForQuick", "requiredForStandard", "requiredForDeep", "affectsDimensions", description, "sortOrder", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ForbiddenPhrase; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ForbiddenPhrase" (id, phrase, "safeAlternative", category, "isActive") FROM stdin;
16	违法了	可能存在合规风险	法律定性	t
17	必须补税	建议核查申报情况并及时处理	税务指令	t
18	一定会被罚款	可能面临税务处理	承诺结果	t
19	保证帮您解决	君册可以为您提供专业解决方案	承诺结果	t
20	保证通过税务检查	君册可以帮助您做好合规准备	承诺结果	t
21	一定没有风险	根据目前信息，暂未发现明显高风险项	承诺结果	t
22	这个不用管	该项暂不构成紧迫风险，但建议持续关注	忽视问题	t
23	可以避税	可以通过合法合规的税务筹划优化税负	避税教唆	t
24	不用开发票	开票是企业法定义务，君册可帮助规范开票流程	避税教唆	t
25	可以走私人账户	建议将经营收入通过公司账户管理	公私混用	t
26	保证多久办完	根据以往经验，办理周期大约需要一定时间	承诺结果	t
27	税局不会查	经营合规、申报规范可以降低被稽查可能性	承诺结果	t
28	这个操作没问题	该操作需由专业人员结合完整资料确认	打包票	t
29	肯定能注销成功	君册可以协助准备完整注销材料推进流程	承诺结果	t
30	一定能省钱	合规的税务筹划通常可以合理优化税负	承诺结果	t
\.


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Question" (id, "questionnaireId", "groupLabel", "groupOrder", "orderInGroup", "questionText", "questionType", options, "isRequired", "riskDimension", "createdAt", "updatedAt", "publicId", "skipLogic") FROM stdin;
51	6	企业基础信息	1	1	贵公司所属行业？	SINGLE_CHOICE	["互联网", "贸易", "餐饮", "建筑", "运输", "制造", "其他"]	t	工商维度	2026-06-22 08:57:56.896	2026-06-22 08:57:56.896	\N	\N
52	6	企业基础信息	1	2	公司注册时间？	SINGLE_CHOICE	["不到1年", "1-3年", "3-5年", "5年以上"]	t	工商维度	2026-06-22 08:57:56.9	2026-06-22 08:57:56.9	\N	\N
53	6	企业基础信息	1	3	公司类型？	SINGLE_CHOICE	["一人公司", "多股东", "个体户"]	t	工商维度	2026-06-22 08:57:56.901	2026-06-22 08:57:56.901	\N	\N
54	6	经营规模	2	1	年流水大约多少？	RANGE	{"options": ["10万以下", "10-50万", "50-100万", "100-500万", "500万以上"]}	t	税务维度	2026-06-22 08:57:56.902	2026-06-22 08:57:56.902	\N	\N
55	6	经营规模	2	2	公司员工人数？	SINGLE_CHOICE	["0人（无员工）", "1-5人", "5-10人", "10-50人", "50人以上"]	t	社保维度	2026-06-22 08:57:56.903	2026-06-22 08:57:56.903	\N	\N
56	6	税务申报	3	1	目前是否正常报税？	YES_NO	["是", "否"]	t	税务维度	2026-06-22 08:57:56.905	2026-06-22 08:57:56.905	\N	\N
57	6	税务申报	3	2	是否长期零申报？	YES_NO	["是", "否"]	f	税务维度	2026-06-22 08:57:56.906	2026-06-22 08:57:56.906	\N	\N
58	6	社保/员工	4	1	是否给员工缴纳社保？	YES_NO	["是", "否", "无员工"]	t	社保维度	2026-06-22 08:57:56.907	2026-06-22 08:57:56.907	\N	\N
59	6	资金/账户	5	1	是否已开设对公账户？	YES_NO	["是", "否"]	t	资金维度	2026-06-22 08:57:56.908	2026-06-22 08:57:56.908	\N	\N
60	6	资金/账户	5	2	是否存在老板个人账户收公司款项的情况？	YES_NO	["是", "否", "不清楚"]	f	资金维度	2026-06-22 08:57:56.909	2026-06-22 08:57:56.909	\N	\N
61	7	企业基础信息	1	1	贵公司所属行业？	SINGLE_CHOICE	["互联网", "贸易", "餐饮", "建筑", "运输", "制造", "其他"]	t	工商维度	2026-06-23 12:04:06.417	2026-06-23 12:04:06.417	\N	\N
62	7	企业基础信息	1	2	公司注册时间？	SINGLE_CHOICE	["不到1年", "1-3年", "3-5年", "5年以上"]	t	工商维度	2026-06-23 12:04:06.422	2026-06-23 12:04:06.422	\N	\N
63	7	企业基础信息	1	3	公司类型？	SINGLE_CHOICE	["一人公司", "多股东", "个体户"]	t	工商维度	2026-06-23 12:04:06.424	2026-06-23 12:04:06.424	\N	\N
64	7	经营规模	2	1	年流水大约多少？	RANGE	{"options": ["10万以下", "10-50万", "50-100万", "100-500万", "500万以上"]}	t	税务维度	2026-06-23 12:04:06.425	2026-06-23 12:04:06.425	\N	\N
65	7	经营规模	2	2	公司员工人数？	SINGLE_CHOICE	["0人（无员工）", "1-5人", "5-10人", "10-50人", "50人以上"]	t	社保维度	2026-06-23 12:04:06.426	2026-06-23 12:04:06.426	\N	\N
66	7	税务申报	3	1	目前是否正常报税？	YES_NO	["是", "否"]	t	税务维度	2026-06-23 12:04:06.428	2026-06-23 12:04:06.428	\N	\N
67	7	税务申报	3	2	是否长期零申报？	YES_NO	["是", "否"]	f	税务维度	2026-06-23 12:04:06.429	2026-06-23 12:04:06.429	\N	\N
68	7	社保/员工	4	1	是否给员工缴纳社保？	YES_NO	["是", "否", "无员工"]	t	社保维度	2026-06-23 12:04:06.43	2026-06-23 12:04:06.43	\N	\N
69	7	资金/账户	5	1	是否已开设对公账户？	YES_NO	["是", "否"]	t	资金维度	2026-06-23 12:04:06.431	2026-06-23 12:04:06.431	\N	\N
70	7	资金/账户	5	2	是否存在老板个人账户收公司款项的情况？	YES_NO	["是", "否", "不清楚"]	f	资金维度	2026-06-23 12:04:06.432	2026-06-23 12:04:06.432	\N	\N
\.


--
-- Data for Name: Questionnaire; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Questionnaire" (id, version, title, description, "isActive", "createdAt", "updatedAt") FROM stdin;
6	v1	君册财税·企业初诊问卷	请如实填写以下信息，我们将为您生成企业财税健康初诊报告。	t	2026-06-22 08:57:56.891	2026-06-22 08:57:56.891
7	v1	君册财税·企业初诊问卷	请如实填写以下信息，我们将为您生成企业财税健康初诊报告。	t	2026-06-23 12:04:06.411	2026-06-23 12:04:06.411
\.


--
-- Data for Name: Report; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Report" (id, "publicId", "diagnosisResultId", "reportNumber", title, "riskLevel", "reviewStatus", "customerVisible", "htmlContent", "disclaimerText", "reviewedById", "reviewedAt", "createdAt", "updatedAt") FROM stdin;
2	cmqp09mia0003vs9kefoso2iw	15	JC-AI-20260622-0002	君册财税·企业初诊报告	LOW	AUTO_RELEASED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0002</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:20:54.320Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>互联网</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>5年以上</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>多股东</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>50-100万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#27ae60;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">低风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">根据您目前填写的信息，系统暂未发现明显高风险项。由于本报告仅基于有限信息生成，仍建议后续结合完整账务、申报、发票和工商资料进行人工确认。</p>\n</section>\n\n\n\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:20:54.322	2026-06-22 09:20:54.322
3	cmqp0azvf0005vs9kdg4mha9u	16	JC-AI-20260622-0003	君册财税·企业初诊报告	HIGH	NEED_REVIEW	f	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0003</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:21:58.297Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>运输</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>1-3年</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>一人公司</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>100-500万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>5-10人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:red;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">高风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个高风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>未正常报税</strong>\n        <p style="color:#555;margin:6px 0">未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。</p>\n        <p style="color:#888;font-size:14px">💡 建议立即联系专业人员，核查申报状态并补报。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>合规项目</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:21:58.299	2026-06-22 09:21:58.299
4	cmqp0b03j0007vs9kswzc33t5	17	JC-AI-20260622-0004	君册财税·企业初诊报告	MEDIUM	AUTO_RELEASED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0004</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:21:58.590Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>餐饮</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>1-3年</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>个体户</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>10-50万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#e67e22;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">中风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个中风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>长期零申报</strong>\n        <p style="color:#555;margin:6px 0">长期零申报可能引起税务关注，尤其是存在实际经营的情况下。</p>\n        <p style="color:#888;font-size:14px">💡 建议规范账务处理，确保每期申报真实准确反映经营状况。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>合规项目</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:21:58.591	2026-06-22 09:21:58.591
5	cmqp0cc0r00019e9kry6y36a9	18	JC-AI-20260622-0005	君册财税·企业初诊报告	MEDIUM	NEED_REVIEW	f	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0005</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:23:00.696Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>餐饮</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>1-3年</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>个体户</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>10-50万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#e67e22;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">中风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个中风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>长期零申报</strong>\n        <p style="color:#555;margin:6px 0">长期零申报可能引起税务关注，尤其是存在实际经营的情况下。</p>\n        <p style="color:#888;font-size:14px">💡 建议规范账务处理，确保每期申报真实准确反映经营状况。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>合规项目</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:23:00.699	2026-06-22 09:23:00.699
6	cmqp0wenv0001t59ky497szoi	19	JC-AI-20260622-0006	君册财税·企业初诊报告	LOW	AUTO_RELEASED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0006</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:38:37.240Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>互联网</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>5年以上</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>多股东</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>50-100万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#27ae60;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">低风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">根据您目前填写的信息，系统暂未发现明显高风险项。由于本报告仅基于有限信息生成，仍建议后续结合完整账务、申报、发票和工商资料进行人工确认。</p>\n</section>\n\n\n\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:38:37.243	2026-06-22 09:38:37.243
7	cmqp0wyaw0003t59k0ukurm6c	20	JC-AI-20260622-0007	君册财税·企业初诊报告	MEDIUM	NEED_REVIEW	f	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0007</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:39:02.694Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>互联网</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>5年以上</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>多股东</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>50-100万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#e67e22;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">中风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个中风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>禁用词测试</strong>\n        <p style="color:#555;margin:6px 0">您的公司可能存在合规风险，建议核查申报情况并及时处理，君册可以为您提供专业解决方案</p>\n        <p style="color:#888;font-size:14px">💡 可以通过合法合规的税务筹划优化税负，经营合规、申报规范可以降低被稽查可能性</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:39:02.696	2026-06-22 09:39:02.696
8	cmqp10por0005t59k48c65zc0	21	JC-AI-20260622-0008	君册财税·企业初诊报告	LOW	AUTO_RELEASED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0008</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:41:58.153Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>贸易</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>5年以上</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>多股东</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>50-100万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#27ae60;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">低风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">根据您目前填写的信息，系统暂未发现明显高风险项。由于本报告仅基于有限信息生成，仍建议后续结合完整账务、申报、发票和工商资料进行人工确认。</p>\n</section>\n\n\n\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:41:58.155	2026-06-22 09:41:58.155
9	cmqp10ptz0007t59kvzp2ky9p	22	JC-AI-20260622-0009	君册财税·企业初诊报告	MEDIUM	NEED_REVIEW	f	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0009</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:41:58.342Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>餐饮</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>1-3年</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>个体户</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>10-50万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#e67e22;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">中风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个中风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>长期零申报</strong>\n        <p style="color:#555;margin:6px 0">长期零申报可能引起税务关注，尤其是存在实际经营的情况下。</p>\n        <p style="color:#888;font-size:14px">💡 建议规范账务处理，确保每期申报真实准确反映经营状况。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>合规项目</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:41:58.343	2026-06-22 09:41:58.343
1	cmqp091g90001vs9kvgwjeqid	14	JC-AI-20260622-0001	君册财税·企业初诊报告	LOW	REVIEWED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0001</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T09:20:27.029Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>互联网</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>3-5年</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>多股东</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>50-100万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#27ae60;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">低风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">根据您目前填写的信息，系统暂未发现明显高风险项。由于本报告仅基于有限信息生成，仍建议后续结合完整账务、申报、发票和工商资料进行人工确认。</p>\n</section>\n\n\n\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	4	2026-06-22 10:11:25.699	2026-06-22 09:20:27.033	2026-06-22 10:11:25.703
12	cmqp3e90q0003009kcjlvpd08	25	JC-AI-20260622-0012	君册财税·企业初诊报告	HIGH	NEED_REVIEW	f	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0012</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T10:48:28.968Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>运输</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>1-3年</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>一人公司</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>100-500万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>5-10人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:red;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">高风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个高风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>未正常报税</strong>\n        <p style="color:#555;margin:6px 0">未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。</p>\n        <p style="color:#888;font-size:14px">💡 建议立即联系专业人员，核查申报状态并补报。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>合规项目</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 10:48:28.97	2026-06-22 10:48:28.97
10	cmqp10pya0009t59kl2h9h4bb	23	JC-AI-20260622-0010	君册财税·企业初诊报告	MEDIUM	NEED_REVIEW	f	<p>主管修改</p>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 09:41:58.498	2026-06-22 10:23:28.405
11	cmqp3e8vz0001009ku6st8uev	24	JC-AI-20260622-0011	君册财税·企业初诊报告	LOW	AUTO_RELEASED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260622-0011</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-22T10:48:28.796Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>贸易</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>5年以上</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>多股东</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>50-100万</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#27ae60;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">低风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">根据您目前填写的信息，系统暂未发现明显高风险项。由于本报告仅基于有限信息生成，仍建议后续结合完整账务、申报、发票和工商资料进行人工确认。</p>\n</section>\n\n\n\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-22 10:48:28.799	2026-06-22 10:48:28.799
\.


--
-- Data for Name: ReportAccessToken; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ReportAccessToken" (id, "reportId", "tokenHash", "expiresAt", "usedAt", "createdAt") FROM stdin;
2	2	$2b$10$CSarM6RZhRpPBAcDivNLIero2756lNM0tDQYhNRROF9pZ20bkgpzO	2026-06-29 09:20:54.405	2026-06-22 09:20:54.571	2026-06-22 09:20:54.405
3	3	$2b$10$QURAzQBV0yAAaj7ZZLRj3uxAMDMJ4OPwCM9flTlmPku3EjzqunXb6	2026-06-29 09:21:58.383	2026-06-22 09:21:58.543	2026-06-22 09:21:58.383
4	4	$2b$10$4nAwfwo3ab8YownYXd3OL.v/d/E5G.SrQgiJXYczqg.VOwizOjeXC	2026-06-29 09:21:58.662	2026-06-22 09:21:58.794	2026-06-22 09:21:58.662
5	5	$2b$10$96H1eubu3vF.7wpsTCW3POwDaQ7J9CGn4MInsBlYwjcC05rJ9Lkfi	2026-06-29 09:23:00.779	2026-06-22 09:23:00.952	2026-06-22 09:23:00.779
1	1	$2b$10$hUuwxVw.gF1m7hE1cxPHNOiVxx7RD5t.ENhBmopIioteUuuy8rg5e	2099-01-01 00:00:00	\N	2026-06-22 09:20:27.114
6	6	$2b$10$fBMA0RfaIqJ644IXYS9UW.6i9kCyBADM4XVniup9t2wT67ZFYz/j.	2020-01-01 00:00:00	2026-06-22 09:38:37.484	2026-06-22 09:38:37.316
7	7	$2b$10$92HQqoOuvOTXw7lKUhQ8jOMPTYlzfYcJ3RJndriwMA1pCupvuGMUy	2026-06-29 09:39:02.771	2026-06-22 09:39:02.911	2026-06-22 09:39:02.772
8	8	$2b$10$XwITH5tF39192kv8qyVIguKUtnm0yg/o4q570lqEyG2Npp4Md7O1.	2026-06-29 09:41:58.243	\N	2026-06-22 09:41:58.243
9	9	$2b$10$hV0PCYerQ0Muj.U836rIbu1MCbm7D6xDKyPhg3RfgFmu0C3J/0..e	2026-06-29 09:41:58.413	\N	2026-06-22 09:41:58.413
10	10	$2b$10$bjjc9wC3eYHrbBxkDdjaiOHi7Nx94in8w6EIyS4Il6imw3a9d4EVy	2026-06-29 09:41:58.568	\N	2026-06-22 09:41:58.568
11	11	$2b$10$GlStCBelnGWtIAcZsc9FbOdFEILrZISkGItW61Til2SH9tQg3I1aC	2026-06-29 10:48:28.879	\N	2026-06-22 10:48:28.879
12	12	$2b$10$KlMENOj4tuzQMhfR0Fw37eJL8EzATiBrj5fiqLtU5341lUfxb3/fi	2026-06-29 10:48:29.042	2026-06-22 10:48:29.177	2026-06-22 10:48:29.042
\.


--
-- Data for Name: ReviewRecord; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ReviewRecord" (id, "reportId", "reviewerId", action, changes, comment, "createdAt") FROM stdin;
1	1	4	APPROVE	\N	复核通过	2026-06-22 10:11:25.709
2	10	6	MODIFY	{"htmlContent": "modified"}	\N	2026-06-22 10:23:28.361
3	10	4	MODIFY	{"riskLevel": "HIGH→MEDIUM"}	管理员修正	2026-06-22 10:23:28.406
\.


--
-- Data for Name: RiskFinding; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."RiskFinding" (id, "diagnosisResultId", "ruleId", "scenarioId", "riskLevel", title, description, suggestion, "recommendServices", "createdAt") FROM stdin;
7	10	22	\N	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	["代理记账", "合规项目"]	2026-06-22 09:00:34.585
8	11	23	\N	HIGH	未正常报税	未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员，核查申报状态并补报。	["代理记账", "合规项目"]	2026-06-22 09:00:35.704
9	12	24	\N	HIGH	公私账户混用	公司款项通过个人账户收取可能导致税务风险和管理混乱。	建议尽快开立对公账户，所有经营收入通过公司账户管理。	["开户", "财务外包", "合规项目"]	2026-06-22 09:00:36.818
10	13	22	\N	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	["代理记账", "合规项目"]	2026-06-22 09:00:37.927
11	13	25	\N	MEDIUM	[测试]新注册公司	新注册公司需要关注初期合规建设。	建议尽快开立对公账户并建立账务体系。	["开户", "代理记账"]	2026-06-22 09:00:37.927
12	13	26	\N	MEDIUM	[测试]未缴纳社保	有员工但未依法缴纳社保可能存在用工合规风险。	建议依法为员工缴纳社保，规范用工管理。	["社保", "合规项目"]	2026-06-22 09:00:37.927
13	16	23	\N	HIGH	未正常报税	未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员，核查申报状态并补报。	["代理记账", "合规项目"]	2026-06-22 09:21:58.272
14	17	22	\N	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	["代理记账", "合规项目"]	2026-06-22 09:21:58.578
15	18	22	\N	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	["代理记账", "合规项目"]	2026-06-22 09:23:00.663
16	20	\N	\N	MEDIUM	禁用词测试	您的公司违法了，必须补税，保证帮您解决	可以避税，税局不会查	["代理记账"]	2026-06-22 09:39:02.675
17	22	22	\N	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	["代理记账", "合规项目"]	2026-06-22 09:41:58.334
18	23	23	\N	HIGH	未正常报税	未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员，核查申报状态并补报。	["代理记账", "合规项目"]	2026-06-22 09:41:58.488
19	25	23	\N	HIGH	未正常报税	未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员，核查申报状态并补报。	["代理记账", "合规项目"]	2026-06-22 10:48:28.955
\.


--
-- Data for Name: RiskScenario; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."RiskScenario" (id, "scenarioName", "scenarioCode", description, "riskLevel", "triggerRules", "safeExplanation", "forbiddenPhrases", suggestion, "recommendServices", "needManualReview", "isActive", "createdAt", "updatedAt") FROM stdin;
5	长期零申报	LONG_ZERO_DECLARATION	连续多个月零申报，但客户可能仍有实际经营	MEDIUM	{"value": "是", "answerField": "长期零申报"}	长期零申报可能引起税务关注，建议核查申报情况	{违法了,必须补税,一定会被罚款}	建议规范账务处理，确保申报真实准确	["代理记账", "合规项目"]	f	t	2026-06-22 08:57:56.919	2026-06-22 08:57:56.919
6	公私账户混用	MIXED_ACCOUNTS	公司经营款项通过老板个人账户收取	HIGH	{"value": "是", "answerField": "个人账户收款"}	通过个人账户收取公司款项可能存在合规风险，建议规范资金管理	{违法了,走私人账户没问题,可以避税}	建议开立对公账户并通过公司账户管理经营收入	["开户", "财务外包", "合规项目"]	t	t	2026-06-22 08:57:56.919	2026-06-22 08:57:56.919
7	未缴纳社保	NO_SOCIAL_INSURANCE	有员工但未依法缴纳社保	HIGH	{"value": "否", "answerField": "缴纳社保"}	有员工但未缴纳社保可能存在用工合规风险，建议尽快规范	{违法了,不用交,不交没关系}	建议依法为员工缴纳社保，规范用工管理	["社保", "合规项目"]	t	t	2026-06-22 08:57:56.919	2026-06-22 08:57:56.919
\.


--
-- Data for Name: ServiceRecommendation; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ServiceRecommendation" (id, "diagnosisResultId", "serviceType", reason, priority, "createdAt") FROM stdin;
11	10	代理记账	根据命中的风险项推荐	SUGGEST	2026-06-22 09:00:34.585
12	10	合规项目	根据命中的风险项推荐	SUGGEST	2026-06-22 09:00:34.585
13	11	代理记账	根据命中的风险项推荐	STRONG	2026-06-22 09:00:35.704
14	11	合规项目	根据命中的风险项推荐	STRONG	2026-06-22 09:00:35.704
15	12	开户	根据命中的风险项推荐	STRONG	2026-06-22 09:00:36.818
16	12	财务外包	根据命中的风险项推荐	STRONG	2026-06-22 09:00:36.818
17	12	合规项目	根据命中的风险项推荐	STRONG	2026-06-22 09:00:36.818
18	13	代理记账	根据命中的风险项推荐	SUGGEST	2026-06-22 09:00:37.927
19	13	合规项目	根据命中的风险项推荐	SUGGEST	2026-06-22 09:00:37.927
20	13	开户	根据命中的风险项推荐	SUGGEST	2026-06-22 09:00:37.927
21	13	社保	根据命中的风险项推荐	SUGGEST	2026-06-22 09:00:37.927
22	16	代理记账	根据命中的风险项推荐	STRONG	2026-06-22 09:21:58.272
23	16	合规项目	根据命中的风险项推荐	STRONG	2026-06-22 09:21:58.272
24	17	代理记账	根据命中的风险项推荐	SUGGEST	2026-06-22 09:21:58.578
25	17	合规项目	根据命中的风险项推荐	SUGGEST	2026-06-22 09:21:58.578
26	18	代理记账	根据命中的风险项推荐	SUGGEST	2026-06-22 09:23:00.663
27	18	合规项目	根据命中的风险项推荐	SUGGEST	2026-06-22 09:23:00.663
28	20	代理记账	根据命中的风险项推荐	SUGGEST	2026-06-22 09:39:02.675
29	22	代理记账	根据命中的风险项推荐	SUGGEST	2026-06-22 09:41:58.334
30	22	合规项目	根据命中的风险项推荐	SUGGEST	2026-06-22 09:41:58.334
31	23	代理记账	根据命中的风险项推荐	STRONG	2026-06-22 09:41:58.488
32	23	合规项目	根据命中的风险项推荐	STRONG	2026-06-22 09:41:58.488
33	25	代理记账	根据命中的风险项推荐	STRONG	2026-06-22 10:48:28.955
34	25	合规项目	根据命中的风险项推荐	STRONG	2026-06-22 10:48:28.955
\.


--
-- Data for Name: SmsVerificationCode; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."SmsVerificationCode" (id, phone, "codeHash", scene, "expiresAt", "verifiedAt", attempts, "createdAt") FROM stdin;
\.


--
-- Data for Name: Submission; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Submission" (id, "publicId", "questionnaireId", status, phone, "phoneVerified", source, "miniProgramCustomerId", "submittedAt", "createdAt", "updatedAt", "accessTokenCreatedAt", "accessTokenHash", "documentCompletenessDetail", "documentCompletenessScore", mode) FROM stdin;
11	cmqozjghc0003r09k46p16e4n	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:00:33.453	2026-06-22 09:00:33.456	2026-06-22 09:00:33.475	\N	\N	\N	\N	\N
12	cmqozjhcc0004r09ko48cte9b	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:00:34.57	2026-06-22 09:00:34.572	2026-06-22 09:00:34.591	\N	\N	\N	\N	\N
13	cmqozji7k0005r09khh53owge	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:00:35.695	2026-06-22 09:00:35.696	2026-06-22 09:00:35.708	\N	\N	\N	\N	\N
14	cmqozjj2h0006r09kislva3gt	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:00:36.808	2026-06-22 09:00:36.809	2026-06-22 09:00:36.822	\N	\N	\N	\N	\N
15	cmqozjjxb0007r09k0asq0q5k	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:00:37.917	2026-06-22 09:00:37.919	2026-06-22 09:00:37.931	\N	\N	\N	\N	\N
16	cmqp091em0000vs9kvu513p61	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:20:26.958	2026-06-22 09:20:26.974	2026-06-22 09:20:27.002	\N	\N	\N	\N	\N
17	cmqp09mh50002vs9kxdnorrb1	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:20:54.279	2026-06-22 09:20:54.281	2026-06-22 09:20:54.3	\N	\N	\N	\N	\N
18	cmqp0azua0004vs9kqcma435o	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:21:58.255	2026-06-22 09:21:58.258	2026-06-22 09:21:58.278	\N	\N	\N	\N	\N
19	cmqp0b02x0006vs9klgib13j1	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:21:58.568	2026-06-22 09:21:58.569	2026-06-22 09:21:58.582	\N	\N	\N	\N	\N
20	cmqp0cbz700009e9kqc8a2xur	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:23:00.627	2026-06-22 09:23:00.644	2026-06-22 09:23:00.671	\N	\N	\N	\N	\N
21	cmqp0wema0000t59kft003vee	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:38:37.171	2026-06-22 09:38:37.186	2026-06-22 09:38:37.214	\N	\N	\N	\N	\N
22	cmqp0wy9y0002t59krwjyczfz	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:39:02.662	2026-06-22 09:39:02.662	2026-06-22 09:39:02.681	\N	\N	\N	\N	\N
23	cmqp10pnx0004t59kkj5fobao	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:41:58.123	2026-06-22 09:41:58.125	2026-06-22 09:41:58.139	\N	\N	\N	\N	\N
24	cmqp10pti0006t59kjd4j59eo	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:41:58.324	2026-06-22 09:41:58.326	2026-06-22 09:41:58.339	\N	\N	\N	\N	\N
25	cmqp10pxr0008t59kbk76d6re	6	COMPLETED	\N	f	WEB	\N	2026-06-22 09:41:58.478	2026-06-22 09:41:58.479	2026-06-22 09:41:58.492	\N	\N	\N	\N	\N
26	cmqp3e8uf0000009kyauu5ecz	6	COMPLETED	\N	f	WEB	\N	2026-06-22 10:48:28.728	2026-06-22 10:48:28.743	2026-06-22 10:48:28.769	\N	\N	\N	\N	\N
27	cmqp3e8zz0002009ki1nthall	6	COMPLETED	\N	f	WEB	\N	2026-06-22 10:48:28.942	2026-06-22 10:48:28.943	2026-06-22 10:48:28.961	\N	\N	\N	\N	\N
\.


--
-- Data for Name: UploadedDocument; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."UploadedDocument" (id, "publicId", "submissionId", "docType", "originalName", "mimeType", "sizeBytes", "storagePath", "uploadStatus", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
c6c6b82e-e71e-4daf-9317-f2d9963f87f0	d95b5014bd1fa2afc39ff3c9c3f6be8988010fc50e061967a4573b9102418ad5	2026-06-22 10:52:05.227802+08	20260622025205_phase0_init	\N	\N	2026-06-22 10:52:05.191002+08	1
\.


--
-- Name: AdminUser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."AdminUser_id_seq"', 6, true);


--
-- Name: Answer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Answer_id_seq"', 270, true);


--
-- Name: DiagnosisResult_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DiagnosisResult_id_seq"', 25, true);


--
-- Name: DiagnosisRule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DiagnosisRule_id_seq"', 28, true);


--
-- Name: Disclaimer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Disclaimer_id_seq"', 2, true);


--
-- Name: DocumentRequirement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DocumentRequirement_id_seq"', 1, false);


--
-- Name: ForbiddenPhrase_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ForbiddenPhrase_id_seq"', 30, true);


--
-- Name: Question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Question_id_seq"', 70, true);


--
-- Name: Questionnaire_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Questionnaire_id_seq"', 7, true);


--
-- Name: ReportAccessToken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ReportAccessToken_id_seq"', 12, true);


--
-- Name: Report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Report_id_seq"', 12, true);


--
-- Name: ReviewRecord_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ReviewRecord_id_seq"', 3, true);


--
-- Name: RiskFinding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."RiskFinding_id_seq"', 19, true);


--
-- Name: RiskScenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."RiskScenario_id_seq"', 7, true);


--
-- Name: ServiceRecommendation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ServiceRecommendation_id_seq"', 34, true);


--
-- Name: SmsVerificationCode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."SmsVerificationCode_id_seq"', 1, false);


--
-- Name: Submission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Submission_id_seq"', 27, true);


--
-- Name: UploadedDocument_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."UploadedDocument_id_seq"', 1, false);


--
-- Name: AdminUser AdminUser_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."AdminUser"
    ADD CONSTRAINT "AdminUser_pkey" PRIMARY KEY (id);


--
-- Name: Answer Answer_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Answer"
    ADD CONSTRAINT "Answer_pkey" PRIMARY KEY (id);


--
-- Name: DiagnosisResult DiagnosisResult_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DiagnosisResult"
    ADD CONSTRAINT "DiagnosisResult_pkey" PRIMARY KEY (id);


--
-- Name: DiagnosisRule DiagnosisRule_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DiagnosisRule"
    ADD CONSTRAINT "DiagnosisRule_pkey" PRIMARY KEY (id);


--
-- Name: Disclaimer Disclaimer_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Disclaimer"
    ADD CONSTRAINT "Disclaimer_pkey" PRIMARY KEY (id);


--
-- Name: DocumentRequirement DocumentRequirement_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DocumentRequirement"
    ADD CONSTRAINT "DocumentRequirement_pkey" PRIMARY KEY (id);


--
-- Name: ForbiddenPhrase ForbiddenPhrase_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ForbiddenPhrase"
    ADD CONSTRAINT "ForbiddenPhrase_pkey" PRIMARY KEY (id);


--
-- Name: Question Question_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_pkey" PRIMARY KEY (id);


--
-- Name: Questionnaire Questionnaire_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Questionnaire"
    ADD CONSTRAINT "Questionnaire_pkey" PRIMARY KEY (id);


--
-- Name: ReportAccessToken ReportAccessToken_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ReportAccessToken"
    ADD CONSTRAINT "ReportAccessToken_pkey" PRIMARY KEY (id);


--
-- Name: Report Report_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Report"
    ADD CONSTRAINT "Report_pkey" PRIMARY KEY (id);


--
-- Name: ReviewRecord ReviewRecord_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ReviewRecord"
    ADD CONSTRAINT "ReviewRecord_pkey" PRIMARY KEY (id);


--
-- Name: RiskFinding RiskFinding_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."RiskFinding"
    ADD CONSTRAINT "RiskFinding_pkey" PRIMARY KEY (id);


--
-- Name: RiskScenario RiskScenario_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."RiskScenario"
    ADD CONSTRAINT "RiskScenario_pkey" PRIMARY KEY (id);


--
-- Name: ServiceRecommendation ServiceRecommendation_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ServiceRecommendation"
    ADD CONSTRAINT "ServiceRecommendation_pkey" PRIMARY KEY (id);


--
-- Name: SmsVerificationCode SmsVerificationCode_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."SmsVerificationCode"
    ADD CONSTRAINT "SmsVerificationCode_pkey" PRIMARY KEY (id);


--
-- Name: Submission Submission_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Submission"
    ADD CONSTRAINT "Submission_pkey" PRIMARY KEY (id);


--
-- Name: UploadedDocument UploadedDocument_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."UploadedDocument"
    ADD CONSTRAINT "UploadedDocument_pkey" PRIMARY KEY (id);


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: AdminUser_username_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "AdminUser_username_key" ON public."AdminUser" USING btree (username);


--
-- Name: DiagnosisResult_submissionId_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "DiagnosisResult_submissionId_key" ON public."DiagnosisResult" USING btree ("submissionId");


--
-- Name: DiagnosisRule_ruleCode_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "DiagnosisRule_ruleCode_key" ON public."DiagnosisRule" USING btree ("ruleCode");


--
-- Name: DocumentRequirement_code_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "DocumentRequirement_code_key" ON public."DocumentRequirement" USING btree (code);


--
-- Name: Question_publicId_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "Question_publicId_key" ON public."Question" USING btree ("publicId");


--
-- Name: Report_diagnosisResultId_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "Report_diagnosisResultId_key" ON public."Report" USING btree ("diagnosisResultId");


--
-- Name: Report_publicId_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "Report_publicId_key" ON public."Report" USING btree ("publicId");


--
-- Name: Report_reportNumber_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "Report_reportNumber_key" ON public."Report" USING btree ("reportNumber");


--
-- Name: RiskScenario_scenarioCode_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "RiskScenario_scenarioCode_key" ON public."RiskScenario" USING btree ("scenarioCode");


--
-- Name: Submission_publicId_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "Submission_publicId_key" ON public."Submission" USING btree ("publicId");


--
-- Name: UploadedDocument_publicId_key; Type: INDEX; Schema: public; Owner: a1234
--

CREATE UNIQUE INDEX "UploadedDocument_publicId_key" ON public."UploadedDocument" USING btree ("publicId");


--
-- Name: Answer Answer_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Answer"
    ADD CONSTRAINT "Answer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Answer Answer_submissionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Answer"
    ADD CONSTRAINT "Answer_submissionId_fkey" FOREIGN KEY ("submissionId") REFERENCES public."Submission"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: DiagnosisResult DiagnosisResult_submissionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DiagnosisResult"
    ADD CONSTRAINT "DiagnosisResult_submissionId_fkey" FOREIGN KEY ("submissionId") REFERENCES public."Submission"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: DiagnosisRule DiagnosisRule_questionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."DiagnosisRule"
    ADD CONSTRAINT "DiagnosisRule_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES public."Question"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: Question Question_questionnaireId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Question"
    ADD CONSTRAINT "Question_questionnaireId_fkey" FOREIGN KEY ("questionnaireId") REFERENCES public."Questionnaire"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ReportAccessToken ReportAccessToken_reportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ReportAccessToken"
    ADD CONSTRAINT "ReportAccessToken_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES public."Report"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Report Report_diagnosisResultId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Report"
    ADD CONSTRAINT "Report_diagnosisResultId_fkey" FOREIGN KEY ("diagnosisResultId") REFERENCES public."DiagnosisResult"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Report Report_reviewedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Report"
    ADD CONSTRAINT "Report_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES public."AdminUser"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ReviewRecord ReviewRecord_reportId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ReviewRecord"
    ADD CONSTRAINT "ReviewRecord_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES public."Report"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ReviewRecord ReviewRecord_reviewerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ReviewRecord"
    ADD CONSTRAINT "ReviewRecord_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES public."AdminUser"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RiskFinding RiskFinding_diagnosisResultId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."RiskFinding"
    ADD CONSTRAINT "RiskFinding_diagnosisResultId_fkey" FOREIGN KEY ("diagnosisResultId") REFERENCES public."DiagnosisResult"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: RiskFinding RiskFinding_ruleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."RiskFinding"
    ADD CONSTRAINT "RiskFinding_ruleId_fkey" FOREIGN KEY ("ruleId") REFERENCES public."DiagnosisRule"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: RiskFinding RiskFinding_scenarioId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."RiskFinding"
    ADD CONSTRAINT "RiskFinding_scenarioId_fkey" FOREIGN KEY ("scenarioId") REFERENCES public."RiskScenario"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ServiceRecommendation ServiceRecommendation_diagnosisResultId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."ServiceRecommendation"
    ADD CONSTRAINT "ServiceRecommendation_diagnosisResultId_fkey" FOREIGN KEY ("diagnosisResultId") REFERENCES public."DiagnosisResult"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Submission Submission_questionnaireId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."Submission"
    ADD CONSTRAINT "Submission_questionnaireId_fkey" FOREIGN KEY ("questionnaireId") REFERENCES public."Questionnaire"(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: UploadedDocument UploadedDocument_submissionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: a1234
--

ALTER TABLE ONLY public."UploadedDocument"
    ADD CONSTRAINT "UploadedDocument_submissionId_fkey" FOREIGN KEY ("submissionId") REFERENCES public."Submission"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict gYWKXfbLZ1BMz32Q1dtcpWiu3JfcP5nGCofWAuqrmhBYTcZShlPr3jiTQGc6W4E

