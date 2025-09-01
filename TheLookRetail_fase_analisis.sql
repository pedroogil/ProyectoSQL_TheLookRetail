-- PROYECTO ANÁLISIS RETAIL 

---------------------------------------------------------------------------------
-- Paso 4: Análisis de datos
---------------------------------------------------------------------------------

use thelookretail;

--------------------------------------------------------------------------------- 
-- Query and Report
--------------------------------------------------------------------------------- 

-- ¿Cuántos pedidos tenemos en nuestro histórico que no se hayan cancelado?
select count(*) from orders where status != "Cancelled"; -- 106.617 pedidos

-- ¿Desde qué día a qué día tenemos datos?
select min(created_at), max(created_at)
from orders; -- Desde el 6 de enero de 2019 hasta el 17 de enero de 2024

-- ¿Cuántos productos distintos tenemos en nuestro catálogo?
select count(distinct name) from products; -- 27.293 productos

-- ¿Cuántos clientes nos han comprado?
select count(distinct user_id) from order_items; -- 80.044 clientes

-- ¿Dónde nos pueden encontrar?
select name from distribution_centers;

-- ¿Cuáles son los 3 centros donde más facturamos? (No beneficio)
select d.name, sum(oi.sale_price) as facturacion
from order_items oi left join products p on oi.product_id = p.id
					left join distribution_centers d on p.distribution_center_id = d.id
group by d.name
order by facturacion desc
limit 3; -- Houston (1.57 millones), Memphis (1.41 millones) y Chicago (1.33 millones)

-- ¿Cuál ha sido la evolución mensual de la facturación por centro de distribución en los últimos 12 meses completos?

-- Aquí comentar que cometí un error al eliminar las fechas de la tabla de hechos. En este caso, nos tocará hacer una relación de más
-- Como hemos visto anteriormente, el último registro es del 17 de enero de 2024, por lo que los últimos 12 meses completos coinciden con el año 2023
select p.distribution_center_id, month(pedidos_ult_12meses.created_at) as mes, sum(pedidos_ult_12meses.sale_price) as facturacion
from products p inner join 
					(select oi.*, o.created_at from order_items oi inner join orders o on oi.order_id = o.order_id where o.created_at between "2023-01-01" and "2023-12-31") pedidos_ult_12meses 
				on p.id = pedidos_ult_12meses.product_id
group by p.distribution_center_id, month(pedidos_ult_12meses.created_at)
order by distribution_center_id, mes;
-- Esta información nos puede ser útil para ver las tendencias de los centros de distribución
-- Ninguno de nuestros canales ha facturado menos el último mes (diciembre, 2023) que el primero (enero, 2023), lo cuál nos indica que nuestra tendencia general es ascendente
-- Aunque, por supuesto, deberíamos entrar más en detalle y saber si esto se debe a una tendencia general de compra por mes, o si efectivamente nuestra tendencia es ascendente

-- Nombre de nuestros 50 clientes con mayor facturación
select u.first_name, u.last_name, sum(oi.sale_price) as facturacion
from order_items oi inner join users u on oi.user_id = u.id
group by first_name, last_name
order by facturacion desc
limit 50;
-- Con estos clientes podemos tener un trato más "favorable" ya que son los que más están aportando a nuestra facturación

-- Facturación por nacionalidad del cliente por trimestre
select country, quarter(o.created_at) as trimestre, sum(oi.sale_price) as facturacion
from location l inner join users u on l.id_location = u.id_location
				inner join order_items oi on u.id = oi.user_id
                inner join orders o on oi.order_id = o.order_id 
group by country, quarter(o.created_at)
order by country, trimestre;
-- A simple vista, parece que nuestros trimestres con mayor facturación al año son los dos últimos
-- Lo cuál podría explicar la evolución en facturación que vimos en los últimos 12 meses, que coincidían con el periodo enero-diciembre

--------------------------------------------------------------------------------- 
-- Análisis del margen
--------------------------------------------------------------------------------- 

