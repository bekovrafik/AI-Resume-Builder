
import React, { useState, useEffect } from 'react';
import { useTheme } from '../ThemeContext';
import Logo from './Logo';

interface OnboardingProps {
  onComplete: () => void;
}

const Onboarding: React.FC<OnboardingProps> = ({ onComplete }) => {
  const [step, setStep] = useState(0);
  const [isInteracted, setIsInteracted] = useState(false);
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  // Reset interaction state on step change
  useEffect(() => {
    setIsInteracted(false);
  }, [step]);

  const steps = [
    {
      title: "The AI Standard",
      content: "Welcome to AI Resume Builder. We don't just build resumes; we architect institutional-grade career legacies using executive AI models.",
      icon: (
        <Logo size="xl" className="mx-auto mb-6" />
      ),
      interaction: null
    },
    {
      title: "The XYZ Formula",
      content: "Google-recommended logic: 'Accomplished [X] as measured by [Y], by doing [Z]'. Watch the transformation below.",
      icon: <span className="text-4xl mb-6 block">📈</span>,
      interaction: (
        <div className="mt-6 space-y-4">
          <div className={`p-4 rounded-2xl border text-left transition-all duration-700 ${isInteracted ? 'opacity-30 scale-95 blur-[1px]' : 'opacity-100'}`}>
            <p className="text-[8px] uppercase font-black text-gray-500 mb-1">Standard Bullet</p>
            <p className="text-xs text-gray-400">"I helped my team with sales targets."</p>
          </div>
          
          <div className={`p-4 rounded-2xl border-2 border-yellow-500/30 bg-yellow-500/5 text-left transition-all duration-700 ${isInteracted ? 'opacity-100 translate-y-0 scale-100' : 'opacity-0 translate-y-4 scale-95'}`}>
            <p className="text-[8px] uppercase font-black text-yellow-600 mb-1">AI Resume Builder XYZ Blueprint</p>
            <p className="text-xs font-bold text-white">"Spearheaded a new sales methodology that boosted quarterly revenue by 22% ($450k) via the implementation of cross-functional CRM automation."</p>
          </div>

          {!isInteracted && (
            <button 
              onClick={() => setIsInteracted(true)}
              className="text-[9px] font-black uppercase tracking-widest text-yellow-600 animate-bounce"
            >
              Click to Apply Logic
            </button>
          )}
        </div>
      )
    },
    {
      title: "ATS Optimization",
      content: "Our engine automatically injects high-traffic industry keywords to ensure your narrative clears every digital gatekeeper.",
      icon: <span className="text-4xl mb-6 block">🔍</span>,
      interaction: (
        <div className="mt-6 relative h-32 w-full glass rounded-2xl overflow-hidden border border-white/10 flex items-center justify-center">
          <div className="absolute inset-0 flex flex-col items-center justify-center gap-2 p-4">
             <div className={`flex flex-wrap gap-2 justify-center transition-all duration-1000 ${isInteracted ? 'opacity-100' : 'opacity-20 blur-sm'}`}>
                {['Strategic Planning', 'Cross-functional Leadership', 'Revenue Growth', 'Agile Methodology', 'Digital Transformation'].map((kw, i) => (
                  <span key={i} className="px-3 py-1 bg-yellow-500/10 border border-yellow-500/30 text-yellow-500 rounded-full text-[8px] font-black uppercase tracking-widest">
                    {kw}
                  </span>
                ))}
             </div>
          </div>
          
          <div className={`absolute top-0 bottom-0 w-1 bg-yellow-500 shadow-[0_0_15px_rgba(234,179,8,0.5)] transition-all duration-[2000ms] ease-in-out ${isInteracted ? 'left-full' : 'left-0'}`}></div>
          
          {!isInteracted && (
            <button 
              onClick={() => setIsInteracted(true)}
              className="absolute inset-0 flex items-center justify-center bg-black/40 text-[9px] font-black uppercase tracking-widest text-white backdrop-blur-[1px]"
            >
              Simulate ATS Scan
            </button>
          )}
        </div>
      )
    },
    {
      title: "Narrative Polish",
      content: "Your dashboard is interactive. Click any achievement to refine it, or chat with the Architect for real-time legacy synthesis.",
      icon: <span className="text-4xl mb-6 block">💎</span>,
      interaction: null
    }
  ];

  const handleNext = () => {
    if (step < steps.length - 1) {
      setStep(step + 1);
    } else {
      onComplete();
    }
  };

  return (
    <div className={`fixed inset-0 z-[100] flex items-center justify-center p-6 animate-in fade-in duration-500 ${isDark ? 'bg-[#073b4c]/95' : 'bg-white/95'}`}>
      <div className={`max-w-md w-full glass p-10 rounded-[2.5rem] text-center relative border shadow-2xl transition-all duration-500 ${isDark ? 'builder-border' : 'border-black/5 bg-white shadow-black/10'}`}>
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-yellow-600 via-yellow-200 to-yellow-600 rounded-t-full"></div>
        
        {steps[step].icon}
        <h3 className="text-2xl font-serif mb-4 builder-gradient uppercase tracking-widest">{steps[step].title}</h3>
        <p className={`text-sm leading-relaxed mb-8 font-medium ${isDark ? 'text-gray-400' : 'text-gray-600'}`}>{steps[step].content}</p>
        
        {steps[step].interaction}

        <div className="flex gap-2 justify-center my-8">
          {steps.map((_, i) => (
            <div key={i} className={`h-1 rounded-full transition-all duration-500 ${i === step ? 'w-10 bg-yellow-600' : (isDark ? 'w-4 bg-white/10' : 'w-4 bg-black/10')}`}></div>
          ))}
        </div>

        <button
          onClick={handleNext}
          className={`w-full py-4 font-black uppercase tracking-[0.3em] text-[10px] rounded-2xl transition-all shadow-xl active:scale-95 ${isDark ? 'bg-white text-black hover:bg-yellow-500' : 'bg-black text-white hover:bg-yellow-700 shadow-black/20'}`}
        >
          {step === steps.length - 1 ? "Begin Architecture" : "Next Milestone"}
        </button>
        
        <button 
          onClick={onComplete}
          className="mt-6 text-[9px] text-gray-400 uppercase font-black tracking-widest hover:text-yellow-600 transition-colors"
        >
          Skip Onboarding
        </button>
      </div>
    </div>
  );
};

export default Onboarding;
