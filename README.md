# Mercado Libre - Marketplace Analytics
**Pre-entrega: Consultas multicapa para análisis de negocio**
*Curso: SQL y Estadística Aplicada al Negocio*

Este repositorio contiene la solución a la pre-entrega del Módulo de **Relaciones, JOINs y Agrupaciones Avanzadas**. Se modeló un esquema relacional enfocado en el ecosistema de Marketplace de Mercado Libre para resolver tres problemáticas clave de negocio mediante consultas SQL multicapa.

---

## 🗄️ Esquema de la Base de Datos

El diseño incluye 4 entidades interconectadas con integridad referencial (`FOREIGN KEY`) y restricciones de negocio (`CHECK`):

* **`categorias`**: Registro de rubros del catálogo (`id_categoria`, `nombre_categoria`).
* **`clientes`**: Compradores registrados en la plataforma (`id_cliente`, `nombre`, `email`, `fecha_registro`).
* **`productos`**: Artículos publicados con validación de precio positivo (`precio > 0`) y stock no negativo (`stock >= 0`).
* **`ventas`**: Tabla de transacciones que relaciona compradores y productos, asegurando que la cantidad vendida sea válida (`cantidad > 0`).

---

## 📊 Consultas y Problemas de Negocio Resueltos

### 1. Rentabilidad y volumen por categoría de marketplace
* **Área de negocio:** Category Management.
* **Problema:** Identificar los rubros con mayor tracción económica para negociar acuerdos con sellers y orientar presupuestos de pauta publicitaria.
* **Técnica:** Unión de 3 tablas (`ventas`, `productos`, `categorias`), cálculo de unidades vendidas y facturación bruta agrupada por categoría, aplicando filtro en `HAVING` para considerar únicamente aquellas con ingresos superiores a $500.

### 2. Detección de usuarios inactivos ("Clientes Escurridizos")
* **Área de negocio:** Growth & User Activation.
* **Problema:** Encontrar usuarios que completaron el registro pero nunca efectuaron su primera compra, para activar campañas de remarketing (cupón de bienvenida "Primer Envío Gratis").
* **Técnica:** `LEFT JOIN` desde `clientes` hacia `ventas` filtrando registros sin transacciones (`v.id_venta IS NULL`) y manejo de valores ausentes con `COALESCE` para devolver 0 compras.

### 3. Producto favorito y última actividad por comprador
* **Área de negocio:** CRM & Personalización de Ofertas.
* **Problema:** Perfilar a cada comprador recurrente con su producto de mayor frecuencia y la fecha de su última interacción en la plataforma para proyectar ciclos de recompra.
* **Técnica:** Agrupación multicapa sobre `clientes`, `ventas` y `productos`, utilizando `DISTINCT ON (c.id_cliente)` ordenado por volumen adquirido y fecha más reciente.

---

## 🚀 Instrucciones de Ejecución

1. Abrir **pgAdmin 4** o **DBeaver** y conectarse al servidor de PostgreSQL.
2. Crear una nueva base de datos o conectarse a una existente:
   ```sql
   CREATE DATABASE retail_project;
