
import { GoogleGenAI, Type } from "@google/genai";
import { ResumeData, InterviewQuestion, ChatMessage, UploadedFile, GroundingSource, SkillCategory, JobResult } from "./types";

const resumeSchema = {
  type: Type.OBJECT,
  properties: {
    fullName: { type: Type.STRING },
    targetRole: { type: Type.STRING },
    summary: { type: Type.STRING },
    experiences: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          company: { type: Type.STRING },
          role: { type: Type.STRING },
          period: { type: Type.STRING },
          achievements: {
            type: Type.ARRAY,
            items: { type: Type.STRING }
          }
        },
        required: ["company", "role", "achievements"]
      }
    },
    skills: {
      type: Type.ARRAY,
      items: {
        type: Type.OBJECT,
        properties: {
          category: { type: Type.STRING },
          skills: { type: Type.ARRAY, items: { type: Type.STRING } }
        },
        required: ["category", "skills"]
      }
    },
    isShortInput: { type: Type.BOOLEAN },
    followUpQuestions: { 
      type: Type.ARRAY, 
      items: { type: Type.STRING }
    }
  },
  required: ["fullName", "targetRole", "summary", "experiences", "skills"]
};

const ARCHITECT_SYSTEM_PROMPT = `You are a Professional Resume Writer, Career Coach, and ATS Optimization Expert for the ROLDANI Professional Suite. Your mission is to engineer high-impact, ATS-optimized resumes that clear every digital gatekeeper.

CORE RULES & STANDARDS:
1. TONE & STYLE: Use clear, professional, results-driven language. No fluff, clichés, or first-person pronouns (no "I", "my"). Write with a confident, high-authority executive voice.
2. THE XYZ FORMULA: Every bullet point MUST follow the XYZ logic: "Accomplished [X] as measured by [Y], by doing [Z]". 
3. ACTION VERBS: Start every bullet with a powerful active verb (e.g., Spearheaded, Orchestrated, Catalyzed, Leveraged).
4. QUANTIFICATION: Prioritize achievements and results. Quantify impact (%, $, time, scale). If the user provides a task without a metric, insert a realistic placeholder like "[X]%" or "$[Y]k" to maintain the standard.
5. CONCISENESS & STRUCTURE:
   - Summary: 3–4 lines. Highlight years of experience and value proposition.
   - Skills: 8–15 high-traffic keywords specific to the target role. Hard skills first.
   - Experience: 3–6 bullet points per role focusing on impact.
6. TENSE CONSISTENCY: Use present tense for current roles and past tense for previous roles.
7. DEEP SKILL INFERENCE: Critically analyze work history to infer technical and core competencies (e.g., if they managed people, infer 'Cross-functional Leadership').
8. ATS OPTIMIZATION: Naturally mirror keywords from the provided job description or industry standards.

If the input is for a refinement, strictly update the existing blueprint JSON while maintaining these high-tier standards. ALWAYS output valid JSON following the schema.`;

export const optimizeResume = async (history: string, jobDescription?: string, file?: UploadedFile): Promise<ResumeData & { groundingSources: GroundingSource[] }> => {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const jobContext = jobDescription 
    ? `TARGET JOB SPECIFICATION: ${jobDescription}`
    : "GENERAL EXECUTIVE STANDARD: Create a high-growth, leadership-focused narrative.";

  const parts: any[] = [
    { text: `${jobContext}\n\nUSER RAW TEXT INPUT:\n${history}` }
  ];

  if (file) {
    parts.push({
      inlineData: {
        data: file.data,
        mimeType: file.mimeType
      }
    });
  }

  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: [{ role: 'user', parts }],
    config: {
      systemInstruction: ARCHITECT_SYSTEM_PROMPT,
      responseMimeType: "application/json",
      responseSchema: resumeSchema,
      tools: [{ googleSearch: {} }]
    },
  });

  const jsonStr = response.text || '{}';
  const data = JSON.parse(jsonStr);
  
  const sources: GroundingSource[] = response.candidates?.[0]?.groundingMetadata?.groundingChunks?.map((chunk: any) => ({
    title: chunk.web?.title || 'Industry Data Source',
    uri: chunk.web?.uri || '#'
  })) || [];

  return { ...data, groundingSources: sources };
};

