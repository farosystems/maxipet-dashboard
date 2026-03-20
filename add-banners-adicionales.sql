-- ============================================================================
-- AGREGAR BANNERS ADICIONALES A LA CONFIGURACIÓN WEB
-- ============================================================================
-- Script para agregar banner_4 y banner_5 a la tabla configuracion_web
-- Fecha: 2026-03-20
-- ============================================================================

-- ============================================================================
-- 1. AGREGAR COLUMNAS DE BANNERS ADICIONALES
-- ============================================================================

-- Agregar columna para BANNER 4
ALTER TABLE public.configuracion_web
ADD COLUMN IF NOT EXISTS banner_4 text NULL;

-- Agregar columna para BANNER 5
ALTER TABLE public.configuracion_web
ADD COLUMN IF NOT EXISTS banner_5 text NULL;

-- ============================================================================
-- 2. COMENTARIOS DESCRIPTIVOS
-- ============================================================================

COMMENT ON COLUMN public.configuracion_web.banner_4 IS 'URL o ruta de la cuarta imagen de banner del home';
COMMENT ON COLUMN public.configuracion_web.banner_5 IS 'URL o ruta de la quinta imagen de banner del home';

-- ============================================================================
-- 3. VERIFICACIÓN
-- ============================================================================

-- Verificar que las columnas se hayan agregado correctamente
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'configuracion_web'
  AND column_name IN ('banner_1', 'banner_2', 'banner_3', 'banner_4', 'banner_5')
ORDER BY ordinal_position;

-- ============================================================================
-- 4. CONSULTAS DE EJEMPLO
-- ============================================================================

-- 4.1 Ver todos los banners configurados
-- SELECT
--     id,
--     banner_1,
--     banner_2,
--     banner_3,
--     banner_4,
--     banner_5
-- FROM public.configuracion_web;

-- 4.2 Actualizar los nuevos banners (ejemplo)
-- UPDATE public.configuracion_web
-- SET
--     banner_4 = 'https://ejemplo.com/banner4.jpg',
--     banner_5 = 'https://ejemplo.com/banner5.jpg'
-- WHERE id = 1;

-- 4.3 Contar cuántos banners están configurados
-- SELECT
--     id,
--     (CASE WHEN banner_1 IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN banner_2 IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN banner_3 IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN banner_4 IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN banner_5 IS NOT NULL THEN 1 ELSE 0 END) AS total_banners_configurados
-- FROM public.configuracion_web;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
