"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import IOSNavBar from '@/components/IOSNavBar';
import IOSTabBar from '@/components/IOSTabBar';
import IOSCard from '@/components/IOSCard';
import IOSButton from '@/components/IOSButton';
import IOSInput from '@/components/IOSInput';
import InvoiceStatusBadge from '@/components/InvoiceStatusBadge';
import { auth, User } from '@/lib/auth';
import { invoices, Invoice, CreateInvoiceData, AddPaymentData } from '@/lib/invoices';
import { clientes, Cliente } from '@/lib/clientes';

type ViewMode = 'overview' | 'create' | 'payment';

export default function SeguimientoPage() {
  const [user, setUser] = useState<User | null>(null);
  const [userInvoices, setUserInvoices] = useState<Invoice[]>([]);
  const [clients, setClients] = useState<Cliente[]>([]);
  const [viewMode, setViewMode] = useState<ViewMode>('overview');
  const [selectedInvoice, setSelectedInvoice] = useState<Invoice | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState<'all' | 'pending' | 'paid' | 'overdue' | 'cancelled'>('all');
  
  const [invoiceForm, setInvoiceForm] = useState<CreateInvoiceData>({
    clientId: '',
    amount: 0,
    description: '',
    issueDate: new Date().toISOString().split('T')[0],
    dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0], // 30 days from now
    category: '',
    notes: ''
  });

  const [paymentForm, setPaymentForm] = useState<AddPaymentData>({
    amount: 0,
    date: new Date().toISOString().split('T')[0],
    method: '',
    notes: ''
  });

  const router = useRouter();

  useEffect(() => {
    const currentUser = auth.getCurrentUser();
    if (!currentUser) {
      router.push('/');
      return;
    }

    setUser(currentUser);
    loadData(currentUser.id);
  }, [router]);

  const loadData = (userId: string) => {
    const userInvoicesData = invoices.getUserInvoices(userId);
    const clientsData = clientes.getClientes();
    setUserInvoices(userInvoicesData);
    setClients(clientsData);
  };

  const handleCreateInvoice = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    setError('');
    setLoading(true);

    try {
      const result = invoices.createInvoice(user.id, invoiceForm);
      
      if (result.success) {
        setInvoiceForm({
          clientId: '',
          amount: 0,
          description: '',
          issueDate: new Date().toISOString().split('T')[0],
          dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
          category: '',
          notes: ''
        });
        setViewMode('overview');
        loadData(user.id);
      } else {
        setError(result.message);
      }
    } catch (error) {
      setError('Error interno del servidor');
    } finally {
      setLoading(false);
    }
  };

  const handleAddPayment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user || !selectedInvoice) return;

    setError('');
    setLoading(true);

    try {
      const result = invoices.addPayment(selectedInvoice.id, user.id, paymentForm);
      
      if (result.success) {
        setPaymentForm({
          amount: 0,
          date: new Date().toISOString().split('T')[0],
          method: '',
          notes: ''
        });
        setViewMode('overview');
        setSelectedInvoice(null);
        loadData(user.id);
      } else {
        setError(result.message);
      }
    } catch (error) {
      setError('Error interno del servidor');
    } finally {
      setLoading(false);
    }
  };

  const handleCancelInvoice = (invoice: Invoice) => {
    if (!user) return;
    
    if (confirm(`¿Estás seguro de que quieres cancelar la factura ${invoice.invoiceNumber}?`)) {
      const result = invoices.cancelInvoice(invoice.id, user.id);
      if (result.success) {
        loadData(user.id);
      }
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('es-ES', {
      style: 'currency',
      currency: 'EUR'
    }).format(amount);
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('es-ES', {
      day: 'numeric',
      month: 'short',
      year: 'numeric'
    });
  };

  const getDaysUntilDue = (dueDate: string) => {
    const today = new Date();
    const due = new Date(dueDate);
    const diffTime = due.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  const filteredInvoices = userInvoices.filter(invoice => {
    if (filter === 'all') return true;
    return invoice.status === filter;
  });

  const stats = user ? invoices.getInvoiceStats(user.id) : null;

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
        title="Seguimiento" 
        showBackButton={viewMode !== 'overview'}
        onBack={() => {
          setViewMode('overview');
          setSelectedInvoice(null);
          setError('');
        }}
        rightButton={
          viewMode === 'overview' ? (
            <IOSButton 
              variant="primary" 
              size="sm" 
              onClick={() => setViewMode('create')}
            >
              Nueva
            </IOSButton>
          ) : null
        }
      />
      
      <div className="pt-16 pb-24 px-4">
        {viewMode === 'overview' && (
          <>
            {/* Statistics Cards */}
            {stats && (
              <div className="grid grid-cols-2 gap-4 mb-6">
                <IOSCard padding="sm">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-blue-600">{stats.total}</p>
                    <p className="text-sm text-gray-600">Total Facturas</p>
                  </div>
                </IOSCard>
                <IOSCard padding="sm">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-green-600">{formatCurrency(stats.paidAmount)}</p>
                    <p className="text-sm text-gray-600">Cobrado</p>
                  </div>
                </IOSCard>
                <IOSCard padding="sm">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-yellow-600">{stats.pending}</p>
                    <p className="text-sm text-gray-600">Pendientes</p>
                  </div>
                </IOSCard>
                <IOSCard padding="sm">
                  <div className="text-center">
                    <p className="text-2xl font-bold text-red-600">{stats.overdue}</p>
                    <p className="text-sm text-gray-600">Vencidas</p>
                  </div>
                </IOSCard>
              </div>
            )}

            {/* Filter Buttons */}
            <IOSCard className="mb-6">
              <div className="flex flex-wrap gap-2">
                {[
                  { key: 'all', label: 'Todas' },
                  { key: 'pending', label: 'Pendientes' },
                  { key: 'paid', label: 'Pagadas' },
                  { key: 'overdue', label: 'Vencidas' },
                  { key: 'cancelled', label: 'Canceladas' }
                ].map(({ key, label }) => (
                  <button
                    key={key}
                    onClick={() => setFilter(key as any)}
                    className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                      filter === key
                        ? 'bg-blue-500 text-white'
                        : 'bg-gray-100 text-gray-700 active:bg-gray-200'
                    }`}
                  >
                    {label}
                  </button>
                ))}
              </div>
            </IOSCard>

            {/* Invoices List */}
            <IOSCard>
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-semibold text-gray-900">Facturas</h2>
                <span className="text-sm text-gray-500">
                  {filteredInvoices.length} facturas
                </span>
              </div>
              
              {filteredInvoices.length > 0 ? (
                <div className="space-y-3">
                  {filteredInvoices.map((invoice) => {
                    const totalPaid = invoice.paymentHistory.reduce((sum, payment) => sum + payment.amount, 0);
                    const remainingAmount = invoice.amount - totalPaid;
                    const daysUntilDue = getDaysUntilDue(invoice.dueDate);
                    
                    return (
                      <div key={invoice.id} className="p-4 bg-gray-50 rounded-lg">
                        <div className="flex items-start justify-between mb-2">
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-1">
                              <p className="font-semibold text-gray-900">{invoice.invoiceNumber}</p>
                              <InvoiceStatusBadge status={invoice.status} size="sm" />
                            </div>
                            <p className="text-sm text-gray-600 mb-1">{invoice.clientName}</p>
                            <p className="text-sm text-gray-800">{invoice.description}</p>
                          </div>
                          <div className="text-right">
                            <p className="font-semibold text-gray-900">{formatCurrency(invoice.amount)}</p>
                            {totalPaid > 0 && (
                              <p className="text-sm text-green-600">Pagado: {formatCurrency(totalPaid)}</p>
                            )}
                          </div>
                        </div>
                        
                        <div className="flex items-center justify-between text-sm text-gray-600 mb-3">
                          <span>Vence: {formatDate(invoice.dueDate)}</span>
                          {invoice.status === 'pending' && daysUntilDue <= 7 && daysUntilDue > 0 && (
                            <span className="text-orange-600 font-medium">
                              Vence en {daysUntilDue} días
                            </span>
                          )}
                          {invoice.status === 'overdue' && (
                            <span className="text-red-600 font-medium">
                              Vencida hace {Math.abs(daysUntilDue)} días
                            </span>
                          )}
                        </div>

                        <div className="flex gap-2">
                          {invoice.status !== 'paid' && invoice.status !== 'cancelled' && (
                            <button
                              onClick={() => {
                                setSelectedInvoice(invoice);
                                setPaymentForm({
                                  ...paymentForm,
                                  amount: remainingAmount
                                });
                                setViewMode('payment');
                              }}
                              className="flex-1 px-3 py-2 bg-green-500 text-white text-sm font-medium rounded-lg active:bg-green-600"
                            >
                              Registrar Pago
                            </button>
                          )}
                          {invoice.status === 'pending' && (
                            <button
                              onClick={() => handleCancelInvoice(invoice)}
                              className="px-3 py-2 bg-red-500 text-white text-sm font-medium rounded-lg active:bg-red-600"
                            >
                              Cancelar
                            </button>
                          )}
                        </div>
                      </div>
                    );
                  })}
                </div>
              ) : (
                <div className="text-center py-8">
                  <div className="w-16 h-16 bg-gray-100 rounded-full mx-auto mb-4 flex items-center justify-center">
                    <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                    </svg>
                  </div>
                  <p className="text-gray-500 mb-2">No hay facturas {filter !== 'all' ? filter : ''}</p>
                  <p className="text-sm text-gray-400">Crea tu primera factura para comenzar el seguimiento</p>
                </div>
              )}
            </IOSCard>
          </>
        )}

        {viewMode === 'create' && (
          <IOSCard>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Nueva Factura
            </h2>
            
            <form onSubmit={handleCreateInvoice} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Cliente *
                </label>
                <select
                  value={invoiceForm.clientId}
                  onChange={(e) => setInvoiceForm(prev => ({ ...prev, clientId: e.target.value }))}
                  className="w-full px-4 py-3 text-base bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  required
                >
                  <option value="">Seleccionar cliente</option>
                  {clients.map(client => (
                    <option key={client.id} value={client.id}>{client.name}</option>
                  ))}
                </select>
              </div>

              <IOSInput
                label="Monto"
                type="number"
                step="0.01"
                placeholder="0.00"
                value={invoiceForm.amount}
                onChange={(e) => setInvoiceForm(prev => ({ ...prev, amount: parseFloat(e.target.value) || 0 }))}
                required
              />

              <IOSInput
                label="Descripción"
                type="text"
                placeholder="Descripción de la factura"
                value={invoiceForm.description}
                onChange={(e) => setInvoiceForm(prev => ({ ...prev, description: e.target.value }))}
                required
              />

              <div className="grid grid-cols-2 gap-4">
                <IOSInput
                  label="Fecha de Emisión"
                  type="date"
                  value={invoiceForm.issueDate}
                  onChange={(e) => setInvoiceForm(prev => ({ ...prev, issueDate: e.target.value }))}
                  required
                />

                <IOSInput
                  label="Fecha de Vencimiento"
                  type="date"
                  value={invoiceForm.dueDate}
                  onChange={(e) => setInvoiceForm(prev => ({ ...prev, dueDate: e.target.value }))}
                  required
                />
              </div>

              <IOSInput
                label="Categoría"
                type="text"
                placeholder="Categoría (opcional)"
                value={invoiceForm.category}
                onChange={(e) => setInvoiceForm(prev => ({ ...prev, category: e.target.value }))}
              />

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Notas
                </label>
                <textarea
                  value={invoiceForm.notes}
                  onChange={(e) => setInvoiceForm(prev => ({ ...prev, notes: e.target.value }))}
                  placeholder="Notas adicionales (opcional)"
                  rows={3}
                  className="w-full px-4 py-3 text-base bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                />
              </div>

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-xl p-3">
                  <p className="text-red-600 text-sm">{error}</p>
                </div>
              )}

              <IOSButton
                type="submit"
                variant="primary"
                fullWidth
                disabled={loading}
              >
                {loading ? 'Creando...' : 'Crear Factura'}
              </IOSButton>
            </form>
          </IOSCard>
        )}

        {viewMode === 'payment' && selectedInvoice && (
          <IOSCard>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Registrar Pago
            </h2>
            
            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <div className="flex items-center justify-between mb-2">
                <span className="font-medium">{selectedInvoice.invoiceNumber}</span>
                <InvoiceStatusBadge status={selectedInvoice.status} size="sm" />
              </div>
              <p className="text-sm text-gray-600 mb-2">{selectedInvoice.clientName}</p>
              <div className="flex justify-between text-sm">
                <span>Total factura:</span>
                <span className="font-medium">{formatCurrency(selectedInvoice.amount)}</span>
              </div>
              {selectedInvoice.paymentHistory.length > 0 && (
                <div className="flex justify-between text-sm">
                  <span>Ya pagado:</span>
                  <span className="font-medium text-green-600">
                    {formatCurrency(selectedInvoice.paymentHistory.reduce((sum, p) => sum + p.amount, 0))}
                  </span>
                </div>
              )}
              <div className="flex justify-between text-sm font-medium border-t border-gray-200 pt-2 mt-2">
                <span>Pendiente:</span>
                <span className="text-red-600">
                  {formatCurrency(selectedInvoice.amount - selectedInvoice.paymentHistory.reduce((sum, p) => sum + p.amount, 0))}
                </span>
              </div>
            </div>
            
            <form onSubmit={handleAddPayment} className="space-y-4">
              <IOSInput
                label="Monto del Pago"
                type="number"
                step="0.01"
                placeholder="0.00"
                value={paymentForm.amount}
                onChange={(e) => setPaymentForm(prev => ({ ...prev, amount: parseFloat(e.target.value) || 0 }))}
                required
              />

              <IOSInput
                label="Fecha del Pago"
                type="date"
                value={paymentForm.date}
                onChange={(e) => setPaymentForm(prev => ({ ...prev, date: e.target.value }))}
                required
              />

              <IOSInput
                label="Método de Pago"
                type="text"
                placeholder="Transferencia, efectivo, etc. (opcional)"
                value={paymentForm.method}
                onChange={(e) => setPaymentForm(prev => ({ ...prev, method: e.target.value }))}
              />

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Notas
                </label>
                <textarea
                  value={paymentForm.notes}
                  onChange={(e) => setPaymentForm(prev => ({ ...prev, notes: e.target.value }))}
                  placeholder="Notas del pago (opcional)"
                  rows={3}
                  className="w-full px-4 py-3 text-base bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                />
              </div>

              {error && (
                <div className="bg-red-50 border border-red-200 rounded-xl p-3">
                  <p className="text-red-600 text-sm">{error}</p>
                </div>
              )}

              <IOSButton
                type="submit"
                variant="primary"
                fullWidth
                disabled={loading}
              >
                {loading ? 'Registrando...' : 'Registrar Pago'}
              </IOSButton>
            </form>
          </IOSCard>
        )}
      </div>

      <IOSTabBar />
    </div>
  );
}