export const searchJobs = async (role: string, location: string): Promise<JobResult[]> => {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const prompt = `Find the latest ${role} job openings in ${location || 'Global/Remote'}. Search on LinkedIn, Indeed, and direct company career portals. Return a list of active job postings.`;

  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: [{ role: 'user', parts: [{ text: prompt }] }],
    config: {
      tools: [{ googleSearch: {} }]
    },
  });

  // Extract from grounding chunks
  const chunks = response.candidates?.[0]?.groundingMetadata?.groundingChunks || [];
  return chunks.map((chunk: any) => ({
    title: chunk.web?.title || 'Open Opportunity',
    company: 'Institutional Partner',
    location: location || 'Remote',
    snippet: response.text?.substring(0, 150) + '...', // Use part of response for context
    url: chunk.web?.uri || '#'
  }));
};

export const suggestMetrics = async (history: string): Promise<{ vagues: string[], suggestions: string[], inferredSkills: string[] }> => {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: [{ 
      role: 'user',
      parts: [{ 
        text: `As a Lead Career Architect, perform a Narrative Audit on this work history. 
        1. Identify 3-5 weak, qualitative statements.
        2. Provide high-impact XYZ rewrites with placeholder metrics.
        3. Infer 5-7 high-value Technical/Core skills that should be added to their expertise section based on this history.
        
        Return JSON with "vagues" (original text), "suggestions" (XYZ version), and "inferredSkills" (array of skills).
        \n\nWORK HISTORY:\n"${history}"` 
      }] 
    }],
    config: {
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          vagues: { type: Type.ARRAY, items: { type: Type.STRING } },
          suggestions: { type: Type.ARRAY, items: { type: Type.STRING } },
          inferredSkills: { type: Type.ARRAY, items: { type: Type.STRING } }
        },
        required: ["vagues", "suggestions", "inferredSkills"]
      },
    },
  });

  return JSON.parse(response.text || '{"vagues": [], "suggestions": [], "inferredSkills": []}');
};

export const generateProfessionalHeadshot = async (role: string): Promise<string> => {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const response = await ai.models.generateContent({
    model: 'gemini-2.5-flash-image',
    contents: [{
      role: 'user',
      parts: [{
        text: `Generate a high-end, executive professional headshot avatar for a ${role}. Minimalist style, ultra-clean lighting, professional studio background.`,
      }],
    }],
    config: {
      imageConfig: { aspectRatio: "1:1" }
    },
  });

  for (const part of response.candidates[0].content.parts) {
    if (part.inlineData) {
      return `data:image/png;base64,${part.inlineData.data}`;
    }
  }
  throw new Error("Headshot generation failed.");
};

export const refineResumeWithChat = async (currentData: ResumeData, chatHistory: ChatMessage[], file?: UploadedFile): Promise<ResumeData> => {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  
  const history = chatHistory.map(m => ({
    role: m.role === 'user' ? 'user' : 'model',
    parts: [{ text: m.content }] as any[]
  }));

  if (file) {
    const lastUser = [...history].reverse().find(h => h.role === 'user');
    if (lastUser) {
      lastUser.parts.push({
        inlineData: {
          data: file.data,
          mimeType: file.mimeType
        }
      });
    }
  }

  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: history,
    config: {
      systemInstruction: `${ARCHITECT_SYSTEM_PROMPT}\n\nCURRENT RESUME BLUEPRINT: ${JSON.stringify(currentData)}`,
      responseMimeType: "application/json",
      responseSchema: resumeSchema,
    },
  });
  
  return JSON.parse(response.text || '{}');
};

export const generateInterviewPrep = async (resume: ResumeData): Promise<InterviewQuestion[]> => {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: [{ 
      role: 'user',
      parts: [{ 
        text: `Generate 5 behavioral interview questions for this resume. Return JSON array.\n\nRESUME: ${JSON.stringify(resume)}` 
      }] 
    }],
    config: {
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.ARRAY,
        items: {
          type: Type.OBJECT,
          properties: {
            question: { type: Type.STRING },
            intent: { type: Type.STRING },
            suggestedAngle: { type: Type.STRING }
          },
          required: ["question", "intent", "suggestedAngle"]
        }
      },
    },
  });

  return JSON.parse(response.text || '[]');
};

export const getBulletAlternatives = async (bullet: string, role: string): Promise<{ style: string, text: string }[]> => {
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: [{
      role: 'user',
      parts: [{
        text: `Rewrite this bullet point into 3 XYZ variations (Aggressive, Strategic, Technical). Return JSON array.\n\nBULLET: "${bullet}"\nROLE: "${role}"`
      }]
    }],
    config: {
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.ARRAY,
        items: {
          type: Type.OBJECT,
          properties: {
            style: { type: Type.STRING },
            text: { type: Type.STRING }
          },
          required: ["style", "text"]
        }
      },
    },
  });

  return JSON.parse(response.text || '[]');
};