-- Vamos a localizar los 20 Productos en los que sacamos mayor margen en cada categoría, para potenciar su venta
select * 
from (select category, name, round(((retail_price - cost)/cost)*100,2) as margen_porc, rank() OVER(Partition by category order by ((retail_price - cost)/cost)*100 desc) as ranking
from products) as tabla_ranking
where ranking between 1 and 20
order by category, ranking;
-- Tenemos bastantes productos que superan el 100% del margen obtenido, es decir, duplicamos coste de adquisición
-- Estos productos serán los que debamos recomendar más

select * from products where name = "Carhartt Men's Utility Suspender";
-- Por ver un ejemplo, este producto nos cuesta al proveedor 5.96 y se vende a 16.99 en nuestros centros

--------------------------------------------------------------------------------- 
-- Análisis de portfolio
--------------------------------------------------------------------------------- 

-- ¿Con qué productos deberíamos quedarnos para mantener el 90% de la facturación?
with facturacion_producto_acumulada as(
select product_id, sum(sale_price) as facturacion, sum(sale_price)/(select sum(sale_price) from order_items)*100 as facturacion_porc_total, 
		sum(sum(sale_price)/(select sum(sale_price) from order_items)*100) OVER(Order by sum(sale_price)/(select sum(sale_price) from order_items)*100 desc rows between Unbounded preceding and current row) as facturacion_acumulada
from order_items
group by product_id
order by facturacion desc)

select * from facturacion_producto_acumulada where facturacion_acumulada <= 90;
-- 18.088 de 29.046, lo cual significa que hay mas de 10.000 productos que podriamos eliminar de nuestro catálogo y no afectaría prácticamente a la facturación
-- Aquí convendría hacer un análisis más profundo de los costes de distribución, u otros costes indirectos, que pueden acarrear estos más de 10.000 productos que no aparecen
-- Aquellos que nos supongan un alto esfuerzo, podemos optar por eliminarlos del catálogo

-- ¿Qué categorías diferentes de productos tenemos?
select distinct category from products; -- 26 categorías

-- ¿Qué nos aporta cada categoría a la facturación?
select category, sum(oi.sale_price) as facturacion, sum(oi.sale_price)/(select sum(sale_price) from order_items)*100 as facturacion_porc
from products p inner join order_items oi on p.id = oi.product_id
group by category
order by facturacion desc;
-- Tenemos 4 categorías que aportan menos del 1% a nuestra facturación
-- Si nos suponen muy costosas a nivel logístico, podemos optar por eliminarlas, y potenciar aquellas que nos son más rentables

-- Dentro de nuestra línea que más factura (Outerwear & coats) hay algún producto en tendencia? 
-- Vamos a definir tendencia como el crecimiento en el cuarto trimestre de 2023 con respecto del tercer trimestre de 2023, que son nuestros últimos datos disponibles
with q3_2023 as(
select product_id, name, sum(oi.sale_price) as fact_q3
from order_items oi inner join products p on oi.product_id = p.id
					inner join orders o on oi.order_id = o.order_id
where o.created_at between '2023-07-01' and '2023-09-30'
group by product_id, name),

q4_2023 as(
select product_id, name, sum(oi.sale_price) as fact_q4
from order_items oi inner join products p on oi.product_id = p.id
					inner join orders o on oi.order_id = o.order_id
where o.created_at between '2023-10-01' and '2023-12-31'
group by product_id, name),

tendencia as(
select q3.product_id, q3.name, fact_q3, fact_q4, round((fact_q4-fact_q3)/fact_q3*100,2) as crecimiento_porc
from q3_2023 q3 inner join q4_2023 q4 on q3.product_id = q4.product_id 
									and q3.name = q4.name
order by crecimiento_porc desc)

select * from tendencia;
select count(*) from tendencia where crecimiento_porc > 100;

-- El producto G-Star Men's Aero Rovic Loose Pant, con id 21889 está en pleno auge, con un crecimiento del 700% en facturacion
-- Tenemos 1.003 productos que han incrementado más de un 100% de facturación el último trimestre
-- Hay que aprovechar el "tirón" que están teniendo estos productos y tratar de maximizar sus ventas

