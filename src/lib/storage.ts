/**
 * Storage utility for localStorage operations with error handling
 */

export const storage = {
  /**
   * Get item from localStorage with error handling
   */
  getItem: <T>(key: string, defaultValue: T | null = null): T | null => {
    try {
      if (typeof window === 'undefined') return defaultValue;
      
      const item = localStorage.getItem(key);
      if (item === null) return defaultValue;
      
      return JSON.parse(item);
    } catch (error) {
      console.error(`Error getting item from localStorage: ${key}`, error);
      return defaultValue;
    }
  },

  /**
   * Set item in localStorage with error handling
   */
  setItem: <T>(key: string, value: T): boolean => {
    try {
      if (typeof window === 'undefined') return false;
      
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {
      console.error(`Error setting item in localStorage: ${key}`, error);
      return false;
    }
  },

  /**
   * Remove item from localStorage with error handling
   */
  removeItem: (key: string): boolean => {
    try {
      if (typeof window === 'undefined') return false;
      
      localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error(`Error removing item from localStorage: ${key}`, error);
      return false;
    }
  },

  /**
   * Clear all localStorage data
   */
  clear: (): boolean => {
    try {
      if (typeof window === 'undefined') return false;
      
      localStorage.clear();
      return true;
    } catch (error) {
      console.error('Error clearing localStorage', error);
      return false;
    }
  }
};
