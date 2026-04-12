-- Archivo SQL para ejecutar en la consola de Supabase (SQL Editor)
-- Esto añadirá la columna fcm_token a las tablas respectivas para poder guardar los tokens de Firebase.

ALTER TABLE info_arrendatarios
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

ALTER TABLE info_arrendadores
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Opcional: si deseas enviar notificaciones desde triggers en base de datos.
-- Puedes habilitar HTTP requests instalando la extensión de pg_net
-- CREATE EXTENSION IF NOT EXISTS pg_net;
