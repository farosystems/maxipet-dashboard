-- ============================================================================
-- AGREGAR CAMPOS KILOS Y TAMAÑO A LA TABLA PRODUCTOS
-- ============================================================================
-- Script para agregar los campos kilos y tamaño a la tabla de productos
-- Fecha: 2026-03-18
-- ============================================================================

-- ============================================================================
-- 1. AGREGAR COLUMNAS A LA TABLA PRODUCTOS
-- ============================================================================

-- Agregar columna para KILOS (valores predefinidos)
ALTER TABLE public.productos
ADD COLUMN IF NOT EXISTS kilos numeric(5,2) NULL;

-- Agregar columna para TAMAÑO (valores predefinidos)
ALTER TABLE public.productos
ADD COLUMN IF NOT EXISTS tamaño varchar(50) NULL;

-- ============================================================================
-- 2. COMENTARIOS DESCRIPTIVOS
-- ============================================================================

COMMENT ON COLUMN public.productos.kilos IS 'Peso del producto en kilogramos (1, 1.8, 3, 3.6, 4, 5, 7, 7.5, 10, 15, 20, 25)';
COMMENT ON COLUMN public.productos.tamaño IS 'Tamaño del producto (Pequeño, Mediano, Adulto)';

-- ============================================================================
-- 3. ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
-- ============================================================================

-- Índice para consultas por kilos
CREATE INDEX IF NOT EXISTS productos_kilos_idx
ON public.productos (kilos)
WHERE kilos IS NOT NULL;

-- Índice para consultas por tamaño
CREATE INDEX IF NOT EXISTS productos_tamaño_idx
ON public.productos (tamaño)
WHERE tamaño IS NOT NULL;

-- ============================================================================
-- 4. CONSTRAINT PARA VALIDAR VALORES DE TAMAÑO (OPCIONAL)
-- ============================================================================

-- Agregar constraint para validar que solo se usen los valores permitidos
ALTER TABLE public.productos
ADD CONSTRAINT productos_tamaño_check
CHECK (tamaño IS NULL OR tamaño IN ('Pequeño', 'Mediano', 'Adulto'));

-- ============================================================================
-- 5. VERIFICACIÓN
-- ============================================================================

-- Verificar que las columnas se hayan agregado correctamente
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'productos'
  AND column_name IN ('kilos', 'tamaño')
ORDER BY ordinal_position;

-- Ver los índices creados
SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'productos'
  AND indexname IN ('productos_kilos_idx', 'productos_tamaño_idx');

-- ============================================================================
-- 6. CONSULTAS DE EJEMPLO
-- ============================================================================

-- 6.1 Contar productos por kilos
-- SELECT kilos, COUNT(*) as total
-- FROM public.productos
-- WHERE kilos IS NOT NULL
-- GROUP BY kilos
-- ORDER BY kilos;

-- 6.2 Contar productos por tamaño
-- SELECT tamaño, COUNT(*) as total
-- FROM public.productos
-- WHERE tamaño IS NOT NULL
-- GROUP BY tamaño
-- ORDER BY tamaño;

-- 6.3 Ver productos sin kilos o tamaño asignado
-- SELECT id, codigo, descripcion, kilos, tamaño
-- FROM public.productos
-- WHERE kilos IS NULL OR tamaño IS NULL;

-- 6.4 Filtrar productos por kilos específico
-- SELECT id, codigo, descripcion, kilos, tamaño, precio
-- FROM public.productos
-- WHERE kilos = 15;

-- 6.5 Filtrar productos por tamaño específico
-- SELECT id, codigo, descripcion, kilos, tamaño, precio
-- FROM public.productos
-- WHERE tamaño = 'Adulto';

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
