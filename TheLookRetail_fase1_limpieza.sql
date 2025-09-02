-- PROYECTO ANÁLISIS RETAIL

---------------------------------------------------------------------------------
-- Contexto
---------------------------------------------------------------------------------

/*
El dataset original viene de Kaggle. 
Las tablas están desnormalizadas en algunos casos, con redundancia y tipos de datos ineficientes en otros. 
Con esta fase 1 se busca:
	Eliminar duplicados,
	Normalizar (ej. tabla location),
	Unificar tipos de datos,
	Definir claves primarias y foráneas.

Resultado final: modelo en estrella con 2 tablas de hechos y 6 de dimensiones, listo para análisis.
*/

---------------------------------------------------------------------------------
-- Paso 1: Importación base de datos y exploración de las diferentes tablas
---------------------------------------------------------------------------------

create database TheLookRetail;
use thelookretail;
-- Se han importado los diferentes archivos csv a través de Python

-- Exploración rápida para ver ante que tipo de datos estamos
select * from distribution_centes;
select * from events;
select * from inventory_items;
select * from order_items;
select * from orders;
select * from products;
select * from users;

-- Ya podemos observar como algunos campos van a necesitar ser retocados en la fase de limpieza

-- Comprobamos el diagrama de entidad relación, para ver como se relacionan nuestras tablas. Database -> Reverse Engineer
-- Tras observarlo, vemos como nuestras tablas no están relacionadas, por lo que también tendremos que crear esas relaciones

---------------------------------------------------------------------------------
-- Paso 2: Limpieza de los datos
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Tabla distribution_centes
---------------------------------------------------------------------------------

-- Para empezar, el nombre de la tabla contiene una pequeña errata
Alter table distribution_centes rename to distribution_centers;
select * from distribution_centers;

-- Viendo los tipos de dato de los campos, la columna id está en Bigint, para ahorrar espacio es conveniente que lo pasemos a un formato int, puesto que no es una tabla que esperamos tener muchísimos registros
Alter table distribution_centers modify column id int;

-- Por lo demás, parece todo correcto.

---------------------------------------------------------------------------------
-- Tabla inventory_items
---------------------------------------------------------------------------------

-- Vamos a comprobar que no haya duplicados
select id, count(id) as conteo
from inventory_items
group by id
order by conteo desc;
-- Perfecto, no tenemos duplicados

-- Las fechas nos es suficiente con formato "date", sin horas, minutos y segundos
Alter table inventory_items modify column created_at Date,
							modify column sold_at Date;
                            
-- Cambiamos los campos bigint a int, para ahorrar espacio
Alter table inventory_items modify column id int,
							modify column product_id int;
                            
-- Los precios deberían estar a dos decimales como máximo
Alter table inventory_items modify column cost Decimal(12,2),
							modify column product_retail_price Decimal(12,2);
                            
-- El product_sku es un identificador único de producto. Como ya tenemos product_id, y además, el sku se encuentra en la tabla products, procedemos a eliminar el campo de esta tabla
Alter table inventory_items drop column product_sku;

-- No solo eso, si no que las columnas coste, categoria, nombre, marca, precio en retail, departamento y centro de distribucion, ya se encuentra en la tabla productos
-- Por lo que aquí la única informacion relevante seria dejar el id de producto y la fecha en la que se ha añadido al inventario y la que se ha vendido (si tiene)
Alter table inventory_items drop column cost,
							drop column product_category,
                            drop column product_name,
                            drop column product_brand,
                            drop column product_retail_price,
                            drop column product_department,
                            drop column product_distribution_center_id;
                            
/* 
De esta forma, 
hemos reducido redundancia, hemos simplificado las tablas, y hemos normalizado en parte lo que será nuestro diagrama de entidad relación.

Aunque posteriormente se determinó que la transformación de precios a dos decimales no era estrictamente necesaria, 
decidí dejarla plasmada para documentar completamente el flujo de limpieza de datos y mantener transparencia en los pasos seguidos. 
Esto demuestra un enfoque meticuloso y orientado a buenas prácticas en el manejo de datos
*/

---------------------------------------------------------------------------------
-- Tabla Order_items 
---------------------------------------------------------------------------------

-- Vamos a comprobar que no haya duplicados
select id, count(id) as conteo
from order_items
group by id
order by conteo desc;
-- Perfecto, no tenemos duplicados

-- Esta tabla de pedidos será nuestra tabla de hechos, por lo que campos como el estatus del pedido, la fecha de cancelación, etc. Ya los tenemos en la tabla orders, podemos eliminarlas
Alter table order_items drop column status,
						drop column created_at,
                        drop column shipped_at,
                        drop column delivered_at,
                        drop column returned_at;
                        
-- Dejamos la columna del precio a dos decimales
Alter table order_items modify column sale_price Decimal(12,2);

-- Por último, cambiamos los campos ID a int en vez de bigint para ahorrar espacio.
Alter table order_items modify column id int,
						modify column order_id int,
                        modify column user_id int,
                        modify column product_id int,
                        modify column inventory_item_id int;
                        
