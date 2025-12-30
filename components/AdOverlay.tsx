
import React from 'react';
import { AdType } from '../types';
import { useTheme } from '../ThemeContext';

interface AdOverlayProps {
  type: AdType;
  message: string;
  onClose: () => void;
}

const AdOverlay: React.FC<AdOverlayProps> = ({ type, message, onClose }) => {
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  return (
    <div className={`fixed inset-0 z-50 flex items-center justify-center p-4 backdrop-blur-md transition-colors duration-500 ${isDark ? 'bg-[#073b4c]/90' : 'bg-white/80'}`}>
      <div className={`max-w-md w-full glass p-8 text-center relative overflow-hidden rounded-3xl border shadow-[0_50px_100px_-20px_rgba(0,0,0,0.3)] transition-all ${isDark ? 'builder-border' : 'border-black/10 bg-white'}`}>
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-yellow-600 via-yellow-200 to-yellow-600"></div>
        
        <span className="text-[10px] uppercase tracking-widest text-yellow-600 font-black mb-4 block">Sponsored Content</span>
        
        <h3 className={`text-xl font-serif mb-2 uppercase tracking-widest ${isDark ? 'text-white' : 'text-black'}`}>{type.replace('_', ' ')} AD</h3>
        <p className={`mb-8 leading-relaxed text-xs font-medium ${isDark ? 'text-gray-400' : 'text-gray-500'}`}>
          {message}
        </p>

        <div className={`p-4 rounded-2xl mb-8 animate-pulse border ${isDark ? 'bg-white/5 border-white/5' : 'bg-gray-50 border-black/5'}`}>
          <div className="h-32 rounded flex flex-col items-center justify-center gap-3">
             <div className="w-8 h-8 rounded-full border-2 border-yellow-600/30 border-t-yellow-600 animate-spin"></div>
            <span className="text-[9px] text-gray-400 font-black uppercase tracking-[0.4em] italic">Architectural Synthesis...</span>
          </div>
        </div>

        <button 
          onClick={onClose}
          className={`w-full py-4 font-black uppercase tracking-[0.2em] text-xs rounded-xl transition-all shadow-lg active:scale-95 ${isDark ? 'bg-white text-black hover:bg-yellow-500' : 'bg-black text-white hover:bg-yellow-700'}`}
        >
          Continue to Resume
        </button>
      </div>
    </div>
  );
};

export default AdOverlay;
