# 🛍️ Proyecto The Look Retail: Limpieza, análisis y visualización
En este proyecto transformé un dataset crudo de e-commerce retail en insights accionables para el negocio.

Partí de datos desordenados, con duplicados, inconsistencias y redundancias.

A través de SQL realicé una limpieza exhaustiva: normalización de tablas, unificación de tipos de datos, eliminación de duplicados y construcción de claves primarias/foráneas.

A partir de ahí, realicé análisis que responden preguntas clave como:

**¿Qué clientes generan la mayor parte de la facturación?**

**¿Qué productos son más rentables y cuáles deberíamos descartar?**

**¿Cómo evoluciona la facturación por canal y región?**

**¿Qué clientes están en riesgo de abandono y cómo podemos reactivarlos?**

Finalmente, convertí todo ese análisis en un dashboard interactivo en Power BI, pensado para que cualquier equipo de negocio pueda tomar decisiones en segundos.

Este proyecto muestra el flujo completo de un Data Analyst: limpiar, modelar, analizar y comunicar.  

---

## 🚀 Insights clave del análisis

   - Pedidos y ventas: +106K pedidos desde 2019, con tendencia de facturación ascendente en 2023.
   - Clientes: +80K clientes, pero 73% inactivos en los últimos 3 meses → buscar estrategias de reactivación.
   - Portfolio: el 62% de los productos generan el 90% de la facturación; detección de productos con >100% de margen y tendencias de crecimiento (+700% el último trimestre).
   - Distribución: Houston, Memphis y Chicago son los centros más rentables.
   - Avanzado: Segmentación de clientes en matriz BCG y un sistema de recomendación de productos listo para orientar ventas.

---

## 📂 Estructura del repositorio
- `TheLookRetail_fase1_limpieza.sql` → Scripts de limpieza, normalización y modelado (Fase 1).
- `TheLookRetail_fase2_analisis.sql` → Consultas SQL con análisis exploratorio (Fase 2).
- `powerbi/` → Capturas y archivo `.pbix` con el dashboard final (Fase 3).
- `README.md` → Documentación del proyecto.

---

## 🗄️ Dataset
- Origen: Looker Ecommerce BigQuery Dataset. Kaggle
- Tamaño: 7 archivos csv (distribution_centers, events, inventory__items, order_items, orders, products, users). 538 megabytes.
- Características: dataset desnormalizado con redundancias y campos inconsistentes y costosos a nivel de memoria.  

---

## 🛠️ Herramientas utilizadas
- **Python (Jupyter Notebook)** → Carga de archivos CSV.  
- **SQL (MySQL Workbench)** → Limpieza, transformación, modelado relacional y fase de análisis.  
- **Power BI** → Visualización y creación de dashboard interactivo.  
- **GitHub** → Documentación del flujo de trabajo.  

---

## 📊 Limpieza y modelo de datos (Fase 1)
Se creó un **modelo en estrella** compuesto por:
- **Tablas de hechos**: `order_items`, `events`
- **Tablas de dimensiones**: `users`, `products`, `orders`, `inventory_items`, `distribution_centers`, `location`

<img width="872" height="827" alt="image" src="https://github.com/user-attachments/assets/8c7830f2-b580-4a9b-898e-3059b581874d" />

---

## 🔍 Análisis exploratorio (Fase 2)
Ejemplos de consultas clave realizadas en SQL:

Creación matriz BCG:

<img width="902" height="517" alt="image" src="https://github.com/user-attachments/assets/9d1ce877-4ab9-452c-b1cb-4278fd04f1d8" />

Clientes inactivos:

<img width="608" height="372" alt="image" src="https://github.com/user-attachments/assets/0d9afdcf-8540-4184-9825-272e5a740964" />

---

## 📈 Dashboard (Fase 3)
Se construyó un **dashboard en Power BI** que incluye:


👉 *(En esta sección sí o sí pon **capturas del dashboard final**. Son oro para los reclutadores: con un vistazo ven lo que sabes hacer.)*

---
## Limitaciones del dataset

    - Algunos usuarios aparecen como “anónimos” → limita la trazabilidad individual.
    - Ciudades y localizaciones incompletas o desconocidas → afecta a ciertos análisis de distribución geográfica.
    - El dataset proviene de Kaggle con fines educativos → no representa datos reales de negocio.

---
## 🤝 Contacto
👤 **Pedro Gil Olivares**  
🔗 [LinkedIn](www.linkedin.com/in/pedro-gil-olivares-485517216)  
📧 pedrogilolivares009@gmail.com  

---

