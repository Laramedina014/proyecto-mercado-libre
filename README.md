# Mercado Libre - Marketplace Analytics
**Proyecto Modular de SQL y Estadística Aplicada al Negocio**  
*Diplomatura en Data Science - Coderhouse*

Este repositorio documenta el desarrollo progresivo de un esquema de base de datos relacional y consultas analíticas sobre el ecosistema de Marketplace de Mercado Libre, abarcando desde modelado y consultas multicapa hasta analítica avanzada de series temporales.

---

## 🗄️ Modelo Relacional y Esquema

El diseño implementa integridad referencial (`FOREIGN KEY`) y reglas de negocio (`CHECK`):

* **`categorias`**: Rubros principales del catálogo (`id_categoria`, `nombre_categoria`).
* **`clientes`**: Compradores registrados (`id_cliente`, `nombre`, `email`, `fecha_registro`).
* **`productos`**: Catálogo con validación de precio positivo (`precio > 0`) y stock (`stock >= 0`).
* **`ventas`**: Registro transaccional que vincula compradores con ítems adquiridos (`cantidad > 0`).

---

## 📂 Módulos y Entregas Desarrolladas

### Módulo 4: Consultas Multicapa para Análisis de Negocio
**Archivo:** `pre-entrega-modulo4.sql`

1. **Rentabilidad por Categoría (Category Management):** Unión de 3 tablas (`ventas`, `productos`, `categorias`), cálculo de unidades vendidas y facturación bruta agrupada por rubro, con filtro en `HAVING` (> $500).
2. **Detección de Clientes Escurridizos (Growth & Retention):** `LEFT JOIN` hacia ventas para aislar compradores registrados sin órdenes (`v.id_venta IS NULL`) usando `COALESCE` para reportar métricas limpias.
3. **Producto Favorito por Cliente (CRM & Recomendaciones):** Identificación del artículo de mayor frecuencia de compra y fecha de última transacción por usuario mediante `DISTINCT ON (c.id_cliente)`.

---

### Módulo 5: Script de Análisis Avanzado con Window Functions
**Archivo:** `preentrega_analisis_avanzado.sql`

Implementación de un pipeline analítico basado en **Common Table Expressions (CTEs)** y **Funciones de Ventana** para evaluar la evolución temporal del catálogo:

* **CTE `ventas_mensuales`:** Agrupación cronológica normalizada por mes (`DATE_TRUNC('month', fecha_venta)`) y categoría para consolidar la facturación periódica.
* **CTE `metricas_ventana`:**
  * **Ranking mensual:** Clasificación competitiva de las categorías más vendidas en cada período mediante `DENSE_RANK() OVER (PARTITION BY mes ORDER BY total_ventas DESC)`.
  * **Total acumulado (Running Total):** Evolución histórica del volumen de ventas por categoría en el tiempo mediante `SUM(total_ventas) OVER (PARTITION BY categoria ORDER BY mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`.
  * **Media histórica:** Benchmark de desempeño promedio por categoría a lo largo del tiempo con `AVG(total_ventas) OVER (PARTITION BY categoria)`.
* **Consulta Principal:** Segmentación condicional con `CASE WHEN` para clasificar automáticamente cada mes de la categoría como **"Exitoso"** (cuando supera o iguala su promedio histórico) o **"Bajo el promedio"**.

---

## 🚀 Instrucciones de Ejecución

1. Conectarse a PostgreSQL mediante **pgAdmin 4** o **DBeaver**.
2. Conectarse a la base de datos de trabajo (`retail_project`).
3. Para inicializar el esquema y los datos base, ejecutar:
   ```bash
   pre-entrega-modulo4.sql

