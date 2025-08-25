"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import IOSNavBar from '@/components/IOSNavBar';
import IOSTabBar from '@/components/IOSTabBar';
import IOSCard from '@/components/IOSCard';
import IOSButton from '@/components/IOSButton';
import IOSInput from '@/components/IOSInput';
import { auth, User } from '@/lib/auth';
import { billing, BillingRecord, CreateBillingData } from '@/lib/billing';

export default function BillingPage() {
  const [user, setUser] = useState<User | null>(null);
  const [records, setRecords] = useState<BillingRecord[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState<CreateBillingData>({
    amount: 0,
    description: '',
    date: new Date().toISOString().split('T')[0],
    type: 'income',
    category: ''
  });
  const router = useRouter();

  useEffect(() => {
    const currentUser = auth.getCurrentUser();
    if (!currentUser) {
      router.push('/');
      return;
    }

    setUser(currentUser);
    loadRecords(currentUser.id);
  }, [router]);

  const loadRecords = (userId: string) => {
    const userRecords = billing.getUserRecords(userId);
    setRecords(userRecords);
  };

  const handleInputChange = (field: keyof CreateBillingData) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const value = field === 'amount' ? parseFloat(e.target.value) || 0 : e.target.value;
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    setError('');
    setLoading(true);

    try {
      const result = billing.createRecord(user.id, formData);
      
      if (result.success) {
        setFormData({
          amount: 0,
          description: '',
          date: new Date().toISOString().split('T')[0],
          type: 'income',
          category: ''
        });
        setShowForm(false);
        loadRecords(user.id);
      } else {
        setError(result.message);
      }
    } catch (error) {
      setError('Error interno del servidor');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = (recordId: string) => {
    if (!user) return;
    
    if (confirm('¿Estás seguro de que quieres eliminar este registro?')) {
      const result = billing.deleteRecord(recordId, user.id);
      if (result.success) {
        loadRecords(user.id);
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

  const summary = user ? billing.getUserSummary(user.id) : null;

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
        title="Facturación" 
        rightButton={
          <IOSButton 
            variant="primary" 
            size="sm" 
            onClick={() => setShowForm(!showForm)}
          >
            {showForm ? 'Cancelar' : 'Nuevo'}
          </IOSButton>
        }
      />
      
      <div className="pt-16 pb-24 px-4">
        {/* Summary Card */}
        {summary && (
          <IOSCard className="mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Resumen Financiero
            </h2>
            
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div className="text-center">
                <p className="text-sm text-gray-600">Ingresos</p>
                <p className="text-lg font-semibold text-green-600">
                  {formatCurrency(summary.totalIncome)}
                </p>
              </div>
              <div className="text-center">
                <p className="text-sm text-gray-600">Gastos</p>
                <p className="text-lg font-semibold text-red-600">
                  {formatCurrency(summary.totalExpenses)}
                </p>
              </div>
            </div>
            
            <div className="border-t border-gray-100 pt-4">
              <div className="text-center">
                <p className="text-sm text-gray-600">Balance Total</p>
                <p className={`text-xl font-bold ${summary.balance >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                  {formatCurrency(summary.balance)}
                </p>
              </div>
            </div>
          </IOSCard>
        )}

        {/* New Record Form */}
        {showForm && (
          <IOSCard className="mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Nuevo Registro
            </h2>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Tipo *
                </label>
                <select
                  value={formData.type}
                  onChange={handleInputChange('type')}
                  className="w-full px-4 py-3 text-base bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  required
                >
                  <option value="income">Ingreso</option>
                  <option value="expense">Gasto</option>
                </select>
              </div>

              <IOSInput
                label="Monto"
                type="number"
                placeholder="0.00"
                value={formData.amount}
                onChange={handleInputChange('amount')}
                required
              />

              <IOSInput
                label="Descripción"
                type="text"
                placeholder="Descripción del registro"
                value={formData.description}
                onChange={handleInputChange('description')}
                required
              />

              <IOSInput
                label="Fecha"
                type="date"
                value={formData.date}
                onChange={handleInputChange('date')}
                required
              />

              <IOSInput
                label="Categoría"
                type="text"
                placeholder="Categoría (opcional)"
                value={formData.category}
                onChange={handleInputChange('category')}
              />

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
                {loading ? 'Guardando...' : 'Guardar Registro'}
              </IOSButton>
            </form>
          </IOSCard>
        )}

        {/* Records List */}
        <IOSCard>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">
              Registros Recientes
            </h2>
            <span className="text-sm text-gray-500">
              {records.length} registros
            </span>
          </div>
          
          {records.length > 0 ? (
            <div className="space-y-3">
              {records.map((record) => (
                <div key={record.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-1">
                      <p className="font-medium text-gray-900">{record.description}</p>
                      <p className={`font-semibold ${record.type === 'income' ? 'text-green-600' : 'text-red-600'}`}>
                        {record.type === 'income' ? '+' : '-'}{formatCurrency(record.amount)}
                      </p>
                    </div>
                    <div className="flex items-center justify-between">
                      <p className="text-sm text-gray-600">
                        {formatDate(record.date)}
                        {record.category && ` • ${record.category}`}
                      </p>
                      <button
                        onClick={() => handleDelete(record.id)}
                        className="text-red-500 text-sm font-medium active:opacity-50"
                      >
                        Eliminar
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <div className="w-16 h-16 bg-gray-100 rounded-full mx-auto mb-4 flex items-center justify-center">
                <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                </svg>
              </div>
              <p className="text-gray-500 mb-2">No tienes registros aún</p>
              <p className="text-sm text-gray-400">Crea tu primer registro financiero</p>
            </div>
          )}
        </IOSCard>
      </div>

      <IOSTabBar />
    </div>
  );
}
