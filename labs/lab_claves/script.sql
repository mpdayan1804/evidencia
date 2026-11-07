-- =====================================================
-- LAB CLAVES: llaves primarias, compuestas y foráneas
-- Requiere: lab_fundamentos (cliente) y lab_restricciones (productos, pedidos)
-- =====================================================

-- Llave primaria natural: el código de la categoría identifica la fila
CREATE TABLE IF NOT EXISTS categorias (
    codigo VARCHAR(10) PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE
);

-- Llave foránea opcional desde productos hacia categorias
ALTER TABLE productos
    ADD COLUMN IF NOT EXISTS categoria_codigo VARCHAR(10) REFERENCES categorias(codigo);

-- Llave primaria compuesta + dos llaves foráneas (relación muchos a muchos)
CREATE TABLE IF NOT EXISTS detalle_pedido (
    pedido_id       INT NOT NULL REFERENCES pedidos(id),
    producto_id     INT NOT NULL REFERENCES productos(id),
    cantidad        INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
    PRIMARY KEY (pedido_id, producto_id)
);

INSERT INTO categorias (codigo, nombre) VALUES
    ('PER', 'Periféricos'),
    ('ALM', 'Almacenamiento')
ON CONFLICT (codigo) DO NOTHING;

UPDATE productos SET categoria_codigo = 'PER' WHERE sku = 'A-100';

INSERT INTO productos (sku, nombre, precio, stock, categoria_codigo) VALUES
    ('A-200', 'Mouse inalámbrico', 50000, 25, 'PER'),
    ('B-100', 'Disco SSD 1TB', 320000, 8, 'ALM')
ON CONFLICT (sku) DO NOTHING;

INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
SELECT 1, id, 1, precio FROM productos WHERE sku = 'A-100'
UNION ALL
SELECT 2, id, 1, precio FROM productos WHERE sku = 'A-200'
ON CONFLICT (pedido_id, producto_id) DO NOTHING;

-- Consulta: productos de cada pedido usando las llaves para unir tablas
SELECT p.id AS pedido, c.nombre AS cliente, pr.nombre AS producto,
       cat.nombre AS categoria, d.cantidad, d.precio_unitario
FROM detalle_pedido d
JOIN pedidos p     ON p.id = d.pedido_id
JOIN cliente c     ON c.id = p.cliente_id
JOIN productos pr  ON pr.id = d.producto_id
LEFT JOIN categorias cat ON cat.codigo = pr.categoria_codigo
ORDER BY p.id;

-- La llave primaria compuesta impide repetir el mismo producto en un pedido
DO $$
BEGIN
    INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
    SELECT 1, id, 2, precio FROM productos WHERE sku = 'A-100';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'OK: llave compuesta (pedido_id, producto_id) rechazó un duplicado';
END $$;
