"use client";

interface IOSButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  type?: 'button' | 'submit' | 'reset';
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  fullWidth?: boolean;
  className?: string;
}

export default function IOSButton({
  children,
  onClick,
  type = 'button',
  variant = 'primary',
  size = 'md',
  disabled = false,
  fullWidth = false,
  className = ''
}: IOSButtonProps) {
  const baseClasses = `
    font-semibold
    rounded-xl
    transition-all
    duration-200
    active:scale-95
    disabled:opacity-50
    disabled:cursor-not-allowed
    disabled:active:scale-100
    ${fullWidth ? 'w-full' : ''}
  `;

  const sizeClasses = {
    sm: 'px-4 py-2 text-sm',
    md: 'px-6 py-3 text-base',
    lg: 'px-8 py-4 text-lg'
  };

  const variantClasses = {
    primary: `
      bg-blue-500 
      text-white 
      active:bg-blue-600
      disabled:bg-blue-300
    `,
    secondary: `
      bg-gray-100 
      text-gray-900 
      active:bg-gray-200
      disabled:bg-gray-50
      disabled:text-gray-400
    `,
    danger: `
      bg-red-500 
      text-white 
      active:bg-red-600
      disabled:bg-red-300
    `
  };

  const combinedClasses = `
    ${baseClasses}
    ${sizeClasses[size]}
    ${variantClasses[variant]}
    ${className}
  `.trim();

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={combinedClasses}
    >
      {children}
    </button>
  );
}
