
import React, { useState, useEffect } from 'react';
import { JobResult } from '../types';
import { useTheme } from '../ThemeContext';

interface JobDiscoveryProps {
  onSearch: (role: string, location: string) => Promise<JobResult[]>;
  initialRole?: string;
  initialLocation?: string;
  isProcessing: boolean;
}

const JobDiscovery: React.FC<JobDiscoveryProps> = ({ onSearch, initialRole, initialLocation, isProcessing }) => {
  const [role, setRole] = useState(initialRole || '');
  const [location, setLocation] = useState(initialLocation || '');
  const [results, setResults] = useState<JobResult[]>([]);
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  // Sync inputs with profile data whenever initial values change (e.g., navigation back to the tab)
  useEffect(() => {
    if (initialRole) setRole(initialRole);
    if (initialLocation) setLocation(initialLocation);
  }, [initialRole, initialLocation]);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!role.trim()) return;
    const jobs = await onSearch(role, location);
    setResults(jobs);
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-500 pb-20">
      <header className="px-2">
        <h2 className="text-4xl font-serif mb-2 leading-tight">Market <span className="builder-gradient">Radar.</span></h2>
        <p className={`text-[10px] font-black uppercase tracking-[0.4em] ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>Real-time Opportunity Discovery</p>
      </header>

      <div className={`p-8 rounded-[2.5rem] border transition-all ${isDark ? 'bg-white/[0.02] border-white/10 shadow-2xl' : 'bg-white border-[#073b4c]/5 shadow-lg'}`}>
        <form onSubmit={handleSearch} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="text-[9px] font-black uppercase tracking-widest text-gray-500 block mb-2 px-1">Target Professional Role</label>
              <input 
                type="text" 
                value={role}
                onChange={(e) => setRole(e.target.value)}
                placeholder="Ex: Executive Creative Director"
                className={`w-full bg-transparent border rounded-2xl px-5 py-4 text-sm transition-all ${isDark ? 'border-white/10 text-white focus:border-yellow-500' : 'border-black/5 text-black focus:border-[#073b4c]'}`}
              />
            </div>
            <div>
              <label className="text-[9px] font-black uppercase tracking-widest text-gray-500 block mb-2 px-1">Geographical Focus</label>
              <input 
                type="text" 
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="Ex: NYC, London, or Remote"
                className={`w-full bg-transparent border rounded-2xl px-5 py-4 text-sm transition-all ${isDark ? 'border-white/10 text-white focus:border-yellow-500' : 'border-black/5 text-black focus:border-[#073b4c]'}`}
              />
            </div>
          </div>
          
          <button 
            type="submit"
            disabled={isProcessing || !role.trim()}
            className={`w-full py-5 rounded-[2rem] font-black uppercase tracking-[0.4em] text-[10px] shadow-2xl transition-all active:scale-[0.98] ${
              isDark 
                ? 'bg-white text-[#073b4c] hover:bg-yellow-500 disabled:bg-white/5 disabled:text-gray-500' 
                : 'bg-[#073b4c] text-white disabled:bg-gray-100 disabled:text-gray-400'
            } transition-all duration-300`}
          >
            {isProcessing ? "Scanning Institutional Portals..." : "Scan Jobs"}
          </button>
        </form>
      </div>

      <div className="space-y-6">
        {results.length > 0 ? (
          results.map((job, idx) => (
            <div 
              key={idx} 
              className={`p-6 rounded-[2rem] border transition-all animate-in slide-in-from-bottom-4 duration-500 ${isDark ? 'bg-white/[0.02] border-white/10 hover:bg-white/5' : 'bg-white border-[#073b4c]/5 hover:shadow-xl'}`}
            >
              <div className="flex justify-between items-start mb-4">
                <div className="flex-1 min-w-0">
                  <h4 className="text-base font-serif truncate pr-4">{job.title}</h4>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-[9px] font-black uppercase tracking-widest text-yellow-600">{job.company}</span>
                    <span className="text-gray-500 text-[14px]">•</span>
                    <span className="text-[9px] font-black uppercase tracking-widest text-gray-500">{job.location}</span>
                  </div>
                </div>
                <div className="w-10 h-10 rounded-full bg-yellow-500/10 flex items-center justify-center text-yellow-600 flex-none">
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
                </div>
              </div>
              <p className={`text-[11px] leading-relaxed mb-6 ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>{job.snippet}</p>
              <a 
                href={job.url} 
                target="_blank" 
                rel="noopener noreferrer"
                className={`inline-flex items-center gap-2 px-6 py-3 rounded-full text-[9px] font-black uppercase tracking-widest transition-all ${isDark ? 'bg-white text-black hover:bg-yellow-500' : 'bg-[#073b4c] text-white'}`}
              >
                Initiate Application
                <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>
              </a>
            </div>
          ))
        ) : (
          !isProcessing && (
            <div className="py-20 text-center opacity-30">
              <div className="w-16 h-16 rounded-[1.5rem] bg-gray-500/10 flex items-center justify-center mx-auto mb-4">
                 <svg className="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" /></svg>
              </div>
              <p className="uppercase tracking-[0.4em] text-[10px] font-black">Awaiting Search Query</p>
            </div>
          )
        )}
      </div>
    </div>
  );
};

export default JobDiscovery;
