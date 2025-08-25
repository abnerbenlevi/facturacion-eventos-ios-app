"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import IOSNavBar from '@/components/IOSNavBar';
import IOSTabBar from '@/components/IOSTabBar';
import IOSCard from '@/components/IOSCard';
import IOSButton from '@/components/IOSButton';
import IOSInput from '@/components/IOSInput';
import { auth, User } from '@/lib/auth';
import { events, Event, CreateEventData } from '@/lib/events';

export default function EventsPage() {
  const [user, setUser] = useState<User | null>(null);
  const [userEvents, setUserEvents] = useState<Event[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [notificationPermission, setNotificationPermission] = useState<string>('default');
  const [formData, setFormData] = useState<CreateEventData>({
    name: '',
    description: '',
    date: new Date().toISOString().split('T')[0],
    time: '12:00',
    reminderEnabled: true,
    reminderMinutes: 15
  });
  const router = useRouter();

  useEffect(() => {
    const currentUser = auth.getCurrentUser();
    if (!currentUser) {
      router.push('/');
      return;
    }

    setUser(currentUser);
    loadEvents(currentUser.id);
    checkNotificationPermission();
  }, [router]);

  const loadEvents = (userId: string) => {
    const allEvents = events.getUserEvents(userId);
    setUserEvents(allEvents);
  };

  const checkNotificationPermission = () => {
    if ('Notification' in window) {
      setNotificationPermission(Notification.permission);
    }
  };

  const requestNotificationPermission = async () => {
    const granted = await events.requestNotificationPermission();
    setNotificationPermission(granted ? 'granted' : 'denied');
  };

  const handleInputChange = (field: keyof CreateEventData) => (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    let value: any = e.target.value;
    
    if (field === 'reminderEnabled') {
      value = (e.target as HTMLInputElement).checked;
    } else if (field === 'reminderMinutes') {
      value = parseInt(e.target.value) || 15;
    }
    
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
      const result = events.createEvent(user.id, formData);
      
      if (result.success) {
        setFormData({
          name: '',
          description: '',
          date: new Date().toISOString().split('T')[0],
          time: '12:00',
          reminderEnabled: true,
          reminderMinutes: 15
        });
        setShowForm(false);
        loadEvents(user.id);
      } else {
        setError(result.message);
      }
    } catch (error) {
      setError('Error interno del servidor');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = (eventId: string) => {
    if (!user) return;
    
    if (confirm('¿Estás seguro de que quieres eliminar este evento?')) {
      const result = events.deleteEvent(eventId, user.id);
      if (result.success) {
        loadEvents(user.id);
      }
    }
  };

  const formatDateTime = (dateStr: string, timeStr: string) => {
    const date = new Date(`${dateStr}T${timeStr}`);
    return date.toLocaleDateString('es-ES', {
      weekday: 'short',
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const isEventPast = (dateStr: string, timeStr: string) => {
    const eventDate = new Date(`${dateStr}T${timeStr}`);
    return eventDate < new Date();
  };

  const getUpcomingEvents = () => {
    const now = new Date();
    return userEvents.filter(event => {
      const eventDate = new Date(`${event.date}T${event.time}`);
      return eventDate > now;
    }).sort((a, b) => {
      const dateA = new Date(`${a.date}T${a.time}`);
      const dateB = new Date(`${b.date}T${b.time}`);
      return dateA.getTime() - dateB.getTime();
    });
  };

  const getPastEvents = () => {
    const now = new Date();
    return userEvents.filter(event => {
      const eventDate = new Date(`${event.date}T${event.time}`);
      return eventDate <= now;
    }).sort((a, b) => {
      const dateA = new Date(`${a.date}T${a.time}`);
      const dateB = new Date(`${b.date}T${b.time}`);
      return dateB.getTime() - dateA.getTime();
    });
  };

  const upcomingEvents = getUpcomingEvents();
  const pastEvents = getPastEvents();

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
        title="Eventos" 
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
        {/* Notification Permission */}
        {notificationPermission !== 'granted' && (
          <IOSCard className="mb-6 bg-yellow-50 border-yellow-200">
            <div className="flex items-start space-x-3">
              <div className="w-6 h-6 bg-yellow-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                <svg className="w-4 h-4 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-5 5v-5zM9 7h6m0 0V3m0 4l4-4M9 7L5 3m4 4v10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2h2z" />
                </svg>
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-yellow-800 mb-2">
                  Habilita las notificaciones
                </p>
                <p className="text-sm text-yellow-700 mb-3">
                  Para recibir recordatorios de tus eventos, necesitas permitir las notificaciones.
                </p>
                <IOSButton 
                  variant="secondary" 
                  size="sm"
                  onClick={requestNotificationPermission}
                >
                  Habilitar Notificaciones
                </IOSButton>
              </div>
            </div>
          </IOSCard>
        )}

        {/* New Event Form */}
        {showForm && (
          <IOSCard className="mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Nuevo Evento
            </h2>
            
            <form onSubmit={handleSubmit} className="space-y-4">
              <IOSInput
                label="Nombre del Evento"
                type="text"
                placeholder="Nombre del evento"
                value={formData.name}
                onChange={handleInputChange('name')}
                required
              />

              <IOSInput
                label="Descripción"
                type="textarea"
                placeholder="Descripción del evento (opcional)"
                value={formData.description}
                onChange={handleInputChange('description')}
                rows={3}
              />

              <div className="grid grid-cols-2 gap-4">
                <IOSInput
                  label="Fecha"
                  type="date"
                  value={formData.date}
                  onChange={handleInputChange('date')}
                  required
                />

                <IOSInput
                  label="Hora"
                  type="time"
                  value={formData.time}
                  onChange={handleInputChange('time')}
                  required
                />
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <label className="text-sm font-medium text-gray-700">
                    Recordatorio
                  </label>
                  <input
                    type="checkbox"
                    checked={formData.reminderEnabled}
                    onChange={handleInputChange('reminderEnabled')}
                    className="w-5 h-5 text-blue-500 rounded focus:ring-blue-500"
                  />
                </div>

                {formData.reminderEnabled && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Minutos antes del evento
                    </label>
                    <select
                      value={formData.reminderMinutes}
                      onChange={handleInputChange('reminderMinutes')}
                      className="w-full px-4 py-3 text-base bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                      <option value={5}>5 minutos</option>
                      <option value={15}>15 minutos</option>
                      <option value={30}>30 minutos</option>
                      <option value={60}>1 hora</option>
                      <option value={120}>2 horas</option>
                      <option value={1440}>1 día</option>
                    </select>
                  </div>
                )}
              </div>

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
                {loading ? 'Creando evento...' : 'Crear Evento'}
              </IOSButton>
            </form>
          </IOSCard>
        )}

        {/* Upcoming Events */}
        {upcomingEvents.length > 0 && (
          <IOSCard className="mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Próximos Eventos ({upcomingEvents.length})
            </h2>
            
            <div className="space-y-3">
              {upcomingEvents.map((event) => (
                <div key={event.id} className="p-3 bg-blue-50 border border-blue-100 rounded-lg">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <h3 className="font-medium text-gray-900">{event.name}</h3>
                      {event.description && (
                        <p className="text-sm text-gray-600 mt-1">{event.description}</p>
                      )}
                    </div>
                    <button
                      onClick={() => handleDelete(event.id)}
                      className="text-red-500 text-sm font-medium active:opacity-50 ml-2"
                    >
                      Eliminar
                    </button>
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <p className="text-sm text-blue-700 font-medium">
                      {formatDateTime(event.date, event.time)}
                    </p>
                    {event.reminderEnabled && (
                      <div className="flex items-center text-xs text-blue-600">
                        <svg className="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-5 5v-5z" />
                        </svg>
                        {event.reminderMinutes}min antes
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </IOSCard>
        )}

        {/* Past Events */}
        {pastEvents.length > 0 && (
          <IOSCard>
            <h2 className="text-lg font-semibold text-gray-900 mb-4">
              Eventos Pasados ({pastEvents.length})
            </h2>
            
            <div className="space-y-3">
              {pastEvents.slice(0, 5).map((event) => (
                <div key={event.id} className="p-3 bg-gray-50 rounded-lg opacity-75">
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <h3 className="font-medium text-gray-700">{event.name}</h3>
                      {event.description && (
                        <p className="text-sm text-gray-500 mt-1">{event.description}</p>
                      )}
                    </div>
                    <button
                      onClick={() => handleDelete(event.id)}
                      className="text-red-400 text-sm font-medium active:opacity-50 ml-2"
                    >
                      Eliminar
                    </button>
                  </div>
                  
                  <p className="text-sm text-gray-500">
                    {formatDateTime(event.date, event.time)}
                  </p>
                </div>
              ))}
              
              {pastEvents.length > 5 && (
                <p className="text-center text-sm text-gray-500 pt-2">
                  Y {pastEvents.length - 5} eventos más...
                </p>
              )}
            </div>
          </IOSCard>
        )}

        {/* Empty State */}
        {userEvents.length === 0 && (
          <IOSCard>
            <div className="text-center py-8">
              <div className="w-16 h-16 bg-gray-100 rounded-full mx-auto mb-4 flex items-center justify-center">
                <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <p className="text-gray-500 mb-2">No tienes eventos aún</p>
              <p className="text-sm text-gray-400">Crea tu primer evento con recordatorio</p>
            </div>
          </IOSCard>
        )}
      </div>

      <IOSTabBar />
    </div>
  );
}
