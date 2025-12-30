
import React from 'react';
import { InterviewQuestion } from '../types';
import { useTheme } from '../ThemeContext';

interface InterviewPrepProps {
  questions: InterviewQuestion[] | null;
  onGenerate: () => void;
  isProcessing: boolean;
  hasResume: boolean;
  onBackToDash: () => void;
}

const InterviewPrep: React.FC<InterviewPrepProps> = ({ questions, onGenerate, isProcessing, hasResume, onBackToDash }) => {
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  if (isProcessing) {
    return (
      <div className="flex flex-col items-center justify-center py-40 animate-pulse">
        <div className="w-16 h-16 rounded-full border-4 border-yellow-500/20 border-t-yellow-600 animate-spin mb-6"></div>
        <p className="text-[10px] font-black uppercase tracking-[0.4em] text-yellow-600">Architecting Tactical Strategy...</p>
      </div>
    );
  }

  if (!questions || questions.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-20 px-6 text-center animate-in fade-in zoom-in-95 duration-1000">
        <div className={`w-24 h-24 rounded-[2rem] flex items-center justify-center mb-10 shadow-2xl ${isDark ? 'bg-white/5 builder-border' : 'bg-gray-100 border border-black/5'}`}>
          <svg className="w-10 h-10 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12l2 2 4-4m5.618-4.016A3.323 3.323 0 0010.605 4.5c-1.107 0-2.139.37-2.964 1.016" /></svg>
        </div>
        <h3 className="text-2xl font-serif mb-4 uppercase tracking-widest">Tactical Analysis Offline</h3>
        <p className={`text-xs leading-relaxed max-w-[280px] mb-12 font-medium ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>
          {hasResume 
            ? "Your professional blueprint is synchronized, but the interview strategy engine has not been initialized." 
            : "A career legacy blueprint is required before strategy analysis can be engineered."}
        </p>
        
        <div className="flex flex-col gap-4 w-full max-w-[240px]">
          {hasResume ? (
            <button 
              onClick={onGenerate}
              className={`w-full py-5 rounded-2xl font-black uppercase tracking-[0.3em] text-[10px] transition-all active:scale-95 shadow-2xl ${isDark ? 'bg-white text-black hover:bg-yellow-500' : 'bg-black text-white'}`}
            >
              Initialize Analysis
            </button>
          ) : (
            <p className="text-[9px] font-black uppercase tracking-widest text-yellow-600 italic mb-4">Navigate to 'Build' to forge your blueprint.</p>
          )}
          <button 
            onClick={onBackToDash}
            className={`w-full py-3 rounded-xl text-[9px] font-black uppercase tracking-widest border transition-all ${isDark ? 'border-white/10 text-gray-500 hover:text-white' : 'border-black/5 text-gray-400 hover:text-black'}`}
          >
            Return to Dash
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 mt-4 animate-in fade-in slide-in-from-bottom-8 duration-700 pb-20">
      <header className="mb-10 text-center relative">
        <button 
          onClick={onBackToDash}
          className={`absolute left-0 top-1/2 -translate-y-1/2 w-9 h-9 rounded-full flex items-center justify-center transition-all active:scale-90 ${isDark ? 'bg-white/5 text-white' : 'bg-[#073b4c]/5 text-[#073b4c]'}`}
        >
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" /></svg>
        </button>
        <span className="text-[9px] font-black text-yellow-600 uppercase tracking-[0.5em] mb-3 block">Tactical Readiness Protocol</span>
        <h3 className={`text-3xl font-serif uppercase tracking-widest ${isDark ? 'text-white' : 'text-black'}`}>Strategy Blueprint</h3>
      </header>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {questions.map((q, idx) => (
          <div key={idx} className={`glass p-8 rounded-[2.5rem] transition-all group border shadow-sm ${isDark ? 'builder-border hover:bg-white/5' : 'border-black/5 bg-white hover:shadow-2xl hover:shadow-black/5'}`}>
            <div className="flex justify-between items-start mb-4">
              <span className={`text-[10px] font-black tracking-widest uppercase ${isDark ? 'text-yellow-600' : 'text-yellow-700'}`}>Scenario 0{idx + 1}</span>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center ${isDark ? 'bg-white/5' : 'bg-gray-100'}`}>
                <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
              </div>
            </div>
            
            <h4 className={`text-sm md:text-base font-bold mb-6 transition-colors leading-relaxed ${isDark ? 'text-white group-hover:text-yellow-200' : 'text-black group-hover:text-yellow-700'}`}>
              "{q.question}"
            </h4>
            
            <div className={`space-y-5 pt-6 border-t ${isDark ? 'border-white/10' : 'border-black/5'}`}>
              <div>
                <p className={`text-[9px] uppercase tracking-widest font-black mb-1.5 ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>Interviewer Intent</p>
                <p className={`text-[11px] leading-relaxed italic ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>{q.intent}</p>
              </div>
              <div className={`p-4 rounded-2xl ${isDark ? 'bg-yellow-500/5' : 'bg-yellow-50 border border-yellow-100'}`}>
                <p className="text-[9px] uppercase tracking-widest text-yellow-600 font-black mb-1.5">Executive Response Vector</p>
                <p className={`text-[11px] leading-relaxed font-bold ${isDark ? 'text-gray-200' : 'text-yellow-900'}`}>{q.suggestedAngle}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
      
      <div className="mt-12 text-center flex flex-col items-center gap-4">
        <button 
          onClick={onGenerate}
          className={`px-8 py-3 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all ${isDark ? 'text-gray-500 hover:text-white border border-white/10' : 'text-gray-400 hover:text-black border border-black/5'}`}
        >
          Re-Synthesize Strategy
        </button>
        <button 
          onClick={onBackToDash}
          className={`text-[9px] font-black uppercase tracking-widest transition-colors ${isDark ? 'text-gray-500 hover:text-yellow-600' : 'text-gray-400 hover:text-[#073b4c]'}`}
        >
          Return to Institutional Dashboard
        </button>
      </div>
    </div>
  );
};

export default InterviewPrep;
