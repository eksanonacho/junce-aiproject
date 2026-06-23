--
-- PostgreSQL database dump
--

\restrict leKLz8MWsVZsTejg60VijDGeBOJfqfWrZszYcBJztP1pscA5vPIZySLMIB3GAX4

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
1	admin	$2b$10$1QUPvPVR4d87/GOl9Pm3cOPlVv2bpFKAH3T1qeg6xvYbNmNu/tKpK	管理员	ADMIN	2026-06-23 12:19:20.932	2026-06-23 12:19:20.932
\.


--
-- Data for Name: Answer; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Answer" (id, "submissionId", "questionId", "answerValue", "createdAt") FROM stdin;
\.


--
-- Data for Name: DiagnosisResult; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DiagnosisResult" (id, "submissionId", "overallRiskLevel", summary, "dimensionResults", "dashboardData", "needReview", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: DiagnosisRule; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."DiagnosisRule" (id, "ruleCode", dimension, "questionId", "triggerCondition", "compositeCondition", "conditionMode", "riskLevel", "riskTitle", "riskDescription", suggestion, "needReview", "recommendServices", "isActive", "createdAt", "updatedAt") FROM stdin;
1	TAX_001	税务维度	7	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	长期零申报	长期零申报可能引起税务关注，尤其是存在实际经营的情况下。	建议规范账务处理，确保每期申报真实准确反映经营状况。	f	["代理记账", "合规项目"]	t	2026-06-23 12:19:20.963	2026-06-23 12:19:20.963
2	TAX_002	税务维度	6	{"value": "否", "operator": "equals"}	\N	SIMPLE	HIGH	未正常报税	未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员，核查申报状态并补报。	t	["代理记账", "合规项目"]	t	2026-06-23 12:19:20.963	2026-06-23 12:19:20.963
3	FUND_001	资金维度	10	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	公私账户混用	公司款项通过个人账户收取可能导致税务风险和管理混乱。	建议尽快开立对公账户，所有经营收入通过公司账户管理。	t	["开户", "财务外包", "合规项目"]	t	2026-06-23 12:19:20.963	2026-06-23 12:19:20.963
4	TEST_M001	工商维度	2	{"value": "不到1年", "operator": "equals"}	\N	SIMPLE	MEDIUM	[测试]新注册公司	新注册公司需要关注初期合规建设。	建议尽快开立对公账户并建立账务体系。	f	["开户", "代理记账"]	t	2026-06-23 12:19:20.963	2026-06-23 12:19:20.963
5	TEST_M002	社保维度	9	{"value": "否", "operator": "equals"}	\N	SIMPLE	MEDIUM	[测试]未缴纳社保	有员工但未依法缴纳社保可能存在用工合规风险。	建议依法为员工缴纳社保，规范用工管理。	f	["社保", "合规项目"]	t	2026-06-23 12:19:20.963	2026-06-23 12:19:20.963
6	V2_TAX_001	TAX_DECLARATION	11	{"value": "否", "operator": "equals"}	\N	SIMPLE	HIGH	未按期纳税申报	未按期纳税申报属于严重税务合规问题，可能面临罚款和滞纳金。	建议立即联系专业人员核查申报状态，尽快完成补申报。	t	["代理记账", "税务合规检查"]	t	2026-06-23 12:19:21.026	2026-06-23 12:19:21.026
7	V2_TAX_002	TAX_DECLARATION	12	{"value": "是", "operator": "equals"}	{"logic": "AND", "conditions": [{"value": "是", "operator": "equals", "questionPublicId": null}, {"value": "是", "operator": "equals", "questionPublicId": null}]}	COMPOSITE	HIGH	长期零申报但仍有经营	长期零申报但实际仍有经营活动，属于高风险税务问题，可能面临补税、滞纳金和罚款。	建议立即停止零申报，规范账务处理，由专业人员代理记账和申报。	t	["代理记账", "补账清账", "税务合规检查"]	t	2026-06-23 12:19:21.028	2026-06-23 12:19:21.028
8	V2_TAX_003	TAX_DECLARATION	14	{"value": "是", "operator": "equals"}	\N	SIMPLE	MEDIUM	历史税务异常	存在税务提醒、异常或处罚记录，需关注是否存在未解决的税务问题。	建议梳理历史税务异常事项，核查是否已妥善处理。	f	["税务合规检查", "异常处理"]	t	2026-06-23 12:19:21.03	2026-06-23 12:19:21.03
9	V2_FUND_001	INVOICE_FUND	16	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	频繁公转私或大额无说明往来	频繁公转私或存在大额无说明资金往来，可能引发税务稽查风险。	建议规范资金管理，所有经营收支通过公司账户，保留完整交易凭证。	t	["财务外包", "税务合规检查"]	t	2026-06-23 12:19:21.031	2026-06-23 12:19:21.031
10	V2_FUND_002	INVOICE_FUND	17	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	私人账户收取公司款项	使用私人账户收取公司款项可能导致公私财产混同，增加税务和管理风险。	建议开立对公账户，所有经营收入通过公司账户规范管理。	t	["开户指导", "财务外包"]	t	2026-06-23 12:19:21.032	2026-06-23 12:19:21.032
11	V2_AR_001	RECEIVABLE_COLLECTION	18	{"value": ["经常拖延", "严重逾期"], "operator": "in"}	\N	SIMPLE	MEDIUM	回款周期过长	客户回款经常拖延或严重逾期，可能影响企业现金流和正常经营。	建议梳理应收账款，建立回款催收制度，对高风险客户采取预付款或停止服务措施。	f	["经营分析"]	t	2026-06-23 12:19:21.033	2026-06-23 12:19:21.033
12	V2_AR_002	RECEIVABLE_COLLECTION	19	{"value": "是", "operator": "equals"}	\N	SIMPLE	HIGH	长期逾期应收账款	存在逾期90天以上的应收账款，坏账风险较高，严重影响现金流。	建议立即梳理逾期账款，评估可回收性，必要时采取法律手段催收。	t	["经营分析", "异常处理"]	t	2026-06-23 12:19:21.034	2026-06-23 12:19:21.034
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
1	BUSINESS_LICENSE	营业执照	工商证照	t	t	t	["RISK"]	用于确认企业主体信息、经营范围与存续状态	1	t	2026-06-23 12:19:20.99	2026-06-23 12:19:20.99
2	INCOME_STATEMENT	利润表	财务报表	t	t	t	["PROFIT"]	用于判断收入、毛利和费用变化情况（快速：近3-6月；标准/深度：近12月）	2	t	2026-06-23 12:19:20.992	2026-06-23 12:19:20.992
3	BALANCE_SHEET	资产负债表	财务报表	t	t	t	["CASH_FLOW", "EFFICIENCY"]	用于判断资产结构、负债水平和运营效率（快速：近3-6月；标准/深度：近12月）	3	t	2026-06-23 12:19:20.993	2026-06-23 12:19:20.993
4	CASH_FLOW_STATEMENT	现金流量表	财务报表	f	t	t	["CASH_FLOW"]	用于判断经营/投资/筹资现金流是否健康（近12月）	4	t	2026-06-23 12:19:20.995	2026-06-23 12:19:20.995
5	ACCOUNT_BALANCE	科目余额表	财务报表	f	t	t	["PROFIT", "RISK"]	用于核对各科目余额，发现账务异常	5	t	2026-06-23 12:19:20.996	2026-06-23 12:19:20.996
6	VAT_DECLARATION	增值税申报表	税务资料	t	t	t	["RISK"]	用于判断增值税申报合规性和税负水平	6	t	2026-06-23 12:19:20.997	2026-06-23 12:19:20.997
7	CIT_DECLARATION	企业所得税申报表	税务资料	f	t	t	["RISK", "PROFIT"]	用于判断企业所得税申报合规性和利润真实性	7	t	2026-06-23 12:19:20.998	2026-06-23 12:19:20.998
8	INVOICE_SUMMARY	开票/收票汇总	税务资料	f	t	t	["RISK"]	用于判断进销项匹配度和发票合规性	8	t	2026-06-23 12:19:20.999	2026-06-23 12:19:20.999
9	BANK_STATEMENT	银行流水	资金资料	f	t	t	["CASH_FLOW", "RISK"]	用于核对收入、支出与合同/发票匹配度	9	t	2026-06-23 12:19:21	2026-06-23 12:19:21
10	PAYROLL_SOCIAL_SECURITY	工资/社保/个税资料	人力资料	f	t	t	["RISK", "EFFICIENCY"]	用于判断用工合规性和人效水平	10	t	2026-06-23 12:19:21	2026-06-23 12:19:21
11	CUSTOMER_REVENUE	客户收入贡献表	经营分析	f	f	t	["PROFIT", "EFFICIENCY"]	用于分析客户集中度和客户毛利贡献	11	t	2026-06-23 12:19:21.002	2026-06-23 12:19:21.002
12	PRODUCT_MARGIN	产品/项目毛利表	经营分析	f	f	t	["PROFIT"]	用于分析各产品/项目盈利能力	12	t	2026-06-23 12:19:21.003	2026-06-23 12:19:21.003
13	AR_AGING	应收账款账龄表	资金资料	f	f	t	["CASH_FLOW"]	用于判断回款能力和坏账风险	13	t	2026-06-23 12:19:21.004	2026-06-23 12:19:21.004
14	AP_AGING	应付账款明细	资金资料	f	f	t	["CASH_FLOW"]	用于判断付款压力和供应商账期	14	t	2026-06-23 12:19:21.004	2026-06-23 12:19:21.004
15	INVENTORY_DETAIL	存货明细及库龄	经营分析	f	f	t	["CASH_FLOW", "EFFICIENCY"]	用于判断存货积压和周转效率	15	t	2026-06-23 12:19:21.005	2026-06-23 12:19:21.005
16	FIXED_ASSET	固定资产/设备清单	经营分析	f	f	t	["EFFICIENCY"]	用于判断资产利用率和闲置情况	16	t	2026-06-23 12:19:21.006	2026-06-23 12:19:21.006
17	EXPENSE_DETAIL	费用明细	经营分析	f	f	t	["PROFIT", "EFFICIENCY"]	用于分析费用结构和投入产出比	17	t	2026-06-23 12:19:21.007	2026-06-23 12:19:21.007
18	CONTRACT_SAMPLE	合同样本	法务资料	f	f	t	["RISK"]	用于判断合同条款合规性和经营风险	18	t	2026-06-23 12:19:21.008	2026-06-23 12:19:21.008
19	TAX_ABNORMAL_RECORD	税务异常/处罚/提醒记录	税务资料	f	f	t	["RISK"]	用于判断历史税务合规问题和风险程度	19	t	2026-06-23 12:19:21.009	2026-06-23 12:19:21.009
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
1	\N	1	企业基础信息	1	1	贵公司所属行业？	SINGLE_CHOICE	["互联网", "贸易", "餐饮", "建筑", "运输", "制造", "其他"]	t	工商维度	\N	2026-06-23 12:19:20.945	2026-06-23 12:19:20.945
2	\N	1	企业基础信息	1	2	公司注册时间？	SINGLE_CHOICE	["不到1年", "1-3年", "3-5年", "5年以上"]	t	工商维度	\N	2026-06-23 12:19:20.949	2026-06-23 12:19:20.949
3	\N	1	企业基础信息	1	3	公司类型？	SINGLE_CHOICE	["一人公司", "多股东", "个体户"]	t	工商维度	\N	2026-06-23 12:19:20.95	2026-06-23 12:19:20.95
4	\N	1	经营规模	2	1	年流水大约多少？	RANGE	{"options": ["10万以下", "10-50万", "50-100万", "100-500万", "500万以上"]}	t	税务维度	\N	2026-06-23 12:19:20.952	2026-06-23 12:19:20.952
5	\N	1	经营规模	2	2	公司员工人数？	SINGLE_CHOICE	["0人（无员工）", "1-5人", "5-10人", "10-50人", "50人以上"]	t	社保维度	\N	2026-06-23 12:19:20.953	2026-06-23 12:19:20.953
6	\N	1	税务申报	3	1	目前是否正常报税？	YES_NO	["是", "否"]	t	税务维度	\N	2026-06-23 12:19:20.954	2026-06-23 12:19:20.954
7	\N	1	税务申报	3	2	是否长期零申报？	YES_NO	["是", "否"]	f	税务维度	\N	2026-06-23 12:19:20.956	2026-06-23 12:19:20.956
8	\N	1	社保/员工	4	1	是否给员工缴纳社保？	YES_NO	["是", "否", "无员工"]	t	社保维度	\N	2026-06-23 12:19:20.957	2026-06-23 12:19:20.957
9	\N	1	资金/账户	5	1	是否已开设对公账户？	YES_NO	["是", "否"]	t	资金维度	\N	2026-06-23 12:19:20.958	2026-06-23 12:19:20.958
10	\N	1	资金/账户	5	2	是否存在老板个人账户收公司款项的情况？	YES_NO	["是", "否", "不清楚"]	f	资金维度	\N	2026-06-23 12:19:20.959	2026-06-23 12:19:20.959
11	\N	2	税务申报	1	1	目前是否按期进行纳税申报？	YES_NO	["是", "否"]	t	TAX_DECLARATION	{}	2026-06-23 12:19:21.013	2026-06-23 12:19:21.013
12	\N	2	税务申报	1	2	是否长期零申报？	YES_NO	["是", "否"]	t	TAX_DECLARATION	{}	2026-06-23 12:19:21.014	2026-06-23 12:19:21.014
13	\N	2	税务申报	1	3	零申报期间是否仍有实际经营？	YES_NO	["是", "否", "未零申报"]	f	TAX_DECLARATION	{"showIfAnswer": {"value": "是", "groupLabel": "税务申报", "orderInGroup": 2, "questionPublicId": null}}	2026-06-23 12:19:21.015	2026-06-23 12:19:21.015
14	\N	2	税务申报	1	4	是否出现过税务提醒、异常或处罚？	YES_NO	["是", "否", "不清楚"]	t	TAX_DECLARATION	{}	2026-06-23 12:19:21.016	2026-06-23 12:19:21.016
15	\N	2	发票资金	2	1	发票与实际业务是否匹配？	YES_NO	["是", "否", "部分不匹配"]	t	INVOICE_FUND	{}	2026-06-23 12:19:21.017	2026-06-23 12:19:21.017
16	\N	2	发票资金	2	2	是否存在频繁公转私或大额无说明往来？	YES_NO	["是", "否", "不清楚"]	t	INVOICE_FUND	{}	2026-06-23 12:19:21.019	2026-06-23 12:19:21.019
17	\N	2	发票资金	2	3	是否存在私人账户收取公司款项的情况？	YES_NO	["是", "否"]	t	INVOICE_FUND	{}	2026-06-23 12:19:21.02	2026-06-23 12:19:21.02
18	\N	2	应收回款	3	1	客户回款是否及时？	SINGLE_CHOICE	["及时", "偶尔逾期", "经常拖延", "严重逾期"]	t	RECEIVABLE_COLLECTION	{}	2026-06-23 12:19:21.021	2026-06-23 12:19:21.021
19	\N	2	应收回款	3	2	是否存在逾期90天以上的应收账款？	YES_NO	["是", "否", "不清楚"]	t	RECEIVABLE_COLLECTION	{}	2026-06-23 12:19:21.022	2026-06-23 12:19:21.022
20	\N	2	应收回款	3	3	是否有专人跟进应收款？	YES_NO	["是", "否"]	f	RECEIVABLE_COLLECTION	{}	2026-06-23 12:19:21.023	2026-06-23 12:19:21.023
\.


