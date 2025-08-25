import { storage } from './storage';

export interface Event {
  id: string;
  userId: string;
  name: string;
  description?: string;
  date: string;
  time: string;
  reminderEnabled: boolean;
  reminderMinutes: number;
  createdAt: string;
}

export interface CreateEventData {
  name: string;
  description?: string;
  date: string;
  time: string;
  reminderEnabled: boolean;
  reminderMinutes: number;
}

const EVENTS_KEY = 'ios_app_events';

/**
 * Event management utilities
 */
export const events = {
  /**
   * Create a new event
   */
  createEvent: (userId: string, data: CreateEventData): { success: boolean; message: string; event?: Event } => {
    try {
      // Validate input
      if (!data.name || !data.date || !data.time) {
        return { success: false, message: 'Nombre, fecha y hora son requeridos' };
      }

      // Validate date is not in the past
      const eventDateTime = new Date(`${data.date}T${data.time}`);
      if (eventDateTime < new Date()) {
        return { success: false, message: 'La fecha del evento no puede ser en el pasado' };
      }

      // Create new event
      const newEvent: Event = {
        id: Date.now().toString(),
        userId,
        name: data.name,
        description: data.description || '',
        date: data.date,
        time: data.time,
        reminderEnabled: data.reminderEnabled,
        reminderMinutes: data.reminderMinutes || 15,
        createdAt: new Date().toISOString()
      };

      // Get existing events
      const allEvents: Event[] = storage.getItem(EVENTS_KEY, []) || [];
      
      // Add new event
      allEvents.push(newEvent);
      storage.setItem(EVENTS_KEY, allEvents);

      // Schedule reminder if enabled
      if (data.reminderEnabled) {
        events.scheduleEventReminder(newEvent);
      }

      return { success: true, message: 'Evento creado exitosamente', event: newEvent };
    } catch (error) {
      console.error('Error creating event:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Get events for a specific user
   */
  getUserEvents: (userId: string): Event[] => {
    try {
      const allEvents: Event[] = storage.getItem(EVENTS_KEY, []) || [];
      return allEvents.filter(event => event.userId === userId);
    } catch (error) {
      console.error('Error getting user events:', error);
      return [];
    }
  },

  /**
   * Delete an event
   */
  deleteEvent: (eventId: string, userId: string): { success: boolean; message: string } => {
    try {
      const allEvents: Event[] = storage.getItem(EVENTS_KEY, []) || [];
      const eventIndex = allEvents.findIndex(event => event.id === eventId && event.userId === userId);
      
      if (eventIndex === -1) {
        return { success: false, message: 'Evento no encontrado' };
      }

      allEvents.splice(eventIndex, 1);
      storage.setItem(EVENTS_KEY, allEvents);

      return { success: true, message: 'Evento eliminado exitosamente' };
    } catch (error) {
      console.error('Error deleting event:', error);
      return { success: false, message: 'Error interno del servidor' };
    }
  },

  /**
   * Schedule a reminder for an event using browser notifications
   */
  scheduleEventReminder: async (event: Event): Promise<void> => {
    try {
      // Check if notifications are supported
      if (!('Notification' in window)) {
        console.warn('Este navegador no soporta notificaciones');
        return;
      }

      // Request permission if not granted
      let permission = Notification.permission;
      if (permission === 'default') {
        permission = await Notification.requestPermission();
      }

      if (permission !== 'granted') {
        console.warn('Permisos de notificación no concedidos');
        return;
      }

      // Calculate delay until reminder
      const eventDateTime = new Date(`${event.date}T${event.time}`);
      const reminderTime = new Date(eventDateTime.getTime() - (event.reminderMinutes * 60 * 1000));
      const delay = reminderTime.getTime() - Date.now();

      if (delay <= 0) {
        // Event is too soon or in the past
        return;
      }

      // Schedule the notification
      setTimeout(() => {
        new Notification(`Recordatorio: ${event.name}`, {
          body: `Tu evento "${event.name}" comenzará en ${event.reminderMinutes} minutos`,
          icon: '/favicon.ico',
          tag: `event-${event.id}`,
          requireInteraction: true
        });
      }, delay);

    } catch (error) {
      console.error('Error scheduling reminder:', error);
    }
  },

  /**
   * Request notification permissions
   */
  requestNotificationPermission: async (): Promise<boolean> => {
    try {
      if (!('Notification' in window)) {
        return false;
      }

      const permission = await Notification.requestPermission();
      return permission === 'granted';
    } catch (error) {
      console.error('Error requesting notification permission:', error);
      return false;
    }
  },

  /**
   * Check if notifications are supported and permitted
   */
  canSendNotifications: (): boolean => {
    return 'Notification' in window && Notification.permission === 'granted';
  }
};
