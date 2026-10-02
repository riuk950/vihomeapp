-- ====================================================================
-- Script DDL: Creación de tabla 'reviews' en Supabase para ViHome
-- ====================================================================

-- 1. Crear tabla de calificaciones
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- solicitud_id es opcional para calificaciones de verificación inicial de perfil (RF-36)
    solicitud_id UUID REFERENCES public.solicitudes(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reviewer_name TEXT,
    target_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment VARCHAR(500) DEFAULT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    
    -- Restricción: Una sola calificación por emisor en cada solicitud (RF-23.2, CL-20)
    CONSTRAINT unique_review_per_solicitud_user UNIQUE (solicitud_id, reviewer_id),
    -- Restricción: Impedir auto-calificación en transacciones de arriendo (RF-23.3, CL-22)
    CONSTRAINT check_no_self_review CHECK ((reviewer_id <> target_user_id) OR (solicitud_id IS NULL))
);

-- 2. Índices de aceleración para tarjetas y perfiles (RNF-16)
CREATE INDEX IF NOT EXISTS idx_reviews_target_user ON public.reviews(target_user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_solicitud ON public.reviews(solicitud_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer ON public.reviews(reviewer_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_verified_review ON public.reviews (target_user_id) WHERE solicitud_id IS NULL;

-- 3. Habilitar Row Level Security (RLS)
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- 4. Políticas RLS:
-- Lectura: Cualquier usuario (o público) puede leer las calificaciones para ver la reputación de perfiles y propiedades
DROP POLICY IF EXISTS "Lectura pública de calificaciones" ON public.reviews;
CREATE POLICY "Lectura pública de calificaciones" 
    ON public.reviews FOR SELECT 
    USING (true);

-- Inserción: Solo el usuario autenticado que emite la reseña (reviewer_id coincide con auth.uid())
DROP POLICY IF EXISTS "Los usuarios autenticados pueden insertar sus calificaciones" ON public.reviews;
CREATE POLICY "Los usuarios autenticados pueden insertar sus calificaciones" 
    ON public.reviews FOR INSERT 
    WITH CHECK (auth.uid() = reviewer_id);
