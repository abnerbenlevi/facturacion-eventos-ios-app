"use client";

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import IOSNavBar from '@/components/IOSNavBar';
import IOSCard from '@/components/IOSCard';
import IOSButton from '@/components/IOSButton';
import IOSInput from '@/components/IOSInput';
import { clientes } from '@/lib/clientes';

export default function ClientesPage() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    address: ''
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleInputChange = (field: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData(prev => ({
      ...prev,
      [field]: e.target.value
    }));
    // Clear messages when user starts typing
    if (error) setError('');
    if (success) setSuccess('');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setLoading(true);

    try {
      // Validate required fields
      if (!formData.name.trim() || !formData.email.trim()) {
        setError('Nombre y email son requeridos');
        setLoading(false);
        return;
      }

      const result = clientes.registerCliente({
        name: formData.name,
        email: formData.email,
        phone: formData.phone || undefined,
        address: formData.address || undefined
      });
      
      if (result.success) {
        setSuccess('Cliente registrado exitosamente');
        // Clear form after successful registration
        setFormData({
          name: '',
          email: '',
          phone: '',
          address: ''
        });
        
        // Redirect to dashboard after 2 seconds
        setTimeout(() => {
          router.push('/dashboard');
        }, 2000);
      } else {
        setError(result.message);
      }
    } catch (error) {
      setError('Error interno del servidor');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <IOSNavBar title="Registrar Cliente" showBackButton />
      
      <div className="pt-16 px-4 pb-8">
        <div className="mt-8 mb-8 text-center">
          <div className="w-20 h-20 bg-blue-500 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            Nuevo Cliente
          </h1>
          <p className="text-gray-600">
            Completa los datos del cliente
          </p>
        </div>

        <IOSCard className="mb-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <IOSInput
              label="Nombre Completo"
              type="text"
              placeholder="Nombre del cliente"
              value={formData.name}
              onChange={handleInputChange('name')}
              required
            />

            <IOSInput
              label="Email"
              type="email"
              placeholder="cliente@email.com"
              value={formData.email}
              onChange={handleInputChange('email')}
              required
            />

            <IOSInput
              label="Teléfono (Opcional)"
              type="text"
              placeholder="+34 600 000 000"
              value={formData.phone}
              onChange={handleInputChange('phone')}
            />

            <IOSInput
              label="Dirección (Opcional)"
              type="text"
              placeholder="Dirección completa"
              value={formData.address}
              onChange={handleInputChange('address')}
            />

            {error && (
              <div className="bg-red-50 border border-red-200 rounded-xl p-3">
                <p className="text-red-600 text-sm">{error}</p>
              </div>
            )}

            {success && (
              <div className="bg-green-50 border border-green-200 rounded-xl p-3">
                <p className="text-green-600 text-sm">{success}</p>
              </div>
            )}

            <IOSButton
              type="submit"
              variant="primary"
              fullWidth
              disabled={loading}
            >
              {loading ? 'Registrando...' : 'Registrar Cliente'}
            </IOSButton>
          </form>
        </IOSCard>

        <IOSCard>
          <div className="text-center">
            <p className="text-gray-600 mb-3">
              ¿Quieres ver todos los clientes?
            </p>
            <IOSButton 
              variant="secondary" 
              fullWidth
              onClick={() => router.push('/dashboard')}
            >
              Volver al Dashboard
            </IOSButton>
          </div>
        </IOSCard>
      </div>
    </div>
  );
}
