import { storage } from './storage';

export interface Cliente {
  id: string;
  name: string;
  email: string;
  phone?: string;
  address?: string;
  createdAt: string;
}

export interface RegisterClienteData {
  name: string;
  email: string;
  phone?: string;
  address?: string;
}

const CLIENTES_KEY = 'ios_app_clientes';

/**
 * Customer management utilities for client registration and retrieval
 */
export const clientes = {
  /**
   * Register a new customer
   */
  registerCliente: (data: RegisterClienteData): { success: boolean; message: string; cliente?: Cliente } => {
    try {
      // Validate required fields
      if (!data.name || !data.email) {
        return { success: false, message: 'Nombre y email son requeridos' };
      }

      // Email validation
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(data.email)) {
        return { success: false, message: 'Email inválido' };
      }

      // Get existing customers
      const existingClientes: Cliente[] = storage.getItem(CLIENTES_KEY, []) || [];

      // Check if customer already exists with this email
      const existingCliente = existingClientes.find(cliente => cliente.email === data.email);
      if (existingCliente) {
        return { success: false, message: 'Ya existe un cliente con este email' };
      }

      // Create new customer
      const newCliente: Cliente = {
        id: Date.now().toString(),
        name: data.name.trim(),
        email: data.email.trim().toLowerCase(),
        phone: data.phone?.trim() || undefined,
        address: data.address?.trim() || undefined,
        createdAt: new Date().toISOString()
      };

      // Add customer to array
      existingClientes.push(newCliente);
      storage.setItem(CLIENTES_KEY, existingClientes);

      return { success: true, message: 'Cliente registrado exitosamente', cliente: newCliente };
    } catch (error) {
      console.error('Error registering cliente:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Get all customers
   */
  getClientes: (): Cliente[] => {
    try {
      return storage.getItem(CLIENTES_KEY, []) || [];
    } catch (error) {
      console.error('Error getting clientes:', error);
      return [];
    }
  },

  /**
   * Get customer by ID
   */
  getClienteById: (id: string): Cliente | null => {
    try {
      const clientes: Cliente[] = storage.getItem(CLIENTES_KEY, []) || [];
      return clientes.find(cliente => cliente.id === id) || null;
    } catch (error) {
      console.error('Error getting cliente by ID:', error);
      return null;
    }
  },

  /**
   * Get customers count
   */
  getClientesCount: (): number => {
    try {
      const clientes = storage.getItem(CLIENTES_KEY, []) || [];
      return clientes.length;
    } catch (error) {
      console.error('Error getting clientes count:', error);
      return 0;
    }
  }
};
