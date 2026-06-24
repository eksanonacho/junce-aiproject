--
-- PostgreSQL database dump
--

\restrict j3B6OsNfI1Gpv9JTgtlcMhXz96iJF32B7dHofKsH9bjSpeFX3EvGHds0T8cQlci

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: a1234
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO a1234;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: a1234
--

COMMENT ON SCHEMA public IS '';


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
    'DRAFT',
    'DOCUMENT_UPLOADING',
    'SUBMITTED',
    'QUESTIONNAIRE_COMPLETED',
    'DIAGNOSING',
    'COMPLETED',
    'FAILED'
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
    "dashboardData" jsonb,
    "needReview" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
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
    "conditionMode" text DEFAULT 'SIMPLE'::text NOT NULL,
    "riskLevel" public."RiskLevel" NOT NULL,
    "riskTitle" text NOT NULL,
    "riskDescription" text NOT NULL,
    suggestion text NOT NULL,
    "needReview" boolean DEFAULT false NOT NULL,
    "recommendServices" jsonb,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
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
    "publicId" text,
    "questionnaireId" integer NOT NULL,
    "groupLabel" text NOT NULL,
    "groupOrder" integer NOT NULL,
    "orderInGroup" integer NOT NULL,
    "questionText" text NOT NULL,
    "questionType" public."QuestionType" NOT NULL,
    options jsonb NOT NULL,
    "isRequired" boolean DEFAULT false NOT NULL,
    "riskDimension" text,
    "skipLogic" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
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
    mode public."DiagnosisMode",
    "documentCompletenessScore" integer,
    "documentCompletenessDetail" jsonb,
    "accessTokenHash" text,
    "accessTokenCreatedAt" timestamp(3) without time zone,
    "submittedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
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
1	admin	$2b$10$bJxO4Uh7qJtS.8.gZ0nQj.7Pp4Tk.AGKDiKFJEc7jHjtc1lK.kU9u	管理员	ADMIN	2026-06-23 12:36:02.768	2026-06-23 12:36:02.768
\.


--
-- Data for Name: Answer; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Answer" (id, "submissionId", "questionId", "answerValue", "createdAt") FROM stdin;
1	4	32	"否"	2026-06-23 13:17:25.244
2	5	11	"否"	2026-06-23 13:25:49.24
3	6	1	"互联网"	2026-06-23 13:33:26.32
4	6	2	"不到1年"	2026-06-23 13:33:26.32
5	6	3	"一人公司"	2026-06-23 13:33:26.32
6	6	4	"3000000"	2026-06-23 13:33:26.32
7	6	5	"1-5人"	2026-06-23 13:33:26.32
8	6	6	"是"	2026-06-23 13:33:26.32
9	6	7	"是"	2026-06-23 13:33:26.32
10	6	8	"否"	2026-06-23 13:33:26.32
11	6	9	"是"	2026-06-23 13:33:26.32
12	6	10	"是"	2026-06-23 13:33:26.32
13	7	11	"增长超过20%"	2026-06-23 13:42:51.89
14	7	12	"毛利15%-30%"	2026-06-23 13:42:51.893
15	7	13	"是"	2026-06-23 13:42:51.894
16	7	15	"否"	2026-06-23 13:42:51.894
17	7	18	"上涨超过30%"	2026-06-23 13:42:51.895
18	7	19	"小幅增长"	2026-06-23 13:42:51.896
19	7	20	"大幅增长"	2026-06-23 13:42:51.897
20	7	21	"有一定压力"	2026-06-23 13:42:51.898
21	7	23	"是"	2026-06-23 13:42:51.898
22	7	25	"前3-5个客户占50%以上"	2026-06-23 13:42:51.899
23	7	27	"是"	2026-06-23 13:42:51.9
24	7	28	"有少量"	2026-06-23 13:42:51.901
25	7	31	"是"	2026-06-23 13:42:51.901
26	7	32	"否"	2026-06-23 13:42:51.902
27	7	33	"否"	2026-06-23 13:42:51.903
28	7	34	"是"	2026-06-23 13:42:51.903
29	7	35	"是"	2026-06-23 13:42:51.904
30	7	36	"一般纳税人"	2026-06-23 13:42:51.905
31	7	37	"是，有担忧"	2026-06-23 13:42:51.905
32	7	38	"有专职会计"	2026-06-23 13:42:51.906
33	7	40	"否"	2026-06-23 13:42:51.91
34	7	41	"基本合理"	2026-06-23 13:42:51.911
35	7	42	"是"	2026-06-23 13:42:51.912
36	7	43	"否"	2026-06-23 13:42:51.912
37	7	44	"基本对应"	2026-06-23 13:42:51.913
38	7	45	"是"	2026-06-23 13:42:51.913
39	7	46	"是"	2026-06-23 13:42:51.914
40	7	48	"10-50人"	2026-06-23 13:42:51.915
41	7	49	"全员正常缴纳"	2026-06-23 13:42:51.915
42	7	50	"存在差异"	2026-06-23 13:42:51.916
43	7	51	"是"	2026-06-23 13:42:51.917
44	7	52	"正常经营"	2026-06-23 13:42:51.918
45	7	53	"近3年有变更"	2026-06-23 13:42:51.918
46	7	55	"及时"	2026-06-23 13:42:51.919
47	7	56	"是"	2026-06-23 13:42:51.92
48	7	57	"否"	2026-06-23 13:42:51.92
49	7	59	"30天以内"	2026-06-23 13:42:51.921
50	7	60	"是"	2026-06-23 13:42:51.921
51	7	62	"积压严重"	2026-06-23 13:42:51.922
52	7	63	"30天以内"	2026-06-23 13:42:51.924
53	7	64	"是"	2026-06-23 13:42:51.925
54	7	65	"偶尔变动"	2026-06-23 13:42:51.926
55	7	66	"是"	2026-06-23 13:42:51.927
56	7	69	"匹配"	2026-06-23 13:42:51.928
57	7	70	"大致了解"	2026-06-23 13:42:51.929
58	7	73	"是，较严重"	2026-06-23 13:42:51.93
59	7	74	"偶尔"	2026-06-23 13:42:51.93
60	7	75	"是，使用成熟系统"	2026-06-23 13:42:51.931
\.


--
-- Data for Name: DiagnosisResult; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DiagnosisResult" (id, "submissionId", "overallRiskLevel", summary, "dimensionResults", "dashboardData", "needReview", "createdAt", "updatedAt") FROM stdin;
1	4	HIGH	\N	[{"findings": [{"title": "未按期纳税申报", "riskLevel": "HIGH", "suggestion": "建议立即联系专业人员核查申报状态，尽快完成补申报。", "description": "未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。", "recommendServices": ["代理记账", "税务合规检查"]}], "dimension": "TAX_DECLARATION", "riskLevel": "HIGH"}]	{"riskScore": 1.7, "conclusion": "根据当前填写和上传资料，企业利润方面经营总体一般，但风险方面经营压力较大。建议优先处理风险相关问题，并由君册人员进一步复核。", "topActions": [{"title": "优先核查利润相关事项", "reason": "未发现明显问题", "priority": 1, "timeline": "1个月内", "serviceType": "经营分析"}, {"title": "优先核查现金流相关事项", "reason": "未发现明显问题", "priority": 2, "timeline": "3个月内", "serviceType": "经营分析"}, {"title": "优先核查效率相关事项", "reason": "未发现明显问题", "priority": 3, "timeline": "6个月内", "serviceType": "经营分析"}], "profitScore": 3.2, "overallLabel": "需重点关注", "overallScore": 2.7, "cashFlowScore": 3.2, "confidenceLevel": "LOW", "efficiencyScore": 3.2, "dimensionDetails": [{"label": "经营总体一般", "score": 3.2, "issues": ["未发现明显问题"], "evidence": "暂无上传资料", "dimension": "PROFIT", "confidence": 0, "suggestions": ["建议保持当前经营状态，定期关注财税合规"]}, {"label": "经营压力较大", "score": 1.7, "issues": ["未按期纳税申报"], "evidence": "暂无上传资料", "dimension": "RISK", "confidence": 0, "suggestions": ["建议立即联系专业人员核查申报状态，尽快完成补申报。"]}, {"label": "经营总体一般", "score": 3.2, "issues": ["未发现明显问题"], "evidence": "暂无上传资料", "dimension": "CASH_FLOW", "confidence": 0, "suggestions": ["建议保持当前经营状态，定期关注财税合规"]}, {"label": "经营总体一般", "score": 3.2, "issues": ["未发现明显问题"], "evidence": "暂无上传资料", "dimension": "EFFICIENCY", "confidence": 0, "suggestions": ["建议保持当前经营状态，定期关注财税合规"]}], "documentCompletenessScore": 0}	t	2026-06-23 13:17:25.272	2026-06-23 13:17:25.285
2	5	LOW	\N	[]	{"riskScore": 3.2, "conclusion": "根据当前填写和上传资料，企业利润方面经营总体一般，但效率方面经营总体一般。建议优先处理效率相关问题，并由君册人员进一步复核。", "topActions": [{"title": "优先核查利润相关事项", "reason": "未发现明显问题", "priority": 1, "timeline": "1个月内", "serviceType": "经营分析"}, {"title": "优先核查风险相关事项", "reason": "未发现明显问题", "priority": 2, "timeline": "3个月内", "serviceType": "税务合规检查"}, {"title": "优先核查现金流相关事项", "reason": "未发现明显问题", "priority": 3, "timeline": "6个月内", "serviceType": "经营分析"}], "profitScore": 3.2, "overallLabel": "经营总体一般", "overallScore": 3.2, "cashFlowScore": 3.2, "confidenceLevel": "LOW", "efficiencyScore": 3.2, "dimensionDetails": [{"label": "经营总体一般", "score": 3.2, "issues": ["未发现明显问题"], "evidence": "暂无上传资料", "dimension": "PROFIT", "confidence": 0, "suggestions": ["建议保持当前经营状态，定期关注财税合规"]}, {"label": "经营总体一般", "score": 3.2, "issues": ["未发现明显问题"], "evidence": "暂无上传资料", "dimension": "RISK", "confidence": 0, "suggestions": ["建议保持当前经营状态，定期关注财税合规"]}, {"label": "经营总体一般", "score": 3.2, "issues": ["未发现明显问题"], "evidence": "暂无上传资料", "dimension": "CASH_FLOW", "confidence": 0, "suggestions": ["建议保持当前经营状态，定期关注财税合规"]}, {"label": "经营总体一般", "score": 3.2, "issues": ["未发现明显问题"], "evidence": "暂无上传资料", "dimension": "EFFICIENCY", "confidence": 0, "suggestions": ["建议保持当前经营状态，定期关注财税合规"]}], "documentCompletenessScore": 0}	f	2026-06-23 13:25:49.266	2026-06-23 13:25:49.277
3	6	HIGH	\N	[{"findings": [{"title": "长期零申报", "riskLevel": "MEDIUM", "suggestion": "建议规范账务处理，确保每期申报真实准确反映经营状况。", "description": "长期零申报可能引起税务关注，尤其是存在实际经营的情况下。", "recommendServices": ["代理记账", "合规项目"]}], "dimension": "税务维度", "riskLevel": "MEDIUM"}, {"findings": [{"title": "公私账户混用", "riskLevel": "HIGH", "suggestion": "建议尽快开立对公账户，所有经营收入通过公司账户管理。", "description": "公司款项通过个人账户收取可能导致税务风险和管理混乱。", "recommendServices": ["开户", "财务外包", "合规项目"]}], "dimension": "资金维度", "riskLevel": "HIGH"}, {"findings": [{"title": "[测试]新注册公司", "riskLevel": "MEDIUM", "suggestion": "建议尽快开立对公账户并建立账务体系。", "description": "新注册公司需要关注初期合规建设。", "recommendServices": ["开户", "代理记账"]}], "dimension": "工商维度", "riskLevel": "MEDIUM"}]	\N	t	2026-06-23 13:33:26.339	2026-06-23 13:33:26.339
4	7	HIGH	\N	[{"findings": [{"title": "存在低毛利或亏损产品", "riskLevel": "MEDIUM", "suggestion": "建议分析各产品线盈利情况，考虑淘汰或优化低效产品。", "description": "存在低毛利或亏损产品线，可能拖累整体利润。", "recommendServices": ["经营分析"]}], "dimension": "REVENUE_MARGIN", "riskLevel": "MEDIUM"}, {"findings": [{"title": "成本大幅上涨", "riskLevel": "HIGH", "suggestion": "建议逐项分析成本上涨原因，评估是否有不合理或可控成本。", "description": "近一年成本上涨超过30%，可能严重侵蚀利润。", "recommendServices": ["经营分析"]}, {"title": "人工成本大幅增长", "riskLevel": "MEDIUM", "suggestion": "建议核算人均产出和人工成本率，评估人员配置合理性。", "description": "人工成本大幅增长，需评估人效是否同步提升。", "recommendServices": ["经营分析"]}, {"title": "公私费用混用", "riskLevel": "HIGH", "suggestion": "建议严格区分公司费用和个人支出，规范报销流程和账务处理。", "description": "老板个人支出与公司费用混用，可能导致税务风险和财务管理混乱。", "recommendServices": ["代理记账", "财务外包"]}], "dimension": "COST_EXPENSE", "riskLevel": "HIGH"}, {"findings": [{"title": "低毛利大客户依赖", "riskLevel": "MEDIUM", "suggestion": "建议评估大客户盈利贡献，对低毛利客户调整价格或服务方案。", "description": "存在低毛利大客户，不仅利润贡献低还占用了资源。", "recommendServices": ["经营分析"]}], "dimension": "CUSTOMER_PRODUCT", "riskLevel": "MEDIUM"}, {"findings": [{"title": "未按期纳税申报", "riskLevel": "HIGH", "suggestion": "建议立即联系专业人员核查申报状态，尽快完成补申报。", "description": "未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。", "recommendServices": ["代理记账", "税务合规检查"]}, {"title": "历史税务异常或处罚", "riskLevel": "MEDIUM", "suggestion": "建议梳理历史税务异常事项，核查是否已妥善处理。", "description": "存在税务提醒、异常或处罚记录，需关注未解决的税务问题。", "recommendServices": ["税务合规检查", "异常处理"]}, {"title": "申报数据与实际经营不一致", "riskLevel": "MEDIUM", "suggestion": "建议由专业人员核查申报数据与实际经营的匹配度。", "description": "申报数据与实际经营存在差异的担忧，可能涉及未申报收入或虚报成本。", "recommendServices": ["税务合规检查", "补账清账"]}], "dimension": "TAX_DECLARATION", "riskLevel": "HIGH"}, {"findings": [{"title": "发票与业务不匹配", "riskLevel": "HIGH", "suggestion": "建议规范发票管理，确保票、货、款三流一致。", "description": "发票与实际业务不匹配，可能涉及虚开发票或账外经营风险。", "recommendServices": ["税务合规检查", "代理记账"]}, {"title": "频繁公转私或大额无说明往来", "riskLevel": "HIGH", "suggestion": "建议规范资金管理，所有经营收支通过公司账户，保留完整交易凭证。", "description": "频繁公转私或存在大额无说明资金往来，可能引发税务稽查风险。", "recommendServices": ["财务外包", "税务合规检查"]}], "dimension": "INVOICE_FUND", "riskLevel": "HIGH"}, {"findings": [{"title": "工资/个税/社保人数不一致", "riskLevel": "MEDIUM", "suggestion": "建议核查三者一致性，规范用工和薪酬管理。", "description": "工资、个税和社保人数不一致，可能触发税务或社保稽查。", "recommendServices": ["社保用工咨询"]}, {"title": "较多兼职/劳务/外包人员", "riskLevel": "MEDIUM", "suggestion": "建议评估用工模式合规性，合理区分劳动关系和劳务关系。", "description": "较多非正式用工人员，可能存在劳动关系认定和社保风险。", "recommendServices": ["社保用工咨询"]}], "dimension": "SOCIAL_BUSINESS", "riskLevel": "MEDIUM"}, {"findings": [{"title": "长期逾期应收账款", "riskLevel": "HIGH", "suggestion": "建议立即梳理逾期账款，评估可回收性，必要时采取法律催收。", "description": "存在逾期90天以上的应收账款，坏账风险较高，严重影响现金流。", "recommendServices": ["经营分析", "异常处理"]}, {"title": "存在坏账或长期挂账", "riskLevel": "MEDIUM", "suggestion": "建议清理长期挂账，评估坏账金额并计提准备。", "description": "存在坏账或长期挂账，虚增资产的同时占用资金。", "recommendServices": ["经营分析"]}, {"title": "无专人跟进应收款", "riskLevel": "MEDIUM", "suggestion": "建议指定专人负责应收账款管理和催收。", "description": "没有专人跟进应收款，可能导致逾期账款累积。", "recommendServices": ["经营分析"]}], "dimension": "RECEIVABLE_COLLECTION", "riskLevel": "HIGH"}, {"findings": [{"title": "存货积压严重", "riskLevel": "MEDIUM", "suggestion": "建议分析存货结构，加快滞销品处理，优化采购计划。", "description": "存货严重积压，占用大量资金并存在贬值风险。", "recommendServices": ["经营分析"]}, {"title": "存在呆滞库存", "riskLevel": "MEDIUM", "suggestion": "建议定期清理呆滞库存，通过折价销售或其他方式变现。", "description": "存在呆滞库存，占用仓储空间和资金，需减值处理。", "recommendServices": ["经营分析"]}, {"title": "先付款后回款", "riskLevel": "MEDIUM", "suggestion": "建议优化采购付款条款，争取延长供应商账期或采用预收款模式。", "description": "经常先付款后回款，企业垫付资金压力大，现金流紧张。", "recommendServices": ["经营分析"]}], "dimension": "INVENTORY_PAYABLE", "riskLevel": "MEDIUM"}, {"findings": [{"title": "流程效率低下", "riskLevel": "MEDIUM", "suggestion": "建议梳理业务流程，引入自动化工具减少重复劳动。", "description": "存在较严重的流程重复、人工录入和效率低问题。", "recommendServices": ["经营分析"]}], "dimension": "HUMAN_ASSET_EFFICIENCY", "riskLevel": "MEDIUM"}]	{"riskScore": 1, "conclusion": "根据当前填写和上传资料，企业效率方面经营压力较大，但现金流方面经营压力较大。建议优先处理现金流相关问题，并由君册人员进一步复核。", "topActions": [{"title": "优先核查效率相关事项", "reason": "低毛利大客户依赖；流程效率低下", "priority": 1, "timeline": "1个月内", "serviceType": "经营分析"}, {"title": "优先核查利润相关事项", "reason": "存在低毛利或亏损产品；成本大幅上涨；人工成本大幅增长", "priority": 2, "timeline": "3个月内", "serviceType": "经营分析"}, {"title": "优先核查风险相关事项", "reason": "未按期纳税申报；历史税务异常或处罚；申报数据与实际经营不一致", "priority": 3, "timeline": "6个月内", "serviceType": "税务合规检查"}], "profitScore": 1, "overallLabel": "经营压力较大", "overallScore": 1.1, "cashFlowScore": 1, "confidenceLevel": "LOW", "efficiencyScore": 1.6, "dimensionDetails": [{"label": "经营压力较大", "score": 1, "issues": ["存在低毛利或亏损产品", "成本大幅上涨", "人工成本大幅增长"], "evidence": "暂无上传资料", "dimension": "PROFIT", "confidence": 0, "suggestions": ["建议分析各产品线盈利情况，考虑淘汰或优化低效产品。", "建议逐项分析成本上涨原因，评估是否有不合理或可控成本。"]}, {"label": "经营压力较大", "score": 1, "issues": ["未按期纳税申报", "历史税务异常或处罚", "申报数据与实际经营不一致"], "evidence": "暂无上传资料", "dimension": "RISK", "confidence": 0, "suggestions": ["建议立即联系专业人员核查申报状态，尽快完成补申报。", "建议梳理历史税务异常事项，核查是否已妥善处理。"]}, {"label": "经营压力较大", "score": 1, "issues": ["长期逾期应收账款", "存在坏账或长期挂账", "无专人跟进应收款"], "evidence": "暂无上传资料", "dimension": "CASH_FLOW", "confidence": 0, "suggestions": ["建议立即梳理逾期账款，评估可回收性，必要时采取法律催收。", "建议清理长期挂账，评估坏账金额并计提准备。"]}, {"label": "经营压力较大", "score": 1.6, "issues": ["低毛利大客户依赖", "流程效率低下"], "evidence": "暂无上传资料", "dimension": "EFFICIENCY", "confidence": 0, "suggestions": ["建议评估大客户盈利贡献，对低毛利客户调整价格或服务方案。", "建议梳理业务流程，引入自动化工具减少重复劳动。"]}], "documentCompletenessScore": 0}	t	2026-06-23 13:42:51.953	2026-06-23 13:42:51.972
\.


