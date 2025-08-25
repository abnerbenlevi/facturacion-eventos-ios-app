"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import IOSNavBar from '@/components/IOSNavBar';
import IOSCard from '@/components/IOSCard';
import IOSButton from '@/components/IOSButton';
import IOSInput from '@/components/IOSInput';
import { auth } from '@/lib/auth';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  useEffect(() => {
    // Check if user is already logged in
    if (auth.isAuthenticated()) {
      router.push('/dashboard');
    }
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const result = auth.loginUser({ email, password });
      
      if (result.success) {
        router.push('/dashboard');
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
      <IOSNavBar title="Iniciar Sesión" />
      
      <div className="pt-16 px-4 pb-8">
        <div className="mt-8 mb-8 text-center">
          <div className="w-20 h-20 bg-blue-500 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg className="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
            </svg>
          </div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">
            Bienvenido
          </h1>
          <p className="text-gray-600">
            Inicia sesión para continuar
          </p>
        </div>

        <IOSCard className="mb-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            <IOSInput
              label="Email"
              type="email"
              placeholder="tu@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />

            <IOSInput
              label="Contraseña"
              type="password"
              placeholder="Tu contraseña"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
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
              {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
            </IOSButton>
          </form>
        </IOSCard>

        <IOSCard>
          <div className="text-center">
            <p className="text-gray-600 mb-3">
              ¿No tienes una cuenta?
            </p>
            <Link href="/register">
              <IOSButton variant="secondary" fullWidth>
                Crear Cuenta
              </IOSButton>
            </Link>
          </div>
        </IOSCard>

        <div className="mt-8 text-center">
          <p className="text-xs text-gray-500">
            Aplicación optimizada para iPhone
          </p>
        </div>
      </div>
    </div>
  );
}
