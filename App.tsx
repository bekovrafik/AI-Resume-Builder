
import React, { useState, useEffect } from 'react';
import { ResumeData, AdState, AdType, ResumeTheme, InterviewQuestion, User, ActiveTab, ProfileData, ChatMessage, UploadedFile, SavedResume, ResumeIteration, JobResult } from './types';
import { optimizeResume, generateInterviewPrep, getBulletAlternatives, refineResumeWithChat, generateProfessionalHeadshot, searchJobs } from './geminiService';
import ResumePreview from './components/ResumePreview';
import AdOverlay from './components/AdOverlay';
import InterviewPrep from './components/InterviewPrep';
import Auth from './components/Auth';
import Profile from './components/Profile';
import ChatInterface from './components/ChatInterface';
import LandingInfo from './components/LandingInfo';
import Onboarding from './components/Onboarding';
import BlueprintDraft from './components/BlueprintDraft';
import StyleGallery from './components/StyleGallery';
import JobDiscovery from './components/JobDiscovery';
import Logo from './components/Logo';
import { pdf } from '@react-pdf/renderer';
import { ResumePDFDocument } from './components/ResumePDFDocument';
import { useTheme } from './ThemeContext';

const App: React.FC = () => {
  const [user, setUser] = useState<User | null>(null);
  const [activeTab, setActiveTab] = useState<ActiveTab>("blueprint");
  const [showOnboarding, setShowOnboarding] = useState(false);
  const { mode, toggleMode } = useTheme();
  
  const [profile, setProfile] = useState<ProfileData>(() => {
    const saved = localStorage.getItem('resume_builder_profile');
    return saved ? JSON.parse(saved) : {
      fullName: '',
      targetRole: '',
      email: '',
      phone: '',
      location: '',
      linkedIn: '',
      avatarUrl: '',
      workExperience: '',
      education: '',
      certifications: '',
      projects: '',
      languages: '',
      availability: ''
    };
  });

  const [savedResumes, setSavedResumes] = useState<SavedResume[]>(() => {
    const saved = localStorage.getItem('resume_builder_vault');
    return saved ? JSON.parse(saved) : [];
  });

  const [activeResumeId, setActiveResumeId] = useState<string | null>(null);
  const [isNamingModalOpen, setIsNamingModalOpen] = useState(false);
  const [resumeNameInput, setResumeNameInput] = useState('');

  const [history, setHistory] = useState('');
  const [jobDescription, setJobDescription] = useState('');
  const [uploadedFile, setUploadedFile] = useState<UploadedFile | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [resumeData, setResumeData] = useState<ResumeData | null>(null);
  const [interviewQuestions, setInterviewQuestions] = useState<InterviewQuestion[] | null>(null);
  const [theme, setTheme] = useState<ResumeTheme>("Executive");
  const [ad, setAd] = useState<AdState | null>(null);

  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [isChatting, setIsChatting] = useState(false);

  const [polishingTarget, setPolishingTarget] = useState<{expIdx: number, achIdx: number, text: string, role: string} | null>(null);
  const [polishAlternatives, setPolishAlternatives] = useState<{style: string, text: string}[]>([]);
  const [isPolishing, setIsPolishing] = useState(false);

  useEffect(() => {
    if (user) {
      setAd({
        type: AdType.APP_OPEN,
        visible: true,
        message: `Welcome, ${user.name}. Accessing your Executive Dashboard.`
      });
      setProfile(prev => ({ ...prev, email: user.email, fullName: user.name }));
      
      const hasOnboarded = localStorage.getItem('resume_onboarded');
      if (!hasOnboarded) {
        setShowOnboarding(true);
      }
    }
  }, [user]);

  useEffect(() => {
    localStorage.setItem('resume_builder_profile', JSON.stringify(profile));
  }, [profile]);

  useEffect(() => {
    localStorage.setItem('resume_builder_vault', JSON.stringify(savedResumes));
  }, [savedResumes]);

  const saveIteration = (data: ResumeData, currentTheme: ResumeTheme, resumeId: string | null, customName?: string) => {
    const iteration: ResumeIteration = {
      id: Date.now().toString(),
      date: new Date().toLocaleString(),
      data,
      theme: currentTheme
    };

    if (resumeId) {
      setSavedResumes(prev => prev.map(r => 
        r.id === resumeId 
          ? { ...r, versions: [iteration, ...r.versions] } 
          : r
      ));
    } else {
      const newResumeId = Date.now().toString();
      const newSaved: SavedResume = {
        id: newResumeId,
        name: customName || data.targetRole || "New Standard",
        versions: [iteration]
      };
      setSavedResumes(prev => [newSaved, ...prev]);
      setActiveResumeId(newResumeId);
    }
  };

  const handleManualSave = () => {
    if (!resumeData) return;
    setResumeNameInput(activeResumeId ? (savedResumes.find(r => r.id === activeResumeId)?.name || resumeData.targetRole) : (resumeData.targetRole || ''));
    setIsNamingModalOpen(true);
  };

  const confirmManualSave = () => {
    if (!resumeData) return;
    if (activeResumeId) {
      setSavedResumes(prev => prev.map(r => 
        r.id === activeResumeId 
          ? { ...r, name: resumeNameInput || r.name } 
          : r
      ));
      saveIteration(resumeData, theme, activeResumeId);
      setAd({ type: AdType.BANNER, visible: true, message: `Vault entry "${resumeNameInput}" updated with ${theme} standard.` });
    } else {
      saveIteration(resumeData, theme, null, resumeNameInput || "Executive Standard");
      setAd({ type: AdType.BANNER, visible: true, message: "Initial blueprint synthesized and vaulted." });
    }
    setIsNamingModalOpen(false);
  };

  const handleSyncVault = () => {
    if (!resumeData) return;
    // If we're already viewing an active resume, just save the current draft iteration.
    // This atomic action ensures narrative refinements are committed.
    if (activeResumeId) {
      saveIteration(resumeData, theme, activeResumeId);
      setAd({ type: AdType.BANNER, visible: true, message: "Draft synchronized and vaulted." });
    } else {
      handleManualSave();
    }
  };

  const handleProcess = async () => {
    if (!history.trim() && !uploadedFile) return;
    setIsProcessing(true);
    setAd({ type: AdType.INTERSTITIAL, visible: true, message: "Architecting your narrative standard..." });

    try {
      const contextAwareHistory = `CORE IDENTITY: Name: ${profile.fullName}, Role: ${profile.targetRole}\n\nWORK HISTORY:\n${history}`;
      const result = await optimizeResume(contextAwareHistory, jobDescription, uploadedFile || undefined);
      
      if (profile.fullName) result.fullName = profile.fullName;
      if (profile.targetRole) result.targetRole = profile.targetRole;
      result.avatarUrl = profile.avatarUrl;

      setResumeData(result);

      if (result.isShortInput) {
        setChatMessages([
          { role: 'assistant', content: "Your legacy data is thin. I've synthesized follow-up questions to help me engineer a powerful narrative:" },
          ...(result.followUpQuestions || []).map(q => ({ role: 'assistant' as const, content: q }))
        ]);
        setActiveTab("chat");
      } else {
        setAd({ type: AdType.BANNER, visible: true, message: "Draft successfully optimized." });
        setActiveTab("narrative");
      }
    } catch (error) {
      console.error(error);
    } finally {
      setIsProcessing(false);
    }
  };

  const handleJobSearch = async (role: string, loc: string): Promise<JobResult[]> => {
    setIsProcessing(true);
    try {
      return await searchJobs(role, loc);
    } catch (error) {
      console.error(error);
      return [];
    } finally {
      setIsProcessing(false);
    }
  };

  const handleGenerateAvatar = async () => {
    if (!profile.targetRole) return;
    setIsProcessing(true);
    try {
      const url = await generateProfessionalHeadshot(profile.targetRole);
      setProfile(prev => ({ ...prev, avatarUrl: url }));
      if (resumeData) {
        const updated = { ...resumeData, avatarUrl: url };
        setResumeData(updated);
        if (activeResumeId) {
          saveIteration(updated, theme, activeResumeId);
        }
      }
    } catch (error) {
      console.error(error);
    } finally {
      setIsProcessing(false);
    }
  };

  const handleLoadResume = (saved: SavedResume) => {
    const latest = saved.versions[0];
    setResumeData(latest.data);
    setTheme(latest.theme);
    setActiveResumeId(saved.id);
    setActiveTab("narrative");
  };

  const handleLoadIteration = (iteration: ResumeIteration, resumeId: string) => {
    setResumeData(iteration.data);
    setTheme(iteration.theme);
    setActiveResumeId(resumeId);
    setActiveTab("narrative");
  };

  const handleDeleteResume = (id: string) => {
    setSavedResumes(prev => prev.filter(r => r.id !== id));
    if (activeResumeId === id) {
      setActiveResumeId(null);
      setResumeData(null);
    }
  };

  const handlePrepInterview = async () => {
    if (!resumeData) return;
    setIsProcessing(true);
    setAd({ type: AdType.REWARDED, visible: true, message: "Architecting tactical strategy..." });
    try {
      const q = await generateInterviewPrep(resumeData);
      setInterviewQuestions(q);
      setActiveTab("strategy");
    } catch (error) {
      console.error(error);
      alert("Strategy engine encounterd a synchronization error. Please try again.");
    } finally {
      setIsProcessing(false);
    }
  };

  const handleSendMessage = async (content: string, file?: UploadedFile) => {
    if (!resumeData || isChatting) return;
    setIsChatting(true);
    setAd({ type: AdType.REWARDED, visible: true, message: "Refining career narrative blueprint..." });
    
    const userMsg: ChatMessage = { role: 'user', content: file ? `${content} [Attached File: ${file.name}]` : content };
    const nextHistory = [...chatMessages, userMsg];
    setChatMessages(nextHistory);

    try {
      const result = await refineResumeWithChat(resumeData, nextHistory, file);
      result.avatarUrl = profile.avatarUrl;
      setResumeData(result);
      if (activeResumeId) {
        saveIteration(result, theme, activeResumeId);
      }
      setChatMessages(prev => [
        ...prev, 
        { role: 'assistant', content: "Architectural refinements complete. Your professional narrative has been elevated and synchronized." }
      ]);
    } catch (error) {
      console.error("Chat Refinement Error:", error);
      setChatMessages(prev => [
        ...prev, 
        { role: 'assistant', content: "Synthesis interrupted. Please check your professional network connection." }
      ]);
    } finally {
      setIsChatting(false);
    }
  };

  const handleAchievementClick = async (expIdx: number, achIdx: number, text: string, role: string) => {
    setPolishingTarget({ expIdx, achIdx, text, role });
    setIsPolishing(true);
    setAd({ type: AdType.REWARDED, visible: true, message: "Unlocking Narrative Polish Mode..." });
    try {
      const alts = await getBulletAlternatives(text, role);
      setPolishAlternatives(alts);
    } catch (error) {
      console.error(error);
      setIsPolishing(false);
    }
  };

  const applyAlternative = (text: string) => {
    if (!resumeData || !polishingTarget) return;
    const newData = { ...resumeData };
    newData.experiences[polishingTarget.expIdx].achievements[polishingTarget.achIdx] = text;
    setResumeData(newData);
    // Note: Iteration saving is now streamlined via the Sync button or manual save.
    setIsPolishing(false);
    setPolishAlternatives([]);
    setPolishingTarget(null);
    setAd({ type: AdType.BANNER, visible: true, message: "Refinement applied to draft. Click 'Apply & Save' to vault." });
  };

  const handleExport = async () => {
    if (!resumeData || isExporting) return;
    setIsExporting(true);
    setAd({ 
      type: AdType.INTERSTITIAL, 
      visible: true, 
      message: `Synthesizing ${theme} Gold-Standard PDF...` 
    });

    try {
      const doc = <ResumePDFDocument data={resumeData} theme={theme} />;
      const blob = await pdf(doc).toBlob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `${(resumeData.fullName || 'Career_Narrative').replace(/\s+/g, '_')}_AI_Resume_${theme}.pdf`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      setTimeout(() => URL.revokeObjectURL(url), 100);
    } catch (error) {
      console.error("PDF Export failed:", error);
      alert("Institutional Standard PDF generation failed. Please check your data.");
    } finally {
      setIsExporting(false);
    }
  };

  const handleThemeChange = (newTheme: ResumeTheme, isLocked: boolean) => {
    if (isLocked) {
      setAd({ 
        type: AdType.REWARDED, 
        visible: true, 
        message: `Architecting Premium Standard: ${newTheme}. Synchronizing with institutional ad registry...`,
        onAdComplete: () => {
          setTheme(newTheme);
          if (resumeData && activeResumeId) {
            saveIteration(resumeData, newTheme, activeResumeId);
          }
        }
      });
    } else {
      setTheme(newTheme);
      if (resumeData && activeResumeId) {
        saveIteration(resumeData, newTheme, activeResumeId);
      }
    }
  };

  if (!user) return <Auth onLogin={setUser} />;
  if (showOnboarding) return <Onboarding onComplete={() => { setShowOnboarding(false); localStorage.setItem('resume_onboarded', 'true'); }} />;

  return (
    <div className={`min-h-screen transition-colors duration-500 selection:bg-yellow-500/30 pb-40 max-w-lg mx-auto md:max-w-none`}>
      {ad?.visible && (
        <AdOverlay 
          type={ad.type} 
          message={ad.message} 
          onClose={() => {
            if (ad.onAdComplete) ad.onAdComplete();
            setAd(prev => prev ? { ...prev, visible: false } : null);
          }} 
        />
      )}

      {isNamingModalOpen && (
        <div className="fixed inset-0 z-[110] bg-[#073b4c]/95 flex items-center justify-center p-6 backdrop-blur-xl animate-in fade-in duration-300">
           <div className={`w-full max-w-sm glass p-8 rounded-[2.5rem] animate-in zoom-in-95 duration-300 ${mode === 'dark' ? 'builder-border' : 'border border-[#073b4c]/10 bg-white'}`}>
              <div className="flex flex-col items-center mb-6">
                <div className="w-12 h-12 bg-yellow-500/10 rounded-2xl flex items-center justify-center mb-4">
                  <svg className="w-6 h-6 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" /></svg>
                </div>
                <h3 className="text-xl font-serif uppercase tracking-widest text-center">Confirm Vaulting</h3>
                <div className="flex items-center gap-2 mt-2 px-3 py-1 bg-yellow-500/10 rounded-full">
                  <span className="text-[8px] font-black uppercase tracking-widest text-yellow-600">Theme: {theme}</span>
                </div>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="text-[9px] font-black uppercase tracking-widest text-gray-400 block mb-2 ml-1">Blueprint Identifier</label>
                  <input 
                    type="text" 
                    autoFocus
                    value={resumeNameInput}
                    onChange={(e) => setResumeNameInput(e.target.value)}
                    placeholder="Ex: Executive Narrative 2024"
                    className={`w-full bg-transparent border rounded-2xl px-5 py-4 text-sm transition-all ${mode === 'dark' ? 'border-white/10 text-white focus:border-yellow-500' : 'border-[#073b4c]/10 text-[#073b4c] focus:border-[#073b4c]'}`}
                  />
                </div>
                
                <button 
                  onClick={confirmManualSave}
                  className={`w-full py-5 rounded-2xl font-black uppercase tracking-widest text-[10px] transition-all active:scale-95 shadow-xl ${mode === 'dark' ? 'bg-white text-[#073b4c] hover:bg-yellow-500' : 'bg-[#073b4c] text-white'}`}
                >
                  Synchronize to Vault
                </button>
                
                <button 
                  onClick={() => setIsNamingModalOpen(false)}
                  className="w-full text-[9px] text-gray-500 uppercase font-black tracking-widest py-2"
                >
                  Cancel
                </button>
              </div>
           </div>
        </div>
      )}

      {isPolishing && (
        <div className="fixed inset-0 z-[100] bg-[#073b4c]/95 backdrop-blur-xl flex items-center justify-center p-6">
          <div className={`w-full max-w-md glass p-8 rounded-3xl animate-in zoom-in-95 duration-300 ${mode === 'dark' ? 'builder-border' : 'border border-[#073b4c]/20'}`}>
            <h3 className="text-xl font-serif mb-6 uppercase tracking-widest text-center">Narrative Refinement</h3>
            <div className={`p-4 border rounded-xl mb-8 text-xs italic ${mode === 'dark' ? 'bg-white/5 border-white/10 text-gray-400' : 'bg-[#073b4c]/5 border-[#073b4c]/10 text-gray-600'}`}>
              "{polishingTarget?.text}"
            </div>
            <div className="space-y-4">
              {polishAlternatives.length > 0 ? (
                polishAlternatives.map((alt, idx) => (
                  <button 
                    key={idx}
                    onClick={() => applyAlternative(alt.text)}
                    className={`w-full p-5 text-left border rounded-2xl transition-all ${mode === 'dark' ? 'border-white/10 hover:bg-white/5 hover:border-yellow-500/50' : 'border-[#073b4c]/10 hover:bg-gray-50'}`}
                  >
                    <span className="text-[9px] font-bold text-yellow-500 uppercase tracking-widest">{alt.style} Standard</span>
                    <p className={`text-xs mt-1 leading-relaxed ${mode === 'dark' ? 'text-gray-300' : 'text-gray-600'}`}>{alt.text}</p>
                  </button>
                ))
              ) : (
                <div className="py-20 text-center animate-pulse text-yellow-500 uppercase tracking-widest text-[10px]">Architectural Synthesis...</div>
              )}
            </div>
            <button onClick={() => setIsPolishing(false)} className="mt-8 w-full py-3 text-[10px] text-gray-500 uppercase font-bold tracking-[0.4em]">Cancel Refinement</button>
          </div>
        </div>
      )}

      <nav className={`sticky top-0 z-40 glass border-b p-4 flex justify-between items-center md:px-12 transition-all`}>
        <div className="flex items-center gap-3">
          <Logo size="sm" />
          <span className="text-sm font-serif font-bold uppercase tracking-widest">AI Resume Builder</span>
        </div>
        <div className="flex items-center gap-4">
          <button onClick={toggleMode} className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${mode === 'dark' ? 'bg-white/10 text-yellow-400' : 'bg-[#073b4c]/5 text-gray-600'}`}>
            {mode === 'dark' ? '☀️' : '🌙'}
          </button>
        </div>
      </nav>

      <main className={`px-4 ${activeTab === 'chat' ? 'py-0 h-[calc(100vh-140px)]' : 'py-8 min-h-[60vh]'} md:max-w-4xl md:mx-auto`}>
        {activeTab === "profile" && <Profile data={profile} onChange={setProfile} savedResumes={savedResumes} onLoadResume={handleLoadResume} onLoadIteration={handleLoadIteration} onDeleteResume={handleDeleteResume} onLogout={() => setUser(null)} onGenerateAvatar={handleGenerateAvatar} isProcessing={isProcessing} onNavigateTab={setActiveTab} />}
        {activeTab === "blueprint" && <div className="space-y-12"><BlueprintDraft history={history} setHistory={setHistory} jobDescription={jobDescription} setJobDescription={setJobDescription} onProcess={handleProcess} onFileUpload={setUploadedFile} uploadedFile={uploadedFile} isProcessing={isProcessing} /><LandingInfo /></div>}
        {activeTab === "chat" && <ChatInterface messages={chatMessages} onSendMessage={handleSendMessage} isProcessing={isChatting} mode={mode} onNavigateToPreview={() => setActiveTab("narrative")} onBackToDash={() => setActiveTab("profile")} />}
        {activeTab === "market" && <JobDiscovery onSearch={handleJobSearch} initialRole={resumeData?.targetRole || profile.targetRole} initialLocation={profile.location} isProcessing={isProcessing} />}
        {activeTab === "narrative" && <div className="animate-in fade-in zoom-in-95 duration-700">{resumeData ? <>
          <StyleGallery currentTheme={theme} onThemeSelect={handleThemeChange} />
          <ResumePreview data={resumeData} onExport={handleExport} onSave={handleManualSave} onSyncVault={handleSyncVault} theme={theme} onAchievementClick={handleAchievementClick} />
          {resumeData.groundingSources && resumeData.groundingSources.length > 0 && (<div className="mt-8 p-6 glass rounded-3xl border border-yellow-500/20"><h4 className="text-[10px] font-black uppercase tracking-widest text-yellow-600 mb-4">Industry Insights</h4><div className="flex flex-wrap gap-4">{resumeData.groundingSources.map((source, idx) => (<a key={idx} href={source.uri} target="_blank" rel="noopener noreferrer" className="text-[9px] text-gray-500 hover:text-yellow-600 underline font-medium truncate max-w-[200px]">{source.title}</a>))}</div></div>)}<div className="mt-12 p-8 glass rounded-3xl text-center border border-[#073b4c]/10"><h3 className="text-lg font-serif mb-2 uppercase tracking-widest">Interview Readiness</h3><button onClick={handlePrepInterview} className="px-10 py-4 bg-yellow-500/10 text-yellow-500 border border-yellow-500/30 font-bold uppercase tracking-[0.2em] text-[10px] rounded-full hover:bg-yellow-500 hover:text-[#073b4c] transition-all">Generate Strategy Blueprint</button></div></> : <div className="py-40 text-center opacity-30 uppercase tracking-[0.4em] text-xs">Awaiting Blueprint Synthesis</div>}</div>}
        {activeTab === "strategy" && <div className="animate-in fade-in slide-in-from-right-4 duration-500"><InterviewPrep questions={interviewQuestions} onGenerate={handlePrepInterview} isProcessing={isProcessing} hasResume={!!resumeData} onBackToDash={() => setActiveTab("profile")} /></div>}
      </main>

      <footer className={`fixed bottom-0 left-0 right-0 z-50 glass border-t flex justify-around items-center p-4 md:max-w-lg md:mx-auto md:rounded-t-[3rem] shadow-2xl transition-all`}>
        {[
          { id: 'profile', label: 'Dash', icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7 7z' },
          { id: 'blueprint', label: 'Build', icon: 'M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z' },
          { id: 'market', label: 'Market', icon: 'M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9' },
          { id: 'narrative', label: 'Preview', icon: 'M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253' },
        ].map((tab) => (
          <button key={tab.id} onClick={() => setActiveTab(tab.id as ActiveTab)} className={`flex flex-col items-center gap-1.5 transition-all flex-1 ${activeTab === tab.id ? 'text-yellow-500 scale-110' : 'text-gray-600 hover:text-gray-400'}`}>
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={tab.icon}/></svg>
            <span className="text-[7px] font-bold uppercase tracking-[0.2em]">{tab.label}</span>
          </button>
        ))}
      </footer>
    </div>
  );
};

export default App;