--
-- Data for Name: DiagnosisRule; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DiagnosisRule" (id, "ruleCode", dimension, "questionId", "triggerCondition", "compositeCondition", "conditionMode", "riskLevel", "riskTitle", "riskDescription", suggestion, "needReview", "recommendServices", "isActive", "createdAt", "updatedAt") FROM stdin;
1	TAX_001	税务维度	7	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	f	["代理记账", "合规项目"]	t	2026-06-23 12:36:02.794	2026-06-23 12:36:02.794
2	TAX_002	税务维度	6	{"value": "否", "operator": "equals"}	\N	SIMPLE	HIGH	未正常报税	未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员，核查申报状态并补报。	t	["代理记账", "合规项目"]	t	2026-06-23 12:36:02.794	2026-06-23 12:36:02.794
3	FUND_001	资金维度	10	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	公私账户混用	公司款项通过个人账户收取可能导致税务风险和管理混乱。	建议尽快开立对公账户，所有经营收入通过公司账户管理。	t	["开户", "财务外包", "合规项目"]	t	2026-06-23 12:36:02.794	2026-06-23 12:36:02.794
4	TEST_M001	工商维度	2	{"value": "不到1年", "operator": "equals"}	\N	SIMPLE	MEDIUM	[测试]新注册公司	新注册公司需要关注初期合规建设。	建议尽快开立对公账户并建立账务体系。	f	["开户", "代理记账"]	t	2026-06-23 12:36:02.794	2026-06-23 12:36:02.794
5	TEST_M002	社保维度	9	{"value": "否", "operator": "equals"}	\N	SIMPLE	MEDIUM	[测试]未缴纳社保	有员工但未依法缴纳社保可能存在用工合规风险。	建议依法为员工缴纳社保，规范用工管理。	f	["社保", "合规项目"]	t	2026-06-23 12:36:02.794	2026-06-23 12:36:02.794
6	V2_REV_001	REVENUE_MARGIN	11	{"value": "下降超过20%", "operator": "equals"}	\N	SIMPLE	HIGH	收入大幅下降	近一年营业收入下降超过20%，可能反映市场竞争加剧、客户流失或产品竞争力下降。	建议分析收入下降原因，评估产品/客户结构，制定应对策略。	t	["经营分析"]	t	2026-06-23 12:36:02.911	2026-06-23 12:36:02.911
7	V2_REV_002	REVENUE_MARGIN	12	{"value": ["毛利低于5%", "不清楚毛利情况"], "operator": "in"}	\N	SIMPLE	MEDIUM	毛利水平偏低或不明	毛利低于5%或不清楚毛利情况，说明盈利能力弱或缺乏成本核算。	建议建立产品/项目毛利核算体系，识别亏损业务。	f	["经营分析"]	t	2026-06-23 12:36:02.915	2026-06-23 12:36:02.915
8	V2_REV_003	REVENUE_MARGIN	13	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	存在低毛利或亏损产品	存在低毛利或亏损产品线，可能拖累整体利润。	建议分析各产品线盈利情况，考虑淘汰或优化低效产品。	f	["经营分析"]	t	2026-06-23 12:36:02.916	2026-06-23 12:36:02.916
9	V2_REV_004	REVENUE_MARGIN	15	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	收入增长但利润未增长	收入增长但利润停滞，可能存在费用失控或低价竞争问题。	建议核查费用增长和定价策略，确保收入增长转化为利润。	f	["经营分析"]	t	2026-06-23 12:36:02.917	2026-06-23 12:36:02.917
10	V2_REV_005C	REVENUE_MARGIN	\N	null	{"logic": "AND", "conditions": [{"value": ["下降10%-20%", "下降超过20%"], "operator": "in", "questionPublicId": null}, {"value": ["毛利低于5%", "毛利5%-15%"], "operator": "in", "questionPublicId": null}]}	COMPOSITE	HIGH	收入下降+毛利偏低	收入下降同时毛利偏低，企业盈利能力面临较大压力，需重点关注。	建议全面复盘收入结构和成本控制，优先处理高亏损业务线。	t	["经营分析", "税务合规检查"]	t	2026-06-23 12:36:02.919	2026-06-23 12:36:02.919
11	V2_REV_006	REVENUE_MARGIN	17	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	关键客户流失或业务收缩	近一年有关键客户流失或业务线收缩，可能影响收入稳定性。	建议分析客户流失原因，加强客户关系管理，开拓新客源。	f	["经营分析"]	t	2026-06-23 12:36:02.921	2026-06-23 12:36:02.921
12	V2_COST_001	COST_EXPENSE	18	{"value": "上涨超过30%", "operator": "equals"}	\N	SIMPLE	HIGH	成本大幅上涨	近一年成本上涨超过30%，可能严重侵蚀利润。	建议逐项分析成本上涨原因，评估是否有不合理或可控成本。	t	["经营分析"]	t	2026-06-23 12:36:02.922	2026-06-23 12:36:02.922
13	V2_COST_002	COST_EXPENSE	19	{"value": "大幅增长", "operator": "equals"}	\N	SIMPLE	MEDIUM	销售费用大幅增长	销售费用大幅增长但需核查是否带来对应的收入增长。	建议核算销售费用投入产出比，优化营销渠道和获客成本。	f	["经营分析"]	t	2026-06-23 12:36:02.924	2026-06-23 12:36:02.924
14	V2_COST_003	COST_EXPENSE	20	{"value": "大幅增长", "operator": "equals"}	\N	SIMPLE	MEDIUM	人工成本大幅增长	人工成本大幅增长，需评估人效是否同步提升。	建议核算人均产出和人工成本率，评估人员配置合理性。	f	["经营分析"]	t	2026-06-23 12:36:02.925	2026-06-23 12:36:02.925
15	V2_COST_004	COST_EXPENSE	21	{"value": "是，压力较大", "operator": "equals"}	\N	SIMPLE	MEDIUM	固定费用压力较大	房租、物流、平台费等固定费用压力较大，可能影响现金流。	建议评估固定费用占比，寻找降本空间或重新谈判合同条款。	f	["经营分析"]	t	2026-06-23 12:36:02.926	2026-06-23 12:36:02.926
16	V2_COST_005	COST_EXPENSE	23	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	公私费用混用	老板个人支出与公司费用混用，可能导致税务风险和财务管理混乱。	建议严格区分公司费用和个人支出，规范报销流程和账务处理。	t	["代理记账", "财务外包"]	t	2026-06-23 12:36:02.929	2026-06-23 12:36:02.929
17	V2_COST_006C	COST_EXPENSE	\N	null	{"logic": "AND", "conditions": [{"value": ["上涨超过30%", "上涨10%-30%"], "operator": "in", "questionPublicId": null}, {"value": "是", "operator": "equals", "questionPublicId": null}]}	COMPOSITE	HIGH	成本上涨+收入增长不增利	成本上涨伴随收入增长但利润未增，费用控制可能存在严重问题。	建议全面审计费用结构，重点核查销售和管理费用。	t	["经营分析", "财务外包"]	t	2026-06-23 12:36:02.93	2026-06-23 12:36:02.93
18	V2_CP_001	CUSTOMER_PRODUCT	25	{"value": "前1-2个客户占50%以上", "operator": "equals"}	\N	SIMPLE	HIGH	客户高度集中	收入高度依赖少数大客户，一旦客户流失将对经营造成重大冲击。	建议积极开拓新客户，降低单一客户依赖度至30%以下。	t	["经营分析"]	t	2026-06-23 12:36:02.932	2026-06-23 12:36:02.932
19	V2_CP_002	CUSTOMER_PRODUCT	27	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	低毛利大客户依赖	存在低毛利大客户，不仅利润贡献低还占用了资源。	建议评估大客户盈利贡献，对低毛利客户调整价格或服务方案。	f	["经营分析"]	t	2026-06-23 12:36:02.933	2026-06-23 12:36:02.933
20	V2_CP_003	CUSTOMER_PRODUCT	28	{"value": "是，较严重", "operator": "equals"}	\N	SIMPLE	HIGH	客户严重拖欠款项	有客户长期严重拖欠款项，坏账风险和现金流压力较大。	建议加紧催收逾期账款，对高风险客户停止赊销。	t	["经营分析", "异常处理"]	t	2026-06-23 12:36:02.934	2026-06-23 12:36:02.934
21	V2_CP_004	CUSTOMER_PRODUCT	29	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	长期不盈利产品仍在经营	有产品/服务长期不赚钱但仍在做，占用资源和精力。	建议定期淘汰亏损产品线，集中资源发展盈利业务。	f	["经营分析"]	t	2026-06-23 12:36:02.935	2026-06-23 12:36:02.935
22	V2_CP_005C	CUSTOMER_PRODUCT	\N	null	{"logic": "AND", "conditions": [{"value": ["前1-2个客户占50%以上", "前3-5个客户占50%以上"], "operator": "in", "questionPublicId": null}, {"value": "是", "operator": "equals", "questionPublicId": null}]}	COMPOSITE	HIGH	客户集中+低毛利依赖	收入依赖少数大客户且存在低毛利客户，经营风险较高。	建议降低客户集中度，优化大客户价格条款，开拓多元收入来源。	t	["经营分析"]	t	2026-06-23 12:36:02.937	2026-06-23 12:36:02.937
23	V2_CP_006	CUSTOMER_PRODUCT	26	{"value": ["大致了解", "不清楚"], "operator": "in"}	\N	SIMPLE	MEDIUM	客户毛利贡献不清	不了解各客户毛利贡献，无法有效管理客户盈利性。	建议建立客户维度盈利核算，识别高价值和低价值客户。	f	["经营分析"]	t	2026-06-23 12:36:02.939	2026-06-23 12:36:02.939
24	V2_TAX_001	TAX_DECLARATION	32	{"value": "否", "operator": "equals"}	\N	SIMPLE	HIGH	未按期纳税申报	未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员核查申报状态，尽快完成补申报。	t	["代理记账", "税务合规检查"]	t	2026-06-23 12:36:02.94	2026-06-23 12:36:02.94
25	V2_TAX_002C	TAX_DECLARATION	\N	null	{"logic": "AND", "conditions": [{"value": "是", "operator": "equals", "questionPublicId": null}, {"value": "是", "operator": "equals", "questionPublicId": null}]}	COMPOSITE	HIGH	长期零申报但仍有经营	长期零申报但实际仍有经营活动，属于高风险税务问题，可能面临补税、滞纳金和罚款。	建议立即停止零申报，规范账务处理，由专业人员代理记账和申报。	t	["代理记账", "补账清账", "税务合规检查"]	t	2026-06-23 12:36:02.941	2026-06-23 12:36:02.941
26	V2_TAX_003	TAX_DECLARATION	35	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	历史税务异常或处罚	存在税务提醒、异常或处罚记录，需关注未解决的税务问题。	建议梳理历史税务异常事项，核查是否已妥善处理。	f	["税务合规检查", "异常处理"]	t	2026-06-23 12:36:02.942	2026-06-23 12:36:02.942
27	V2_TAX_004	TAX_DECLARATION	37	{"value": "是，有担忧", "operator": "equals"}	\N	SIMPLE	MEDIUM	申报数据与实际经营不一致	申报数据与实际经营存在差异的担忧，可能涉及未申报收入或虚报成本。	建议由专业人员核查申报数据与实际经营的匹配度。	f	["税务合规检查", "补账清账"]	t	2026-06-23 12:36:02.943	2026-06-23 12:36:02.943
28	V2_TAX_005	TAX_DECLARATION	38	{"value": ["自己做账", "无专人负责"], "operator": "in"}	\N	SIMPLE	MEDIUM	无专业会计人员	没有专业会计或代理记账，账务处理和税务申报可能存在较多不规范之处。	建议委托专业代理记账机构，确保账务规范和申报合规。	f	["代理记账"]	t	2026-06-23 12:36:02.946	2026-06-23 12:36:02.946
29	V2_TAX_006	TAX_DECLARATION	36	{"value": "不清楚", "operator": "equals"}	\N	SIMPLE	MEDIUM	不清楚纳税人身份	不清楚自身纳税人身份，可能影响发票使用和税务申报合规。	建议确认纳税人身份，确保按正确方式申报和开票。	f	["税务合规检查"]	t	2026-06-23 12:36:02.947	2026-06-23 12:36:02.947
30	V2_TAX_007	TAX_DECLARATION	33	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议核查零申报合规性，确保每期申报真实反映经营情况。	f	["代理记账", "税务合规检查"]	t	2026-06-23 12:36:02.948	2026-06-23 12:36:02.948
31	V2_FUND_001	INVOICE_FUND	40	{"value": ["否", "部分不匹配"], "operator": "in"}	\N	SIMPLE	HIGH	发票与业务不匹配	发票与实际业务不匹配，可能涉及虚开发票或账外经营风险。	建议规范发票管理，确保票、货、款三流一致。	t	["税务合规检查", "代理记账"]	t	2026-06-23 12:36:02.949	2026-06-23 12:36:02.949
32	V2_FUND_002	INVOICE_FUND	42	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	频繁公转私或大额无说明往来	频繁公转私或存在大额无说明资金往来，可能引发税务稽查风险。	建议规范资金管理，所有经营收支通过公司账户，保留完整交易凭证。	t	["财务外包", "税务合规检查"]	t	2026-06-23 12:36:02.95	2026-06-23 12:36:02.95
33	V2_FUND_003	INVOICE_FUND	43	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	私人账户收公司款	使用私人账户收取公司款项可能导致公私财产混同，增加税务和管理风险。	建议开立对公账户，所有经营收入通过公司账户规范管理。	t	["开户指导", "财务外包"]	t	2026-06-23 12:36:02.951	2026-06-23 12:36:02.951
34	V2_FUND_004	INVOICE_FUND	44	{"value": ["部分不对应", "差异较大", "未核对过"], "operator": "in"}	\N	SIMPLE	MEDIUM	银行流水与业务不匹配	银行流水不能对应合同、发票和业务，可能存在账外资金往来。	建议逐笔核对银行流水与业务凭证，确保资金流向清晰可追溯。	f	["财务外包"]	t	2026-06-23 12:36:02.952	2026-06-23 12:36:02.952
35	V2_FUND_005	INVOICE_FUND	45	{"value": "否", "operator": "equals"}	\N	SIMPLE	MEDIUM	未开设对公账户	未开设对公账户，所有资金通过个人账户流转，存在财税合规风险。	建议尽快开立对公账户，规范经营资金管理。	f	["开户指导"]	t	2026-06-23 12:36:02.956	2026-06-23 12:36:02.956
36	V2_FUND_006	INVOICE_FUND	41	{"value": ["进项偏少", "不清楚"], "operator": "in"}	\N	SIMPLE	MEDIUM	进销项结构异常	进项与销项结构不合理，可能反映取票不足或虚开风险。	建议核查进销项匹配度，确保发票链条完整合规。	f	["税务合规检查"]	t	2026-06-23 12:36:02.957	2026-06-23 12:36:02.957
37	V2_FUND_007	INVOICE_FUND	47	{"value": "是，占比较大", "operator": "equals"}	\N	SIMPLE	MEDIUM	未开票收入占比较大	未开票收入占比较大，可能涉及隐匿收入风险。	建议规范开票管理，如实申报全部经营收入。	f	["税务合规检查", "代理记账"]	t	2026-06-23 12:36:02.958	2026-06-23 12:36:02.958
38	V2_SB_001	SOCIAL_BUSINESS	49	{"value": ["部分缴纳", "未缴纳"], "operator": "in"}	\N	SIMPLE	HIGH	社保未正常缴纳	有员工但社保未正常缴纳，可能面临劳动监察和社保稽查风险。	建议尽快为员工办理社保登记和缴纳，确保用工合规。	t	["社保用工咨询"]	t	2026-06-23 12:36:02.959	2026-06-23 12:36:02.959
39	V2_SB_002	SOCIAL_BUSINESS	50	{"value": ["存在差异", "不清楚"], "operator": "in"}	\N	SIMPLE	MEDIUM	工资/个税/社保人数不一致	工资、个税和社保人数不一致，可能触发税务或社保稽查。	建议核查三者一致性，规范用工和薪酬管理。	f	["社保用工咨询"]	t	2026-06-23 12:36:02.96	2026-06-23 12:36:02.96
40	V2_SB_003	SOCIAL_BUSINESS	52	{"value": "存在异常", "operator": "equals"}	\N	SIMPLE	MEDIUM	工商状态异常	工商状态存在异常，可能影响企业经营资质和信用记录。	建议核查工商异常原因，及时处理年报、地址变更等事项。	f	["工商变更", "异常处理"]	t	2026-06-23 12:36:02.962	2026-06-23 12:36:02.962
41	V2_SB_004	SOCIAL_BUSINESS	51	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	较多兼职/劳务/外包人员	较多非正式用工人员，可能存在劳动关系认定和社保风险。	建议评估用工模式合规性，合理区分劳动关系和劳务关系。	f	["社保用工咨询"]	t	2026-06-23 12:36:02.963	2026-06-23 12:36:02.963
42	V2_SB_005C	SOCIAL_BUSINESS	\N	null	{"logic": "AND", "conditions": [{"value": ["1-5人", "5-10人", "10-50人", "50人以上"], "operator": "in", "questionPublicId": null}, {"value": "未缴纳", "operator": "equals", "questionPublicId": null}]}	COMPOSITE	HIGH	有员工全员未缴社保	有员工但全员未缴纳社保，属于严重用工合规问题。	建议立即为员工办理社保登记，规范用工关系。	t	["社保用工咨询"]	t	2026-06-23 12:36:02.964	2026-06-23 12:36:02.964
43	V2_SB_006	SOCIAL_BUSINESS	53	{"value": "近一年有变更", "operator": "equals"}	\N	SIMPLE	MEDIUM	频繁变更工商信息	近一年频繁变更法人、股东或地址，可能反映经营不稳定。	建议关注变更原因，确保变更手续合法合规。	f	["工商变更"]	t	2026-06-23 12:36:02.966	2026-06-23 12:36:02.966
44	V2_AR_001	RECEIVABLE_COLLECTION	55	{"value": ["经常拖延", "严重逾期"], "operator": "in"}	\N	SIMPLE	MEDIUM	回款周期过长	客户回款经常拖延或严重逾期，可能影响企业现金流。	建议梳理应收账款，建立回款催收制度。	f	["经营分析"]	t	2026-06-23 12:36:02.967	2026-06-23 12:36:02.967
45	V2_AR_002	RECEIVABLE_COLLECTION	56	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	长期逾期应收账款	存在逾期90天以上的应收账款，坏账风险较高，严重影响现金流。	建议立即梳理逾期账款，评估可回收性，必要时采取法律催收。	t	["经营分析", "异常处理"]	t	2026-06-23 12:36:02.967	2026-06-23 12:36:02.967
46	V2_AR_003	RECEIVABLE_COLLECTION	59	{"value": ["90天以上", "不清楚"], "operator": "in"}	\N	SIMPLE	MEDIUM	回款周期过长或不明确	回款周期超过90天或不掌握回款周期，应收账款管理薄弱。	建议建立应收账款台账，设定回款目标和催收流程。	f	["经营分析"]	t	2026-06-23 12:36:02.968	2026-06-23 12:36:02.968
47	V2_AR_004	RECEIVABLE_COLLECTION	60	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	存在坏账或长期挂账	存在坏账或长期挂账，虚增资产的同时占用资金。	建议清理长期挂账，评估坏账金额并计提准备。	f	["经营分析"]	t	2026-06-23 12:36:02.972	2026-06-23 12:36:02.972
48	V2_AR_005C	RECEIVABLE_COLLECTION	\N	null	{"logic": "AND", "conditions": [{"value": ["经常拖延", "严重逾期"], "operator": "in", "questionPublicId": null}, {"value": "是", "operator": "equals", "questionPublicId": null}]}	COMPOSITE	HIGH	回款延误+长期逾期并存	回款普遍拖延且存在大额逾期账款，现金流风险较高。	建议收紧信用政策，加大催收力度，评估坏账风险。	t	["经营分析", "异常处理"]	t	2026-06-23 12:36:02.973	2026-06-23 12:36:02.973
49	V2_AR_006	RECEIVABLE_COLLECTION	57	{"value": "否", "operator": "equals"}	\N	SIMPLE	MEDIUM	无专人跟进应收款	没有专人跟进应收款，可能导致逾期账款累积。	建议指定专人负责应收账款管理和催收。	f	["经营分析"]	t	2026-06-23 12:36:02.974	2026-06-23 12:36:02.974
50	V2_IP_001	INVENTORY_PAYABLE	62	{"value": "积压严重", "operator": "equals"}	\N	SIMPLE	MEDIUM	存货积压严重	存货严重积压，占用大量资金并存在贬值风险。	建议分析存货结构，加快滞销品处理，优化采购计划。	f	["经营分析"]	t	2026-06-23 12:36:02.975	2026-06-23 12:36:02.975
51	V2_IP_002	INVENTORY_PAYABLE	63	{"value": ["90天以上", "不清楚"], "operator": "in"}	\N	SIMPLE	MEDIUM	存货周转天数过长	存货周转超过90天或不掌握周转情况，资金使用效率低。	建议加快存货周转，设定安全库存和周转率目标。	f	["经营分析"]	t	2026-06-23 12:36:02.976	2026-06-23 12:36:02.976
52	V2_IP_003	INVENTORY_PAYABLE	64	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	存在呆滞库存	存在呆滞库存，占用仓储空间和资金，需减值处理。	建议定期清理呆滞库存，通过折价销售或其他方式变现。	f	["经营分析"]	t	2026-06-23 12:36:02.976	2026-06-23 12:36:02.976
53	V2_IP_004	INVENTORY_PAYABLE	66	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	先付款后回款	经常先付款后回款，企业垫付资金压力大，现金流紧张。	建议优化采购付款条款，争取延长供应商账期或采用预收款模式。	f	["经营分析"]	t	2026-06-23 12:36:02.978	2026-06-23 12:36:02.978
54	V2_IP_005C	INVENTORY_PAYABLE	\N	null	{"logic": "AND", "conditions": [{"value": "积压严重", "operator": "equals", "questionPublicId": null}, {"value": "是", "operator": "equals", "questionPublicId": null}]}	COMPOSITE	HIGH	存货积压+先付后收	存货严重积压同时先付款后回款，现金流双重压力。	建议优先清理存货，改善采购付款条件，缓解资金压力。	t	["经营分析"]	t	2026-06-23 12:36:02.979	2026-06-23 12:36:02.979
55	V2_IP_006	INVENTORY_PAYABLE	65	{"value": "经常变动", "operator": "equals"}	\N	SIMPLE	MEDIUM	供应商账期不稳定	供应商账期经常变动，不利于现金流规划和管理。	建议与主要供应商协商稳定账期，纳入现金流预算管理。	f	["经营分析"]	t	2026-06-23 12:36:02.98	2026-06-23 12:36:02.98
56	V2_HAE_001	HUMAN_ASSET_EFFICIENCY	69	{"value": "人员偏多/业务不足", "operator": "equals"}	\N	SIMPLE	MEDIUM	人员配置冗余	人员偏多而业务量不足，可能存在人效偏低和成本浪费。	建议评估人员配置和业务量匹配度，优化人员结构。	f	["经营分析"]	t	2026-06-23 12:36:02.982	2026-06-23 12:36:02.982
57	V2_HAE_002	HUMAN_ASSET_EFFICIENCY	70	{"value": "不清楚", "operator": "equals"}	\N	SIMPLE	MEDIUM	人均产出不明确	不清楚人均产出，无法有效评估人员效率和优化配置。	建议建立人均产出指标，定期跟踪和评估人效。	f	["经营分析"]	t	2026-06-23 12:36:02.982	2026-06-23 12:36:02.982
58	V2_HAE_003	HUMAN_ASSET_EFFICIENCY	73	{"value": "是，较严重", "operator": "equals"}	\N	SIMPLE	MEDIUM	流程效率低下	存在较严重的流程重复、人工录入和效率低问题。	建议梳理业务流程，引入自动化工具减少重复劳动。	f	["经营分析"]	t	2026-06-23 12:36:02.983	2026-06-23 12:36:02.983
59	V2_HAE_004	HUMAN_ASSET_EFFICIENCY	75	{"value": "基本手工", "operator": "equals"}	\N	SIMPLE	MEDIUM	缺乏管理系统	基本手工管理，数据准确性和效率可能不足。	建议引入适合规模的ERP或管理系统，提升管理效率。	f	["经营分析"]	t	2026-06-23 12:36:02.984	2026-06-23 12:36:02.984
60	V2_HAE_005C	HUMAN_ASSET_EFFICIENCY	\N	null	{"logic": "AND", "conditions": [{"value": "人员偏多/业务不足", "operator": "equals", "questionPublicId": null}, {"value": ["大幅增长", "小幅增长"], "operator": "in", "questionPublicId": null}]}	COMPOSITE	HIGH	人员冗余+人工成本增长	人员配置冗余同时人工成本增长，人效问题叠加成本压力。	建议评估人员结构，优化编制和薪酬策略。	t	["经营分析", "社保用工咨询"]	t	2026-06-23 12:36:02.985	2026-06-23 12:36:02.985
\.


