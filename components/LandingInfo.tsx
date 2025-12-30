
import React from 'react';
import { useTheme } from '../ThemeContext';

const LandingInfo: React.FC = () => {
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  return (
    <div className="space-y-20 mt-20">
      {/* Success Stories */}
      <section>
        <h3 className="text-xl font-serif text-center uppercase tracking-widest mb-12 builder-gradient">AI Resume Success Stories</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {[
            { name: 'Marcus L.', role: 'VP of Product', story: 'Transformed my bullet points from generic tasks to high-impact achievements. Landed a leadership role in 3 weeks.' },
            { name: 'Sarah J.', role: 'Director of Marketing', story: 'The XYZ formula changed how I communicate value. The ATS optimization is top-tier and actually works.' },
            { name: 'Kenji T.', role: 'Lead Architect', story: 'Clean, professional, and powerful. The chat feature helped me refine my narrative in real-time with an expert voice.' },
          ].map((s, i) => (
            <div key={i} className={`glass p-6 rounded-2xl relative overflow-hidden group border transition-all ${isDark ? 'builder-border' : 'border-black/5 bg-white shadow-lg shadow-black/5'}`}>
              <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:opacity-10 transition-opacity">
                <svg className={`w-12 h-12 ${isDark ? 'text-white' : 'text-black'}`} fill="currentColor" viewBox="0 0 24 24"><path d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"/></svg>
              </div>
              <p className={`text-xs italic mb-6 leading-relaxed ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>"{s.story}"</p>
              <h4 className={`text-sm font-bold ${isDark ? 'text-white' : 'text-black'}`}>{s.name}</h4>
              <p className="text-[10px] text-yellow-600 font-bold tracking-widest uppercase">{s.role}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default LandingInfo;