--------------------------------------------------------------------------------- 
-- Gestión avanzada de clientes
--------------------------------------------------------------------------------- 

-- Vamos a segmentar nuestros clientes en base al número de pedidos y la facturación de cada cliente
with pedidos as(
	select user_id, count(order_id) as pedidos from order_items group by user_id),
    
facturacion as(
	select user_id, sum(sale_price) as facturacion from order_items group by user_id),
    
matriz as(
select user_id,
	Case
		when count(order_id) > (select avg(pedidos) from pedidos) then 2
        else 1
	end as cat_pedidos,
	Case 
		when sum(sale_price) > (select avg(facturacion) from facturacion) then 2
        else 1
	end as cat_facturacion
from order_items
group by user_id)

select count(*) from matriz where cat_pedidos = 2 and cat_facturacion = 2; #19.742 usuarios que nos hacen más pedidos que la media y que aportan a la facturación mas de la media. 24,7%
select count(*) from matriz where cat_pedidos = 2 and cat_facturacion = 1; #5.693 usuarios que nos hacen más pedidos que la media, pero que aportan menos a la facturación que la media. 7,1%
select count(*) from matriz where cat_pedidos = 1 and cat_facturacion = 2; #8.669 usuarios que no nos hacen muchos pedidos, pero que aportan a la facturación más que la media. Clientes muy rentables. 10,8%
select count(*) from matriz where cat_pedidos = 1 and cat_facturacion = 1; #45.940 usuarios que no nos hacen muchos pedidos, y que tampoco aportan excesivamente a la facturación. Los más comunes. 57,4%

-- Esto nos permite hacer una segmentación de clientes, para ver cómo es nuestro mercado

--------------------------------------------------------------------------------- 
-- Reactivación de clientes
--------------------------------------------------------------------------------- 

-- Clientes que lleven más de 3 meses sin comprar
with fechas as(
  select 
    MAX(created_at) ult_fecha,
    DATE_SUB(MAX(created_at), INTERVAL 3 MONTH) ult_fecha_3meses
  from orders
)

select u.id as user_id, u.first_name, u.last_name
from users u
inner join order_items oi on u.id = oi.user_id
inner join orders o on oi.order_id = o.order_id
group by u.id, u.first_name, u.last_name
having MAX(o.created_at) < (select ult_fecha_3meses from fechas);

-- Tenemos 58.516 usuarios que no han comprado los últimos 3 meses, de los 80.044 clientes totales que tenemos
-- Es un 73%, lo cuál a simple vista parece bastante. No obstante, por el modelo de negocio, parece que tenemos más volumen que frecuencia de clientes

--------------------------------------------------------------------------------- 
-- Sistema de recomendación
---------------------------------------------------------------------------------

-- En base a compras anteriores de un cliente, ¿qué producto le podemos recomendar?

create table recomendador
select oi1.product_id antecedente, oi2.product_id consecuente, count(*) frecuencia
from order_items oi1 inner join order_items oi2
on oi1.order_id = oi2.order_id
and oi1.product_id < oi2.product_id
group by oi1.product_id, oi2.product_id;

select * from recomendador;

with cliente_a_recomendar as(
select product_id, user_id
from order_items
where user_id = 100),
            
producto_recomendado as(
select consecuente, sum(frecuencia) as frecuencia
from cliente_a_recomendar c left join recomendador r
on c.product_id = r.antecedente
group by consecuente
order by frecuencia desc)
		
select consecuente as recomendado, frecuencia
from producto_recomendado p left join cliente_a_recomendar c
on p.consecuente = c.product_id
where product_id is null
limit 10;

/*
Como nuestra empresa cuenta con muchos clientes, pero poca frecuencia de compra, no se ve el total potencial de esta herramienta,
pero solo cambiando el id de usuario en la CTE de cliente a recomendar, podríamos saber exactamente qué productos recomendar a qué clientes.
Con solo un click sabemos, basándonos en los datos, hacia donde orientar nuestras ventas. Ahorrándonos así mucho tiempo de análisis
*/