--
-- Data for Name: Disclaimer; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Disclaimer" (id, version, content, "isActive") FROM stdin;
1	v1	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	t
2	v2	本系统生成内容仅作为企业经营与财税风险初步筛查参考，基于当前填写和上传资料计算，不构成最终税务、法律、审计或行政结论。\n\n报告中的四维经营评分和风险分析系根据您提供的信息由系统自动生成，具体事项建议结合完整资料由君册专业人员进一步复核。\n\n本报告不替代专业会计师、税务师或律师的正式意见。如涉及重大经营决策，请咨询君册专业顾问。\n\n君册财税保留对报告内容的最终解释权。	t
\.


--
-- Data for Name: DocumentRequirement; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DocumentRequirement" (id, code, name, category, "requiredForQuick", "requiredForStandard", "requiredForDeep", "affectsDimensions", description, "sortOrder", "isActive", "createdAt", "updatedAt") FROM stdin;
1	BUSINESS_LICENSE	营业执照	工商证照	t	t	t	["RISK"]	用于确认企业主体信息、经营范围与存续状态	1	t	2026-06-23 12:36:02.814	2026-06-23 12:36:02.814
2	INCOME_STATEMENT	利润表	财务报表	t	t	t	["PROFIT"]	用于判断收入、毛利和费用变化情况（快速：近3-6月；标准/深度：近12月）	2	t	2026-06-23 12:36:02.818	2026-06-23 12:36:02.818
3	BALANCE_SHEET	资产负债表	财务报表	t	t	t	["CASH_FLOW", "EFFICIENCY"]	用于判断资产结构、负债水平和运营效率（快速：近3-6月；标准/深度：近12月）	3	t	2026-06-23 12:36:02.819	2026-06-23 12:36:02.819
4	CASH_FLOW_STATEMENT	现金流量表	财务报表	f	t	t	["CASH_FLOW"]	用于判断经营/投资/筹资现金流是否健康（近12月）	4	t	2026-06-23 12:36:02.821	2026-06-23 12:36:02.821
5	ACCOUNT_BALANCE	科目余额表	财务报表	f	t	t	["PROFIT", "RISK"]	用于核对各科目余额，发现账务异常	5	t	2026-06-23 12:36:02.823	2026-06-23 12:36:02.823
6	VAT_DECLARATION	增值税申报表	税务资料	t	t	t	["RISK"]	用于判断增值税申报合规性和税负水平	6	t	2026-06-23 12:36:02.824	2026-06-23 12:36:02.824
7	CIT_DECLARATION	企业所得税申报表	税务资料	f	t	t	["RISK", "PROFIT"]	用于判断企业所得税申报合规性和利润真实性	7	t	2026-06-23 12:36:02.825	2026-06-23 12:36:02.825
8	INVOICE_SUMMARY	开票/收票汇总	税务资料	f	t	t	["RISK"]	用于判断进销项匹配度和发票合规性	8	t	2026-06-23 12:36:02.826	2026-06-23 12:36:02.826
9	BANK_STATEMENT	银行流水	资金资料	f	t	t	["CASH_FLOW", "RISK"]	用于核对收入、支出与合同/发票匹配度	9	t	2026-06-23 12:36:02.826	2026-06-23 12:36:02.826
10	PAYROLL_SOCIAL_SECURITY	工资/社保/个税资料	人力资料	f	t	t	["RISK", "EFFICIENCY"]	用于判断用工合规性和人效水平	10	t	2026-06-23 12:36:02.831	2026-06-23 12:36:02.831
11	CUSTOMER_REVENUE	客户收入贡献表	经营分析	f	f	t	["PROFIT", "EFFICIENCY"]	用于分析客户集中度和客户毛利贡献	11	t	2026-06-23 12:36:02.833	2026-06-23 12:36:02.833
12	PRODUCT_MARGIN	产品/项目毛利表	经营分析	f	f	t	["PROFIT"]	用于分析各产品/项目盈利能力	12	t	2026-06-23 12:36:02.834	2026-06-23 12:36:02.834
13	AR_AGING	应收账款账龄表	资金资料	f	f	t	["CASH_FLOW"]	用于判断回款能力和坏账风险	13	t	2026-06-23 12:36:02.835	2026-06-23 12:36:02.835
14	AP_AGING	应付账款明细	资金资料	f	f	t	["CASH_FLOW"]	用于判断付款压力和供应商账期	14	t	2026-06-23 12:36:02.838	2026-06-23 12:36:02.838
15	INVENTORY_DETAIL	存货明细及库龄	经营分析	f	f	t	["CASH_FLOW", "EFFICIENCY"]	用于判断存货积压和周转效率	15	t	2026-06-23 12:36:02.839	2026-06-23 12:36:02.839
16	FIXED_ASSET	固定资产/设备清单	经营分析	f	f	t	["EFFICIENCY"]	用于判断资产利用率和闲置情况	16	t	2026-06-23 12:36:02.84	2026-06-23 12:36:02.84
17	EXPENSE_DETAIL	费用明细	经营分析	f	f	t	["PROFIT", "EFFICIENCY"]	用于分析费用结构和投入产出比	17	t	2026-06-23 12:36:02.841	2026-06-23 12:36:02.841
18	CONTRACT_SAMPLE	合同样本	法务资料	f	f	t	["RISK"]	用于判断合同条款合规性和经营风险	18	t	2026-06-23 12:36:02.842	2026-06-23 12:36:02.842
19	TAX_ABNORMAL_RECORD	税务异常/处罚/提醒记录	税务资料	f	f	t	["RISK"]	用于判断历史税务合规问题和风险程度	19	t	2026-06-23 12:36:02.843	2026-06-23 12:36:02.843
\.


