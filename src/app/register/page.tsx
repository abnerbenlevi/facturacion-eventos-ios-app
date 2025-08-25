"use client";

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import IOSNavBar from '@/components/IOSNavBar';
import IOSCard from '@/components/IOSCard';
import IOSButton from '@/components/IOSButton';
import IOSInput from '@/components/IOSInput';
import { auth } from '@/lib/auth';

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleInputChange = (field: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData(prev => ({
      ...prev,
      [field]: e.target.value
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      // Validate passwords match
      if (formData.password !== formData.confirmPassword) {
        setError('Las contraseñas no coinciden');
        setLoading(false);
        return;
      }

      const result = auth.registerUser({
        username: formData.username,
        email: formData.email,
        password: formData.password
      });
      
      if (result.success) {
        // Auto login after registration
        const loginResult = auth.loginUser({
          email: formData.email,
          password: formData.password
        });
        
        if (loginResult.success) {
          router.push('/dashboard');
        } else {
          router.push('/');
        }
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
      <IOSNavBar title="Crear Cuenta" showBackButton />
      
      <div className="pt-16 px-4 pb-8">
        <div className="mt-8 mb-8 text-center">
          <div className="w-20 h-20 bg-green-500 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            Crear Cuenta
          </h1>
          <p className="text-gray-600">
            Completa los datos para registrarte
          </p>
        </div>

        <IOSCard className="mb-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <IOSInput
              label="Nombre de Usuario"
              type="text"
              placeholder="Tu nombre de usuario"
              value={formData.username}
              onChange={handleInputChange('username')}
              required
            />

            <IOSInput
              label="Email"
              type="email"
              placeholder="tu@email.com"
              value={formData.email}
              onChange={handleInputChange('email')}
              required
            />

            <IOSInput
              label="Contraseña"
              type="password"
              placeholder="Mínimo 6 caracteres"
              value={formData.password}
              onChange={handleInputChange('password')}
              required
            />

            <IOSInput
              label="Confirmar Contraseña"
              type="password"
              placeholder="Repite tu contraseña"
              value={formData.confirmPassword}
              onChange={handleInputChange('confirmPassword')}
              required
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
              {loading ? 'Creando cuenta...' : 'Crear Cuenta'}
            </IOSButton>
          </form>
        </IOSCard>

        <IOSCard>
          <div className="text-center">
            <p className="text-gray-600 mb-3">
              ¿Ya tienes una cuenta?
            </p>
            <Link href="/">
              <IOSButton variant="secondary" fullWidth>
                Iniciar Sesión
              </IOSButton>
            </Link>
          </div>
        </IOSCard>
      </div>
    </div>
  );
}
