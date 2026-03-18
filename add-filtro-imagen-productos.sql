-- ============================================================================
-- FILTROS PARA IMÁGENES EN PRODUCTOS
-- ============================================================================
-- Script para agregar índices y consultas útiles para filtrar productos
-- según tengan o no imágenes
-- Fecha: 2026-03-18
-- ============================================================================

-- ============================================================================
-- 1. ÍNDICES ADICIONALES PARA OPTIMIZAR CONSULTAS DE PRODUCTOS SIN IMÁGENES
-- ============================================================================

-- Índice para productos SIN ninguna imagen (todos los campos de imagen son NULL)
CREATE INDEX IF NOT EXISTS productos_sin_imagenes_idx
ON public.productos (id)
WHERE imagen IS NULL
  AND imagen_2 IS NULL
  AND imagen_3 IS NULL
  AND imagen_4 IS NULL
  AND imagen_5 IS NULL;

COMMENT ON INDEX productos_sin_imagenes_idx IS 'Índice para filtrar productos que no tienen ninguna imagen configurada';

-- ============================================================================
-- 2. CONSULTAS ÚTILES PARA FILTRAR PRODUCTOS POR IMÁGENES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 2.1 VISTA: productos_con_imagenes
-- Descripción: Muestra todos los productos que tienen al menos una imagen
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.productos_con_imagenes AS
SELECT
    p.id,
    p.codigo,
    p.descripcion,
    p.precio,
    p.activo,
    p.destacado,
    p.tiene_stock,
    p.imagen,
    p.imagen_2,
    p.imagen_3,
    p.imagen_4,
    p.imagen_5,
    -- Contador de imágenes que tiene el producto
    (CASE WHEN p.imagen IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN p.imagen_2 IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN p.imagen_3 IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN p.imagen_4 IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN p.imagen_5 IS NOT NULL THEN 1 ELSE 0 END) AS total_imagenes,
    c.descripcion AS categoria,
    m.descripcion AS marca,
    p.created_at
FROM public.productos p
LEFT JOIN public.categorias c ON p.fk_id_categoria = c.id
LEFT JOIN public.marcas m ON p.fk_id_marca = m.id
WHERE p.imagen IS NOT NULL
   OR p.imagen_2 IS NOT NULL
   OR p.imagen_3 IS NOT NULL
   OR p.imagen_4 IS NOT NULL
   OR p.imagen_5 IS NOT NULL
ORDER BY p.id;

COMMENT ON VIEW public.productos_con_imagenes IS 'Vista que muestra productos que tienen al menos una imagen configurada';

-- ----------------------------------------------------------------------------
-- 2.2 VISTA: productos_sin_imagenes
-- Descripción: Muestra todos los productos que NO tienen ninguna imagen
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW public.productos_sin_imagenes AS
SELECT
    p.id,
    p.codigo,
    p.descripcion,
    p.precio,
    p.activo,
    p.destacado,
    p.tiene_stock,
    c.descripcion AS categoria,
    m.descripcion AS marca,
    p.created_at
FROM public.productos p
LEFT JOIN public.categorias c ON p.fk_id_categoria = c.id
LEFT JOIN public.marcas m ON p.fk_id_marca = m.id
WHERE p.imagen IS NULL
  AND p.imagen_2 IS NULL
  AND p.imagen_3 IS NULL
  AND p.imagen_4 IS NULL
  AND p.imagen_5 IS NULL
ORDER BY p.id;

COMMENT ON VIEW public.productos_sin_imagenes IS 'Vista que muestra productos que no tienen ninguna imagen configurada';