--
-- Data for Name: ForbiddenPhrase; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ForbiddenPhrase" (id, phrase, "safeAlternative", category, "isActive") FROM stdin;
1	违法了	可能存在合规风险	法律定性	t
2	必须补税	建议核查申报情况并及时处理	税务指令	t
3	一定会被罚款	可能面临税务处理	承诺结果	t
4	保证帮您解决	君册可以为您提供专业解决方案	承诺结果	t
5	保证通过税务检查	君册可以帮助您做好合规准备	承诺结果	t
6	一定没有风险	根据目前信息，暂未发现明显高风险项	承诺结果	t
7	这个不用管	该项暂不构成紧迫风险，但建议持续关注	忽视问题	t
8	可以避税	可以通过合法合规的税务筹划优化税负	避税教唆	t
9	不用开发票	开票是企业法定义务，君册可帮助规范开票流程	避税教唆	t
10	可以走私人账户	建议将经营收入通过公司账户管理	公私混用	t
11	保证多久办完	根据以往经验，办理周期大约需要一定时间	承诺结果	t
12	税局不会查	经营合规、申报规范可以降低被稽查可能性	承诺结果	t
13	这个操作没问题	该操作需由专业人员结合完整资料确认	打包票	t
14	肯定能注销成功	君册可以协助准备完整注销材料推进流程	承诺结果	t
15	一定能省钱	合规的税务筹划通常可以合理优化税负	承诺结果	t
\.


