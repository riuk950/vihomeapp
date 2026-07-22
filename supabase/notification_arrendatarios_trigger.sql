-- =====================================================================================
-- Configuración del Trigger de Webhook en Supabase para notificación de Arrendatarios
-- =====================================================================================
--
-- Tienes dos opciones para configurar esto:
--
-- OPCIÓN 1: Desde la Interfaz de Supabase (Recomendado)
-- 1. Ve a tu Dashboard de Supabase -> Integrations -> Webhooks.
-- 2. Haz clic en "Create Webhook".
-- 3. Configura:
--    - Name: `on_solicitud_updated_webhook`
--    - Table: `solicitudes`
--    - Events: Selecciona únicamente `Update`
--    - Method: `POST`
--    - URL: `https://atbxaoqjgogxrumujohc.supabase.co/functions/v1/notification_arrendatarios`
--    - Headers:
--        * Content-Type: `application/json`
--        * Authorization: `Bearer [TU_SUPABASE_SERVICE_ROLE_KEY]`
--
-- OPCIÓN 2: Usando SQL directo (Editor de SQL en Supabase)
-- Ejecuta el siguiente bloque SQL para crear el trigger del Webhook automáticamente:

-- 1. Crear el trigger para invocar la Edge Function cuando cambie el estado de la solicitud
CREATE OR REPLACE TRIGGER on_solicitud_estado_updated
  AFTER UPDATE OF estado ON public.solicitudes
  FOR EACH ROW
  WHEN (OLD.estado IS DISTINCT FROM NEW.estado AND NEW.estado IN ('aceptada', 'rechazada'))
  EXECUTE FUNCTION supabase_functions.http_request(
    'https://atbxaoqjgogxrumujohc.supabase.co/functions/v1/notification_arrendatarios',
    'POST',
    '{"Content-Type":"application/json","Authorization":"Bearer [TU_SUPABASE_SERVICE_ROLE_KEY]"}',
    '{}',
    '5000'
  );
