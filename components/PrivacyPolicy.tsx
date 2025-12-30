
import React from 'react';
import { useTheme } from '../ThemeContext';

interface PrivacyPolicyProps {
  onBack: () => void;
}

const PrivacyPolicy: React.FC<PrivacyPolicyProps> = ({ onBack }) => {
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  const sections = [
    {
      title: "1. Identity Architecture",
      content: "We collect personal data (Name, Email, Role) to construct your professional profile. This data remains on your local instance and is only transmitted for synthesis during active generation cycles."
    },
    {
      title: "2. Narrative Synthesis Protection",
      content: "When using our AI Career Architect, your work history is processed via Google Gemini API. AI Resume Builder does not retain persistent logs of your raw career legacy data once the synthesis is complete."
    },
    {
      title: "3. The Vault (Local Storage)",
      content: "Your 'Career Vault' utilizes localized storage protocols. Deleting a narrative standard from your dashboard permanently expunges the data from our synthesized cache."
    },
    {
      title: "4. Institutional Analytics",
      content: "We may collect anonymized interaction data to optimize the AI Resume Builder interface. This never includes specific achievements, metrics, or identity-linked career milestones."
    }
  ];

  return (
    <div className="animate-in slide-in-from-right-4 duration-500">
      <div className="flex items-center gap-4 mb-8">
        <button 
          onClick={onBack}
          className={`w-10 h-10 rounded-full flex items-center justify-center transition-all active:scale-90 ${isDark ? 'bg-white/5 text-white' : 'bg-gray-100 text-black'}`}
        >
          <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" /></svg>
        </button>
        <h3 className="text-2xl font-serif">Legal Standard</h3>
      </div>

      <div className="space-y-6">
        <div className={`p-6 rounded-[2rem] border ${isDark ? 'bg-yellow-500/5 border-yellow-500/20' : 'bg-yellow-50 border-yellow-100'}`}>
          <p className="text-[10px] font-black uppercase tracking-widest text-yellow-600 mb-2">Architectural Commitment</p>
          <p className={`text-xs leading-relaxed font-medium ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>
            The AI Resume Builder Suite is engineered on a 'Privacy-by-Architecture' framework. We believe your career narrative is your most valuable asset.
          </p>
        </div>

        {sections.map((section, idx) => (
          <div key={idx} className={`p-6 rounded-3xl border ${isDark ? 'bg-white/5 border-white/10' : 'bg-white border-black/5 shadow-sm'}`}>
            <h4 className="text-[11px] font-black uppercase tracking-[0.2em] mb-3 text-primary">{section.title}</h4>
            <p className="text-[11px] text-gray-500 leading-relaxed">{section.content}</p>
          </div>
        ))}

        <div className={`p-8 rounded-[2.5rem] border ${isDark ? 'bg-black border-white/10' : 'bg-gray-50 border-black/5'} space-y-4`}>
          <h4 className="text-[10px] font-black uppercase tracking-[0.3em] text-center text-primary">Institutional Contact</h4>
          <div className="space-y-3">
            <div className="flex flex-col items-center">
              <span className="text-[8px] text-gray-500 uppercase font-black mb-1">Career Support</span>
              <a href="mailto:support@pilllens.com" className="text-sm font-serif text-yellow-600 hover:underline">support@pilllens.com</a>
            </div>
            <div className="flex flex-col items-center">
              <span className="text-[8px] text-gray-500 uppercase font-black mb-1">Direct Terminal</span>
              <a href="tel:+16062570048" className="text-sm font-serif text-yellow-600 hover:underline">+1 606 257 0048</a>
            </div>
          </div>
          <p className="text-[8px] text-center text-gray-600 uppercase tracking-widest pt-4">Last Sync: October 2025</p>
        </div>
      </div>
    </div>
  );
};

export default PrivacyPolicy;