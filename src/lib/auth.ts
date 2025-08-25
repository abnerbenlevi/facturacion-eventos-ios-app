import { storage } from './storage';

export interface User {
  id: string;
  username: string;
  email: string;
  createdAt: string;
}

export interface RegisterData {
  username: string;
  email: string;
  password: string;
}

export interface LoginData {
  email: string;
  password: string;
}

const USERS_KEY = 'ios_app_users';
const CURRENT_USER_KEY = 'ios_app_current_user';

/**
 * Authentication utilities for user management
 */
export const auth = {
  /**
   * Register a new user
   */
  registerUser: (data: RegisterData): { success: boolean; message: string; user?: User } => {
    try {
      // Validate input
      if (!data.username || !data.email || !data.password) {
        return { success: false, message: 'Todos los campos son requeridos' };
      }

      if (data.password.length < 6) {
        return { success: false, message: 'La contraseña debe tener al menos 6 caracteres' };
      }

      // Email validation
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(data.email)) {
        return { success: false, message: 'Email inválido' };
      }

      // Get existing users
      const users: User[] = storage.getItem(USERS_KEY, []) || [];

      // Check if user already exists
      const existingUser = users.find(user => user.email === data.email);
      if (existingUser) {
        return { success: false, message: 'El usuario ya existe con este email' };
      }

      // Create new user
      const newUser: User = {
        id: Date.now().toString(),
        username: data.username,
        email: data.email,
        createdAt: new Date().toISOString()
      };

      // Store password separately (in real app, this would be hashed)
      const passwords: Record<string, string> = storage.getItem('ios_app_passwords', {}) || {};
      passwords[data.email] = data.password;
      storage.setItem('ios_app_passwords', passwords);

      // Add user to users array
      users.push(newUser);
      storage.setItem(USERS_KEY, users);

      return { success: true, message: 'Usuario registrado exitosamente', user: newUser };
    } catch (error) {
      console.error('Error registering user:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Login user
   */
  loginUser: (data: LoginData): { success: boolean; message: string; user?: User } => {
    try {
      // Validate input
      if (!data.email || !data.password) {
        return { success: false, message: 'Email y contraseña son requeridos' };
      }

      // Get users and passwords
      const users: User[] = storage.getItem(USERS_KEY, []) || [];
      const passwords: Record<string, string> = storage.getItem('ios_app_passwords', {}) || {};

      // Find user
      const user = users.find(u => u.email === data.email);
      if (!user) {
        return { success: false, message: 'Usuario no encontrado' };
      }

      // Verify password
      if (passwords[data.email] !== data.password) {
        return { success: false, message: 'Contraseña incorrecta' };
      }

      // Set current user
      storage.setItem(CURRENT_USER_KEY, user);

      return { success: true, message: 'Login exitoso', user };
    } catch (error) {
      console.error('Error logging in user:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Logout current user
   */
  logoutUser: (): boolean => {
    try {
      storage.removeItem(CURRENT_USER_KEY);
      return true;
    } catch (error) {
      console.error('Error logging out user:', error);
      return false;
    }
  },

  /**
   * Get current logged in user
   */
  getCurrentUser: (): User | null => {
    return storage.getItem(CURRENT_USER_KEY, null);
  },

  /**
   * Check if user is authenticated
   */
  isAuthenticated: (): boolean => {
    return auth.getCurrentUser() !== null;
  }
};
