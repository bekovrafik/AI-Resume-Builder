
import React, { useState, useRef, useEffect } from 'react';
import { ChatMessage, ThemeMode, UploadedFile } from '../types';
import { useTheme } from '../ThemeContext';
import Logo from './Logo';

interface ChatInterfaceProps {
  onSendMessage: (message: string, file?: UploadedFile) => void;
  messages: ChatMessage[];
  isProcessing: boolean;
  mode: ThemeMode;
  onNavigateToPreview: () => void;
  onBackToDash: () => void;
}

const QUICK_ACTIONS = [
  "Apply Executive Tone",
  "Inject High-Impact Metrics",
  "FAANG ATS Optimization",
  "Refine for Startups",
  "Expand Core Skills",
  "Shorten Summary"
];

const ChatInterface: React.FC<ChatInterfaceProps> = ({ 
  onSendMessage, 
  messages, 
  isProcessing, 
  mode,
  onNavigateToPreview,
  onBackToDash
}) => {
  const [input, setInput] = useState('');
  const [pendingFile, setPendingFile] = useState<UploadedFile | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const { mode: themeMode } = useTheme();
  const isDark = themeMode === 'dark';

  // Smooth scroll to bottom on new messages
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTo({
        top: scrollRef.current.scrollHeight,
        behavior: 'smooth'
      });
    }
  }, [messages, isProcessing]);

  // Handle auto-expanding textarea
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      const newHeight = Math.min(textareaRef.current.scrollHeight, 120);
      textareaRef.current.style.height = `${newHeight}px`;
    }
  }, [input]);

  const handleSend = (text?: string) => {
    if (isProcessing) return;
    const messageToSend = typeof text === 'string' ? text : input;
    
    if (!messageToSend.trim() && !pendingFile) return;
    
    onSendMessage(messageToSend, pendingFile || undefined);
    setInput('');
    setPendingFile(null);
    if (textareaRef.current) textareaRef.current.style.height = 'auto';
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = () => {
      const base64 = (reader.result as string).split(',')[1];
      setPendingFile({
        data: base64,
        mimeType: file.type,
        name: file.name
      });
    };
    reader.readAsDataURL(file);
    e.target.value = '';
  };

  const getTime = () => {
    return new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className={`flex flex-col h-[calc(100dvh-170px)] md:h-[calc(100dvh-180px)] overflow-hidden rounded-[2.5rem] border transition-all ${isDark ? 'bg-[#073b4c] border-white/5' : 'bg-[#f8f9fa] border-black/5 shadow-inner'}`}>
      
      {/* Pinned Header */}
      <header className={`flex-none z-30 px-4 py-4 flex items-center justify-between border-b backdrop-blur-xl ${isDark ? 'bg-[#073b4c]/90 border-white/5' : 'bg-white/90 border-black/5 shadow-sm'}`}>
        <div className="flex items-center gap-2">
          <button 
            onClick={onBackToDash}
            className={`w-9 h-9 rounded-full flex items-center justify-center transition-all active:scale-90 ${isDark ? 'bg-white/5 text-white' : 'bg-[#073b4c]/5 text-[#073b4c]'}`}
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" /></svg>
          </button>
          <div className="flex items-center gap-3">
            <div className="relative">
              <Logo size="sm" />
              <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-500 rounded-full border-2 border-[#073b4c]"></div>
            </div>
            <div className="hidden sm:block">
              <h3 className={`text-[11px] font-black uppercase tracking-widest leading-none mb-1 ${isDark ? 'text-white' : 'text-[#073b4c]'}`}>Architect</h3>
              <span className={`text-[8px] font-bold uppercase tracking-widest ${isDark ? 'text-gray-400' : 'text-gray-500'}`}>Online</span>
            </div>
          </div>
        </div>
        
        <button 
          onClick={onNavigateToPreview}
          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all active:scale-95 ${isDark ? 'bg-white/10 text-white' : 'bg-[#073b4c] text-white'}`}
        >
          <span>Preview</span>
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
        </button>
      </header>

      {/* Scrollable Message Stream */}
      <div 
        ref={scrollRef} 
        className="flex-1 overflow-y-auto px-5 py-6 space-y-6 no-scrollbar"
      >
        {messages.length === 0 && (
          <div className="h-full flex flex-col items-center justify-center text-center px-10 opacity-40">
            <div className={`w-16 h-16 rounded-3xl mb-6 flex items-center justify-center ${isDark ? 'bg-white/5' : 'bg-white shadow-sm'}`}>
              <svg className="w-8 h-8 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" /></svg>
            </div>
            <h4 className="text-sm font-serif mb-2 uppercase tracking-[0.2em]">Narrative Forge</h4>
            <p className="text-[10px] leading-relaxed max-w-[200px] font-medium">
              Awaiting instructions. How shall we refine your career legacy today?
            </p>
          </div>
        )}

        {messages.map((m, i) => {
          const isUser = m.role === 'user';
          const isSuccess = !isUser && (
            m.content.toLowerCase().includes("complete") || 
            m.content.toLowerCase().includes("refined") || 
            m.content.toLowerCase().includes("updated")
          );
          
          return (
            <div 
              key={i} 
              className={`flex ${isUser ? 'justify-end' : 'justify-start'} animate-in fade-in slide-in-from-bottom-2 duration-300`}
            >
              <div className={`max-w-[85%] flex flex-col ${isUser ? 'items-end' : 'items-start'}`}>
                <div className={`px-4 py-3 rounded-2xl text-[14px] leading-relaxed shadow-sm relative ${
                  isUser 
                    ? 'bg-yellow-500 text-[#073b4c] font-bold rounded-br-sm' 
                    : (isDark 
                        ? 'bg-[#1a5165] text-white rounded-bl-sm border border-white/5' 
                        : 'bg-white text-[#073b4c] rounded-bl-sm border border-black/5 shadow-sm')
                }`}>
                  <p className="whitespace-pre-wrap">{m.content}</p>
                </div>
                <span className={`mt-1.5 text-[8px] font-black uppercase tracking-widest ${isDark ? 'text-gray-500' : 'text-gray-400'}`}>
                    {isUser ? 'Sent' : 'Architect'} • {getTime()}
                </span>

                {isSuccess && (
                  <button 
                    onClick={onNavigateToPreview}
                    className={`mt-4 flex items-center gap-2 px-5 py-2.5 rounded-xl text-[9px] font-black uppercase tracking-[0.2em] transition-all active:scale-95 shadow-xl ${isDark ? 'bg-white text-[#073b4c]' : 'bg-[#073b4c] text-white'}`}
                  >
                    <span>Inspect Blueprint</span>
                    <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M13 7l5 5m0 0l-5 5m5-5H6" /></svg>
                  </button>
                )}
              </div>
            </div>
          );
        })}

        {isProcessing && (
          <div className="flex justify-start animate-in fade-in duration-300">
            <div className={`px-4 py-3 rounded-2xl rounded-bl-sm border shadow-sm ${isDark ? 'bg-[#1a5165] border-white/5' : 'bg-white border-black/5'}`}>
              <div className="flex gap-1.5">
                <div className="w-1.5 h-1.5 bg-yellow-600 rounded-full animate-bounce [animation-duration:0.8s]"></div>
                <div className="w-1.5 h-1.5 bg-yellow-600 rounded-full animate-bounce [animation-duration:0.8s] [animation-delay:0.2s]"></div>
                <div className="w-1.5 h-1.5 bg-yellow-600 rounded-full animate-bounce [animation-duration:0.8s] [animation-delay:0.4s]"></div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Pinned Input Footer */}
      <footer className={`flex-none p-4 pb-6 space-y-4 backdrop-blur-xl border-t ${isDark ? 'bg-[#073b4c]/95 border-white/5' : 'bg-white/95 border-black/5'}`}>
        
        {/* Horizontal Action Chips */}
        <div className="flex gap-2 overflow-x-auto no-scrollbar py-1">
          {QUICK_ACTIONS.map((action, idx) => (
            <button
              key={idx}
              onClick={() => handleSend(action)}
              disabled={isProcessing}
              className={`flex-none px-4 py-2 rounded-full text-[8px] font-black uppercase tracking-widest border transition-all active:scale-95 whitespace-nowrap ${
                isDark 
                  ? 'bg-white/5 border-white/10 text-gray-500 hover:text-white hover:border-yellow-500/50' 
                  : 'bg-white border-black/10 text-gray-400 hover:text-[#073b4c] hover:border-[#073b4c]/30'
              } disabled:opacity-30`}
            >
              {action}
            </button>
          ))}
        </div>

        {/* Input Controls */}
        <div className="flex items-end gap-2.5">
          <button
            onClick={() => fileInputRef.current?.click()}
            disabled={isProcessing}
            className={`w-11 h-11 flex-none rounded-full flex items-center justify-center transition-all active:scale-90 ${
              pendingFile ? 'bg-yellow-500 text-[#073b4c]' : (isDark ? 'bg-white/5 text-gray-400 border border-white/10' : 'bg-[#073b4c]/5 text-gray-500 border border-black/5')
            }`}
          >
            <input type="file" ref={fileInputRef} onChange={handleFileChange} className="hidden" accept=".pdf,.doc,.docx,.txt" />
            {pendingFile ? (
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z"/></svg>
            ) : (
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 6v6m0 0v6m0-6h6m-6 0H6" /></svg>
            )}
          </button>

          <div className={`flex-1 flex items-end min-h-[44px] rounded-[22px] border px-4 py-1.5 transition-all focus-within:ring-2 focus-within:ring-yellow-500/20 ${
            isDark ? 'bg-[#1a5165] border-white/10 focus-within:border-yellow-500/50' : 'bg-white border-black/10 focus-within:border-[#073b4c]/30 shadow-sm'
          }`}>
            <textarea
              ref={textareaRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  handleSend();
                }
              }}
              placeholder={pendingFile ? `Attached: ${pendingFile.name}` : "Apply refinement..."}
              rows={1}
              disabled={isProcessing}
              className={`w-full bg-transparent py-2 text-[14px] focus:outline-none resize-none placeholder:text-gray-500 max-h-[100px] leading-snug ${isDark ? 'text-white' : 'text-[#073b4c]'}`}
            />
          </div>

          <button
            onClick={() => handleSend()}
            disabled={isProcessing || (!input.trim() && !pendingFile)}
            className={`w-11 h-11 rounded-full flex-none flex items-center justify-center shadow-lg transition-all active:scale-90 ${
              isDark ? 'bg-white text-[#073b4c]' : 'bg-[#073b4c] text-white'
            } disabled:opacity-20 disabled:grayscale`}
          >
            {isProcessing ? (
              <div className="w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin"></div>
            ) : (
              <svg className="w-4 h-4 ml-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 12h14M12 5l7 7-7 7" />
              </svg>
            )}
          </button>
        </div>
      </footer>
    </div>
  );
};

export default ChatInterface;
