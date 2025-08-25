"use client";

import { useRouter } from 'next/navigation';

interface IOSNavBarProps {
  title: string;
  showBackButton?: boolean;
  onBack?: () => void;
  rightButton?: React.ReactNode;
}

export default function IOSNavBar({ 
  title, 
  showBackButton = false, 
  onBack,
  rightButton 
}: IOSNavBarProps) {
  const router = useRouter();

  const handleBack = () => {
    if (onBack) {
      onBack();
    } else {
      router.back();
    }
  };

  return (
    <div className="fixed top-0 left-0 right-0 z-50 bg-white border-b border-gray-200">
      <div className="flex items-center justify-between h-14 px-4">
        {/* Left side - Back button or spacer */}
        <div className="flex items-center min-w-0 flex-1">
          {showBackButton ? (
            <button
              onClick={handleBack}
              className="flex items-center text-blue-500 font-medium text-base active:opacity-50 transition-opacity"
            >
              <svg 
                className="w-5 h-5 mr-1" 
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path 
                  strokeLinecap="round" 
                  strokeLinejoin="round" 
                  strokeWidth={2} 
                  d="M15 19l-7-7 7-7" 
                />
              </svg>
              Atrás
            </button>
          ) : (
            <div className="w-16" />
          )}
        </div>

        {/* Center - Title */}
        <div className="flex-1 text-center">
          <h1 className="text-lg font-semibold text-black truncate">
            {title}
          </h1>
        </div>

        {/* Right side - Action button or spacer */}
        <div className="flex items-center justify-end min-w-0 flex-1">
          {rightButton || <div className="w-16" />}
        </div>
      </div>
    </div>
  );
}
