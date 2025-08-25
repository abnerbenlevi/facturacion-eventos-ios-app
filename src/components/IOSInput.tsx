"use client";

import { forwardRef } from 'react';

interface IOSInputProps {
  label?: string;
  placeholder?: string;
  type?: 'text' | 'email' | 'password' | 'number' | 'date' | 'time' | 'textarea';
  value?: string | number;
  onChange?: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  onBlur?: (e: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
  error?: string;
  disabled?: boolean;
  required?: boolean;
  className?: string;
  rows?: number;
  step?: string;
}

const IOSInput = forwardRef<HTMLInputElement | HTMLTextAreaElement, IOSInputProps>(
  ({
    label,
    placeholder,
    type = 'text',
    value,
    onChange,
    onBlur,
    error,
    disabled = false,
    required = false,
    className = '',
    rows = 4,
    step
  }, ref) => {
    const baseInputClasses = `
      w-full
      px-4
      py-3
      text-base
      bg-gray-50
      border
      border-gray-200
      rounded-xl
      focus:outline-none
      focus:ring-2
      focus:ring-blue-500
      focus:border-transparent
      disabled:opacity-50
      disabled:cursor-not-allowed
      transition-all
      duration-200
      ${error ? 'border-red-500 focus:ring-red-500' : ''}
      ${className}
    `;

    const renderInput = () => {
      if (type === 'textarea') {
        return (
          <textarea
            ref={ref as React.Ref<HTMLTextAreaElement>}
            placeholder={placeholder}
            value={value}
            onChange={onChange}
            onBlur={onBlur}
            disabled={disabled}
            required={required}
            rows={rows}
            className={baseInputClasses}
          />
        );
      }

      return (
        <input
          ref={ref as React.Ref<HTMLInputElement>}
          type={type}
          placeholder={placeholder}
          value={value}
          onChange={onChange}
          onBlur={onBlur}
          disabled={disabled}
          required={required}
          step={step}
          className={baseInputClasses}
        />
      );
    };

    return (
      <div className="space-y-2">
        {label && (
          <label className="block text-sm font-medium text-gray-700">
            {label}
            {required && <span className="text-red-500 ml-1">*</span>}
          </label>
        )}
        
        {renderInput()}
        
        {error && (
          <p className="text-sm text-red-500 mt-1">
            {error}
          </p>
        )}
      </div>
    );
  }
);

IOSInput.displayName = 'IOSInput';

export default IOSInput;