--
-- Data for Name: Question; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Question" (id, "publicId", "questionnaireId", "groupLabel", "groupOrder", "orderInGroup", "questionText", "questionType", options, "isRequired", "riskDimension", "skipLogic", "createdAt", "updatedAt") FROM stdin;
6	q_574dbbef4b8c460f8cb980f429c56453	1	税务申报	3	1	目前是否正常报税？	YES_NO	["是", "否"]	t	税务维度	\N	2026-06-23 12:36:02.786	2026-06-23 12:36:02.786
1	q_3057c78581cb47888da23c1eef45815e	1	企业基础信息	1	1	贵公司所属行业？	SINGLE_CHOICE	["互联网", "贸易", "餐饮", "建筑", "运输", "制造", "其他"]	t	工商维度	\N	2026-06-23 12:36:02.777	2026-06-23 12:36:02.777
2	q_3d6653e608634df39bd85d07829d7bbc	1	企业基础信息	1	2	公司注册时间？	SINGLE_CHOICE	["不到1年", "1-3年", "3-5年", "5年以上"]	t	工商维度	\N	2026-06-23 12:36:02.78	2026-06-23 12:36:02.78
3	q_53074ceaca814e88834474f0f7ec4d18	1	企业基础信息	1	3	公司类型？	SINGLE_CHOICE	["一人公司", "多股东", "个体户"]	t	工商维度	\N	2026-06-23 12:36:02.781	2026-06-23 12:36:02.781
4	q_4dab72a792db461990a0303ee34a7104	1	经营规模	2	1	年流水大约多少？	RANGE	{"options": ["10万以下", "10-50万", "50-100万", "100-500万", "500万以上"]}	t	税务维度	\N	2026-06-23 12:36:02.783	2026-06-23 12:36:02.783
5	q_663c6281ff3f471ab866bdc79d70fb98	1	经营规模	2	2	公司员工人数？	SINGLE_CHOICE	["0人（无员工）", "1-5人", "5-10人", "10-50人", "50人以上"]	t	社保维度	\N	2026-06-23 12:36:02.785	2026-06-23 12:36:02.785
7	q_b49cd6d182334e5f8afcd46a218d5dd9	1	税务申报	3	2	是否长期零申报？	YES_NO	["是", "否"]	f	税务维度	\N	2026-06-23 12:36:02.788	2026-06-23 12:36:02.788
8	q_96de97dd44d04cc98077dce0f85a0509	1	社保/员工	4	1	是否给员工缴纳社保？	YES_NO	["是", "否", "无员工"]	t	社保维度	\N	2026-06-23 12:36:02.789	2026-06-23 12:36:02.789
9	q_7af865dba71c4bc288127d37c475fd38	1	资金/账户	5	1	是否已开设对公账户？	YES_NO	["是", "否"]	t	资金维度	\N	2026-06-23 12:36:02.79	2026-06-23 12:36:02.79
10	q_741615838017432d8e0497c62f15f1e2	1	资金/账户	5	2	是否存在老板个人账户收公司款项的情况？	YES_NO	["是", "否", "不清楚"]	f	资金维度	\N	2026-06-23 12:36:02.79	2026-06-23 12:36:02.79
11	q_84ff76353bbf45c78c3fc59579317def	2	收入与毛利	1	1	近一年营业收入变化情况？	SINGLE_CHOICE	["增长超过20%", "增长10%-20%", "基本持平", "下降10%-20%", "下降超过20%"]	t	REVENUE_MARGIN	{}	2026-06-23 12:36:02.852	2026-06-23 12:36:02.852
12	q_6a2dcc4203f947609ac068b98a6a968f	2	收入与毛利	1	2	主要产品或服务毛利水平如何？	SINGLE_CHOICE	["毛利30%以上", "毛利15%-30%", "毛利5%-15%", "毛利低于5%", "不清楚毛利情况"]	t	REVENUE_MARGIN	{}	2026-06-23 12:36:02.853	2026-06-23 12:36:02.853
13	q_4a55fbd05d104115a99a364e04a8ea70	2	收入与毛利	1	3	是否存在低毛利或亏损产品？	YES_NO	["是", "否", "不清楚"]	t	REVENUE_MARGIN	{}	2026-06-23 12:36:02.854	2026-06-23 12:36:02.854
14	q_6585800075cb448ab1cf89ea9e37d3fc	2	收入与毛利	1	4	是否能区分不同产品/项目毛利？	YES_NO	["是，有明确核算", "部分可以", "无法区分"]	t	REVENUE_MARGIN	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.855	2026-06-23 12:36:02.855
15	q_9fc030d29d4049bbadbf160f23065e03	2	收入与毛利	1	5	是否存在收入增长但利润没有增长？	YES_NO	["是", "否", "收入未增长"]	t	REVENUE_MARGIN	{}	2026-06-23 12:36:02.856	2026-06-23 12:36:02.856
16	q_d3f91aee70be40aa8067e5e8b7057031	2	收入与毛利	1	6	是否有季节性收入波动？	SINGLE_CHOICE	["有明显季节性", "波动较小", "比较稳定"]	f	REVENUE_MARGIN	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.857	2026-06-23 12:36:02.857
17	q_55537bf4a89c44d8b438819f5627103b	2	收入与毛利	1	7	近一年是否有关键客户流失或业务线收缩？	YES_NO	["是", "否"]	f	REVENUE_MARGIN	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.858	2026-06-23 12:36:02.858
18	q_b0279c9745674d6d86ac9558639f6ff4	2	成本费用	2	1	近一年成本是否明显上涨？	SINGLE_CHOICE	["上涨超过30%", "上涨10%-30%", "基本持平", "下降"]	t	COST_EXPENSE	{}	2026-06-23 12:36:02.859	2026-06-23 12:36:02.859
19	q_07c2924f3c6c48a49082b34a7a11f898	2	成本费用	2	2	销售费用是否明显增长？	SINGLE_CHOICE	["大幅增长", "小幅增长", "基本持平", "下降"]	t	COST_EXPENSE	{}	2026-06-23 12:36:02.86	2026-06-23 12:36:02.86
20	q_0588b3a44e704cba997ac61a971bed2b	2	成本费用	2	3	人工成本是否明显增长？	SINGLE_CHOICE	["大幅增长", "小幅增长", "基本持平", "下降"]	t	COST_EXPENSE	{}	2026-06-23 12:36:02.862	2026-06-23 12:36:02.862
21	q_9c635534c1de4ce4b620353b1c671e3c	2	成本费用	2	4	房租、物流、平台费等固定费用是否有压力？	YES_NO	["是，压力较大", "有一定压力", "无压力"]	t	COST_EXPENSE	{}	2026-06-23 12:36:02.863	2026-06-23 12:36:02.863
22	q_3d7ce59d722d43cd9c54319030cd9e0a	2	成本费用	2	5	是否定期核算费用投入产出比？	YES_NO	["是，定期核算", "偶尔核算", "不清楚"]	f	COST_EXPENSE	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.864	2026-06-23 12:36:02.864
23	q_b2164af11199404aa94d1915eb954585	2	成本费用	2	6	是否存在老板个人支出与公司费用混用？	YES_NO	["是", "否", "不确定"]	t	COST_EXPENSE	{}	2026-06-23 12:36:02.865	2026-06-23 12:36:02.865
24	q_ba08090e79eb4c3f821c68b19113172f	2	成本费用	2	7	近一年是否有大额非经常性支出？	YES_NO	["是", "否"]	f	COST_EXPENSE	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.866	2026-06-23 12:36:02.866
25	q_0ae6571f11134e1ca89a1cc54df53e05	2	客户产品贡献	3	1	收入是否依赖少数大客户？	SINGLE_CHOICE	["前1-2个客户占50%以上", "前3-5个客户占50%以上", "客户较分散", "不清楚"]	t	CUSTOMER_PRODUCT	{}	2026-06-23 12:36:02.867	2026-06-23 12:36:02.867
26	q_e9f4ea502daa4d7293baee665100c16d	2	客户产品贡献	3	2	是否知道前五大客户毛利贡献？	YES_NO	["是，清楚核算", "大致了解", "不清楚"]	t	CUSTOMER_PRODUCT	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.868	2026-06-23 12:36:02.868
27	q_e6789b1bcc904ca4807f2b238a00efbd	2	客户产品贡献	3	3	是否存在低毛利大客户？	YES_NO	["是", "否", "不清楚"]	t	CUSTOMER_PRODUCT	{}	2026-06-23 12:36:02.869	2026-06-23 12:36:02.869
28	q_dc82563ccde840d69ef8309e000ce478	2	客户产品贡献	3	4	是否有客户长期拖欠款项？	YES_NO	["是，较严重", "有少量", "没有"]	t	CUSTOMER_PRODUCT	{}	2026-06-23 12:36:02.876	2026-06-23 12:36:02.876
29	q_5e9787f3669f4250baf4772b4b70fc96	2	客户产品贡献	3	5	是否有产品/服务长期不赚钱但仍在做？	YES_NO	["是", "否", "不确定"]	f	CUSTOMER_PRODUCT	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.876	2026-06-23 12:36:02.876
30	q_34527d502583468ba8159d81dc75abda	2	客户产品贡献	3	6	是否定期淘汰低效产品或客户？	YES_NO	["是，定期评估", "偶尔", "从未"]	f	CUSTOMER_PRODUCT	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.877	2026-06-23 12:36:02.877
31	q_794aadf013de4378b3895ed45e57d80d	2	客户产品贡献	3	7	近一年是否开拓了新客户或新产品线？	YES_NO	["是", "否"]	f	CUSTOMER_PRODUCT	{}	2026-06-23 12:36:02.877	2026-06-23 12:36:02.877
32	q_78c9d3fe8de14fe894c89c2286adecbc	2	税务申报	4	1	目前是否按期进行纳税申报？	YES_NO	["是", "否"]	t	TAX_DECLARATION	{}	2026-06-23 12:36:02.878	2026-06-23 12:36:02.878
33	q_8260204fbb71450db739608d3d047cda	2	税务申报	4	2	是否长期零申报？	YES_NO	["是", "否"]	t	TAX_DECLARATION	{}	2026-06-23 12:36:02.879	2026-06-23 12:36:02.879
34	q_19b8d79c3f464205b3f7a231706cec79	2	税务申报	4	3	零申报期间是否仍有实际经营？	YES_NO	["是", "否", "未零申报"]	f	TAX_DECLARATION	{}	2026-06-23 12:36:02.879	2026-06-23 12:36:02.879
35	q_0f467bb9990444638047089e9442a3cc	2	税务申报	4	4	是否出现过税务提醒、异常或处罚？	YES_NO	["是", "否", "不清楚"]	t	TAX_DECLARATION	{}	2026-06-23 12:36:02.88	2026-06-23 12:36:02.88
36	q_a678cc60ec674b8882820e3fd3d9a7a4	2	税务申报	4	5	纳税人身份是否清楚？	SINGLE_CHOICE	["一般纳税人", "小规模纳税人", "不清楚"]	t	TAX_DECLARATION	{}	2026-06-23 12:36:02.881	2026-06-23 12:36:02.881
37	q_14608a6c2dcf44f89f2ec753bd8d3341	2	税务申报	4	6	是否存在申报数据与实际经营不一致的担忧？	YES_NO	["是，有担忧", "否，基本一致", "不确定"]	t	TAX_DECLARATION	{}	2026-06-23 12:36:02.881	2026-06-23 12:36:02.881
38	q_67dfd320c2614c7f9d4760a9f621eb01	2	税务申报	4	7	是否有专业会计或代理记账？	YES_NO	["有专职会计", "委托代理记账", "自己做账", "无专人负责"]	t	TAX_DECLARATION	{}	2026-06-23 12:36:02.882	2026-06-23 12:36:02.882
39	q_b42fbbd88453460b97315f2768741389	2	税务申报	4	8	是否了解最新税收优惠政策？	YES_NO	["了解并已享受", "了解但未享受", "不了解"]	f	TAX_DECLARATION	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.883	2026-06-23 12:36:02.883
40	q_cf576574cfd7435fb147ebf7c1472194	2	发票资金	5	1	发票与实际业务是否匹配？	YES_NO	["是", "否", "部分不匹配"]	t	INVOICE_FUND	{}	2026-06-23 12:36:02.884	2026-06-23 12:36:02.884
41	q_279914a53de84b8bab4bd6888da55a38	2	发票资金	5	2	进项与销项结构是否合理？	SINGLE_CHOICE	["基本合理", "进项偏少", "销项偏少", "不清楚"]	t	INVOICE_FUND	{}	2026-06-23 12:36:02.884	2026-06-23 12:36:02.884
42	q_a03af299703f40cf8738ee76415a69ec	2	发票资金	5	3	是否存在频繁公转私或大额无说明往来？	YES_NO	["是", "否", "不清楚"]	t	INVOICE_FUND	{}	2026-06-23 12:36:02.885	2026-06-23 12:36:02.885
43	q_9db319c34aa54d11a904e50c98fdc375	2	发票资金	5	4	是否存在私人账户收取公司款项的情况？	YES_NO	["是", "否"]	t	INVOICE_FUND	{}	2026-06-23 12:36:02.886	2026-06-23 12:36:02.886
44	q_e96101486a084bc0924bce078abece6f	2	发票资金	5	5	银行流水是否能对应合同、发票和业务？	SINGLE_CHOICE	["基本对应", "部分不对应", "差异较大", "未核对过"]	t	INVOICE_FUND	{}	2026-06-23 12:36:02.887	2026-06-23 12:36:02.887
45	q_98652a4d4dfa404ca70cfe0f5f569f25	2	发票资金	5	6	是否已开设对公账户？	YES_NO	["是", "否"]	t	INVOICE_FUND	{}	2026-06-23 12:36:02.887	2026-06-23 12:36:02.887
46	q_6d36322f37174677a1f078ac6865e2f2	2	发票资金	5	7	是否存在大额现金收款？	YES_NO	["是", "否"]	f	INVOICE_FUND	{}	2026-06-23 12:36:02.888	2026-06-23 12:36:02.888
47	q_3fae39218b874c25b3f2d452aa54195a	2	发票资金	5	8	是否有未开票收入？	YES_NO	["是，占比较大", "是，少量", "全部开票"]	f	INVOICE_FUND	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.888	2026-06-23 12:36:02.888
48	q_5e2cd6b91fb246c08965ca38eea7de79	2	社保工商	6	1	是否有员工？	SINGLE_CHOICE	["0人（无员工）", "1-5人", "5-10人", "10-50人", "50人以上"]	t	SOCIAL_BUSINESS	{}	2026-06-23 12:36:02.889	2026-06-23 12:36:02.889
49	q_3a0fafd9afeb487c8028c8e2f2f7d72c	2	社保工商	6	2	社保是否正常缴纳？	SINGLE_CHOICE	["全员正常缴纳", "部分缴纳", "未缴纳", "无员工无需缴纳"]	t	SOCIAL_BUSINESS	{}	2026-06-23 12:36:02.89	2026-06-23 12:36:02.89
50	q_cc764a8fea7f4b7b861011e722a429c8	2	社保工商	6	3	工资、个税和社保人数是否一致？	YES_NO	["基本一致", "存在差异", "不清楚"]	t	SOCIAL_BUSINESS	{}	2026-06-23 12:36:02.89	2026-06-23 12:36:02.89
51	q_5d97b829c2d0478fa16c07118b3e6ab8	2	社保工商	6	4	是否有较多兼职、劳务或外包人员？	YES_NO	["是", "否"]	t	SOCIAL_BUSINESS	{}	2026-06-23 12:36:02.891	2026-06-23 12:36:02.891
52	q_f8f25f066d2346439e516fbb4713fb11	2	社保工商	6	5	工商状态是否正常？	SINGLE_CHOICE	["正常经营", "存在异常", "不清楚"]	t	SOCIAL_BUSINESS	{}	2026-06-23 12:36:02.891	2026-06-23 12:36:02.891
53	q_22f0459d2e1e4f409be3e0b035c8c332	2	社保工商	6	6	是否频繁变更法人、股东或地址？	YES_NO	["近一年有变更", "近3年有变更", "无变更"]	f	SOCIAL_BUSINESS	{}	2026-06-23 12:36:02.892	2026-06-23 12:36:02.892
54	q_cc1e11e30b3b4483b48cc68b6414ed25	2	社保工商	6	7	是否考虑注销或股权转让？	YES_NO	["正在考虑", "有计划", "无计划"]	f	SOCIAL_BUSINESS	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.892	2026-06-23 12:36:02.892
55	q_c98ff0dd4fff4a9b9c96a70d6b7fa191	2	应收回款	7	1	客户回款是否及时？	SINGLE_CHOICE	["及时", "偶尔逾期", "经常拖延", "严重逾期"]	t	RECEIVABLE_COLLECTION	{}	2026-06-23 12:36:02.893	2026-06-23 12:36:02.893
56	q_2f6f550544d94d39ba2c38d81eb17e9f	2	应收回款	7	2	是否存在逾期90天以上的应收账款？	YES_NO	["是", "否", "不清楚"]	t	RECEIVABLE_COLLECTION	{}	2026-06-23 12:36:02.893	2026-06-23 12:36:02.893
57	q_82091fc33ee9498daf849aadfa99c0e5	2	应收回款	7	3	是否有专人跟进应收款？	YES_NO	["是", "否"]	f	RECEIVABLE_COLLECTION	{}	2026-06-23 12:36:02.894	2026-06-23 12:36:02.894
58	q_0ca94e5e37f0426bb83b68344e2eb058	2	应收回款	7	4	是否对高风险客户停止发货或服务？	YES_NO	["是", "否", "无高风险客户"]	f	RECEIVABLE_COLLECTION	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.895	2026-06-23 12:36:02.895
59	q_29a3992b105343c486ad68dd93d5cfb1	2	应收回款	7	5	是否知道平均回款周期？	SINGLE_CHOICE	["30天以内", "30-60天", "60-90天", "90天以上", "不清楚"]	t	RECEIVABLE_COLLECTION	{}	2026-06-23 12:36:02.895	2026-06-23 12:36:02.895
60	q_b4f81d114f604cdf9b585a4f8f75098c	2	应收回款	7	6	是否有坏账或长期挂账？	YES_NO	["是", "否", "不清楚"]	t	RECEIVABLE_COLLECTION	{}	2026-06-23 12:36:02.896	2026-06-23 12:36:02.896
61	q_ffc9b2b7ea56443c841bca94f62dc37e	2	应收回款	7	7	是否使用预收款或定金模式？	YES_NO	["是", "否"]	f	RECEIVABLE_COLLECTION	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.896	2026-06-23 12:36:02.896
62	q_10f76d682caf433d99811e48dea74bdd	2	存货付款	8	1	是否存在存货积压？	SINGLE_CHOICE	["积压严重", "有一定积压", "基本正常", "无存货/服务业"]	t	INVENTORY_PAYABLE	{}	2026-06-23 12:36:02.897	2026-06-23 12:36:02.897
63	q_0e022d9db0bc42cabbdf2d01b0456594	2	存货付款	8	2	是否知道存货周转天数？	SINGLE_CHOICE	["30天以内", "30-60天", "60-90天", "90天以上", "不清楚", "无存货/服务业"]	t	INVENTORY_PAYABLE	{}	2026-06-23 12:36:02.898	2026-06-23 12:36:02.898
64	q_8c91f44a462a4290a47e8c37464f4558	2	存货付款	8	3	是否有呆滞库存？	YES_NO	["是", "否", "无存货/服务业"]	f	INVENTORY_PAYABLE	{}	2026-06-23 12:36:02.899	2026-06-23 12:36:02.899
65	q_19434c559f8a440fa3f7739d73eb1c99	2	存货付款	8	4	供应商账期是否稳定？	SINGLE_CHOICE	["稳定", "偶尔变动", "经常变动", "无供应商/服务业"]	t	INVENTORY_PAYABLE	{}	2026-06-23 12:36:02.899	2026-06-23 12:36:02.899
66	q_7afca36e24f8451ab226b379ac059c90	2	存货付款	8	5	是否经常先付款后回款？	YES_NO	["是", "否"]	t	INVENTORY_PAYABLE	{}	2026-06-23 12:36:02.9	2026-06-23 12:36:02.9
67	q_4e092f279acb4d11b8fe9e510ddd427b	2	存货付款	8	6	是否存在采购占用大量现金？	YES_NO	["是", "否", "不确定"]	f	INVENTORY_PAYABLE	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.901	2026-06-23 12:36:02.901
68	q_15aef816bbf44de9a3e1413c7f65db93	2	存货付款	8	7	是否有紧急采购或断货风险？	YES_NO	["是", "否"]	f	INVENTORY_PAYABLE	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.901	2026-06-23 12:36:02.901
69	q_bc06fd53293b4555b706e99e014c59d0	2	人效资产	9	1	人员配置是否与业务量匹配？	SINGLE_CHOICE	["匹配", "人员偏多/业务不足", "人员不足/业务量大", "不确定"]	t	HUMAN_ASSET_EFFICIENCY	{}	2026-06-23 12:36:02.902	2026-06-23 12:36:02.902
70	q_ec267272aaa34016a33e55a834c50628	2	人效资产	9	2	是否知道人均产出？	SINGLE_CHOICE	["有明确指标", "大致了解", "不清楚"]	t	HUMAN_ASSET_EFFICIENCY	{}	2026-06-23 12:36:02.904	2026-06-23 12:36:02.904
71	q_3cae4cdf0ac94aacbdb8865b3fbbc821	2	人效资产	9	3	是否存在明显人员冗余？	YES_NO	["是", "否", "不确定"]	f	HUMAN_ASSET_EFFICIENCY	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.905	2026-06-23 12:36:02.905
72	q_596ed786ecc94d0cb536fa7aa42df5a3	2	人效资产	9	4	是否存在设备、仓库、车辆闲置？	YES_NO	["是", "否", "无相关资产"]	f	HUMAN_ASSET_EFFICIENCY	{"hideInModes": ["QUICK"]}	2026-06-23 12:36:02.906	2026-06-23 12:36:02.906
73	q_4d1785a5ade548e7b47bea79023ac91f	2	人效资产	9	5	是否有流程重复、人工录入、效率低的问题？	YES_NO	["是，较严重", "有一些", "基本没有"]	t	HUMAN_ASSET_EFFICIENCY	{}	2026-06-23 12:36:02.907	2026-06-23 12:36:02.907
74	q_c966edd37cb34b1cb47cd62417b14646	2	人效资产	9	6	是否定期复盘经营效率？	YES_NO	["是，定期复盘", "偶尔", "从未"]	f	HUMAN_ASSET_EFFICIENCY	{}	2026-06-23 12:36:02.908	2026-06-23 12:36:02.908
75	q_2092bf9b5a544b6b9e26fd0c528d7e2a	2	人效资产	9	7	是否使用ERP或管理系统？	YES_NO	["是，使用成熟系统", "使用简单工具", "基本手工"]	f	HUMAN_ASSET_EFFICIENCY	{}	2026-06-23 12:36:02.909	2026-06-23 12:36:02.909
\.


