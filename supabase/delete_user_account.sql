-- ====================================================================
-- Script DDL: Función RPC 'delete_user_account' en Supabase para ViHome
-- Propósito: Eliminación permanente y borrado en cascada de datos de usuario
-- Cumplimiento: Apple App Store 5.1.1(v) y Google Play Store User Data Policy
-- ====================================================================

CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    current_user_id UUID;
BEGIN
    -- 1. Verificar identidad del usuario que invoca la función
    current_user_id := auth.uid();
    
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'No autorizado: No existe una sesión activa para ejecutar esta acción.';
    END IF;

    -- 2. Borrar calificaciones (tanto enviadas como recibidas)
    DELETE FROM public.reviews 
    WHERE reviewer_id = current_user_id OR target_user_id = current_user_id;

    -- 3. Borrar solicitudes de arriendo asociadas a las propiedades del usuario o creadas por él
    DELETE FROM public.solicitudes 
    WHERE arrendatario_id = current_user_id OR arrendador_id = current_user_id;

    -- 4. Borrar propiedades publicadas si el usuario es arrendador
    DELETE FROM public.propiedades 
    WHERE arrendador_id = current_user_id;

    -- 5. Borrar datos complementarios de roles
    DELETE FROM public.info_arrendatarios 
    WHERE id = current_user_id;

    DELETE FROM public.info_arrendadores 
    WHERE id = current_user_id;

    -- 6. Borrar perfil público del usuario
    DELETE FROM public.profiles 
    WHERE id = current_user_id;

    -- 7. Borrar el registro del usuario en auth.users (elimina credenciales y tokens)
    DELETE FROM auth.users 
    WHERE id = current_user_id;
END;
$$;

-- Restringir permisos de ejecución:
-- Revocar para el rol público anónimo
REVOKE EXECUTE ON FUNCTION public.delete_user_account() FROM public;

-- Conceder a los roles autenticado y service_role
GRANT EXECUTE ON FUNCTION public.delete_user_account() TO authenticated, service_role;

-- Notificar a PostgREST para recargar la caché del esquema de inmediato
NOTIFY pgrst, 'reload schema';