---------------------------------------------------------------------------------
-- Tabla orders
---------------------------------------------------------------------------------

-- Vamos a comprobar que no haya duplicados
select order_id, count(order_id) as conteo
from orders
group by order_id
order by conteo desc;
-- Perfecto, no tenemos duplicados

-- Cambiamos los campos ID de bigint a int
Alter table orders modify column order_id int,
					modify column user_id int,
					modify column num_of_item int;

-- Eliminamos el campo del id de usuario y género, puesto que ya están en la tabla order_items y users, respectivamente
Alter table orders drop column user_id,
					drop column gender;

-- Cambiamos las fechas al formato "date", sin horas, minutos y segundos
Alter table orders modify column created_at date,
					modify column returned_at date,
                    modify column shipped_at date,
                    modify column delivered_at date;

---------------------------------------------------------------------------------
-- Tabla products
---------------------------------------------------------------------------------

-- Vamos a comprobar que no haya duplicados
select id, count(id) as conteo
from products
group by id
order by conteo desc;
-- Perfecto, no tenemos duplicados

-- Cambiamos los campos ID de bigint a int
Alter table products modify column id int,
					modify column distribution_center_id int;

-- Cambiamos los precios para mostrar solo dos decimales
Alter table products modify column cost decimal(12,2),
					modify column retail_price decimal(12,2);

-- La categoría de departamento parece un poco ambigua, vamos a comprobar qué valores tiene
select distinct department from products;

-- Parece que solo sale "hombres" y "mujeres", de momento lo dejamos ahí, aunque deberíamos pedir más información al respecto

---------------------------------------------------------------------------------
-- Tabla users
---------------------------------------------------------------------------------

-- Vamos a comprobar que no haya duplicados
select id, count(id) as conteo
from users
group by id
order by conteo desc;
-- Perfecto, no tenemos duplicados

-- Cambiamos los campos numéricos enteros de bigint a int
Alter table users modify column id int,
					modify column age int;
 
-- Cambiamos la fechas al formato Date, sin horas, minutos y segundos
Alter table users modify column created_at date;

-- El resto de datos parecen correctos, sin embargo vemos a simple vista que algunas ciudades salen nulas 
select count(*) from users where city is null;
-- Tenemos 958 registros sin ciudad registrada de 100000 totales. Al ser menos del 1%, en principio no nos debería suponer un problema
-- Aunque más adelante vamos a darle solución

-- Los campos de la localización ocupan bastante, sería recomendable crear una tabla aparte con los datos de postal_code, ciudad, pais, latitud y longitud
CREATE TABLE location (
    id_location INT AUTO_INCREMENT PRIMARY KEY,
    postal_code VARCHAR(30) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    latitude Double,
    longitude Double,
    UNIQUE (postal_code, city, country)
);

INSERT INTO location (postal_code, city, country, state, latitude, longitude)
SELECT DISTINCT postal_code, city, country, state, latitude, longitude
FROM users;

select * from location;

-- Comprobamos que no haya duplicados
select id_location, count(id_location) as conteo
from location
group by id_location
Order by conteo desc;
-- Perfecto, no tenemos duplicados

-- Ahora vamos a darle solución al problema de los nulos en las ciudades. Vamos a sustituirlos por "Desconocida"
-- Para ello, se desactiva modo seguro para permitir updates sin cláusula WHERE usando clave primaria
SET SQL_SAFE_UPDATES = 0;

UPDATE Location SET city = "Desconocida"
where city is null;

-- Y volvemos al modo seguro 
SET SQL_SAFE_UPDATES = 1;

-- Vamos a añadir la columna id_location a nuestra tabla users
select * from users;
Alter table users add column id_location int; 

-- Tenemos que desconectar el modo seguro un instante para que nos deje introducir los registros
SET SQL_SAFE_UPDATES = 0;

UPDATE users u
INNER JOIN location l 
  ON u.postal_code = l.postal_code
 AND u.city = l.city
 AND u.country = l.country
SET u.id_location = l.id_location;

-- Volvemos a activar el modo seguro
SET SQL_SAFE_UPDATES = 1;

-- Eliminamos los campos que ya no nos hacen falta en la tabla users
alter table users drop column state,
					drop column postal_code,
                    drop column city,
                    drop column country,
                    drop column latitude,
                    drop column longitude;

-- Tenemos nuestra tabla más normalizada
select * from users;

---------------------------------------------------------------------------------
-- Tabla events
---------------------------------------------------------------------------------

-- Vamos a comprobar que no haya duplicados
select id, count(id) as conteo
from events
group by id
order by conteo desc;
-- Perfecto, no tenemos duplicados

-- Parece que hay un error con el user_id, vamos a ver cuantos nulos tenemos
select count(*) from events where user_id is null;
select count(*) from events where user_id is not null;
-- Efectivamente, tenemos más de 1 millón de registros donde el user_id es nulo. Aproximadamente el 50%

