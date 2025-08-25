import { storage } from './storage';
import { clientes } from './clientes';

export interface Invoice {
  id: string;
  userId: string;
  invoiceNumber: string;
  clientId: string;
  clientName: string;
  amount: number;
  description: string;
  issueDate: string;
  dueDate: string;
  status: 'pending' | 'paid' | 'overdue' | 'cancelled';
  category?: string;
  notes?: string;
  createdAt: string;
  paidAt?: string;
  paymentHistory: PaymentRecord[];
}

export interface PaymentRecord {
  id: string;
  amount: number;
  date: string;
  method?: string;
  notes?: string;
  createdAt: string;
}

export interface CreateInvoiceData {
  clientId: string;
  amount: number;
  description: string;
  issueDate: string;
  dueDate: string;
  category?: string;
  notes?: string;
}

export interface AddPaymentData {
  amount: number;
  date: string;
  method?: string;
  notes?: string;
}

const INVOICES_KEY = 'ios_app_invoices';
const INVOICE_COUNTER_KEY = 'ios_app_invoice_counter';

/**
 * Invoice management utilities with tracking functionality
 */
export const invoices = {
  /**
   * Generate next invoice number
   */
  generateInvoiceNumber: (): string => {
    const currentYear = new Date().getFullYear();
    const counter = storage.getItem(INVOICE_COUNTER_KEY, 0) || 0;
    const newCounter = counter + 1;
    storage.setItem(INVOICE_COUNTER_KEY, newCounter);
    
    return `FAC-${currentYear}-${newCounter.toString().padStart(4, '0')}`;
  },

  /**
   * Create a new invoice
   */
  createInvoice: (userId: string, data: CreateInvoiceData): { success: boolean; message: string; invoice?: Invoice } => {
    try {
      // Validate input
      if (!data.clientId || !data.description || !data.issueDate || !data.dueDate || data.amount <= 0) {
        return { success: false, message: 'Todos los campos requeridos deben ser completados' };
      }

      // Validate dates
      const issueDate = new Date(data.issueDate);
      const dueDate = new Date(data.dueDate);
      if (dueDate <= issueDate) {
        return { success: false, message: 'La fecha de vencimiento debe ser posterior a la fecha de emisión' };
      }

      // Get client info
      const client = clientes.getClienteById(data.clientId);
      if (!client) {
        return { success: false, message: 'Cliente no encontrado' };
      }

      // Create new invoice
      const newInvoice: Invoice = {
        id: Date.now().toString(),
        userId,
        invoiceNumber: invoices.generateInvoiceNumber(),
        clientId: data.clientId,
        clientName: client.name,
        amount: data.amount,
        description: data.description,
        issueDate: data.issueDate,
        dueDate: data.dueDate,
        status: 'pending',
        category: data.category || '',
        notes: data.notes || '',
        createdAt: new Date().toISOString(),
        paymentHistory: []
      };

      // Get existing invoices
      const allInvoices: Invoice[] = storage.getItem(INVOICES_KEY, []) || [];
      
      // Add new invoice
      allInvoices.push(newInvoice);
      storage.setItem(INVOICES_KEY, allInvoices);

      return { success: true, message: 'Factura creada exitosamente', invoice: newInvoice };
    } catch (error) {
      console.error('Error creating invoice:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Get invoices for a specific user
   */
  getUserInvoices: (userId: string): Invoice[] => {
    try {
      const allInvoices: Invoice[] = storage.getItem(INVOICES_KEY, []) || [];
      return allInvoices
        .filter(invoice => invoice.userId === userId)
        .map(invoice => invoices.updateInvoiceStatus(invoice))
        .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
    } catch (error) {
      console.error('Error getting user invoices:', error);
      return [];
    }
  },

  /**
   * Update invoice status based on due date and payments
   */
  updateInvoiceStatus: (invoice: Invoice): Invoice => {
    const today = new Date();
    const dueDate = new Date(invoice.dueDate);
    const totalPaid = invoice.paymentHistory.reduce((sum, payment) => sum + payment.amount, 0);

    let newStatus = invoice.status;

    if (invoice.status === 'cancelled') {
      return invoice;
    }

    if (totalPaid >= invoice.amount) {
      newStatus = 'paid';
    } else if (today > dueDate && invoice.status === 'pending') {
      newStatus = 'overdue';
    }

    return { ...invoice, status: newStatus };
  },

  /**
   * Add payment to invoice
   */
  addPayment: (invoiceId: string, userId: string, paymentData: AddPaymentData): { success: boolean; message: string; invoice?: Invoice } => {
    try {
      const allInvoices: Invoice[] = storage.getItem(INVOICES_KEY, []) || [];
      const invoiceIndex = allInvoices.findIndex(inv => inv.id === invoiceId && inv.userId === userId);
      
      if (invoiceIndex === -1) {
        return { success: false, message: 'Factura no encontrada' };
      }

      const invoice = allInvoices[invoiceIndex];
      
      if (invoice.status === 'cancelled') {
        return { success: false, message: 'No se puede agregar pago a una factura cancelada' };
      }

      // Validate payment amount
      const totalPaid = invoice.paymentHistory.reduce((sum, payment) => sum + payment.amount, 0);
      const remainingAmount = invoice.amount - totalPaid;
      
      if (paymentData.amount > remainingAmount) {
        return { success: false, message: `El pago no puede exceder el monto pendiente: ${remainingAmount.toFixed(2)}€` };
      }

      // Create payment record
      const newPayment: PaymentRecord = {
        id: Date.now().toString(),
        amount: paymentData.amount,
        date: paymentData.date,
        method: paymentData.method || '',
        notes: paymentData.notes || '',
        createdAt: new Date().toISOString()
      };

      // Update invoice
      const updatedInvoice = {
        ...invoice,
        paymentHistory: [...invoice.paymentHistory, newPayment],
        paidAt: totalPaid + paymentData.amount >= invoice.amount ? new Date().toISOString() : invoice.paidAt
      };

      // Update status
      const finalInvoice = invoices.updateInvoiceStatus(updatedInvoice);
      
      allInvoices[invoiceIndex] = finalInvoice;
      storage.setItem(INVOICES_KEY, allInvoices);

      return { success: true, message: 'Pago registrado exitosamente', invoice: finalInvoice };
    } catch (error) {
      console.error('Error adding payment:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Cancel invoice
   */
  cancelInvoice: (invoiceId: string, userId: string): { success: boolean; message: string } => {
    try {
      const allInvoices: Invoice[] = storage.getItem(INVOICES_KEY, []) || [];
      const invoiceIndex = allInvoices.findIndex(inv => inv.id === invoiceId && inv.userId === userId);
      
      if (invoiceIndex === -1) {
        return { success: false, message: 'Factura no encontrada' };
      }

      const invoice = allInvoices[invoiceIndex];
      
      if (invoice.status === 'paid') {
        return { success: false, message: 'No se puede cancelar una factura pagada' };
      }

      allInvoices[invoiceIndex] = { ...invoice, status: 'cancelled' };
      storage.setItem(INVOICES_KEY, allInvoices);

      return { success: true, message: 'Factura cancelada exitosamente' };
    } catch (error) {
      console.error('Error cancelling invoice:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Get invoice statistics
   */
  getInvoiceStats: (userId: string): {
    total: number;
    pending: number;
    paid: number;
    overdue: number;
    cancelled: number;
    totalAmount: number;
    paidAmount: number;
    pendingAmount: number;
  } => {
    try {
      const userInvoices = invoices.getUserInvoices(userId);
      
      const stats = {
        total: userInvoices.length,
        pending: 0,
        paid: 0,
        overdue: 0,
        cancelled: 0,
        totalAmount: 0,
        paidAmount: 0,
        pendingAmount: 0
      };

      userInvoices.forEach(invoice => {
        stats[invoice.status]++;
        stats.totalAmount += invoice.amount;
        
        const totalPaid = invoice.paymentHistory.reduce((sum, payment) => sum + payment.amount, 0);
        stats.paidAmount += totalPaid;
        
        if (invoice.status !== 'paid' && invoice.status !== 'cancelled') {
          stats.pendingAmount += (invoice.amount - totalPaid);
        }
      });

      return stats;
    } catch (error) {
      console.error('Error getting invoice stats:', error);
      return {
        total: 0,
        pending: 0,
        paid: 0,
        overdue: 0,
        cancelled: 0,
        totalAmount: 0,
        paidAmount: 0,
        pendingAmount: 0
      };
    }
  },

  /**
   * Get overdue invoices
   */
  getOverdueInvoices: (userId: string): Invoice[] => {
    return invoices.getUserInvoices(userId).filter(invoice => invoice.status === 'overdue');
  },

  /**
   * Get invoices by status
   */
  getInvoicesByStatus: (userId: string, status: Invoice['status']): Invoice[] => {
    return invoices.getUserInvoices(userId).filter(invoice => invoice.status === status);
  }
};
