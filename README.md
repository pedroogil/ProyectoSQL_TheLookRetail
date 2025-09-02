# 🛍️ Proyecto The Look Retail: Limpieza, análisis y visualización
En este proyecto transformé un dataset crudo de e-commerce en insights accionables para el negocio.

El trabajo se centra en la fase de limpieza y análisis con SQL, mostrando cómo a partir de datos desordenados, con duplicados y redundancias, es posible construir un modelo sólido y obtener respuestas a preguntas clave:

**¿Qué clientes generan la mayor parte de la facturación?**

**¿Qué productos son más rentables y cuáles habría que descartar?**

**¿Cómo evoluciona la facturación por canal y región?**

**¿Qué clientes están en riesgo de abandono y cómo podemos reactivarlos?**

Este proyecto refleja el flujo de un Data Analyst en su parte más crítica: limpiar, modelar y analizar datos con SQL.

---

## 🛠️ Flujo de trabajo end-to-end

Carga de datos: Importación de archivos CSV con Python.

Limpieza y normalización (SQL): Eliminación de duplicados, estandarización de tipos de datos, reducción de redundancia y construcción de modelo en estrella con claves primarias y foráneas.

Análisis exploratorio (SQL): Segmentación de clientes, facturación por producto y centro, identificación de clientes inactivos, creación de una matriz BCG para evaluar el portfolio de productos y creación de sistema de recomendación.

---

## 📊 Técnicas SQL aplicadas

### 1. Limpieza y modelado de datos

   - Eliminación de duplicados y gestión de valores nulos mediante reemplazos controlados (“Desconocida”, “Anónimo”).
   - Supresión de campos redundantes y normalización parcial para mejorar la integridad.
   - Transformación del esquema original en un modelo en estrella con dos tablas de hechos (order_items, events) y seis tablas de dimensiones.

<img width="872" height="827" alt="image" src="https://github.com/user-attachments/assets/8c7830f2-b580-4a9b-898e-3059b581874d" />

### 2. Consultas de explotación y análisis

   - Subconsultas y CTEs para segmentaciones avanzadas (clientes, productos en tendencia).
   - Funciones de ventana (window functions) como RANK() o ROW_NUMBER() para calcular márgenes por categoría y ranking de productos.
   - Análisis temporal con funciones de fecha.
   - Segmentación de clientes en matriz BCG, categorizados según número de pedidos y facturación media.
   - Sistema básico de recomendación a partir de co-ocurrencia de productos en pedidos compartidos, materializado en tabla auxiliar.

---

## 🚀 Hallazgos más importantes
Más allá del aspecto técnico, el uso de SQL permitió extraer insights relevantes:

   - +106K pedidos desde 2019 → facturación con tendencia ascendente en 2023.
   - +80K clientes, pero **73% inactivos en los últimos 3 meses** → oportunidad de reactivación.
   - **El 62% de los productos generan el 90% de la facturación** (ley de Pareto) → posibilidad de optimizar el catálogo.
   - Identificación de productos con **márgenes >100%** y tendencias de crecimiento (+700% el último trimestre) → se debería potenciar la venta de estos productos
   - Centros de distribución más rentables: Houston, Memphis y Chicago.

---

## 🗄️ Dataset
- Origen: Looker Ecommerce BigQuery Dataset (Kaggle).
- Tamaño: 7 archivos CSV (538 MB)
- Tablas: distribution_centes, events, inventory_items, order_items, orders, products, users.
- Características: dataset desnormalizado con redundancias y campos inconsistentes.  

---

## 📂 Estructura del repositorio
- `TheLookRetail_fase1_limpieza.sql` → Scripts de limpieza, normalización y modelado.
- `TheLookRetail_fase2_analisis.sql` → Consultas SQL con análisis exploratorio.
- `README.md` → Documentación del proyecto.

---

## ⚠️ Limitaciones del dataset

- Usuarios anónimos que limitan la trazabilidad individual.
- Localizaciones incompletas o desconocidas. Afecta a ciertos análisis de distribución geográfica.
- El dataset proviene de Kaggle con fines educativos, no representa datos reales de negocio.

---

## 🔜 Próximos pasos

En una fase posterior, se añadirá un dashboard interactivo en Power BI para complementar los análisis y facilitar la toma de decisiones visual.

---

## 🤝 Contacto
👤 **Pedro Gil Olivares**  
🔗 [LinkedIn](www.linkedin.com/in/pedro-gil-olivares-485517216)  
📧 pedrogilolivares009@gmail.com  

---