--
-- Data for Name: Questionnaire; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Questionnaire" (id, version, title, description, "isActive", "createdAt", "updatedAt") FROM stdin;
1	v1	君册财税·企业初诊问卷	请如实填写以下信息，我们将为您生成企业财税健康初诊报告。	t	2026-06-23 12:36:02.773	2026-06-23 12:36:02.773
2	v2	君册财税·企业经营初诊（V2）	请补充资料中无法体现的经营情况，系统将结合资料完整度和问卷答案生成四维经营初诊看板。	t	2026-06-23 12:36:02.85	2026-06-23 12:36:02.85
\.


--
-- Data for Name: Report; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Report" (id, "publicId", "diagnosisResultId", "reportNumber", title, "riskLevel", "reviewStatus", "customerVisible", "htmlContent", "disclaimerText", "reviewedById", "reviewedAt", "createdAt", "updatedAt") FROM stdin;
1	cmqqo5n0c00037n9ky6hral8y	1	JC-AI-20260623-0001	君册财税·企业初诊报告	HIGH	REJECTED	f	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260623-0001</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-23T13:17:25.306Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否按期进行纳税申报？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:red;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">高风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个高风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>未按期纳税申报</strong>\n        <p style="color:#555;margin:6px 0">未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。</p>\n        <p style="color:#888;font-size:14px">💡 建议立即联系专业人员核查申报状态，尽快完成补申报。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>税务合规检查</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	1	2026-06-23 13:17:25.831	2026-06-23 13:17:25.308	2026-06-23 13:17:25.832
2	cmqqogfw80001fi9k2ijg62m6	2	JC-AI-20260623-0002	君册财税·企业初诊报告	LOW	REVIEWED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260623-0002</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-23T13:25:49.301Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">近一年营业收入变化情况？：</span>否</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:#27ae60;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">低风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">根据您目前填写的信息，系统暂未发现明显高风险项。由于本报告仅基于有限信息生成，仍建议后续结合完整账务、申报、发票和工商资料进行人工确认。</p>\n</section>\n\n\n\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	1	2026-06-23 13:25:49.793	2026-06-23 13:25:49.304	2026-06-23 13:25:49.793
3	cmqqoq8kf0003fi9kptvx0p96	3	JC-AI-20260623-0003	君册财税·企业初诊报告	HIGH	NEED_REVIEW	f	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260623-0003</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-23T13:33:26.364Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">贵公司所属行业？：</span>互联网</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司注册时间？：</span>不到1年</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司类型？：</span>一人公司</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">年流水大约多少？：</span>3000000</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">公司员工人数？：</span>1-5人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否正常报税？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否给员工缴纳社保？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人账户收公司款项的情况？：</span>是</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:red;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">高风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 1 个高风险项、2 个中风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>长期零申报</strong>\n        <p style="color:#555;margin:6px 0">长期零申报可能引起税务关注，尤其是存在实际经营的情况下。</p>\n        <p style="color:#888;font-size:14px">💡 建议规范账务处理，确保每期申报真实准确反映经营状况。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>公私账户混用</strong>\n        <p style="color:#555;margin:6px 0">公司款项通过个人账户收取可能导致税务风险和管理混乱。</p>\n        <p style="color:#888;font-size:14px">💡 建议尽快开立对公账户，所有经营收入通过公司账户管理。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>[测试]新注册公司</strong>\n        <p style="color:#555;margin:6px 0">新注册公司需要关注初期合规建设。</p>\n        <p style="color:#888;font-size:14px">💡 建议尽快开立对公账户并建立账务体系。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>合规项目</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>开户</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>财务外包</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	\N	\N	2026-06-23 13:33:26.367	2026-06-23 13:33:26.367
4	cmqqp2d0h0005fi9k1x4ku6fd	4	JC-AI-20260623-0004	君册财税·企业初诊报告	HIGH	REVIEWED	t	<!DOCTYPE html>\n<html lang="zh-CN">\n<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>\n<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">\n\n<section style="text-align:center;margin-bottom:24px">\n  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>\n  <p style="color:#888;font-size:13px;margin:0">报告编号：JC-AI-20260623-0004</p>\n  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：2026-06-23T13:42:51.997Z</p>\n</section>\n\n<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">\n  ⚠️ 本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。\n</section>\n\n<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>\n  <p style="margin:4px 0;font-size:14px"><span style="color:#888">近一年营业收入变化情况？：</span>增长超过20%</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">主要产品或服务毛利水平如何？：</span>毛利15%-30%</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在低毛利或亏损产品？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在收入增长但利润没有增长？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">近一年成本是否明显上涨？：</span>上涨超过30%</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">销售费用是否明显增长？：</span>小幅增长</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">人工成本是否明显增长？：</span>大幅增长</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">房租、物流、平台费等固定费用是否有压力？：</span>有一定压力</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在老板个人支出与公司费用混用？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">收入是否依赖少数大客户？：</span>前3-5个客户占50%以上</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在低毛利大客户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有客户长期拖欠款项？：</span>有少量</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">近一年是否开拓了新客户或新产品线？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">目前是否按期进行纳税申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否长期零申报？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">零申报期间是否仍有实际经营？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否出现过税务提醒、异常或处罚？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">纳税人身份是否清楚？：</span>一般纳税人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在申报数据与实际经营不一致的担忧？：</span>是，有担忧</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有专业会计或代理记账？：</span>有专职会计</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">发票与实际业务是否匹配？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">进项与销项结构是否合理？：</span>基本合理</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在频繁公转私或大额无说明往来？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在私人账户收取公司款项的情况？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">银行流水是否能对应合同、发票和业务？：</span>基本对应</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否已开设对公账户？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在大额现金收款？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有员工？：</span>10-50人</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">社保是否正常缴纳？：</span>全员正常缴纳</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">工资、个税和社保人数是否一致？：</span>存在差异</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有较多兼职、劳务或外包人员？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">工商状态是否正常？：</span>正常经营</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否频繁变更法人、股东或地址？：</span>近3年有变更</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">客户回款是否及时？：</span>及时</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在逾期90天以上的应收账款？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有专人跟进应收款？：</span>否</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否知道平均回款周期？：</span>30天以内</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有坏账或长期挂账？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否存在存货积压？：</span>积压严重</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否知道存货周转天数？：</span>30天以内</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有呆滞库存？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">供应商账期是否稳定？：</span>偶尔变动</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否经常先付款后回款？：</span>是</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">人员配置是否与业务量匹配？：</span>匹配</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否知道人均产出？：</span>大致了解</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否有流程重复、人工录入、效率低的问题？：</span>是，较严重</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否定期复盘经营效率？：</span>偶尔</p><p style="margin:4px 0;font-size:14px"><span style="color:#888">是否使用ERP或管理系统？：</span>是，使用成熟系统</p>\n</section>\n\n<section style="text-align:center;margin-bottom:20px">\n  <div style="display:inline-block;background:red;color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">高风险</div>\n  <p style="color:#555;font-size:14px;margin:8px 0 0">系统检测到 6 个高风险项、13 个中风险项，建议您关注以下内容。</p>\n</section>\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>\n  \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>存在低毛利或亏损产品</strong>\n        <p style="color:#555;margin:6px 0">存在低毛利或亏损产品线，可能拖累整体利润。</p>\n        <p style="color:#888;font-size:14px">💡 建议分析各产品线盈利情况，考虑淘汰或优化低效产品。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>成本大幅上涨</strong>\n        <p style="color:#555;margin:6px 0">近一年成本上涨超过30%，可能严重侵蚀利润。</p>\n        <p style="color:#888;font-size:14px">💡 建议逐项分析成本上涨原因，评估是否有不合理或可控成本。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>人工成本大幅增长</strong>\n        <p style="color:#555;margin:6px 0">人工成本大幅增长，需评估人效是否同步提升。</p>\n        <p style="color:#888;font-size:14px">💡 建议核算人均产出和人工成本率，评估人员配置合理性。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>公私费用混用</strong>\n        <p style="color:#555;margin:6px 0">老板个人支出与公司费用混用，可能导致税务风险和财务管理混乱。</p>\n        <p style="color:#888;font-size:14px">💡 建议严格区分公司费用和个人支出，规范报销流程和账务处理。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>低毛利大客户依赖</strong>\n        <p style="color:#555;margin:6px 0">存在低毛利大客户，不仅利润贡献低还占用了资源。</p>\n        <p style="color:#888;font-size:14px">💡 建议评估大客户盈利贡献，对低毛利客户调整价格或服务方案。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>未按期纳税申报</strong>\n        <p style="color:#555;margin:6px 0">未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。</p>\n        <p style="color:#888;font-size:14px">💡 建议立即联系专业人员核查申报状态，尽快完成补申报。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>历史税务异常或处罚</strong>\n        <p style="color:#555;margin:6px 0">存在税务提醒、异常或处罚记录，需关注未解决的税务问题。</p>\n        <p style="color:#888;font-size:14px">💡 建议梳理历史税务异常事项，核查是否已妥善处理。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>申报数据与实际经营不一致</strong>\n        <p style="color:#555;margin:6px 0">申报数据与实际经营存在差异的担忧，可能涉及未申报收入或虚报成本。</p>\n        <p style="color:#888;font-size:14px">💡 建议由专业人员核查申报数据与实际经营的匹配度。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>发票与业务不匹配</strong>\n        <p style="color:#555;margin:6px 0">发票与实际业务不匹配，可能涉及虚开发票或账外经营风险。</p>\n        <p style="color:#888;font-size:14px">💡 建议规范发票管理，确保票、货、款三流一致。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>频繁公转私或大额无说明往来</strong>\n        <p style="color:#555;margin:6px 0">频繁公转私或存在大额无说明资金往来，可能引发税务稽查风险。</p>\n        <p style="color:#888;font-size:14px">💡 建议规范资金管理，所有经营收支通过公司账户，保留完整交易凭证。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>工资/个税/社保人数不一致</strong>\n        <p style="color:#555;margin:6px 0">工资、个税和社保人数不一致，可能触发税务或社保稽查。</p>\n        <p style="color:#888;font-size:14px">💡 建议核查三者一致性，规范用工和薪酬管理。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>较多兼职/劳务/外包人员</strong>\n        <p style="color:#555;margin:6px 0">较多非正式用工人员，可能存在劳动关系认定和社保风险。</p>\n        <p style="color:#888;font-size:14px">💡 建议评估用工模式合规性，合理区分劳动关系和劳务关系。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e74c3c;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">高风险</span>\n        <strong>长期逾期应收账款</strong>\n        <p style="color:#555;margin:6px 0">存在逾期90天以上的应收账款，坏账风险较高，严重影响现金流。</p>\n        <p style="color:#888;font-size:14px">💡 建议立即梳理逾期账款，评估可回收性，必要时采取法律催收。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>存在坏账或长期挂账</strong>\n        <p style="color:#555;margin:6px 0">存在坏账或长期挂账，虚增资产的同时占用资金。</p>\n        <p style="color:#888;font-size:14px">💡 建议清理长期挂账，评估坏账金额并计提准备。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>无专人跟进应收款</strong>\n        <p style="color:#555;margin:6px 0">没有专人跟进应收款，可能导致逾期账款累积。</p>\n        <p style="color:#888;font-size:14px">💡 建议指定专人负责应收账款管理和催收。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>存货积压严重</strong>\n        <p style="color:#555;margin:6px 0">存货严重积压，占用大量资金并存在贬值风险。</p>\n        <p style="color:#888;font-size:14px">💡 建议分析存货结构，加快滞销品处理，优化采购计划。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>存在呆滞库存</strong>\n        <p style="color:#555;margin:6px 0">存在呆滞库存，占用仓储空间和资金，需减值处理。</p>\n        <p style="color:#888;font-size:14px">💡 建议定期清理呆滞库存，通过折价销售或其他方式变现。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>先付款后回款</strong>\n        <p style="color:#555;margin:6px 0">经常先付款后回款，企业垫付资金压力大，现金流紧张。</p>\n        <p style="color:#888;font-size:14px">💡 建议优化采购付款条款，争取延长供应商账期或采用预收款模式。</p>\n      </div>\n    \n      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">\n        <span style="display:inline-block;background:#e67e22;color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">中风险</span>\n        <strong>流程效率低下</strong>\n        <p style="color:#555;margin:6px 0">存在较严重的流程重复、人工录入和效率低问题。</p>\n        <p style="color:#888;font-size:14px">💡 建议梳理业务流程，引入自动化工具减少重复劳动。</p>\n      </div>\n    \n</section>\n\n\n\n<section style="margin-bottom:20px">\n  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>\n  \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>经营分析</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>代理记账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>财务外包</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>税务合规检查</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议优先了解</span>\n        <strong>异常处理</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>补账清账</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">\n        <span style="font-size:12px;color:#3498db;white-space:nowrap">建议关注</span>\n        <strong>社保用工咨询</strong>\n        <span style="color:#888;font-size:13px;margin-left:auto">根据命中的风险项推荐</span>\n      </div>\n    \n  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>\n</section>\n\n\n<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">\n  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>\n  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>\n</section>\n\n</body></html>	本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。	1	2026-06-23 13:44:20.375	2026-06-23 13:42:52.001	2026-06-23 13:44:20.376
\.