-- ============================================================================
-- 3. FUNCIÓN ÚTIL: obtener_estado_imagenes_producto
-- ============================================================================
-- Descripción: Función que retorna información detallada sobre el estado
--              de las imágenes de un producto
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.obtener_estado_imagenes_producto(producto_id BIGINT)
RETURNS TABLE (
    producto_id_out BIGINT,
    descripcion_producto TEXT,
    tiene_imagen_principal BOOLEAN,
    tiene_imagen_2 BOOLEAN,
    tiene_imagen_3 BOOLEAN,
    tiene_imagen_4 BOOLEAN,
    tiene_imagen_5 BOOLEAN,
    total_imagenes INTEGER,
    necesita_imagenes BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.descripcion,
        p.imagen IS NOT NULL AS tiene_imagen_principal,
        p.imagen_2 IS NOT NULL AS tiene_imagen_2,
        p.imagen_3 IS NOT NULL AS tiene_imagen_3,
        p.imagen_4 IS NOT NULL AS tiene_imagen_4,
        p.imagen_5 IS NOT NULL AS tiene_imagen_5,
        (CASE WHEN p.imagen IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN p.imagen_2 IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN p.imagen_3 IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN p.imagen_4 IS NOT NULL THEN 1 ELSE 0 END +
         CASE WHEN p.imagen_5 IS NOT NULL THEN 1 ELSE 0 END) AS total_imagenes,
        (p.imagen IS NULL AND p.imagen_2 IS NULL AND p.imagen_3 IS NULL
         AND p.imagen_4 IS NULL AND p.imagen_5 IS NULL) AS necesita_imagenes
    FROM public.productos p
    WHERE p.id = producto_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.obtener_estado_imagenes_producto IS 'Retorna información detallada sobre el estado de las imágenes de un producto específico';

-- ============================================================================
-- 4. CONSULTAS DE EJEMPLO
-- ============================================================================

-- 4.1 Listar productos que tienen al menos una imagen
-- SELECT * FROM public.productos_con_imagenes;

-- 4.2 Listar productos que NO tienen ninguna imagen
-- SELECT * FROM public.productos_sin_imagenes;

-- 4.3 Contar productos con y sin imágenes
-- SELECT
--     'Con imágenes' AS estado,
--     COUNT(*) AS total
-- FROM public.productos
-- WHERE imagen IS NOT NULL
--    OR imagen_2 IS NOT NULL
--    OR imagen_3 IS NOT NULL
--    OR imagen_4 IS NOT NULL
--    OR imagen_5 IS NOT NULL
-- UNION ALL
-- SELECT
--     'Sin imágenes' AS estado,
--     COUNT(*) AS total
-- FROM public.productos
-- WHERE imagen IS NULL
--   AND imagen_2 IS NULL
--   AND imagen_3 IS NULL
--   AND imagen_4 IS NULL
--   AND imagen_5 IS NULL;

-- 4.4 Obtener estado de imágenes de un producto específico
-- SELECT * FROM public.obtener_estado_imagenes_producto(1);

-- 4.5 Productos activos sin imágenes (para identificar productos que necesitan imágenes)
-- SELECT * FROM public.productos_sin_imagenes WHERE activo = true;

-- 4.6 Productos destacados sin imágenes (alerta importante)
-- SELECT * FROM public.productos_sin_imagenes WHERE destacado = true;

-- 4.7 Productos con stock pero sin imágenes
-- SELECT * FROM public.productos_sin_imagenes WHERE tiene_stock = true;

-- 4.8 Contar cuántas imágenes tiene cada producto (ordenado por cantidad)
-- SELECT
--     id,
--     codigo,
--     descripcion,
--     (CASE WHEN imagen IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN imagen_2 IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN imagen_3 IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN imagen_4 IS NOT NULL THEN 1 ELSE 0 END +
--      CASE WHEN imagen_5 IS NOT NULL THEN 1 ELSE 0 END) AS total_imagenes
-- FROM public.productos
-- ORDER BY total_imagenes DESC, id;

-- 4.9 Productos por categoría sin imágenes
-- SELECT
--     c.descripcion AS categoria,
--     COUNT(*) AS productos_sin_imagenes
-- FROM public.productos p
-- LEFT JOIN public.categorias c ON p.fk_id_categoria = c.id
-- WHERE p.imagen IS NULL
--   AND p.imagen_2 IS NULL
--   AND p.imagen_3 IS NULL
--   AND p.imagen_4 IS NULL
--   AND p.imagen_5 IS NULL
-- GROUP BY c.descripcion
-- ORDER BY productos_sin_imagenes DESC;

-- 4.10 Productos por marca sin imágenes
-- SELECT
--     m.descripcion AS marca,
--     COUNT(*) AS productos_sin_imagenes
-- FROM public.productos p
-- LEFT JOIN public.marcas m ON p.fk_id_marca = m.id
-- WHERE p.imagen IS NULL
--   AND p.imagen_2 IS NULL
--   AND p.imagen_3 IS NULL
--   AND p.imagen_4 IS NULL
--   AND p.imagen_5 IS NULL
-- GROUP BY m.descripcion
-- ORDER BY productos_sin_imagenes DESC;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
