
import React, { useState } from 'react';
import { ResumeData, ResumeTheme } from '../types';
import { useTheme } from '../ThemeContext';

interface ResumePreviewProps {
  data: ResumeData;
  onExport: () => void;
  onSave: () => void;
  onSyncVault: () => void;
  theme: ResumeTheme;
  onAchievementClick: (expIdx: number, achIdx: number, text: string, role: string) => void;
}

const ResumePreview: React.FC<ResumePreviewProps> = ({ data, onExport, onSave, onSyncVault, theme, onAchievementClick }) => {
  const { mode } = useTheme();
  const [isShareModalOpen, setIsShareModalOpen] = useState(false);
  const [copyStatus, setCopyStatus] = useState<'idle' | 'copied'>('idle');
  
  const getThemeStyles = () => {
    switch (theme) {
      case "Minimalist":
        return {
          container: "bg-white text-gray-900 p-6 sm:p-8 md:p-12 border border-gray-100 font-sans",
          header: "flex flex-col items-center mb-8 md:mb-10 text-center",
          h1: "text-xl sm:text-2xl md:text-3xl font-light tracking-[0.2em] uppercase mb-1",
          h2: "text-[9px] sm:text-[10px] font-bold uppercase tracking-[0.3em] text-gray-400 mb-6 border-b pb-2",
          itemTitle: "font-semibold text-gray-900",
          avatar: "w-16 h-16 sm:w-20 sm:h-20 rounded-full border border-gray-100 mb-4 grayscale",
          timelineTrack: "bg-gray-100",
          timelineNode: "bg-gray-300"
        };
      case "Creative Nomad":
        return {
          container: "bg-[#fcfaf7] text-[#2c241d] p-6 sm:p-8 md:p-10 font-mono border-l-[6px] sm:border-l-[8px] md:border-l-[12px] border-[#d4af37]",
          header: "flex flex-col sm:flex-row items-center sm:items-start gap-4 sm:gap-6 mb-8",
          h1: "text-2xl sm:text-3xl md:text-4xl font-bold tracking-tighter mb-1 text-center sm:text-left",
          h2: "text-[9px] sm:text-[10px] font-bold uppercase tracking-widest text-white mb-4 bg-[#2c241d] px-3 py-1.5 inline-block",
          itemTitle: "font-bold text-[#2c241d]",
          avatar: "w-20 h-20 sm:w-24 sm:h-24 rounded-2xl border-4 border-[#d4af37] rotate-3",
          timelineTrack: "bg-[#d4af37]",
          timelineNode: "bg-[#2c241d]"
        };
      case "Modernist":
        return {
          container: "bg-white text-gray-900 p-6 sm:p-8 md:p-12 font-sans border-t-[8px] md:border-t-[10px] border-blue-900",
          header: "flex flex-col sm:flex-row justify-between items-center gap-4 mb-10 md:mb-12",
          h1: "text-2xl sm:text-3xl font-black tracking-tight mb-0",
          h2: "text-[10px] sm:text-xs font-black uppercase text-blue-900 mb-6 flex items-center gap-2 after:content-[''] after:flex-1 after:h-px after:bg-gray-200",
          itemTitle: "font-bold text-blue-900",
          avatar: "w-16 h-16 sm:w-20 sm:h-20 rounded-xl border-2 border-blue-900",
          timelineTrack: "bg-blue-900",
          timelineNode: "bg-blue-900"
        };
      case "Silicon Valley":
        return {
          container: "bg-[#0a0a0a] text-white p-6 sm:p-8 md:p-12 font-sans border-t border-green-500",
          header: "mb-10 md:mb-12 text-center sm:text-left",
          h1: "text-3xl sm:text-4xl font-black text-transparent bg-clip-text bg-gradient-to-r from-green-400 to-blue-500 mb-2",
          h2: "text-[9px] sm:text-[10px] font-black uppercase tracking-[0.4em] text-green-500 mb-6 opacity-60",
          itemTitle: "font-bold text-green-400",
          avatar: "w-20 h-20 sm:w-24 sm:h-24 rounded-full border-2 border-green-500 p-1 shadow-[0_0_15px_rgba(34,197,94,0.3)] mx-auto sm:mx-0 mb-4",
          timelineTrack: "bg-green-500",
          timelineNode: "bg-green-500"
        };
      case "Academic":
        return {
          container: "bg-white text-gray-800 p-8 sm:p-10 md:p-14 font-serif border border-gray-200",
          header: "text-center mb-10 md:mb-12 border-b-2 border-gray-800 pb-6",
          h1: "text-2xl sm:text-3xl font-bold mb-1",
          h2: "text-xs sm:text-sm font-bold uppercase tracking-widest text-gray-800 mb-8 text-center",
          itemTitle: "font-bold text-gray-900",
          avatar: "w-16 h-16 sm:w-20 sm:h-20 rounded-full mx-auto mb-4 border border-gray-300",
          timelineTrack: "bg-gray-300",
          timelineNode: "bg-gray-800"
        };
      case "Royal High-End":
        return {
          container: "bg-[#111] text-[#f5f5f5] p-8 sm:p-12 md:p-16 border-[8px] sm:border-[12px] border-double border-[#d4af37] font-serif",
          header: "flex flex-col items-center mb-12 md:mb-16 text-center",
          h1: "text-3xl sm:text-4xl font-black uppercase tracking-[0.2em] sm:tracking-[0.3em] text-[#d4af37] mb-2",
          h2: "text-[9px] sm:text-[11px] font-bold uppercase tracking-[0.3em] sm:tracking-[0.5em] text-[#d4af37] mb-10",
          itemTitle: "font-bold text-[#d4af37] text-lg sm:text-xl",
          avatar: "w-24 h-24 sm:w-32 sm:h-32 rounded-full border-2 border-[#d4af37] mb-8 shadow-[0_0_30px_rgba(212,175,55,0.2)]",
          timelineTrack: "bg-[#d4af37]",
          timelineNode: "bg-[#d4af37]"
        };
      default: // Executive
        return {
          container: "bg-white text-black p-6 sm:p-8 md:p-12 font-sans",
          header: "flex flex-col sm:flex-row items-center sm:items-center gap-6 sm:gap-8 border-b-[2px] sm:border-b-[3px] border-black pb-8 mb-8 text-center sm:text-left",
          h1: "text-3xl sm:text-4xl md:text-5xl font-serif font-bold uppercase tracking-tight mb-2 text-black",
          h2: "text-[10px] sm:text-xs font-bold uppercase tracking-[0.2em] text-gray-500 mb-6 border-b border-gray-200 pb-2",
          itemTitle: "font-bold text-gray-900 text-sm sm:text-base md:text-lg",
          avatar: "w-20 h-20 sm:w-28 sm:h-28 rounded-full border-[2px] sm:border-[3px] border-black shadow-xl",
          timelineTrack: "bg-black",
          timelineNode: "bg-black"
        };
    }
  };

  const generateShareLink = () => {
    const payload = btoa(JSON.stringify({ 
      n: data.fullName, 
      r: data.targetRole, 
      t: theme,
      s: Date.now() 
    }));
    return `${window.location.origin}${window.location.pathname}?blueprint=${payload}`;
  };

  const handleCopy = () => {
    navigator.clipboard.writeText(generateShareLink());
    setCopyStatus('copied');
    setTimeout(() => setCopyStatus('idle'), 2000);
  };

  const s = getThemeStyles();
  const isDark = mode === 'dark';

  return (
    <div className="flex flex-col gap-8 pb-32 animate-in fade-in duration-700">
      {/* Share Modal */}
      {isShareModalOpen && (
        <div className="fixed inset-0 z-[120] flex items-center justify-center p-6 bg-[#073b4c]/95 backdrop-blur-xl animate-in fade-in duration-300">
          <div className={`w-full max-w-sm glass p-8 rounded-[2.5rem] border animate-in zoom-in-95 duration-300 ${isDark ? 'builder-border' : 'bg-white border-black/10'}`}>
            <div className="flex flex-col items-center mb-8">
              <div className="w-16 h-16 bg-yellow-500/10 rounded-[2rem] flex items-center justify-center mb-4">
                <svg className="w-8 h-8 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" /></svg>
              </div>
              <h3 className="text-xl font-serif uppercase tracking-widest text-center">Institutional Share</h3>
              <p className="text-[9px] font-black uppercase tracking-widest text-gray-500 mt-2">Generate Strategic Distribution Link</p>
            </div>

            <div className="space-y-4">
              <div className={`p-4 rounded-2xl border flex items-center gap-3 ${isDark ? 'bg-white/5 border-white/10' : 'bg-gray-50 border-black/5'}`}>
                <input 
                  readOnly 
                  value={generateShareLink()} 
                  className="bg-transparent text-[10px] font-mono text-gray-500 w-full focus:outline-none"
                />
                <button 
                  onClick={handleCopy}
                  className={`p-2 rounded-xl transition-all ${copyStatus === 'copied' ? 'bg-green-500 text-white' : (isDark ? 'bg-white/10 text-white' : 'bg-[#073b4c] text-white')}`}
                >
                  {copyStatus === 'copied' ? (
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" /></svg>
                  ) : (
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3" /></svg>
                  )}
                </button>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <a 
                  href={`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(generateShareLink())}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className={`py-3 rounded-xl flex items-center justify-center gap-2 text-[9px] font-black uppercase tracking-widest transition-all ${isDark ? 'bg-white/5 border border-white/10 text-white' : 'bg-blue-50 border border-blue-100 text-blue-700'}`}
                >
                  LinkedIn
                </a>
                <a 
                  href={`https://wa.me/?text=${encodeURIComponent(`Check out my professional narrative: ${generateShareLink()}`)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className={`py-3 rounded-xl flex items-center justify-center gap-2 text-[9px] font-black uppercase tracking-widest transition-all ${isDark ? 'bg-white/5 border border-white/10 text-white' : 'bg-green-50 border border-green-100 text-green-700'}`}
                >
                  WhatsApp
                </a>
              </div>

              <button 
                onClick={() => setIsShareModalOpen(false)}
                className="w-full text-[9px] text-gray-500 uppercase font-black tracking-widest pt-4"
              >
                Close Distribution Protocol
              </button>
            </div>
          </div>
        </div>
      )}

      <div className={`sm:rounded-[2.5rem] overflow-hidden border transition-all duration-500 ${isDark ? 'border-white/10 shadow-2xl' : 'border-black/5 shadow-[0_30px_100px_-30px_rgba(0,0,0,0.15)]'}`}>
        <div id="resume-document" className={`${s.container} min-h-[600px] sm:min-h-[800px] w-full max-w-4xl mx-auto leading-relaxed relative`}>
          <header className={s.header}>
            {data.avatarUrl && (
              <img src={data.avatarUrl} alt="Executive Avatar" className={s.avatar} />
            )}
            <div className={theme === 'Minimalist' || theme === 'Academic' || theme === 'Royal High-End' ? 'w-full' : 'flex-1 min-w-0'}>
              <h1 className={s.h1}>{data.fullName}</h1>
              <p className={`text-sm sm:text-base md:text-xl font-medium tracking-wide truncate ${theme === 'Silicon Valley' || theme === 'Royal High-End' ? 'text-gray-400' : 'text-gray-600'}`}>{data.targetRole}</p>
            </div>
          </header>

          <section className="mb-8 sm:mb-10">
            <h2 className={s.h2}>Professional Profile</h2>
            <p className={`text-[11px] sm:text-xs md:text-sm leading-relaxed font-medium ${theme === 'Silicon Valley' || theme === 'Royal High-End' ? 'text-gray-300' : 'text-gray-700'}`}>{data.summary}</p>
          </section>

          <section className="mb-8 sm:mb-10">
            <h2 className={s.h2}>Experience Narrative</h2>
            <div className="relative">
              {data.experiences.map((exp, idx) => (
                <div key={idx} className="mb-6 sm:mb-8 last:mb-0 relative pl-6 sm:pl-8">
                  <div className={`absolute left-0 top-0 bottom-0 w-px ${s.timelineTrack} opacity-30`}></div>
                  <div className={`absolute left-[-2px] sm:left-[-3px] top-1.5 w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full ${s.timelineNode}`}></div>
                  
                  <div className="flex flex-col sm:flex-row sm:justify-between items-start sm:items-baseline mb-1">
                    <h3 className={`${s.itemTitle} truncate w-full sm:w-auto`}>{exp.company}</h3>
                    <span className="text-[8px] sm:text-[9px] font-bold text-gray-400 uppercase tracking-widest">{exp.period}</span>
                  </div>
                  <p className={`text-[9px] sm:text-[10px] md:text-xs font-bold italic mb-3 sm:mb-4 ${theme === 'Silicon Valley' ? 'text-green-600' : 'text-gray-500'}`}>{exp.role}</p>
                  <div className="space-y-2 sm:space-y-3">
                    {exp.achievements.map((ach, aIdx) => (
                      <div 
                        key={aIdx} 
                        onClick={() => onAchievementClick(idx, aIdx, ach, exp.role)}
                        className={`group relative flex items-start gap-2 sm:gap-3 p-2 sm:p-3 rounded-xl sm:rounded-2xl transition-all cursor-pointer border ${
                          theme === 'Silicon Valley' || theme === 'Royal High-End' 
                            ? 'bg-white/5 border-white/5 hover:bg-white/10' 
                            : 'bg-gray-50 border-gray-100 hover:bg-yellow-50'
                        }`}
                      >
                        <div className={`mt-1.5 w-1.5 h-1.5 rounded-full flex-none ${theme === 'Silicon Valley' ? 'bg-green-500' : 'bg-yellow-600'}`}></div>
                        <p className={`text-[10px] sm:text-[11px] md:text-xs leading-relaxed font-medium ${theme === 'Silicon Valley' || theme === 'Royal High-End' ? 'text-gray-300' : 'text-gray-700'}`}>{ach}</p>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </section>

          <section>
            <h2 className={s.h2}>Core Expertise</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 sm:gap-6">
              {data.skills.map((skillGroup, idx) => (
                <div key={idx} className={`p-3 sm:p-4 rounded-xl sm:rounded-2xl border ${theme === 'Silicon Valley' || theme === 'Royal High-End' ? 'bg-white/5 border-white/5' : 'bg-gray-50 border-gray-100'}`}>
                  <h3 className="text-[8px] sm:text-[9px] font-bold uppercase tracking-widest mb-2 sm:mb-3 text-gray-400">{skillGroup.category}</h3>
                  <div className="flex flex-wrap gap-1 sm:gap-1.5">
                    {skillGroup.skills.map((skill, sIdx) => (
                      <span key={sIdx} className={`text-[8px] sm:text-[9px] font-bold px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-lg shadow-sm border ${
                        theme === 'Silicon Valley' 
                          ? 'bg-black border-green-500/30 text-green-400' 
                          : 'bg-white border-gray-200 text-gray-600'
                      }`}>{skill}</span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </section>
        </div>
      </div>

      <div className="fixed bottom-28 left-1/2 -translate-x-1/2 w-full max-w-sm px-6 z-40 animate-in slide-in-from-bottom-8 duration-500">
        <div className={`glass p-2 sm:p-2.5 rounded-2xl sm:rounded-3xl flex items-center justify-between border shadow-2xl ${isDark ? 'border-white/10' : 'border-black/5 shadow-black/10'}`}>
          <div className="pl-3 sm:pl-4 flex-1">
             <p className="text-[6px] sm:text-[7px] uppercase tracking-[0.2em] text-gray-400 font-black">Architecture Synthesis</p>
             <p className={`text-[8px] sm:text-[9px] font-black uppercase tracking-widest text-yellow-600 truncate max-w-[80px] sm:max-w-none`}>{theme} Standard</p>
          </div>
          <div className="flex gap-1 sm:gap-1.5">
            <button 
              onClick={() => setIsShareModalOpen(true)}
              className={`px-2.5 sm:px-4 py-3 sm:py-3.5 rounded-xl font-black uppercase tracking-[0.1em] text-[8px] sm:text-[9px] transition-all active:scale-95 border ${isDark ? 'bg-white/5 border-white/10 text-white hover:bg-white/10' : 'bg-white border-black/10 text-black hover:bg-gray-50'}`}
            >
              Share
            </button>
            <button 
              onClick={onSyncVault}
              className={`px-2.5 sm:px-4 py-3 sm:py-3.5 rounded-xl font-black uppercase tracking-[0.1em] text-[8px] sm:text-[9px] transition-all active:scale-95 border ${isDark ? 'bg-yellow-500/10 border-yellow-500/20 text-yellow-500 hover:bg-yellow-500/20' : 'bg-yellow-50 border-yellow-200 text-yellow-700 hover:bg-yellow-100'}`}
            >
              Apply & Save
            </button>
            <button 
              onClick={onExport}
              className={`px-4 sm:px-6 py-3 sm:py-3.5 rounded-xl font-black uppercase tracking-[0.1em] text-[8px] sm:text-[9px] flex items-center gap-1.5 sm:gap-2 transition-all active:scale-95 shadow-xl ${isDark ? 'bg-white text-black hover:bg-yellow-500' : 'bg-black text-white'}`}
            >
              Export
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ResumePreview;
