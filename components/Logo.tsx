
import React from 'react';

interface LogoProps {
  className?: string;
  variant?: 'gold' | 'white' | 'navy';
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

const Logo: React.FC<LogoProps> = ({ className = '', variant = 'gold', size = 'md' }) => {
  const sizes = {
    sm: 'w-6 h-6',
    md: 'w-10 h-10',
    lg: 'w-16 h-16',
    xl: 'w-24 h-24'
  };

  const getColors = () => {
    switch (variant) {
      case 'white': return { primary: '#FFFFFF', secondary: '#F5F5F5', bg: 'transparent' };
      case 'navy': return { primary: '#073B4C', secondary: '#118AB2', bg: 'transparent' };
      default: return { primary: '#D4AF37', secondary: '#F9F295', bg: '#073B4C' };
    }
  };

  const colors = getColors();

  return (
    <div className={`relative flex items-center justify-center ${sizes[size]} ${className}`}>
      <svg viewBox="0 0 100 100" className="w-full h-full drop-shadow-2xl">
        <defs>
          <linearGradient id="goldGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#D4AF37" />
            <stop offset="50%" stopColor="#F9F295" />
            <stop offset="100%" stopColor="#B8860B" />
          </linearGradient>
          <clipPath id="logoClip">
            <rect x="0" y="0" width="100" height="100" rx="24" />
          </clipPath>
        </defs>
        
        {/* Background Shield */}
        <rect 
          x="0" 
          y="0" 
          width="100" 
          height="100" 
          rx="24" 
          fill={variant === 'gold' ? '#073B4C' : 'transparent'} 
        />
        
        {/* Architectural Emblem */}
        <g transform="translate(20, 20) scale(0.6)">
          {/* Main Pillar/Building Shape */}
          <path 
            d="M50 0 L100 80 L85 80 L50 25 L15 80 L0 80 Z" 
            fill="url(#goldGradient)"
            style={{ filter: 'drop-shadow(0px 4px 4px rgba(0,0,0,0.25))' }}
          />
          {/* Internal Cross Bar representing precision/alignment */}
          <rect 
            x="20" 
            y="50" 
            width="60" 
            height="8" 
            fill="url(#goldGradient)" 
            rx="2"
          />
          {/* Stylized Nib/Tip for Resume Drafting */}
          <path 
            d="M45 0 L55 0 L55 15 L45 15 Z" 
            fill="url(#goldGradient)"
          />
        </g>

        {/* Outer Ring Detail */}
        <rect 
          x="5" 
          y="5" 
          width="90" 
          height="90" 
          rx="20" 
          fill="none" 
          stroke="url(#goldGradient)" 
          strokeWidth="1.5"
          strokeOpacity="0.4"
        />
      </svg>
    </div>
  );
};

export default Logo;
