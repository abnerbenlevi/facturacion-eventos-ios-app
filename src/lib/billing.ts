import { storage } from './storage';

export interface BillingRecord {
  id: string;
  userId: string;
  amount: number;
  description: string;
  date: string;
  type: 'income' | 'expense';
  category?: string;
  createdAt: string;
}

export interface CreateBillingData {
  amount: number;
  description: string;
  date: string;
  type: 'income' | 'expense';
  category?: string;
}

const BILLING_KEY = 'ios_app_billing';

/**
 * Billing management utilities
 */
export const billing = {
  /**
   * Create a new billing record
   */
  createRecord: (userId: string, data: CreateBillingData): { success: boolean; message: string; record?: BillingRecord } => {
    try {
      // Validate input
      if (!data.description || !data.date || data.amount === undefined || data.amount === null) {
        return { success: false, message: 'Descripción, fecha y monto son requeridos' };
      }

      if (data.amount <= 0) {
        return { success: false, message: 'El monto debe ser mayor a 0' };
      }

      if (!data.type || (data.type !== 'income' && data.type !== 'expense')) {
        return { success: false, message: 'Tipo debe ser ingreso o gasto' };
      }

      // Create new billing record
      const newRecord: BillingRecord = {
        id: Date.now().toString(),
        userId,
        amount: data.amount,
        description: data.description,
        date: data.date,
        type: data.type,
        category: data.category || '',
        createdAt: new Date().toISOString()
      };

      // Get existing records
      const allRecords: BillingRecord[] = storage.getItem(BILLING_KEY, []) || [];
      
      // Add new record
      allRecords.push(newRecord);
      storage.setItem(BILLING_KEY, allRecords);

      return { success: true, message: 'Registro creado exitosamente', record: newRecord };
    } catch (error) {
      console.error('Error creating billing record:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Get billing records for a specific user
   */
  getUserRecords: (userId: string): BillingRecord[] => {
    try {
      const allRecords: BillingRecord[] = storage.getItem(BILLING_KEY, []) || [];
      return allRecords
        .filter(record => record.userId === userId)
        .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    } catch (error) {
      console.error('Error getting user billing records:', error);
      return [];
    }
  },

  /**
   * Update a billing record
   */
  updateRecord: (recordId: string, userId: string, data: Partial<CreateBillingData>): { success: boolean; message: string; record?: BillingRecord } => {
    try {
      const allRecords: BillingRecord[] = storage.getItem(BILLING_KEY, []) || [];
      const recordIndex = allRecords.findIndex(record => record.id === recordId && record.userId === userId);
      
      if (recordIndex === -1) {
        return { success: false, message: 'Registro no encontrado' };
      }

      // Update record
      const updatedRecord = {
        ...allRecords[recordIndex],
        ...data,
        id: recordId, // Ensure ID doesn't change
        userId: userId // Ensure userId doesn't change
      };

      allRecords[recordIndex] = updatedRecord;
      storage.setItem(BILLING_KEY, allRecords);

      return { success: true, message: 'Registro actualizado exitosamente', record: updatedRecord };
    } catch (error) {
      console.error('Error updating billing record:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Delete a billing record
   */
  deleteRecord: (recordId: string, userId: string): { success: boolean; message: string } => {
    try {
      const allRecords: BillingRecord[] = storage.getItem(BILLING_KEY, []) || [];
      const recordIndex = allRecords.findIndex(record => record.id === recordId && record.userId === userId);
      
      if (recordIndex === -1) {
        return { success: false, message: 'Registro no encontrado' };
      }

      allRecords.splice(recordIndex, 1);
      storage.setItem(BILLING_KEY, allRecords);

      return { success: true, message: 'Registro eliminado exitosamente' };
    } catch (error) {
      console.error('Error deleting billing record:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Get billing summary for a user
   */
  getUserSummary: (userId: string): { totalIncome: number; totalExpenses: number; balance: number; recordCount: number } => {
    try {
      const records = billing.getUserRecords(userId);
      
      const totalIncome = records
        .filter(record => record.type === 'income')
        .reduce((sum, record) => sum + record.amount, 0);
      
      const totalExpenses = records
        .filter(record => record.type === 'expense')
        .reduce((sum, record) => sum + record.amount, 0);
      
      return {
        totalIncome,
        totalExpenses,
        balance: totalIncome - totalExpenses,
        recordCount: records.length
      };
    } catch (error) {
      console.error('Error getting billing summary:', error);
      return {
        totalIncome: 0,
        totalExpenses: 0,
        balance: 0,
        recordCount: 0
      };
    }
  },

  /**
   * Get records by date range
   */
  getRecordsByDateRange: (userId: string, startDate: string, endDate: string): BillingRecord[] => {
    try {
      const records = billing.getUserRecords(userId);
      const start = new Date(startDate);
      const end = new Date(endDate);
      
      return records.filter(record => {
        const recordDate = new Date(record.date);
        return recordDate >= start && recordDate <= end;
      });
    } catch (error) {
      console.error('Error getting records by date range:', error);
      return [];
    }
  }
};
