-- Migración de respaldo para producción (specs/012-vihomeapp-mvp):
-- Habilitar lectura pública (SELECT) para el rol anon (invitado) únicamente
-- en las tablas de catálogo inmobiliario público (RF-2.2, RF-2.3, RNF-2).
-- Las tablas privadas (solicitudes, profiles, info_arrendatarios, info_arrendadores)
-- permanecen estrictamente restringidas al rol authenticated.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'proyectos'
      AND policyname = 'proyectos_anon_select'
  ) THEN
    CREATE POLICY "proyectos_anon_select"
      ON public.proyectos
      FOR SELECT
      TO anon
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'contructora'
      AND policyname = 'contructora_anon_select'
  ) THEN
    CREATE POLICY "contructora_anon_select"
      ON public.contructora
      FOR SELECT
      TO anon
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'tipos_propiedad'
      AND policyname = 'tipos_propiedad_anon_select'
  ) THEN
    CREATE POLICY "tipos_propiedad_anon_select"
      ON public.tipos_propiedad
      FOR SELECT
      TO anon
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'amenidades'
      AND policyname = 'amenidades_anon_select'
  ) THEN
    CREATE POLICY "amenidades_anon_select"
      ON public.amenidades
      FOR SELECT
      TO anon
      USING (true);
  END IF;
END $$;