/* 
Sin embargo, tenemos un problema, 
y es que tenemos muy pocos campos en común entre las tablas de eventos y usuarios, por lo que es prácticamente imposible hacer match perfecto para completar el user_id.
Quizás no detectó el usuario porque entraron en modo anónimo.
Como no tenemos forma de solucionar este problema, vamos a completar los registros nulos como usuarios "anónimos" (0)
Tendremos cuidado al analizar conversión usuarios anónimos vs registrados 
*/

INSERT INTO users (id, first_name)
Values (0, "Anonimo");

SET SQL_SAFE_UPDATES = 0;

UPDATE events 
SET user_id = 0
where user_id is null;

SET SQL_SAFE_UPDATES = 1;

-- Continuamos con la limpieza, vamos a cambiar los campos bigint a int, incluso user_id aparece como double, también lo cambiamos a int
Alter table events modify column id int,
					modify column user_id int,
                    modify column sequence_number int;
                    
-- Cambiamos la fecha al formato correcto
Alter table events modify column created_at date;
select * from events;

-- Aprovechamos la tabla que creamos anteriormente de location para conectarla con esta
Alter table events add column id_location int;

SET SQL_SAFE_UPDATES = 0;

Update 
events e INNER JOIN location l on 
e.city = l.city and e.state = l.state and e.postal_code = l.postal_code
set e.id_location = l.id_location;

SET SQL_SAFE_UPDATES = 1;

-- Eliminamos columnas que ya no necesitamos
Alter table events drop column city,
					drop column state,
                    drop column postal_code;
                    
-- La ubicación en la tabla events es la ubicación desde donde se está realizando el evento (registro, cancelación, etc.), no la ubicación del usuario
-- Por ejemplo, un usuario procedente de Madrid puede estar realizando una búsqueda en Barcelona

---------------------------------------------------------------------------------
-- Revisión
---------------------------------------------------------------------------------

select * from distribution_centers;
select * from events;
select * from inventory_items;
select * from order_items;
select * from orders;
select * from products;
select * from users;
-- Parece que está todo correcto, podemos proceder a crear las relaciones

---------------------------------------------------------------------------------
-- Paso 3: conexiones entre tablas
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Tabla distribution_centers
---------------------------------------------------------------------------------

-- Asignamos la columna id como Primary Key
Alter table distribution_centers add primary key(id);

---------------------------------------------------------------------------------
-- Tabla products
---------------------------------------------------------------------------------

-- Asignamos la columna id como Primary Key y distribution center como foreign key de nuestra tabla distribution_centers. 
-- On delete cascade es para asegurarnos que si se borra un valor en la tabla asociada con la primary key, se borre también en esta tabla donde aparece como foreign key
Alter table products add primary key(id),
					add foreign key (distribution_center_id) References distribution_centers(id) on delete cascade;
                    
---------------------------------------------------------------------------------                    
-- Tabla orders
---------------------------------------------------------------------------------

-- Asignamos la columna order_id como Primary Key
Alter table orders add primary key (order_id);

---------------------------------------------------------------------------------
-- Tabla inventory_items
---------------------------------------------------------------------------------

-- Asignamos la columna id como Primary Key y product_id como foreign key
Alter table inventory_items add primary key (id),
							add foreign key (product_id) references products(id) on delete cascade;
                            
---------------------------------------------------------------------------------
-- Tabla users
---------------------------------------------------------------------------------

-- Asignamos la columna id como Primary Key e id_location como foreign key
Alter table users add primary key (id),
					add foreign key (id_location) references location(id_location) on delete cascade;
                    
---------------------------------------------------------------------------------                    
-- Tabla events
---------------------------------------------------------------------------------

-- Asignamos la columna id como Primary Key, user_id e id_location como Foreign Key
Alter table events add primary key (id),
					add foreign key (user_id) references users (id) on delete cascade,
                    add foreign key (id_location) references location (id_location) on delete cascade;

---------------------------------------------------------------------------------
-- Tabla order_items
---------------------------------------------------------------------------------
-- Asignamos la columna id como Primary Key, y, order_id, user_id, product_id e inventory_item_id como foreign key
Alter table order_items add primary key (id),
						add foreign key (order_id) references orders(order_id) On delete cascade,
                        add foreign key (user_id) references users(id) on delete cascade,
                        add foreign key (product_id) references products(id) on delete cascade,
                        add foreign key (inventory_item_id) references inventory_items(id) on delete cascade;
                        
-- Vamos a ver ahora nuestro diagrama de entidad relación -> reverse engineer

---------------------------------------------------------------------------------
-- Final fase limpieza
---------------------------------------------------------------------------------

/*
Tenemos la siguiente estructura:
Tablas de hechos: Order_items y events
Tablas de dimensiones: Distribution_centers, products, inventory items, orders, users y location
Ya hemos limpiado y establecido conexiones, por lo que el siguiente paso será analizar nuestros datos

PASOS 1-2-3 ACABADOS
*/
