
import React, { useState } from 'react';
import { User } from '../types';
import { useTheme } from '../ThemeContext';
import Logo from './Logo';

interface AuthProps {
  onLogin: (user: User) => void;
}

const Auth: React.FC<AuthProps> = ({ onLogin }) => {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { mode } = useTheme();
  const isDark = mode === 'dark';

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onLogin({
      email,
      name: email.split('@')[0],
      isPremium: true
    });
  };

  return (
    <div className={`min-h-screen flex flex-col items-center justify-center p-6 relative overflow-hidden transition-colors duration-500 ${isDark ? 'bg-[#073b4c]' : 'bg-white'}`}>
      {/* Background Decor */}
      <div className={`absolute top-[-10%] left-[-10%] w-80 h-80 rounded-full blur-[120px] ${isDark ? 'bg-yellow-600/10' : 'bg-yellow-500/5'}`}></div>
      <div className={`absolute bottom-[-10%] right-[-10%] w-80 h-80 rounded-full blur-[120px] ${isDark ? 'bg-yellow-400/5' : 'bg-yellow-500/10'}`}></div>

      <div className={`w-full max-w-md rounded-[2.5rem] p-10 z-10 animate-in fade-in slide-in-from-bottom-8 duration-700 border transition-all ${
        isDark 
          ? 'glass builder-border shadow-2xl' 
          : 'bg-white border-black/5 shadow-[0_40px_100px_-20px_rgba(0,0,0,0.1)]'
      }`}>
        <div className="text-center mb-10">
          <Logo size="lg" className="mx-auto mb-6" />
          <h1 className={`text-3xl font-serif uppercase tracking-widest font-bold ${isDark ? 'text-white' : 'text-black'}`}>AI Resume Builder</h1>
          <p className="text-gray-400 text-[10px] mt-2 uppercase tracking-[0.4em] font-black">Lead AI Career Architect</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="text-[10px] font-black uppercase tracking-widest text-gray-400 block mb-2 px-1">Institutional Email</label>
            <input 
              type="email" 
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className={`w-full border rounded-2xl px-5 py-4 text-sm transition-all ${
                isDark 
                  ? 'bg-white/5 border-white/10 text-white focus:border-yellow-500/50' 
                  : 'bg-gray-50 border-black/5 text-black focus:border-black'
              }`}
              placeholder="name@executive.com"
            />
          </div>
          <div>
            <label className="text-[10px] font-black uppercase tracking-widest text-gray-400 block mb-2 px-1">Credentials</label>
            <input 
              type="password" 
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={`w-full border rounded-2xl px-5 py-4 text-sm transition-all ${
                isDark 
                  ? 'bg-white/5 border-white/10 text-white focus:border-yellow-500/50' 
                  : 'bg-gray-50 border-black/5 text-black focus:border-black'
              }`}
              placeholder="••••••••"
            />
          </div>

          <button 
            type="submit"
            className={`w-full font-black uppercase tracking-widest py-4 rounded-2xl transition-all shadow-xl active:scale-[0.98] ${
              isDark 
                ? 'bg-white text-black hover:bg-yellow-500' 
                : 'bg-black text-white hover:bg-gray-900 shadow-black/10'
            }`}
          >
            {isLogin ? "Authenticate Access" : "Create Blueprint"}
          </button>
        </form>

        <div className="mt-8 text-center">
          <button 
            onClick={() => setIsLogin(!isLogin)}
            className={`text-[10px] font-bold uppercase tracking-widest transition-colors ${isDark ? 'text-gray-500 hover:text-white' : 'text-gray-400 hover:text-black'}`}
          >
            {isLogin ? "Don't have an account? Sign up" : "Already registered? Log in"}
          </button>
        </div>
      </div>

      <p className={`mt-12 text-[10px] uppercase tracking-[0.6em] font-black transition-colors ${isDark ? 'text-white/10' : 'text-gray-200'}`}>Milan • Paris • NYC • Tokyo</p>
    </div>
  );
};

export default Auth;
