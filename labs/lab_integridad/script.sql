-- =====================================================
-- LAB INTEGRIDAD: integridad referencial y transacciones
-- Requiere: lab_fundamentos, lab_restricciones y lab_claves
-- =====================================================

-- Acciones referenciales: al borrar un pedido se borran sus detalles (CASCADE),
-- pero no se puede borrar un producto que ya fue vendido (RESTRICT).
ALTER TABLE detalle_pedido DROP CONSTRAINT IF EXISTS detalle_pedido_pedido_id_fkey;
ALTER TABLE detalle_pedido
    ADD CONSTRAINT detalle_pedido_pedido_id_fkey
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE;

ALTER TABLE detalle_pedido DROP CONSTRAINT IF EXISTS detalle_pedido_producto_id_fkey;
ALTER TABLE detalle_pedido
    ADD CONSTRAINT detalle_pedido_producto_id_fkey
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT;

-- 1. No se puede crear un pedido para un cliente que no existe
DO $$
BEGIN
    INSERT INTO pedidos (cliente_id, total) VALUES (9999, 10000);
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'OK: pedido rechazado, el cliente 9999 no existe';
END $$;

-- 2. No se puede borrar un producto que aparece en un pedido (RESTRICT)
DO $$
BEGIN
    DELETE FROM productos WHERE sku = 'A-100';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'OK: no se puede borrar A-100 porque tiene ventas';
END $$;

-- 3. Transacción: registrar una venta descontando stock de forma atómica.
--    Si cualquier paso falla (por ejemplo stock negativo por el CHECK), no se guarda nada.
BEGIN;
    INSERT INTO pedidos (cliente_id, total) VALUES (2, 640000);
    INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
    SELECT currval(pg_get_serial_sequence('pedidos', 'id')), id, 2, precio
    FROM productos WHERE sku = 'B-100';
    UPDATE productos SET stock = stock - 2 WHERE sku = 'B-100';
COMMIT;

-- 4. Una venta que deja el stock en negativo se revierte completa
DO $$
DECLARE
    stock_antes INT;
    pedidos_antes INT;
BEGIN
    SELECT stock INTO stock_antes FROM productos WHERE sku = 'B-100';
    SELECT count(*) INTO pedidos_antes FROM pedidos;
    BEGIN
        INSERT INTO pedidos (cliente_id, total) VALUES (1, 32000000);
        UPDATE productos SET stock = stock - 100 WHERE sku = 'B-100';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'OK: venta revertida, stock insuficiente (había %)', stock_antes;
    END;
    ASSERT (SELECT count(*) FROM pedidos) = pedidos_antes, 'el pedido no debió guardarse';
END $$;

-- 5. ON DELETE CASCADE: borrar un pedido elimina sus detalles
DELETE FROM pedidos WHERE id = 2;

-- Verificación: no hay detalles huérfanos
SELECT count(*) AS detalles_huerfanos
FROM detalle_pedido d
LEFT JOIN pedidos p ON p.id = d.pedido_id
WHERE p.id IS NULL;

SELECT sku, nombre, stock FROM productos ORDER BY sku;
