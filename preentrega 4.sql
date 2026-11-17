-- PROYECTO: Mercado Libre - Marketplace Analytics
-- 1. DDL: CREACIÓN DE TABLAS CON RESTRICCIONES

-- Tabla de Categorías de Mercado Libre
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(80) NOT NULL UNIQUE
);

-- Tabla de Clientes / Compradores
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    fecha_registro DATE DEFAULT CURRENT_DATE
);

-- Tabla de Productos del Marketplace
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    id_categoria INTEGER NOT NULL,
    precio NUMERIC(10, 2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT fk_productos_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria) ON DELETE RESTRICT,
    CONSTRAINT check_precio_positivo CHECK (precio > 0),
    CONSTRAINT check_stock_no_negativo CHECK (stock >= 0)
);

-- Tabla de Ventas / Órdenes
CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ventas_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente) ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto) ON DELETE RESTRICT,
    CONSTRAINT check_cantidad_positiva CHECK (cantidad > 0)
);

-- 2. DML: CARGA INICIAL DE DATOS (Transacción explícita)
BEGIN;

-- Categorías
INSERT INTO categorias (nombre_categoria) VALUES
    ('Tecnología'),
    ('Hogar y Muebles'),
    ('Herramientas'),
    ('Deportes y Fitness');

-- Clientes 
INSERT INTO clientes (nombre, email, fecha_registro) VALUES
    ('Lara Medina', 'lara.medina@gmail.com', '2026-01-10'),
    ('Tiziana Deliso', 'tiziana.deliso@gmail.com', '2026-01-15'),
    ('Sofía Rial', 'sofia.rial@gmailcom', '2026-02-01'),
    ('Isabella Deluchi', 'isabella.deluchi@gmail.com', '2026-02-10'),
    ('Agostina Servello', 'agostina.servello@gmail.com', '2026-02-20'),
    ('Bianca vinuales', 'bianca.vinuales@gmial.com', '2026-03-01'); -- Sin compras

-- Productos
INSERT INTO productos (nombre, id_categoria, precio, stock) VALUES
    ('Smartphone 128GB', 1, 850.00, 30),
    ('Notebook 16GB RAM', 1, 1400.00, 15),
    ('Auriculares Bluetooth', 1, 75.00, 50),
    ('Silla Ergonómica Pro', 2, 280.00, 20),
    ('Escritorio Regulable', 2, 450.00, 10),
    ('Taladro Percutor 750W', 3, 110.00, 25),
    ('Set Mancuernas 20kg', 4, 95.00, 18);

-- Ventas
INSERT INTO ventas (id_cliente, id_producto, cantidad, fecha_venta) VALUES
    (1, 1, 1, '2026-02-01 10:15:00'),
    (1, 2, 1, '2026-02-15 16:30:00'),
    (1, 3, 3, '2026-03-01 11:00:00'),
    (2, 2, 2, '2026-02-18 14:00:00'),
    (3, 4, 1, '2026-02-22 09:20:00'),
    (3, 5, 1, '2026-02-28 17:45:00'),
    (4, 6, 2, '2026-03-02 12:10:00'),
    (5, 3, 2, '2026-03-05 18:25:00'),
    (1, 3, 2, '2026-03-10 13:40:00'); -- Lara compra auriculares de nuevo

COMMIT;

-- 3. CONSULTAS MULTICAPA REQUERIDAS

-- CONSULTA 1: Rentabilidad y volumen por categoría de marketplace
/*
 PROBLEMA DE NEGOCIO (Mercado Libre - Category Management):
 El equipo comercial necesita identificar las categorías de mayor volumen
 y facturación para negociar mejores comisiones y acuerdos con sellers.
 Se unen 3 tablas (ventas, productos, categorias), se calculan unidades vendidas
 y facturación total, y se filtra con HAVING para ver solo categorías que
 superen los $500 en ventas (umbral de negocio).
*/
SELECT 
    cat.nombre_categoria AS categoria,
    SUM(v.cantidad) AS total_unidades_vendidas,
    SUM(v.cantidad * p.precio) AS ingreso_total
FROM ventas AS v
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat 
    ON p.id_categoria = cat.id_categoria
GROUP BY 
    cat.id_categoria,
    cat.nombre_categoria
HAVING 
    SUM(v.cantidad * p.precio) > 500.00
ORDER BY 
    ingreso_total DESC;

-- CONSULTA 2: Detección de usuarios inactivos / 'Clientes Escurridizos'
/*
 PROBLEMA DE NEGOCIO (Mercado Libre - Growth & User Activation):
 El área de marketing busca usuarios registrados en el marketplace que todavía
 no hayan realizado ninguna compra, con el fin de enviarles una notificación push
 y un cupón de bienvenida ("Primer Envío Gratis").
 Se usa un LEFT JOIN hacia ventas y COALESCE para mostrar 0 transacciones.
*/
SELECT 
    c.id_cliente,
    c.nombre,
    c.email,
    COALESCE(COUNT(v.id_venta), 0) AS total_compras_realizadas
FROM clientes AS c
LEFT JOIN ventas AS v 
    ON c.id_cliente = v.id_cliente
WHERE 
    v.id_venta IS NULL
GROUP BY 
    c.id_cliente,
    c.nombre,
    c.email
ORDER BY 
    c.id_cliente ASC;

-- CONSULTA 3: Producto favorito y última actividad por comprador
/*
 PROBLEMA DE NEGOCIO (Mercado Libre - CRM & Personalización):
 Para el recomendador de ofertas personalizadas, se requiere identificar para
 cada cliente recurrente cuál fue el producto que compró en mayor cantidad
 y la fecha de su última interacción en la plataforma.
 Se unen clientes, ventas y productos utilizando DISTINCT ON por cliente.
*/
SELECT DISTINCT ON (c.id_cliente)
    c.id_cliente,
    c.nombre AS cliente,
    p.nombre AS producto_mas_comprado,
    SUM(v.cantidad) AS unidades_compradas,
    MAX(v.fecha_venta) AS fecha_ultima_transaccion
FROM clientes AS c
INNER JOIN ventas AS v 
    ON c.id_cliente = v.id_cliente
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
GROUP BY 
    c.id_cliente,
    c.nombre,
    p.id_producto,
    p.nombre
ORDER BY 
    c.id_cliente,
    unidades_compradas DESC,
    fecha_ultima_transaccion DESC;