--
-- Data for Name: ReportAccessToken; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ReportAccessToken" (id, "reportId", "tokenHash", "expiresAt", "usedAt", "createdAt") FROM stdin;
1	1	$2b$10$pEe1DykrWRXM9QHuyLzJLOboflI7FxCRxEm03WH.PYsnoRlXpkVpi	2026-06-30 13:17:25.385	2026-06-23 13:17:25.945	2026-06-23 13:17:25.385
2	2	$2b$10$JYa6jViRp9BnCJLmDDg7mOWVnuVVGL0gV/p23K4uzpjKcPQtCcReG	2026-06-30 13:25:49.379	2026-06-23 13:25:49.903	2026-06-23 13:25:49.38
3	3	$2b$10$eq231x2MGIKc7uqGL/1jGOzUKXQ98YFkmGMJLKyydkEGdwEqJwFdC	2026-06-30 13:33:26.443	2026-06-23 13:33:30.66	2026-06-23 13:33:26.443
4	4	$2b$10$JaQaEaFQYezMLvVkP8IQNOy50OV/mw25rljasGmxUOZ2i8XzPwuJe	2026-06-30 13:42:52.082	2026-06-24 03:02:33.938	2026-06-23 13:42:52.082
\.


--
-- Data for Name: ReviewRecord; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ReviewRecord" (id, "reportId", "reviewerId", action, changes, comment, "createdAt") FROM stdin;
1	1	1	APPROVE	\N	通过	2026-06-23 13:17:25.713
2	1	1	REJECT	\N	驳回	2026-06-23 13:17:25.833
3	2	1	APPROVE	\N	经复核，报告内容属实，同意发布	2026-06-23 13:25:49.795
4	4	1	APPROVE	\N	\N	2026-06-23 13:44:18.354
5	4	1	APPROVE	\N	\N	2026-06-23 13:44:20.377
\.


--
-- Data for Name: RiskFinding; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."RiskFinding" (id, "diagnosisResultId", "ruleId", "scenarioId", "riskLevel", title, description, suggestion, "recommendServices", "createdAt") FROM stdin;
1	1	24	\N	HIGH	未按期纳税申报	未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员核查申报状态，尽快完成补申报。	["代理记账", "税务合规检查"]	2026-06-23 13:17:25.272
2	3	1	\N	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	["代理记账", "合规项目"]	2026-06-23 13:33:26.339
3	3	3	\N	HIGH	公私账户混用	公司款项通过个人账户收取可能导致税务风险和管理混乱。	建议尽快开立对公账户，所有经营收入通过公司账户管理。	["开户", "财务外包", "合规项目"]	2026-06-23 13:33:26.339
4	3	4	\N	MEDIUM	[测试]新注册公司	新注册公司需要关注初期合规建设。	建议尽快开立对公账户并建立账务体系。	["开户", "代理记账"]	2026-06-23 13:33:26.339
5	4	8	\N	MEDIUM	存在低毛利或亏损产品	存在低毛利或亏损产品线，可能拖累整体利润。	建议分析各产品线盈利情况，考虑淘汰或优化低效产品。	["经营分析"]	2026-06-23 13:42:51.953
6	4	12	\N	HIGH	成本大幅上涨	近一年成本上涨超过30%，可能严重侵蚀利润。	建议逐项分析成本上涨原因，评估是否有不合理或可控成本。	["经营分析"]	2026-06-23 13:42:51.953
7	4	14	\N	MEDIUM	人工成本大幅增长	人工成本大幅增长，需评估人效是否同步提升。	建议核算人均产出和人工成本率，评估人员配置合理性。	["经营分析"]	2026-06-23 13:42:51.953
8	4	16	\N	HIGH	公私费用混用	老板个人支出与公司费用混用，可能导致税务风险和财务管理混乱。	建议严格区分公司费用和个人支出，规范报销流程和账务处理。	["代理记账", "财务外包"]	2026-06-23 13:42:51.953
9	4	19	\N	MEDIUM	低毛利大客户依赖	存在低毛利大客户，不仅利润贡献低还占用了资源。	建议评估大客户盈利贡献，对低毛利客户调整价格或服务方案。	["经营分析"]	2026-06-23 13:42:51.953
10	4	24	\N	HIGH	未按期纳税申报	未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员核查申报状态，尽快完成补申报。	["代理记账", "税务合规检查"]	2026-06-23 13:42:51.953
11	4	26	\N	MEDIUM	历史税务异常或处罚	存在税务提醒、异常或处罚记录，需关注未解决的税务问题。	建议梳理历史税务异常事项，核查是否已妥善处理。	["税务合规检查", "异常处理"]	2026-06-23 13:42:51.953
12	4	27	\N	MEDIUM	申报数据与实际经营不一致	申报数据与实际经营存在差异的担忧，可能涉及未申报收入或虚报成本。	建议由专业人员核查申报数据与实际经营的匹配度。	["税务合规检查", "补账清账"]	2026-06-23 13:42:51.953
13	4	31	\N	HIGH	发票与业务不匹配	发票与实际业务不匹配，可能涉及虚开发票或账外经营风险。	建议规范发票管理，确保票、货、款三流一致。	["税务合规检查", "代理记账"]	2026-06-23 13:42:51.953
14	4	32	\N	HIGH	频繁公转私或大额无说明往来	频繁公转私或存在大额无说明资金往来，可能引发税务稽查风险。	建议规范资金管理，所有经营收支通过公司账户，保留完整交易凭证。	["财务外包", "税务合规检查"]	2026-06-23 13:42:51.953
15	4	39	\N	MEDIUM	工资/个税/社保人数不一致	工资、个税和社保人数不一致，可能触发税务或社保稽查。	建议核查三者一致性，规范用工和薪酬管理。	["社保用工咨询"]	2026-06-23 13:42:51.953
16	4	41	\N	MEDIUM	较多兼职/劳务/外包人员	较多非正式用工人员，可能存在劳动关系认定和社保风险。	建议评估用工模式合规性，合理区分劳动关系和劳务关系。	["社保用工咨询"]	2026-06-23 13:42:51.953
17	4	45	\N	HIGH	长期逾期应收账款	存在逾期90天以上的应收账款，坏账风险较高，严重影响现金流。	建议立即梳理逾期账款，评估可回收性，必要时采取法律催收。	["经营分析", "异常处理"]	2026-06-23 13:42:51.953
18	4	47	\N	MEDIUM	存在坏账或长期挂账	存在坏账或长期挂账，虚增资产的同时占用资金。	建议清理长期挂账，评估坏账金额并计提准备。	["经营分析"]	2026-06-23 13:42:51.953
19	4	49	\N	MEDIUM	无专人跟进应收款	没有专人跟进应收款，可能导致逾期账款累积。	建议指定专人负责应收账款管理和催收。	["经营分析"]	2026-06-23 13:42:51.953
20	4	50	\N	MEDIUM	存货积压严重	存货严重积压，占用大量资金并存在贬值风险。	建议分析存货结构，加快滞销品处理，优化采购计划。	["经营分析"]	2026-06-23 13:42:51.953
21	4	52	\N	MEDIUM	存在呆滞库存	存在呆滞库存，占用仓储空间和资金，需减值处理。	建议定期清理呆滞库存，通过折价销售或其他方式变现。	["经营分析"]	2026-06-23 13:42:51.953
22	4	53	\N	MEDIUM	先付款后回款	经常先付款后回款，企业垫付资金压力大，现金流紧张。	建议优化采购付款条款，争取延长供应商账期或采用预收款模式。	["经营分析"]	2026-06-23 13:42:51.953
23	4	58	\N	MEDIUM	流程效率低下	存在较严重的流程重复、人工录入和效率低问题。	建议梳理业务流程，引入自动化工具减少重复劳动。	["经营分析"]	2026-06-23 13:42:51.953
\.


