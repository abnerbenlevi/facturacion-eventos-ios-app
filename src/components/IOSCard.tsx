"use client";

interface IOSCardProps {
  children: React.ReactNode;
  className?: string;
  onClick?: () => void;
  padding?: 'sm' | 'md' | 'lg';
}

export default function IOSCard({ 
  children, 
  className = '', 
  onClick,
  padding = 'md'
}: IOSCardProps) {
  const paddingClasses = {
    sm: 'p-3',
    md: 'p-4',
    lg: 'p-6'
  };

  const baseClasses = `
    bg-white 
    rounded-xl 
    shadow-sm 
    border 
    border-gray-100
    ${paddingClasses[padding]}
    ${onClick ? 'cursor-pointer active:scale-95 transition-transform duration-150' : ''}
    ${className}
  `;

  if (onClick) {
    return (
      <button
        onClick={onClick}
        className={baseClasses}
      >
        {children}
      </button>
    );
  }

  return (
    <div className={baseClasses}>
      {children}
    </div>
  );
}
