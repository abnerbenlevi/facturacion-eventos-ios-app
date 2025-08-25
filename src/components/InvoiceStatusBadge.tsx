"use client";

interface InvoiceStatusBadgeProps {
  status: 'pending' | 'paid' | 'overdue' | 'cancelled';
  size?: 'sm' | 'md';
}

export default function InvoiceStatusBadge({ status, size = 'md' }: InvoiceStatusBadgeProps) {
  const sizeClasses = {
    sm: 'px-2 py-1 text-xs',
    md: 'px-3 py-1 text-sm'
  };

  const statusConfig = {
    pending: {
      label: 'Pendiente',
      classes: 'bg-yellow-100 text-yellow-800 border-yellow-200'
    },
    paid: {
      label: 'Pagada',
      classes: 'bg-green-100 text-green-800 border-green-200'
    },
    overdue: {
      label: 'Vencida',
      classes: 'bg-red-100 text-red-800 border-red-200'
    },
    cancelled: {
      label: 'Cancelada',
      classes: 'bg-gray-100 text-gray-800 border-gray-200'
    }
  };

  const config = statusConfig[status];

  return (
    <span className={`
      inline-flex items-center font-medium rounded-full border
      ${sizeClasses[size]}
      ${config.classes}
    `}>
      {config.label}
    </span>
  );
}
