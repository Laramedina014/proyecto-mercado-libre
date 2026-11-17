-- preentrega_analisis_avanzado.sql

WITH ventas_mensuales AS (
    SELECT 
        DATE_TRUNC('month', v.fecha_venta)::DATE AS mes,
        cat.nombre_categoria AS categoria,
        SUM(v.cantidad * p.precio) AS total_ventas
    FROM ventas AS v
    INNER JOIN productos AS p 
        ON v.id_producto = p.id_producto
    INNER JOIN categorias AS cat 
        ON p.id_categoria = cat.id_categoria
    GROUP BY 
        DATE_TRUNC('month', v.fecha_venta)::DATE,
        cat.nombre_categoria
),
metricas_ventana AS (
    SELECT 
        mes,
        categoria,
        total_ventas,
        DENSE_RANK() OVER (
            PARTITION BY mes 
            ORDER BY total_ventas DESC
        ) AS ranking_mensual,
        SUM(total_ventas) OVER (
            PARTITION BY categoria 
            ORDER BY mes 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_acumulado_categoria,
        AVG(total_ventas) OVER (
            PARTITION BY categoria
        ) AS promedio_historico_categoria
    FROM ventas_mensuales
)
SELECT 
    mes,
    categoria,
    total_ventas,
    ranking_mensual,
    total_acumulado_categoria,
    ROUND(promedio_historico_categoria, 2) AS promedio_historico_categoria,
    CASE 
        WHEN total_ventas >= promedio_historico_categoria THEN 'Exitoso'
        ELSE 'Bajo el promedio'
    END AS evaluacion_rendimiento
FROM metricas_ventana
ORDER BY 
    categoria,
    mes ASC;