--
-- Data for Name: RiskScenario; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."RiskScenario" (id, "scenarioName", "scenarioCode", description, "riskLevel", "triggerRules", "safeExplanation", "forbiddenPhrases", suggestion, "recommendServices", "needManualReview", "isActive", "createdAt", "updatedAt") FROM stdin;
1	长期零申报	LONG_ZERO_DECLARATION	连续多个月零申报，但客户可能仍有实际经营	MEDIUM	{"value": "是", "answerField": "长期零申报"}	长期零申报可能引起税务关注，建议核查申报情况	{违法了,必须补税,一定会被罚款}	建议规范账务处理，确保申报真实准确	["代理记账", "合规项目"]	f	t	2026-06-23 12:36:02.798	2026-06-23 12:36:02.798
2	公私账户混用	MIXED_ACCOUNTS	公司经营款项通过老板个人账户收取	HIGH	{"value": "是", "answerField": "个人账户收款"}	通过个人账户收取公司款项可能存在合规风险，建议规范资金管理	{违法了,走私人账户没问题,可以避税}	建议开立对公账户并通过公司账户管理经营收入	["开户", "财务外包", "合规项目"]	t	t	2026-06-23 12:36:02.798	2026-06-23 12:36:02.798
3	未缴纳社保	NO_SOCIAL_INSURANCE	有员工但未依法缴纳社保	HIGH	{"value": "否", "answerField": "缴纳社保"}	有员工但未缴纳社保可能存在用工合规风险，建议尽快规范	{违法了,不用交,不交没关系}	建议依法为员工缴纳社保，规范用工管理	["社保", "合规项目"]	t	t	2026-06-23 12:36:02.798	2026-06-23 12:36:02.798
4	长期零申报持续经营	V2_SC_001	企业长期零申报但实际存在经营活动，属于高风险税务违规行为。	HIGH	["V2_TAX_002C"]	长期零申报但实际有经营活动，是税务部门重点关注的情形，可能面临补税、滞纳金和行政处罚。	{肯定会被查,一定会被罚,可以继续零申报}	建议立即委托专业人员规范账务，如实申报经营情况。君册可提供代理记账和补账清账服务。	["代理记账", "补账清账", "税务合规检查"]	t	t	2026-06-23 12:36:02.988	2026-06-23 12:36:02.988
5	公私账户混用	V2_SC_002	企业资金通过个人账户流转，包括私人账户收公司款、频繁公转私，存在严重财税合规风险。	HIGH	["V2_FUND_002", "V2_FUND_003"]	公私账户混用可能导致财产混同、难以区分经营收支，也是税务稽查的重点关注事项。	{违法了,一定会被罚,包解决}	建议尽快规范资金账户管理，开设对公账户，所有经营收支通过公司账户。	["开户指导", "财务外包", "税务合规检查"]	t	t	2026-06-23 12:36:02.99	2026-06-23 12:36:02.99
6	回款大面积逾期	V2_SC_003	客户回款严重延迟，存在大额逾期账款，企业现金流面临较大压力。	MEDIUM	["V2_AR_001", "V2_AR_002", "V2_AR_005C"]	应收账款回款周期过长会影响企业日常经营所需现金流，建议建立规范的账款管理制度。	{肯定收不回来,一定会坏账}	建议建立应收账款台账和催收流程，对高风险客户收紧信用政策。	["经营分析"]	f	t	2026-06-23 12:36:02.992	2026-06-23 12:36:02.992
7	发票业务不匹配	V2_SC_004	发票与实际业务不匹配，进销项结构异常，存在虚开发票或账外经营风险。	HIGH	["V2_FUND_001", "V2_FUND_006"]	发票与业务不匹配可能涉及虚开发票、账外经营等问题，是税务稽查的重点领域。	{违法了,肯定会查,一定会处罚}	建议规范发票管理，确保票货款三流一致，由专业人员核查发票合规性。	["税务合规检查", "代理记账"]	t	t	2026-06-23 12:36:02.993	2026-06-23 12:36:02.993
8	全员未缴社保	V2_SC_005	有员工但全员未缴纳社保，属于严重劳动用工合规问题。	HIGH	["V2_SB_001", "V2_SB_005C"]	有员工未缴纳社保违反劳动法和社保法规定，可能面临劳动监察、补缴和罚款。	{违法了,一定会被查,可以不交}	建议立即为员工办理社保登记和缴纳，规范用工关系，君册可提供社保用工咨询服务。	["社保用工咨询"]	t	t	2026-06-23 12:36:02.998	2026-06-23 12:36:02.998
9	收入高度依赖大客户	V2_SC_006	收入高度依赖少数大客户，经营风险集中，一旦客户流失将造成重大影响。	MEDIUM	["V2_CP_001", "V2_CP_005C"]	客户集中度偏高是常见的经营风险，建议主动分散客户结构，降低单一客户依赖。	{一定会破产,肯定不行}	建议积极开拓新客户和市场，逐步降低大客户收入占比至30%以下。	["经营分析"]	f	t	2026-06-23 12:36:03	2026-06-23 12:36:03
10	收入持续下降	V2_SC_007	近一年营业收入持续下降，可能反映市场竞争力减弱或行业下行。	MEDIUM	["V2_REV_001", "V2_REV_005C"]	收入持续下降需要重点关注业务结构和市场竞争策略，建议深入分析原因。	{公司不行了,肯定倒闭}	建议全面分析收入下降原因，评估产品/客户/渠道结构，制定应对方案。	["经营分析"]	f	t	2026-06-23 12:36:03.001	2026-06-23 12:36:03.001
11	费用失控利润承压	V2_SC_008	成本费用快速增长，利润空间不断压缩，企业经营效益下降。	MEDIUM	["V2_COST_001", "V2_COST_006C"]	成本费用增速超过收入增速会导致利润持续下降，需关注费用控制。	{肯定亏损,一定会倒闭}	建议全面审计费用结构，建立费用预算和控制机制。	["经营分析", "财务外包"]	f	t	2026-06-23 12:36:03.002	2026-06-23 12:36:03.002
12	存货积压+现金流紧张	V2_SC_009	存货严重积压同时付款压力大，资金周转困难。	MEDIUM	["V2_IP_001", "V2_IP_005C"]	存货积压占用大量资金，叠加付款压力可能导致现金流断裂。	{肯定破产,资金链断了一定完蛋}	建议加快存货变现，优化采购和库存管理，缓解现金流压力。	["经营分析"]	f	t	2026-06-23 12:36:03.005	2026-06-23 12:36:03.005
13	未按期申报+无专业会计	V2_SC_010	未按期纳税申报且无专业会计人员，税务合规风险极高。	HIGH	["V2_TAX_001", "V2_TAX_005"]	未按期申报且没有专业人员处理账务，随时可能触发税务风险。	{违法了,可以不申报,不会被发现}	建议立即委托代理记账，由专业人员补申报和规范后续账务。	["代理记账", "补账清账", "税务合规检查"]	t	t	2026-06-23 12:36:03.007	2026-06-23 12:36:03.007
14	先付后收资金倒挂	V2_SC_011	经常先向供应商付款再向客户收款，企业长期垫付资金，现金流压力持续。	MEDIUM	["V2_IP_004"]	先付款后收款模式占用大量运营资金，建议争取改善付款条款或采用预收模式。	{肯定缺钱,一定会周转不开}	建议优化采购付款条件，争取客户预付款或缩短回款周期。	["经营分析"]	f	t	2026-06-23 12:36:03.008	2026-06-23 12:36:03.008
15	人员冗余+人效低下	V2_SC_012	人员配置冗余且缺乏人效管理，人工成本浪费严重。	MEDIUM	["V2_HAE_001", "V2_HAE_005C"]	人员冗余和低效管理会持续消耗企业利润，建议定期评估人效指标。	{肯定要裁员,养了一堆闲人}	建议建立人效考核体系，优化人员配置，提升整体运营效率。	["经营分析", "社保用工咨询"]	f	t	2026-06-23 12:36:03.01	2026-06-23 12:36:03.01
\.


--
-- Data for Name: ServiceRecommendation; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ServiceRecommendation" (id, "diagnosisResultId", "serviceType", reason, priority, "createdAt") FROM stdin;
1	1	代理记账	根据命中的风险项推荐	STRONG	2026-06-23 13:17:25.272
2	1	税务合规检查	根据命中的风险项推荐	STRONG	2026-06-23 13:17:25.272
3	3	合规项目	根据命中的风险项推荐	STRONG	2026-06-23 13:33:26.339
4	3	开户	根据命中的风险项推荐	STRONG	2026-06-23 13:33:26.339
5	3	财务外包	根据命中的风险项推荐	STRONG	2026-06-23 13:33:26.339
6	3	代理记账	根据命中的风险项推荐	SUGGEST	2026-06-23 13:33:26.339
7	4	经营分析	根据命中的风险项推荐	STRONG	2026-06-23 13:42:51.953
8	4	代理记账	根据命中的风险项推荐	STRONG	2026-06-23 13:42:51.953
9	4	财务外包	根据命中的风险项推荐	STRONG	2026-06-23 13:42:51.953
10	4	税务合规检查	根据命中的风险项推荐	STRONG	2026-06-23 13:42:51.953
11	4	异常处理	根据命中的风险项推荐	STRONG	2026-06-23 13:42:51.953
12	4	补账清账	根据命中的风险项推荐	SUGGEST	2026-06-23 13:42:51.953
13	4	社保用工咨询	根据命中的风险项推荐	SUGGEST	2026-06-23 13:42:51.953
\.


--
-- Data for Name: SmsVerificationCode; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."SmsVerificationCode" (id, phone, "codeHash", scene, "expiresAt", "verifiedAt", attempts, "createdAt") FROM stdin;
\.


--
-- Data for Name: Submission; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Submission" (id, "publicId", "questionnaireId", status, phone, "phoneVerified", source, "miniProgramCustomerId", mode, "documentCompletenessScore", "documentCompletenessDetail", "accessTokenHash", "accessTokenCreatedAt", "submittedAt", "createdAt", "updatedAt") FROM stdin;
1	cmqqo0b290000xn9kkdyb0jjr	2	DRAFT	13800000001	f	WEB	\N	STANDARD	\N	\N	$2b$10$z0Vd8OZSU0fVL/N0Hi7Oa.1wT8xhiKyW4o68a9rO0TSA34DHe00hK	2026-06-23 13:13:16.54	\N	2026-06-23 13:13:16.545	2026-06-23 13:13:16.545
2	cmqqo2usp00007n9kl94jqz3z	2	DRAFT	13800000002	f	WEB	\N	STANDARD	\N	\N	$2b$10$MLz3Ufovqnl2cggjVBK7RuHsTTgs2hbTawHs7jyClYgrtjjSETpji	2026-06-23 13:15:15.427	\N	2026-06-23 13:15:15.433	2026-06-23 13:15:15.433
3	cmqqo3fcf00017n9k7090v8iw	2	DRAFT	13800000004	f	WEB	\N	STANDARD	\N	\N	$2b$10$StwQl6s75JfWqy8K0ZAwl.wpyUSkHVC3kLwV4t8duDznqxmzx1HPO	2026-06-23 13:15:42.063	\N	2026-06-23 13:15:42.063	2026-06-23 13:15:42.063
8	cmqs2szpg0006fi9k598ku03e	2	DRAFT	12345678900	f	WEB	\N	DEEP	\N	\N	$2b$10$i7Dnr6yBzjuJJmxz0yXkG.MwJRrsZy7N3DfOLfXRuvOWC9mNowp1a	2026-06-24 12:55:15.648	\N	2026-06-24 12:55:15.652	2026-06-24 12:55:15.652
4	cmqqo5mtn00027n9k4l0js0yy	2	COMPLETED	13800000005	f	WEB	\N	STANDARD	0	{"mode": "STANDARD", "requiredCount": 10, "uploadedCount": 0, "missingDocuments": ["营业执照", "利润表", "资产负债表", "现金流量表", "科目余额表", "增值税申报表", "企业所得税申报表", "开票/收票汇总", "银行流水", "工资/社保/个税资料"], "dimensionConfidence": {"RISK": 0, "PROFIT": 0, "CASH_FLOW": 0, "EFFICIENCY": 0}}	$2b$10$WPjFOWFfzDhyCmRHQMIORuq2sIHJqQnDUZ6cXrVwN49G0bgUe2rNK	2026-06-23 13:17:25.067	2026-06-23 13:17:25.246	2026-06-23 13:17:25.067	2026-06-23 13:17:25.28
5	cmqqogfla0000fi9k75z9uzof	2	COMPLETED	13800009999	f	WEB	\N	STANDARD	0	{"mode": "STANDARD", "requiredCount": 10, "uploadedCount": 0, "missingDocuments": ["营业执照", "利润表", "资产负债表", "现金流量表", "科目余额表", "增值税申报表", "企业所得税申报表", "开票/收票汇总", "银行流水", "工资/社保/个税资料"], "dimensionConfidence": {"RISK": 0, "PROFIT": 0, "CASH_FLOW": 0, "EFFICIENCY": 0}}	$2b$10$PGpFK9sZvoSAAHOj2w5XCumjY24ZgZvoYXZyWgc9xybpxUXEftf8C	2026-06-23 13:25:48.905	2026-06-23 13:25:49.244	2026-06-23 13:25:48.91	2026-06-23 13:25:49.272
6	cmqqoq8j40002fi9kde81b00o	1	COMPLETED	19854231982	f	WEB	\N	\N	\N	\N	\N	\N	2026-06-23 13:33:26.315	2026-06-23 13:33:26.32	2026-06-23 13:33:26.346
7	cmqqp087u0004fi9krq3bb2ja	2	COMPLETED	10099998888	f	WEB	\N	QUICK	0	{"mode": "QUICK", "requiredCount": 4, "uploadedCount": 0, "missingDocuments": ["营业执照", "利润表", "资产负债表", "增值税申报表"], "dimensionConfidence": {"RISK": 0, "PROFIT": 0, "CASH_FLOW": 0, "EFFICIENCY": 0}}	$2b$10$KfOSYV7kgNzRCQMf4GB2huq0THs/0t/QVeTKZxa8JevFcVm1.DPAK	2026-06-23 13:41:12.472	2026-06-23 13:42:51.933	2026-06-23 13:41:12.474	2026-06-23 13:42:51.967
\.


--
-- Data for Name: UploadedDocument; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."UploadedDocument" (id, "publicId", "submissionId", "docType", "originalName", "mimeType", "sizeBytes", "storagePath", "uploadStatus", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Name: AdminUser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."AdminUser_id_seq"', 1, true);


--
-- Name: Answer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Answer_id_seq"', 60, true);


--
-- Name: DiagnosisResult_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DiagnosisResult_id_seq"', 4, true);


--
-- Name: DiagnosisRule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DiagnosisRule_id_seq"', 60, true);


--
-- Name: Disclaimer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Disclaimer_id_seq"', 2, true);


--
-- Name: DocumentRequirement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DocumentRequirement_id_seq"', 19, true);


--
-- Name: ForbiddenPhrase_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ForbiddenPhrase_id_seq"', 15, true);


--
-- Name: Question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Question_id_seq"', 75, true);


--
-- Name: Questionnaire_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Questionnaire_id_seq"', 2, true);


--
-- Name: ReportAccessToken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ReportAccessToken_id_seq"', 4, true);


--
-- Name: Report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Report_id_seq"', 4, true);


--
-- Name: ReviewRecord_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ReviewRecord_id_seq"', 5, true);


--
-- Name: RiskFinding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."RiskFinding_id_seq"', 23, true);


--
-- Name: RiskScenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."RiskScenario_id_seq"', 15, true);


--
-- Name: ServiceRecommendation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ServiceRecommendation_id_seq"', 13, true);


--
-- Name: SmsVerificationCode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."SmsVerificationCode_id_seq"', 1, false);


--
-- Name: Submission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Submission_id_seq"', 8, true);


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
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: a1234
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict j3B6OsNfI1Gpv9JTgtlcMhXz96iJF32B7dHofKsH9bjSpeFX3EvGHds0T8cQlci

