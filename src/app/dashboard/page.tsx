"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import IOSNavBar from '@/components/IOSNavBar';
import IOSTabBar from '@/components/IOSTabBar';
import IOSCard from '@/components/IOSCard';
import IOSButton from '@/components/IOSButton';
import { auth, User } from '@/lib/auth';
import { billing } from '@/lib/billing';
import { events } from '@/lib/events';
import { invoices } from '@/lib/invoices';

export default function DashboardPage() {
  const [user, setUser] = useState<User | null>(null);
  const [billingSummary, setBillingSummary] = useState({
    totalIncome: 0,
    totalExpenses: 0,
    balance: 0,
    recordCount: 0
  });
  const [invoiceStats, setInvoiceStats] = useState({
    total: 0,
    pending: 0,
    paid: 0,
    overdue: 0,
    cancelled: 0,
    totalAmount: 0,
    paidAmount: 0,
    pendingAmount: 0
  });
  const [upcomingEvents, setUpcomingEvents] = useState<any[]>([]);
  const [overdueInvoices, setOverdueInvoices] = useState<any[]>([]);
  const router = useRouter();

  useEffect(() => {
    const currentUser = auth.getCurrentUser();
    if (!currentUser) {
      router.push('/');
      return;
    }

    setUser(currentUser);
    
    // Load billing summary
    const summary = billing.getUserSummary(currentUser.id);
    setBillingSummary(summary);

    // Load invoice statistics
    const invoiceStatistics = invoices.getInvoiceStats(currentUser.id);
    setInvoiceStats(invoiceStatistics);

    // Load overdue invoices
    const overdue = invoices.getOverdueInvoices(currentUser.id);
    setOverdueInvoices(overdue);

    // Load upcoming events
    const userEvents = events.getUserEvents(currentUser.id);
    const now = new Date();
    const upcoming = userEvents
      .filter(event => {
        const eventDate = new Date(`${event.date}T${event.time}`);
        return eventDate > now;
      })
      .sort((a, b) => {
        const dateA = new Date(`${a.date}T${a.time}`);
        const dateB = new Date(`${b.date}T${b.time}`);
        return dateA.getTime() - dateB.getTime();
      })
      .slice(0, 3);
    
    setUpcomingEvents(upcoming);
  }, [router]);

  const handleLogout = () => {
    auth.logoutUser();
    router.push('/');
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-ES', {
      style: 'currency',
      currency: 'EUR'
    }).format(amount);
  };

  const formatDate = (dateStr: string, timeStr: string) => {
    const date = new Date(`${dateStr}T${timeStr}`);
    return date.toLocaleDateString('es-ES', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
          <p className="mt-2 text-gray-600">Cargando...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <IOSNavBar 
        title="Dashboard" 
        rightButton={
          <IOSButton 
            variant="secondary" 
            size="sm" 
            onClick={handleLogout}
          >
            Salir
          </IOSButton>
        }
      />
      
      <div className="pt-16 pb-24 px-4">
        {/* Welcome Section */}
        <div className="mt-6 mb-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            ¡Hola, {user.username}!
          </h1>
          <p className="text-gray-600">
            Bienvenido a tu panel de control
          </p>
        </div>

        {/* Financial Summary */}
        <div className="grid grid-cols-1 gap-4 mb-6">
          {/* Billing Summary */}
          <IOSCard>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">
                Gastos Generales
              </h2>
              <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                <svg className="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                </svg>
              </div>
            </div>
            
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div className="text-center">
                <p className="text-sm text-gray-600">Ingresos</p>
                <p className="text-lg font-semibold text-green-600">
                  {formatCurrency(billingSummary.totalIncome)}
                </p>
              </div>
              <div className="text-center">
                <p className="text-sm text-gray-600">Gastos</p>
                <p className="text-lg font-semibold text-red-600">
                  {formatCurrency(billingSummary.totalExpenses)}
                </p>
              </div>
            </div>
            
            <div className="border-t border-gray-100 pt-4">
              <div className="text-center">
                <p className="text-sm text-gray-600">Balance</p>
                <p className={`text-xl font-bold ${billingSummary.balance >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                  {formatCurrency(billingSummary.balance)}
                </p>
              </div>
            </div>
          </IOSCard>

          {/* Invoice Summary */}
          <IOSCard>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gray-900">
                Seguimiento de Facturas
              </h2>
              <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                <svg className="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
              </div>
            </div>
            
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div className="text-center">
                <p className="text-sm text-gray-600">Pendientes</p>
                <p className="text-lg font-semibold text-yellow-600">
                  {invoiceStats.pending}
                </p>
              </div>
              <div className="text-center">
                <p className="text-sm text-gray-600">Vencidas</p>
                <p className="text-lg font-semibold text-red-600">
                  {invoiceStats.overdue}
                </p>
              </div>
            </div>
            
            <div className="border-t border-gray-100 pt-4">
              <div className="text-center">
                <p className="text-sm text-gray-600">Por Cobrar</p>
                <p className="text-xl font-bold text-blue-600">
                  {formatCurrency(invoiceStats.pendingAmount)}
                </p>
              </div>
            </div>
          </IOSCard>
        </div>

        {/* Overdue Invoices Alert */}
        {overdueInvoices.length > 0 && (
          <IOSCard className="mb-6 bg-red-50 border-red-200">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center">
                <div className="w-8 h-8 bg-red-100 rounded-full flex items-center justify-center mr-3">
                  <svg className="w-4 h-4 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z" />
                  </svg>
                </div>
                <div>
                  <h3 className="font-semibold text-red-900">Facturas Vencidas</h3>
                  <p className="text-sm text-red-700">Tienes {overdueInvoices.length} facturas vencidas</p>
                </div>
              </div>
              <IOSButton 
                variant="primary" 
                size="sm"
                onClick={() => router.push('/seguimiento')}
              >
                Ver Todas
              </IOSButton>
            </div>
          </IOSCard>
        )}

        {/* Upcoming Events */}
        <IOSCard className="mb-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">
              Próximos Eventos
            </h2>
            <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
              <svg className="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </div>
          </div>
          
          {upcomingEvents.length > 0 ? (
            <div className="space-y-3">
              {upcomingEvents.map((event) => (
                <div key={event.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div>
                    <p className="font-medium text-gray-900">{event.name}</p>
                    <p className="text-sm text-gray-600">
                      {formatDate(event.date, event.time)}
                    </p>
                  </div>
                  {event.reminderEnabled && (
                    <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-4">
              <p className="text-gray-500">No tienes eventos próximos</p>
            </div>
          )}
        </IOSCard>

        {/* Quick Actions */}
        <IOSCard>
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Acciones Rápidas
          </h2>
          
          <div className="grid grid-cols-3 gap-3">
            <IOSButton 
              variant="primary" 
              size="sm"
              onClick={() => router.push('/seguimiento')}
            >
              Nueva Factura
            </IOSButton>
            <IOSButton 
              variant="secondary" 
              size="sm"
              onClick={() => router.push('/events')}
            >
              Nuevo Evento
            </IOSButton>
            <IOSButton 
              variant="secondary" 
              size="sm"
              onClick={() => router.push('/clientes')}
            >
              Registrar Cliente
            </IOSButton>
          </div>
        </IOSCard>
      </div>

      <IOSTabBar />
    </div>
  );
}
