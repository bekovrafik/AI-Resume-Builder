
export interface User {
  email: string;
  name: string;
  isPremium: boolean;
}

export type ThemeMode = 'dark' | 'light';

export interface ProfileData {
  fullName: string;
  targetRole: string;
  email: string;
  phone: string;
  location: string;
  linkedIn: string;
  avatarUrl?: string;
  workExperience: string;
  education: string;
  certifications: string;
  projects: string;
  languages: string;
  availability: string;
}

export type ActiveTab = "profile" | "blueprint" | "narrative" | "strategy" | "chat" | "market";

export interface Experience {
  company: string;
  role: string;
  period: string;
  achievements: string[];
}

export interface SkillCategory {
  category: "Technical" | "Core Competencies" | "Soft Skills";
  skills: string[];
}

export interface InterviewQuestion {
  question: string;
  intent: string;
  suggestedAngle: string;
}

export type ResumeTheme = 
  | "Executive" 
  | "Minimalist" 
  | "Creative Nomad" 
  | "Modernist" 
  | "Silicon Valley" 
  | "Academic" 
  | "Royal High-End";

export interface GroundingSource {
  title: string;
  uri: string;
}

export interface JobResult {
  title: string;
  company: string;
  location: string;
  snippet: string;
  url: string;
  postedDate?: string;
}

export interface ResumeData {
  fullName: string;
  targetRole: string;
  summary: string;
  experiences: Experience[];
  skills: SkillCategory[];
  followUpQuestions?: string[];
  isShortInput?: boolean;
  avatarUrl?: string;
  groundingSources?: GroundingSource[];
}

export interface ResumeIteration {
  id: string;
  date: string;
  data: ResumeData;
  theme: ResumeTheme;
}

export interface SavedResume {
  id: string;
  name: string;
  versions: ResumeIteration[];
}

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

export enum AdType {
  BANNER = 'BANNER',
  INTERSTITIAL = 'INTERSTITIAL',
  REWARDED = 'REWARDED',
  APP_OPEN = 'APP_OPEN'
}

export interface AdState {
  type: AdType;
  visible: boolean;
  message: string;
  onAdComplete?: () => void;
}

export interface UploadedFile {
  data: string; // base64
  mimeType: string;
  name: string;
}