--
-- Data for Name: Questionnaire; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Questionnaire" (id, version, title, description, "isActive", "createdAt", "updatedAt") FROM stdin;
1	v1	君册财税·企业初诊问卷	请如实填写以下信息，我们将为您生成企业财税健康初诊报告。	t	2026-06-23 12:19:20.94	2026-06-23 12:19:20.94
2	v2	君册财税·企业经营初诊（V2）	请补充资料中无法体现的经营情况，系统将结合资料完整度和问卷答案生成四维经营初诊看板。	t	2026-06-23 12:19:21.011	2026-06-23 12:19:21.011
\.


--
-- Data for Name: Report; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."Report" (id, "publicId", "diagnosisResultId", "reportNumber", title, "riskLevel", "reviewStatus", "customerVisible", "htmlContent", "disclaimerText", "reviewedById", "reviewedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: ReportAccessToken; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ReportAccessToken" (id, "reportId", "tokenHash", "expiresAt", "usedAt", "createdAt") FROM stdin;
\.


--
-- Data for Name: ReviewRecord; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ReviewRecord" (id, "reportId", "reviewerId", action, changes, comment, "createdAt") FROM stdin;
\.


--
-- Data for Name: RiskFinding; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."RiskFinding" (id, "diagnosisResultId", "ruleId", "scenarioId", "riskLevel", title, description, suggestion, "recommendServices", "createdAt") FROM stdin;
\.


--
-- Data for Name: RiskScenario; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."RiskScenario" (id, "scenarioName", "scenarioCode", description, "riskLevel", "triggerRules", "safeExplanation", "forbiddenPhrases", suggestion, "recommendServices", "needManualReview", "isActive", "createdAt", "updatedAt") FROM stdin;
1	长期零申报	LONG_ZERO_DECLARATION	连续多个月零申报，但客户可能仍有实际经营	MEDIUM	{"value": "是", "answerField": "长期零申报"}	长期零申报可能引起税务关注，建议核查申报情况	{违法了,必须补税,一定会被罚款}	建议规范账务处理，确保申报真实准确	["代理记账", "合规项目"]	f	t	2026-06-23 12:19:20.972	2026-06-23 12:19:20.972
2	公私账户混用	MIXED_ACCOUNTS	公司经营款项通过老板个人账户收取	HIGH	{"value": "是", "answerField": "个人账户收款"}	通过个人账户收取公司款项可能存在合规风险，建议规范资金管理	{违法了,走私人账户没问题,可以避税}	建议开立对公账户并通过公司账户管理经营收入	["开户", "财务外包", "合规项目"]	t	t	2026-06-23 12:19:20.972	2026-06-23 12:19:20.972
3	未缴纳社保	NO_SOCIAL_INSURANCE	有员工但未依法缴纳社保	HIGH	{"value": "否", "answerField": "缴纳社保"}	有员工但未缴纳社保可能存在用工合规风险，建议尽快规范	{违法了,不用交,不交没关系}	建议依法为员工缴纳社保，规范用工管理	["社保", "合规项目"]	t	t	2026-06-23 12:19:20.972	2026-06-23 12:19:20.972
4	长期零申报持续经营	V2_SC_001	企业长期进行零申报，但实际存在经营活动（有开票、流水、人员等），属于高风险税务违规行为。	HIGH	["V2_TAX_002"]	长期零申报但实际有经营活动，是税务部门重点关注的情形，可能面临补税、滞纳金和行政处罚。	{肯定会被查,一定会被罚,可以继续零申报}	建议立即委托专业人员规范账务，如实申报经营情况。君册可提供代理记账和补账清账服务。	["代理记账", "补账清账", "税务合规检查"]	t	t	2026-06-23 12:19:21.036	2026-06-23 12:19:21.036
5	公私账户混用	V2_SC_002	企业资金通过个人账户流转，包括私人账户收公司款、频繁公转私，存在严重的财税合规风险。	HIGH	["V2_FUND_001", "V2_FUND_002"]	公私账户混用可能导致财产混同、难以区分经营收支，也是税务稽查的重点关注事项。	{违法了,一定会被罚,包解决}	建议尽快规范资金账户管理，开设对公账户，所有经营收支通过公司账户。君册可协助开户和财务外包。	["开户指导", "财务外包", "税务合规检查"]	t	t	2026-06-23 12:19:21.039	2026-06-23 12:19:21.039
6	回款大面积逾期	V2_SC_003	客户回款严重延迟，存在大额逾期账款，企业现金流面临较大压力。	MEDIUM	["V2_AR_001", "V2_AR_002"]	应收账款回款周期过长会影响企业日常经营所需现金流，建议建立规范的账款管理制度。	{肯定收不回来,一定会坏账}	建议建立应收账款台账和催收流程，对高风险客户收紧信用政策。	["经营分析"]	f	t	2026-06-23 12:19:21.041	2026-06-23 12:19:21.041
\.


--
-- Data for Name: ServiceRecommendation; Type: TABLE DATA; Schema: public; Owner: a1234
--

COPY public."ServiceRecommendation" (id, "diagnosisResultId", "serviceType", reason, priority, "createdAt") FROM stdin;
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
1	cmqqmhzkr0000yi9kc8ckzoxf	2	DRAFT	13800000000	f	WEB	\N	STANDARD	\N	\N	$2b$10$lZHAffEXoNJIjwL16t5hrei7qQYnFsrIGHYLd3UOOsAi4Bf7hj0L6	2026-06-23 12:31:02.23	\N	2026-06-23 12:31:02.235	2026-06-23 12:31:02.235
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

SELECT pg_catalog.setval('public."Answer_id_seq"', 1, false);


--
-- Name: DiagnosisResult_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DiagnosisResult_id_seq"', 1, false);


--
-- Name: DiagnosisRule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."DiagnosisRule_id_seq"', 12, true);


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

SELECT pg_catalog.setval('public."Question_id_seq"', 20, true);


--
-- Name: Questionnaire_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Questionnaire_id_seq"', 2, true);


--
-- Name: ReportAccessToken_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ReportAccessToken_id_seq"', 1, false);


--
-- Name: Report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Report_id_seq"', 1, false);


--
-- Name: ReviewRecord_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ReviewRecord_id_seq"', 1, false);


--
-- Name: RiskFinding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."RiskFinding_id_seq"', 1, false);


--
-- Name: RiskScenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."RiskScenario_id_seq"', 6, true);


--
-- Name: ServiceRecommendation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."ServiceRecommendation_id_seq"', 1, false);


--
-- Name: SmsVerificationCode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."SmsVerificationCode_id_seq"', 1, false);


--
-- Name: Submission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: a1234
--

SELECT pg_catalog.setval('public."Submission_id_seq"', 1, true);


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

\unrestrict leKLz8MWsVZsTejg60VijDGeBOJfqfWrZszYcBJztP1pscA5vPIZySLMIB3GAX4

