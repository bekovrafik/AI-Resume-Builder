
import React from 'react';
import { ResumeTheme } from '../types';
import { useTheme } from '../ThemeContext';

interface StyleGalleryProps {
  currentTheme: ResumeTheme;
  onThemeSelect: (theme: ResumeTheme, isLocked: boolean) => void;
}

interface ThemeMeta {
  id: ResumeTheme;
  name: string;
  description: string;
  isFree: boolean;
}

const StyleGallery: React.FC<StyleGalleryProps> = ({ currentTheme, onThemeSelect }) => {
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  const themes: ThemeMeta[] = [
    { id: "Executive", name: "The Executive", description: "High-authority serif standard.", isFree: true },
    { id: "Minimalist", name: "The Minimalist", description: "Ultra-modern focus on whitespace.", isFree: true },
    { id: "Creative Nomad", name: "The Creative Nomad", description: "Bold asymmetrical blueprint.", isFree: true },
    { id: "Modernist", name: "The Modernist", description: "Clean sans-serif tech standard.", isFree: true },
    { id: "Silicon Valley", name: "Silicon Valley", description: "Disruptor aesthetic with tech accents.", isFree: false },
    { id: "Academic", name: "The Academic", description: "Institutional rigor & density.", isFree: false },
    { id: "Royal High-End", name: "Royal High-End", description: "Luxury brand executive narrative.", isFree: false },
  ];

  const ThemePreview = ({ id }: { id: ResumeTheme }) => {
    switch (id) {
      case "Executive":
        return (
          <div className="w-full h-12 flex flex-col gap-1 p-2 bg-white rounded shadow-inner">
            <div className="w-full h-2 bg-black rounded-sm mb-1" />
            <div className="w-1/2 h-1 bg-gray-200" />
            <div className="w-full h-1 bg-gray-100" />
          </div>
        );
      case "Minimalist":
        return (
          <div className="w-full h-12 flex flex-col items-center gap-1 p-2 bg-white rounded shadow-inner">
            <div className="w-4 h-4 rounded-full bg-gray-200 mb-1" />
            <div className="w-12 h-1 bg-gray-300" />
            <div className="w-full h-1 bg-gray-100" />
          </div>
        );
      case "Creative Nomad":
        return (
          <div className="w-full h-12 flex gap-1 p-2 bg-[#FCFAF7] rounded shadow-inner border-l-4 border-[#D4AF37]">
            <div className="flex-1 flex flex-col gap-1">
              <div className="w-3/4 h-2 bg-[#2C241D]" />
              <div className="w-full h-1 bg-gray-200" />
            </div>
            <div className="w-4 h-4 rounded-sm bg-[#D4AF37] rotate-6" />
          </div>
        );
      case "Modernist":
        return (
          <div className="w-full h-12 flex flex-col gap-1 p-2 bg-white rounded shadow-inner">
            <div className="w-full h-3 bg-blue-900 rounded-sm mb-1" />
            <div className="w-full h-1 bg-gray-100" />
            <div className="w-full h-1 bg-gray-100" />
          </div>
        );
      case "Silicon Valley":
        return (
          <div className="w-full h-12 flex flex-col gap-1 p-2 bg-[#0a0a0a] rounded shadow-inner border-t-2 border-green-500">
            <div className="w-1/2 h-2 bg-green-500/20 rounded-sm mb-1" />
            <div className="w-full h-1 bg-white/10" />
            <div className="w-full h-1 bg-white/10" />
          </div>
        );
      case "Academic":
        return (
          <div className="w-full h-12 flex flex-col gap-0.5 p-2 bg-white rounded shadow-inner border border-gray-100">
            <div className="w-full h-1 bg-gray-800" />
            <div className="w-full h-1 bg-gray-800" />
            <div className="w-full h-1 bg-gray-800" />
            <div className="w-full h-1 bg-gray-800" />
          </div>
        );
      case "Royal High-End":
        return (
          <div className="w-full h-12 flex flex-col items-center justify-center p-2 bg-[#1a1a1a] rounded shadow-inner border-double border-4 border-[#d4af37]">
            <div className="w-8 h-1 bg-[#d4af37] mb-1" />
            <div className="w-4 h-1 bg-[#d4af37]" />
          </div>
        );
      default:
        return null;
    }
  };

  return (
    <div className={`p-6 glass rounded-3xl mb-8 border transition-all ${isDark ? 'builder-border' : 'border-[#073b4c]/10 bg-white shadow-lg shadow-[#073b4c]/5'}`}>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-yellow-600 mb-1">Architectural Gallery</h4>
          <p className={`text-[9px] font-bold uppercase tracking-widest ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>Select Visual Standard</p>
        </div>
        <div className="flex gap-1.5 items-center">
          <span className="text-[8px] font-black uppercase text-gray-500 tracking-widest mr-2">Sync: Operational</span>
          <div className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse"></div>
        </div>
      </div>
      
      <div className="flex gap-4 overflow-x-auto no-scrollbar pb-2">
        {themes.map((t) => (
          <button
            key={t.id}
            onClick={() => onThemeSelect(t.id, !t.isFree)}
            className={`flex-none w-44 p-4 rounded-2xl border transition-all group relative overflow-hidden ${
              currentTheme === t.id 
                ? (isDark ? 'bg-white/10 border-yellow-500 shadow-[0_0_20px_rgba(212,175,55,0.2)]' : 'bg-gray-50 border-yellow-600 shadow-md')
                : (isDark ? 'bg-white/5 border-white/5 opacity-60 hover:opacity-100' : 'bg-white border-gray-100 opacity-70 hover:opacity-100')
            }`}
          >
            {/* Status Indicators */}
            <div className="absolute top-2 right-2 flex gap-1">
              {!t.isFree && (
                <div className="w-5 h-5 bg-black/40 backdrop-blur-md rounded-lg flex items-center justify-center border border-white/10">
                  <svg className="w-3 h-3 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
                  </svg>
                </div>
              )}
              {currentTheme === t.id && (
                <div className="w-5 h-5 bg-yellow-500 rounded-lg flex items-center justify-center shadow-lg">
                  <svg className="w-3 h-3 text-[#073b4c]" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={4} d="M5 13l4 4L19 7" />
                  </svg>
                </div>
              )}
            </div>

            <ThemePreview id={t.id} />
            <h5 className={`mt-4 text-[10px] font-black uppercase tracking-widest ${isDark ? 'text-white' : 'text-[#073b4c]'}`}>{t.name}</h5>
            <div className="flex items-center gap-1.5 mt-1">
               <span className={`text-[7px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded ${t.isFree ? 'bg-gray-500/10 text-gray-500' : 'bg-yellow-500/20 text-yellow-600'}`}>
                {t.isFree ? "Free" : "Reward"}
               </span>
               <p className="text-[8px] font-bold text-gray-500 uppercase tracking-widest leading-tight truncate">{t.description}</p>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
};

export default StyleGallery;
