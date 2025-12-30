
import React, { useState, useRef } from 'react';
import { useTheme } from '../ThemeContext';
import { UploadedFile } from '../types';
import { suggestMetrics } from '../geminiService';

interface BlueprintDraftProps {
  history: string;
  setHistory: (val: string) => void;
  jobDescription: string;
  setJobDescription: (val: string) => void;
  onProcess: () => void;
  onFileUpload: (file: UploadedFile | null) => void;
  uploadedFile: UploadedFile | null;
  isProcessing: boolean;
}

const BlueprintDraft: React.FC<BlueprintDraftProps> = ({ 
  history, 
  setHistory, 
  jobDescription, 
  setJobDescription, 
  onProcess, 
  onFileUpload,
  uploadedFile,
  isProcessing 
}) => {
  const { mode } = useTheme();
  const [activeSegment, setActiveSegment] = useState<'history' | 'specs'>('history');
  const [quantificationResults, setQuantificationResults] = useState<{ vagues: string[], suggestions: string[], inferredSkills: string[] } | null>(null);
  const [isQuantifying, setIsQuantifying] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const isDark = mode === 'dark';
  
  const historyScore = Math.min((history.length + (uploadedFile ? 500 : 0)) / 200, 0.5);
  const specsScore = Math.min(jobDescription.length / 100, 0.5);
  const totalProgress = (historyScore + specsScore) * 100;

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = () => {
      const base64 = (reader.result as string).split(',')[1];
      onFileUpload({
        data: base64,
        mimeType: file.type,
        name: file.name
      });
    };
    reader.readAsDataURL(file);
  };

  const handleQuantify = async () => {
    if (!history.trim()) return;
    setIsQuantifying(true);
    try {
      const results = await suggestMetrics(history);
      setQuantificationResults(results);
    } catch (error) {
      console.error("Quantification failed", error);
    } finally {
      setIsQuantifying(false);
    }
  };

  return (
    <div className="space-y-10 animate-in fade-in slide-in-from-bottom-6 duration-500 pb-20">
      <header className="px-2">
        <h2 className="text-4xl font-serif mb-2 leading-tight">Career <span className="builder-gradient">Forge.</span></h2>
        <div className="flex items-center gap-3">
          <div className={`flex-1 h-1.5 rounded-full overflow-hidden ${isDark ? 'bg-white/5' : 'bg-[#073b4c]/10'}`}>
            <div 
              className="h-full bg-gradient-to-r from-yellow-600 to-yellow-300 transition-all duration-700 ease-out"
              style={{ width: `${totalProgress}%` }}
            ></div>
          </div>
          <span className={`text-[10px] font-black uppercase tracking-widest ${isDark ? 'text-yellow-500' : 'text-yellow-700'}`}>{Math.round(totalProgress)}% Synced</span>
        </div>
      </header>

      <div className={`relative flex p-1 rounded-full ${isDark ? 'bg-white/5 shadow-inner' : 'bg-[#073b4c]/5 shadow-inner'}`}>
        <div 
          className={`absolute top-1 bottom-1 w-[calc(50%-4px)] rounded-full transition-all duration-500 ease-spring ${activeSegment === 'history' ? 'left-1' : 'left-[50%]'} ${isDark ? 'bg-white shadow-xl' : 'bg-white shadow-lg'}`}
        />
        <button 
          onClick={() => setActiveSegment('history')}
          className={`relative z-10 flex-1 py-3.5 text-[10px] font-black uppercase tracking-[0.2em] transition-colors duration-300 ${activeSegment === 'history' ? 'text-[#073b4c]' : 'text-gray-500'}`}
        >
          Work History
        </button>
        <button 
          onClick={() => setActiveSegment('specs')}
          className={`relative z-10 flex-1 py-3.5 text-[10px] font-black uppercase tracking-[0.2em] transition-colors duration-300 ${activeSegment === 'specs' ? 'text-[#073b4c]' : 'text-gray-500'}`}
        >
          Target Spec
        </button>
      </div>

      <div className="relative">
        {activeSegment === 'history' ? (
          <div key="history" className="animate-in fade-in slide-in-from-left-6 duration-500 space-y-6">
            <div className={`p-8 rounded-[2.5rem] border transition-all ${isDark ? 'bg-white/[0.02] border-white/10 shadow-2xl' : 'bg-white border-[#073b4c]/5 shadow-[0_20px_60px_-20px_rgba(0,0,0,0.05)]'}`}>
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-4">
                  <div className={`w-10 h-10 rounded-2xl flex items-center justify-center rotate-3 ${isDark ? 'bg-yellow-500/10 text-yellow-600' : 'bg-yellow-50 text-yellow-700'}`}>
                    <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253" /></svg>
                  </div>
                  <div>
                    <h4 className="text-[11px] font-black uppercase tracking-[0.2em]">Career Legacy Data</h4>
                    <p className={`text-[9px] uppercase tracking-widest font-bold ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>Input raw history or upload profile.</p>
                  </div>
                </div>
                
                <input type="file" ref={fileInputRef} onChange={handleFileChange} accept=".pdf,.doc,.docx" className="hidden" />
                <button 
                  onClick={() => fileInputRef.current?.click()}
                  className={`px-4 py-2 rounded-xl border text-[9px] font-black uppercase tracking-widest transition-all ${isDark ? 'bg-white/5 border-white/10 text-gray-400 hover:text-yellow-500 hover:border-yellow-500/50' : 'bg-[#073b4c]/5 border-[#073b4c]/10 text-gray-600 hover:text-[#073b4c] hover:border-[#073b4c]'}`}
                >
                  Import File
                </button>
              </div>

              {uploadedFile && (
                <div className={`mb-4 flex items-center justify-between px-4 py-2 rounded-xl border animate-in zoom-in-95 duration-300 ${isDark ? 'bg-yellow-500/5 border-yellow-500/20' : 'bg-yellow-50 border-yellow-200 shadow-sm'}`}>
                  <div className="flex items-center gap-2 overflow-hidden">
                    <svg className="w-3 h-3 text-yellow-600 flex-none" fill="currentColor" viewBox="0 0 20 20"><path d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z"/></svg>
                    <span className="text-[9px] font-bold text-yellow-700 truncate">{uploadedFile.name} Attached</span>
                  </div>
                  <button onClick={() => onFileUpload(null)} className="text-yellow-700 opacity-50 hover:opacity-100 transition-opacity">
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" /></svg>
                  </button>
                </div>
              )}

              <textarea 
                value={history}
                onChange={(e) => setHistory(e.target.value)}
                placeholder={uploadedFile ? "Provide additional context or instructions for your profile..." : "Ex: Led engineering team at Tech Corp. Launched mobile app reaching 1M users..."}
                className={`w-full h-56 bg-transparent text-sm focus:outline-none resize-none leading-relaxed placeholder:text-gray-400 font-medium ${isDark ? 'text-gray-200' : 'text-[#073b4c]'}`}
              />
              <div className="mt-6 flex justify-between items-center border-t border-gray-500/10 pt-4">
                <button 
                  onClick={handleQuantify}
                  disabled={isQuantifying || !history.trim()}
                  className={`flex items-center gap-2 text-[9px] font-black uppercase tracking-widest transition-all ${isQuantifying ? 'opacity-50' : (isDark ? 'text-yellow-600 hover:text-yellow-400' : 'text-yellow-700 hover:text-black')}`}
                >
                  {isQuantifying ? (
                    <div className="w-3 h-3 border-2 border-yellow-600 border-t-transparent rounded-full animate-spin"></div>
                  ) : (
                    <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" /></svg>
                  )}
                  Audit Impact (XYZ)
                </button>
                <button 
                  onClick={() => setActiveSegment('specs')}
                  className={`text-[10px] font-black uppercase tracking-widest flex items-center gap-2 transition-transform hover:translate-x-1 ${isDark ? 'text-yellow-600' : 'text-yellow-700'}`}
                >
                  NEXT STAGE <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" /></svg>
                </button>
              </div>
            </div>

            {quantificationResults && (
              <div className="animate-in slide-in-from-bottom-4 duration-500 space-y-6">
                {/* Metrics Section */}
                <div>
                  <div className="flex items-center gap-2 mb-4">
                    <div className={`h-px flex-1 ${isDark ? 'bg-yellow-500/20' : 'bg-yellow-600/10'}`}></div>
                    <span className={`text-[10px] font-black uppercase tracking-widest ${isDark ? 'text-yellow-600' : 'text-yellow-700'}`}>Narrative Audit Results</span>
                    <div className={`h-px flex-1 ${isDark ? 'bg-yellow-500/20' : 'bg-yellow-600/10'}`}></div>
                  </div>
                  <div className="space-y-4">
                    {quantificationResults.vagues.map((vague, idx) => (
                      <div key={idx} className={`p-6 rounded-3xl border transition-all ${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
                        <div className="flex items-center gap-2 mb-3">
                          <span className={`text-[8px] font-black uppercase tracking-widest ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>Weak Point Detected:</span>
                          <p className={`text-[10px] italic flex-1 ${isDark ? 'text-gray-400' : 'text-gray-500'}`}>"{vague}"</p>
                        </div>
                        <div className={`flex items-start gap-3 mt-4 pt-4 border-t ${isDark ? 'border-white/5' : 'border-[#073b4c]/5'}`}>
                          <div className={`w-7 h-7 rounded-full flex items-center justify-center flex-none shadow-sm ${isDark ? 'bg-yellow-600 text-[#073b4c]' : 'bg-[#073b4c] text-white'}`}>
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" /></svg>
                          </div>
                          <div>
                            <p className={`text-[9px] font-black uppercase tracking-widest mb-1 ${isDark ? 'text-yellow-600' : 'text-yellow-700'}`}>Institutional XYZ Correction:</p>
                            <p className={`text-xs font-semibold leading-relaxed ${isDark ? 'text-white' : 'text-[#073b4c]'}`}>{quantificationResults.suggestions[idx]}</p>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Skills Inference Section */}
                <div>
                   <div className="flex items-center gap-2 mb-4">
                    <div className={`h-px flex-1 ${isDark ? 'bg-yellow-500/20' : 'bg-yellow-600/10'}`}></div>
                    <span className={`text-[10px] font-black uppercase tracking-widest ${isDark ? 'text-yellow-600' : 'text-yellow-700'}`}>Inferred Core Expertise</span>
                    <div className={`h-px flex-1 ${isDark ? 'bg-yellow-500/20' : 'bg-yellow-600/10'}`}></div>
                  </div>
                  <div className={`p-6 rounded-3xl border ${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
                    <p className={`text-[9px] font-black uppercase tracking-[0.2em] mb-4 ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>The architect has extrapolated these high-impact skills based on your legacy narrative:</p>
                    <div className="flex flex-wrap gap-2">
                      {quantificationResults.inferredSkills.map((skill, idx) => (
                        <span key={idx} className={`px-3 py-1.5 rounded-xl border text-[9px] font-black uppercase tracking-widest transition-all ${isDark ? 'bg-yellow-500/10 border-yellow-500/30 text-yellow-500' : 'bg-yellow-50 border-yellow-200 text-yellow-700'}`}>
                          {skill}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>

                <button 
                  onClick={() => setQuantificationResults(null)}
                  className={`w-full text-[8px] uppercase font-black tracking-widest transition-colors py-4 ${isDark ? 'text-gray-500 hover:text-white' : 'text-gray-400 hover:text-black'}`}
                >
                  Dismiss Narrative Recommendations
                </button>
              </div>
            )}
          </div>
        ) : (
          <div key="specs" className="animate-in fade-in slide-in-from-right-6 duration-500">
            <div className={`p-8 rounded-[2.5rem] border transition-all ${isDark ? 'bg-white/[0.02] border-white/10 shadow-2xl' : 'bg-white border-[#073b4c]/5 shadow-[0_20px_60px_-20px_rgba(0,0,0,0.05)]'}`}>
              <div className="flex items-center gap-4 mb-6">
                <div className={`w-10 h-10 rounded-2xl flex items-center justify-center -rotate-3 ${isDark ? 'bg-yellow-500/10 text-yellow-600' : 'bg-yellow-50 text-yellow-700'}`}>
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
                </div>
                <div>
                  <h4 className="text-[11px] font-black uppercase tracking-[0.2em]">Opportunity Specs</h4>
                  <p className={`text-[9px] uppercase tracking-widest font-bold ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>Keyword synchronization mapping.</p>
                </div>
              </div>
              <textarea 
                value={jobDescription}
                onChange={(e) => setJobDescription(e.target.value)}
                placeholder="Paste the Job Description or key requirements here to enable precise ATS alignment..."
                className={`w-full h-64 bg-transparent text-sm focus:outline-none resize-none leading-relaxed placeholder:text-gray-400 font-medium ${isDark ? 'text-gray-200' : 'text-[#073b4c]'}`}
              />
              <div className="mt-6 flex justify-between items-center border-t border-gray-500/10 pt-4">
                <span className={`text-[9px] font-black uppercase tracking-widest ${isDark ? 'text-gray-400' : 'text-gray-500'}`}>{jobDescription.length} CHARS</span>
                <button 
                  onClick={() => setActiveSegment('history')}
                  className={`text-[10px] font-black uppercase tracking-widest flex items-center gap-2 transition-transform hover:-translate-x-1 ${isDark ? 'text-gray-500 hover:text-white' : 'text-gray-400 hover:text-black'}`}
                >
                  <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" /></svg> BACK TO HISTORY
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      <div className={`fixed bottom-28 left-1/2 -translate-x-1/2 w-full max-w-sm px-6 z-40 transition-all duration-700 ${isProcessing ? 'opacity-30 pointer-events-none translate-y-8' : 'opacity-100 translate-y-0'}`}>
        <button 
          onClick={onProcess}
          disabled={!history.trim() && !uploadedFile}
          className={`w-full py-5 rounded-[2rem] font-black uppercase tracking-[0.4em] text-[10px] shadow-2xl transition-all active:scale-[0.98] ${
            isDark 
              ? 'bg-white text-[#073b4c] hover:bg-yellow-500 hover:shadow-yellow-500/20' 
              : 'bg-[#073b4c] text-white hover:bg-yellow-600 hover:shadow-[#073b4c]/30'
          } disabled:opacity-20`}
        >
          {isProcessing ? "Synthesizing Architecturally..." : "Build Resume"}
        </button>
      </div>

      <div className="grid grid-cols-2 gap-4 px-2 pb-10">
        <div className={`p-5 rounded-3xl border transition-all ${isDark ? 'bg-white/5 border-white/5' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
          <div className="w-6 h-6 rounded-full bg-yellow-500/10 flex items-center justify-center text-yellow-600 mb-3">
            <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" /></svg>
          </div>
          <p className="text-[8px] font-black text-yellow-600 uppercase tracking-widest mb-1">Impact First</p>
          <p className={`text-[10px] leading-tight ${isDark ? 'text-gray-500' : 'text-gray-600'}`}>Quantitative data leads to 3x higher interview rates.</p>
        </div>
        <div className={`p-5 rounded-3xl border transition-all ${isDark ? 'bg-white/5 border-white/5' : 'bg-white border-[#073b4c]/5 shadow-sm'}`}>
          <div className="w-6 h-6 rounded-full bg-yellow-500/10 flex items-center justify-center text-yellow-600 mb-3">
            <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 12l2 2 4-4m5.618-4.016A3.323 3.323 0 0010.605 4.5c-1.107 0-2.139.37-2.964 1.016" /></svg>
          </div>
          <p className="text-[8px] font-black text-yellow-600 uppercase tracking-widest mb-1">ATS Ready</p>
          <p className={`text-[10px] leading-tight ${isDark ? 'text-gray-500' : 'text-gray-600'}`}>Synchronizing inputs with 500+ industry algorithms.</p>
        </div>
      </div>
    </div>
  );
};

export default BlueprintDraft;
