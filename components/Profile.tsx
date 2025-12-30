
import React, { useState, useMemo, useRef } from 'react';
import { ProfileData, SavedResume, ResumeIteration, ActiveTab } from '../types';
import { useTheme } from '../ThemeContext';
import PrivacyPolicy from './PrivacyPolicy';

interface ProfileProps {
  data: ProfileData;
  onChange: (data: ProfileData) => void;
  savedResumes: SavedResume[];
  onLoadResume: (resume: SavedResume) => void;
  onLoadIteration: (iteration: ResumeIteration, resumeId: string) => void;
  onDeleteResume: (id: string) => void;
  onLogout: () => void;
  onGenerateAvatar: () => void;
  isProcessing: boolean;
  onNavigateTab: (tab: ActiveTab) => void;
}

type SubView = 'main' | 'identity' | 'vault' | 'concierge' | 'privacy' | 'history';

const Profile: React.FC<ProfileProps> = ({ 
  data, onChange, savedResumes, onLoadResume, onLoadIteration, 
  onDeleteResume, onLogout, onGenerateAvatar, isProcessing, onNavigateTab 
}) => {
  const { mode, toggleMode } = useTheme();
  const [subView, setSubView] = useState<SubView>('main');
  const [activeResumeId, setActiveResumeId] = useState<string | null>(null);
  const [showContactForm, setShowContactForm] = useState(false);
  const [contactStatus, setContactStatus] = useState<'idle' | 'sending' | 'sent'>('idle');
  const [searchQuery, setSearchQuery] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  const isDark = mode === 'dark';

  const handleFieldChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    onChange({ ...data, [name]: value });
  };

  const handleAvatarUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = () => {
      onChange({ ...data, avatarUrl: reader.result as string });
    };
    reader.readAsDataURL(file);
  };

  const handleContactSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setContactStatus('sending');
    setTimeout(() => {
      setContactStatus('sent');
      setTimeout(() => {
        setShowContactForm(false);
        setContactStatus('idle');
      }, 2000);
    }, 1500);
  };

  const filledFields = Object.values(data).filter(v => typeof v === 'string' && v.length > 0).length;
  const identityProgress = Math.round((filledFields / 13) * 100);

  const filteredResumes = useMemo(() => {
    if (!searchQuery.trim()) return savedResumes;
    const query = searchQuery.toLowerCase();
    return savedResumes.filter(resume => {
      const d = resume.versions[0].data;
      const searchFields = [
        d.fullName, d.targetRole, d.summary,
        ...d.experiences.flatMap(e => [e.company, e.role, ...e.achievements]),
        ...d.skills.flatMap(s => [s.category, ...s.skills])
      ].filter(Boolean).map(s => s?.toLowerCase());
      return searchFields.some(field => field?.includes(query));
    });
  }, [savedResumes, searchQuery]);

  const activeResumeIterations = useMemo(() => {
    return savedResumes.find(r => r.id === activeResumeId)?.versions || [];
  }, [savedResumes, activeResumeId]);

  const SettingRow = ({ icon, title, subtitle, onClick, color = "text-yellow-500", destructive = false }: any) => (
    <button 
      onClick={onClick}
      className={`w-full flex items-center gap-4 px-4 py-4 transition-all active:bg-gray-500/10 border-b last:border-0 ${isDark ? 'border-white/5' : 'border-[#073b4c]/5'}`}
    >
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-none ${isDark ? 'bg-white/5' : 'bg-[#073b4c]/5'} ${destructive ? 'text-red-500' : color}`}>
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={icon} /></svg>
      </div>
      <div className="flex-1 text-left">
        <p className={`text-sm font-semibold ${destructive ? 'text-red-500' : (isDark ? 'text-white' : 'text-[#073b4c]')}`}>{title}</p>
        {subtitle && <p className="text-[10px] text-gray-500 uppercase tracking-widest font-bold">{subtitle}</p>}
      </div>
      <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" /></svg>
    </button>
  );

  const SubviewHeader = ({ title, onBack }: { title: string, onBack?: () => void }) => (
    <div className="flex items-center gap-4 mb-8">
      <button 
        onClick={onBack || (() => setSubView('main'))}
        className={`w-10 h-10 rounded-full flex items-center justify-center transition-all active:scale-90 ${isDark ? 'bg-white/5 text-white' : 'bg-[#073b4c]/5 text-[#073b4c]'}`}
      >
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" /></svg>
      </button>
      <h3 className="text-2xl font-serif">{title}</h3>
    </div>
  );

  return (
    <div className="min-h-screen pb-20 animate-in fade-in duration-500">
      {subView === 'main' ? (
        <div className="space-y-8">
          {/* Profile Header Card */}
          <div className={`p-6 rounded-[2.5rem] border relative overflow-hidden flex items-center gap-5 ${isDark ? 'bg-white/[0.03] border-white/10' : 'bg-white border-[#073b4c]/5 shadow-lg shadow-[#073b4c]/5'}`}>
            <div className="relative flex-none">
              <div className={`w-20 h-20 rounded-full overflow-hidden border-2 border-yellow-500/30 ${isDark ? 'bg-[#0b5168]' : 'bg-[#073b4c]/10'}`}>
                {data.avatarUrl ? (
                  <img src={data.avatarUrl} alt="User" className="w-full h-full object-cover" />
                ) : (
                  <div className={`w-full h-full flex items-center justify-center ${isDark ? 'text-gray-700' : 'text-[#073b4c]/30'}`}>
                    <svg className="w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                  </div>
                )}
              </div>
              <div className={`absolute -bottom-1 -right-1 w-6 h-6 bg-yellow-500 rounded-full border-2 flex items-center justify-center text-[10px] font-black text-[#073b4c] ${isDark ? 'border-[#073b4c]' : 'border-white'}`}>
                {identityProgress}%
              </div>
            </div>
            <div className="flex-1 min-w-0">
              <h2 className="text-xl font-serif truncate">{data.fullName || 'Career Architect'}</h2>
              <p className="text-[10px] text-gray-500 uppercase tracking-widest font-black truncate">{data.targetRole || 'Identity Not Synced'}</p>
              <div className="mt-2 h-1.5 w-full bg-gray-500/10 rounded-full overflow-hidden">
                <div className="h-full bg-yellow-500" style={{ width: `${identityProgress}%` }}></div>
              </div>
            </div>
          </div>

          {/* Settings Section: Identity */}
          <div className={`rounded-3xl border overflow-hidden ${isDark ? 'bg-white/[0.02] border-white/10' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
            <p className="px-5 pt-5 pb-2 text-[10px] font-black text-gray-500 uppercase tracking-[0.2em]">Personalization</p>
            <SettingRow 
              title="Identity Standard" 
              subtitle="Profile, Role, Contact" 
              icon="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" 
              onClick={() => setSubView('identity')}
            />
            <SettingRow 
              title="Career Vault" 
              subtitle={`${savedResumes.length} Narratives Indexed`} 
              icon="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" 
              onClick={() => setSubView('vault')}
            />
          </div>

          {/* Settings Section: Architecture Controls */}
          <div className={`rounded-3xl border overflow-hidden ${isDark ? 'bg-white/[0.02] border-white/10' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
            <p className="px-5 pt-5 pb-2 text-[10px] font-black text-gray-500 uppercase tracking-[0.2em]">Architecture Controls</p>
            <SettingRow 
              title="Interview Prep Protocol" 
              subtitle="Initialize Tactical Analysis" 
              icon="M9 12l2 2 4-4m5.618-4.016A3.323 3.323 0 0010.605 4.5c-1.107 0-2.139.37-2.964 1.016" 
              onClick={() => onNavigateTab('strategy')}
              color="text-yellow-600"
            />
            <SettingRow 
              title="Narrative Refinement" 
              subtitle="Synthesize with AI Architect" 
              icon="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" 
              onClick={() => onNavigateTab('chat')}
              color="text-yellow-600"
            />
          </div>

          {/* Settings Section: Global Settings */}
          <div className={`rounded-3xl border overflow-hidden ${isDark ? 'bg-white/[0.02] border-white/10' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
            <p className="px-5 pt-5 pb-2 text-[10px] font-black text-gray-500 uppercase tracking-[0.2em]">Preferences</p>
            <SettingRow 
              title="Concierge & Support" 
              subtitle="Inquiry Dispatch" 
              icon="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" 
              onClick={() => setSubView('concierge')}
            />
            <SettingRow 
              title="Legal Standard" 
              subtitle="Institutional Privacy Policy" 
              icon="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" 
              onClick={() => setSubView('privacy')}
            />
            <SettingRow 
              title="Appearance" 
              subtitle={mode === 'dark' ? 'Dark Mode Active' : 'Light Mode Active'} 
              icon="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707m12.728 0l-.707-.707M6.343 6.343l-.707-.707" 
              onClick={toggleMode}
            />
          </div>

          {/* Logout Section */}
          <div className={`rounded-3xl border overflow-hidden ${isDark ? 'bg-white/[0.02] border-white/10' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
            <SettingRow 
              title="Terminate Session" 
              icon="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" 
              destructive={true}
              onClick={onLogout}
            />
          </div>
          
          <div className="text-center py-6">
            <p className="text-[9px] text-gray-600 font-black uppercase tracking-[0.5em]">AI Resume Builder Professional Suite v2.0</p>
            <p className="text-[8px] text-gray-500 mt-1">End-to-End Career Architecture</p>
          </div>
        </div>
      ) : (
        <div className="animate-in slide-in-from-right-4 duration-500">
          {subView === 'identity' && (
            <div className="space-y-6">
              <SubviewHeader title="Identity Standard" />
              <div className="flex flex-col items-center gap-6 p-8 rounded-[2.5rem] border border-white/10 bg-white/5 mb-8">
                <div className="relative group">
                  <div className={`w-24 h-24 rounded-full overflow-hidden border-2 border-yellow-500/30 bg-[#073b4c] shadow-2xl`}>
                    {data.avatarUrl ? (
                      <img src={data.avatarUrl} alt="Avatar" className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-gray-600 bg-[#073b4c]">
                        <svg className="w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                      </div>
                    )}
                  </div>
                  {isProcessing && <div className="absolute inset-0 bg-[#073b4c]/50 flex items-center justify-center rounded-full"><div className="w-4 h-4 border-2 border-yellow-500 border-t-transparent rounded-full animate-spin"></div></div>}
                </div>
                <div className="flex gap-3">
                  <button onClick={onGenerateAvatar} disabled={isProcessing} className="px-5 py-2.5 bg-yellow-500 text-[#073b4c] rounded-full text-[9px] font-black uppercase tracking-widest active:scale-95 transition-all disabled:opacity-30">AI Headshot</button>
                  <button onClick={() => fileInputRef.current?.click()} disabled={isProcessing} className="px-5 py-2.5 bg-white/10 text-white border border-white/20 rounded-full text-[9px] font-black uppercase tracking-widest active:scale-95 transition-all">Upload</button>
                  <input type="file" ref={fileInputRef} onChange={handleAvatarUpload} accept="image/*" className="hidden" />
                </div>
              </div>
              <div className="space-y-4">
                {[
                  { label: 'Full Name', name: 'fullName', icon: 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z' },
                  { label: 'Target Role', name: 'targetRole', icon: 'M21 13.255A23.931 23.931 0 0112 15c-3.183 0-6.22-.62-9-1.745M16 6V4a2 2 0 00-2-2h-4a2 2 0 00-2 2v2m4 6h.01M5 20h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z' },
                  { label: 'Email', name: 'email', icon: 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z' },
                  { label: 'Phone', name: 'phone', icon: 'M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z' },
                  { label: 'Location', name: 'location', icon: 'M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0zM15 11a3 3 0 11-6 0 3 3 0 016 0z' },
                  { label: 'LinkedIn', name: 'linkedIn', icon: 'M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1' },
                  { label: 'Work Experience', name: 'workExperience', icon: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z' },
                  { label: 'Education', name: 'education', icon: 'M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14zm-4 6v-7.5l4-2.222' },
                  { label: 'Certifications', name: 'certifications', icon: 'M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138z' },
                  { label: 'Projects', name: 'projects', icon: 'M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4' },
                  { label: 'Languages', name: 'languages', icon: 'M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9' },
                  { label: 'Availability', name: 'availability', icon: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z' },
                ].map(field => (
                  <div key={field.name} className="flex items-center gap-4 px-6 py-4 rounded-2xl border border-white/5 bg-white/5">
                    <div className="w-8 h-8 rounded-full bg-gray-500/10 flex items-center justify-center text-gray-500 flex-none">
                      <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={field.icon} /></svg>
                    </div>
                    <div className="flex-1">
                      <label className="text-[7px] uppercase tracking-widest text-gray-500 font-black block">{field.label}</label>
                      <input name={field.name} value={(data as any)[field.name]} onChange={handleFieldChange} className="w-full bg-transparent text-sm focus:outline-none text-white font-medium" />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {subView === 'vault' && (
            <div className="space-y-6">
              <SubviewHeader title="Career Vault" />
              <div className="relative mb-6">
                <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none text-gray-500">
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
                </div>
                <input 
                  type="text" 
                  value={searchQuery} 
                  onChange={(e) => setSearchQuery(e.target.value)} 
                  placeholder="Search standards..." 
                  className={`w-full pl-12 pr-6 py-4 rounded-2xl border transition-all text-xs focus:outline-none ${isDark ? 'bg-white/5 border-white/10 text-white focus:border-yellow-500/50' : 'bg-white border-[#073b4c]/10 text-[#073b4c]'}`}
                />
              </div>
              <div className="space-y-4">
                {filteredResumes.map(resume => (
                  <div key={resume.id} className="p-6 rounded-3xl border border-white/10 bg-white/5 group hover:border-yellow-500/30 transition-all">
                    <div className="flex items-center justify-between mb-3">
                        <div className="flex-1 min-w-0">
                        <h4 className="text-sm font-serif truncate pr-4">{resume.name || 'Untitled'}</h4>
                        <p className="text-[9px] text-gray-400 font-black uppercase tracking-widest">{resume.versions.length} Iterations Logged</p>
                        </div>
                        <div className="flex gap-2">
                        <button onClick={() => onLoadResume(resume)} className="p-3 rounded-xl bg-white/5 text-gray-400 hover:text-white hover:bg-yellow-500/20 transition-all"><svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg></button>
                        <button onClick={() => { setActiveResumeId(resume.id); setSubView('history'); }} className="p-3 rounded-xl bg-white/5 text-gray-400 hover:text-white hover:bg-yellow-500/20 transition-all"><svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg></button>
                        <button onClick={() => onDeleteResume(resume.id)} className="p-3 rounded-xl bg-white/5 text-gray-400 hover:text-red-500 transition-all"><svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg></button>
                        </div>
                    </div>
                  </div>
                ))}
                {filteredResumes.length === 0 && (
                    <div className="py-20 text-center opacity-30 uppercase tracking-[0.4em] text-[10px]">Vault Empty</div>
                )}
              </div>
            </div>
          )}

          {subView === 'history' && (
            <div className="space-y-6">
              <SubviewHeader title="Iteration Browser" onBack={() => setSubView('vault')} />
              <div className="space-y-4">
                {activeResumeIterations.map((version, idx) => (
                  <div key={version.id} className="p-6 rounded-3xl border border-white/10 bg-white/5 flex items-center justify-between group hover:border-yellow-500/30 transition-all">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="w-4 h-4 rounded-full bg-yellow-500 text-[#073b4c] text-[8px] font-black flex items-center justify-center">
                            {activeResumeIterations.length - idx}
                        </span>
                        <h4 className="text-sm font-serif truncate pr-4">{version.theme} Snapshot</h4>
                      </div>
                      <p className="text-[9px] text-gray-400 font-black uppercase tracking-widest">{version.date}</p>
                    </div>
                    <div className="flex gap-2">
                      <button 
                        onClick={() => onLoadIteration(version, activeResumeId!)} 
                        className="px-4 py-2 rounded-xl bg-white/10 text-white text-[8px] font-black uppercase tracking-widest hover:bg-yellow-500 hover:text-[#073b4c] transition-all"
                      >
                        Revert
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {subView === 'concierge' && (
            <div className="space-y-6">
              <SubviewHeader title="Concierge" />
              <div className="p-8 rounded-[2.5rem] border border-white/10 bg-white/5 space-y-4">
                <h4 className="text-[10px] font-black uppercase tracking-widest text-yellow-600">Architect Privacy</h4>
                <p className="text-[11px] text-gray-400 leading-relaxed">Your professional history is stored locally. We do not maintain off-site narrative backups to ensure absolute career privacy.</p>
              </div>
              <button onClick={() => setShowContactForm(true)} className="w-full py-5 rounded-[2rem] border border-white/10 bg-white/5 text-[10px] font-black uppercase tracking-widest text-gray-400 active:bg-white/10 transition-all">Contact Career Concierge</button>
            </div>
          )}

          {subView === 'privacy' && (
            <PrivacyPolicy onBack={() => setSubView('main')} />
          )}
        </div>
      )}

      {showContactForm && (
        <div className="fixed inset-0 z-[100] bg-[#073b4c]/95 flex items-center justify-center p-6 backdrop-blur-sm">
           <div className="w-full max-w-sm glass p-8 rounded-3xl builder-border animate-in zoom-in-95 duration-300">
              <h3 className="text-xl font-serif mb-6 uppercase tracking-widest text-center">Contact Architect</h3>
              {contactStatus === 'sent' ? (
                <div className="py-10 text-center text-yellow-600 text-[10px] font-black uppercase tracking-widest">Instruction Received</div>
              ) : (
                <form onSubmit={handleContactSubmit} className="space-y-4">
                  <textarea required className="w-full h-32 bg-transparent border border-white/10 rounded-xl px-4 py-3 text-xs focus:outline-none text-white" placeholder="Describe your inquiry..." />
                  <button className="w-full py-4 rounded-xl font-black uppercase tracking-widest text-[9px] bg-white text-[#073b4c] active:scale-95 transition-all">Dispatch Inquiry</button>
                  <button type="button" onClick={() => setShowContactForm(false)} className="w-full py-2 text-[8px] text-gray-500 uppercase font-bold tracking-widest">Cancel</button>
                </form>
              )}
           </div>
        </div>
      )}
    </div>
  );
};

export default Profile;
