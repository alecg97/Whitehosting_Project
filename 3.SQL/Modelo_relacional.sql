######################################
# MODELO RELACIONAL - PROYECTO HOSTING 
######################################

#################################
# Creación de la Base de Datos
#################################

-- Eliminamos la base de datos si existe
DROP DATABASE IF EXISTS proyecto_hosting;

-- Creamos la base de datos
CREATE DATABASE proyecto_hosting;

-- Seleccionamos la base de datos para trabajar con ella
USE proyecto_hosting;

-- Eliminamos tablas si existen (respetando dependencias)
DROP TABLE IF EXISTS 
    ocupacion_Ciudad,
    precio_Vivienda,
    evolucion_historica_turismo,
    pernoctaciones,
    detalles,
    ratings,
    disponibilidad,
    servicios,
    anuncios,
    localizaciones,
    ciudades,
    provincias,
    comunidades,
    paises,
    tipo_alojamiento,
    anfitriones;

##########################################
# Creación de Tablas e Inserción de Datos
##########################################   

----- Jerarquías Geográficas ------

-- Tabla Paises
CREATE TABLE paises (
    id_pais INT PRIMARY KEY,
    nombre_pais VARCHAR(50)
);

INSERT INTO paises (id_pais, nombre_pais)
VALUES (1, 'España');

 -- Tabla Comunidades
CREATE TABLE comunidades (
    id_ccaa INT PRIMARY KEY,
    nombre_ccaa VARCHAR(50),
    id_pais INT,
    CONSTRAINT fk_ccaa_pais FOREIGN KEY (id_pais) REFERENCES paises(id_pais)
);

INSERT INTO comunidades (id_ccaa, nombre_ccaa, id_pais)
VALUES 
(1, 'Cataluña', 1),
(2, 'Comunidad de Madrid', 1),
(3, 'Comunidad Valenciana', 1),
(4, 'Aragón', 1),
(5, 'Castilla y León', 1);
    
 -- Tabla Provincias
CREATE TABLE provincias (
    id_provincia INT PRIMARY KEY,
    nombre_provincia VARCHAR(50),
    id_ccaa INT,
    CONSTRAINT fk_prov_ccaa FOREIGN KEY (id_ccaa) REFERENCES comunidades(id_ccaa)
);

INSERT INTO provincias (id_provincia, nombre_provincia, id_ccaa)
VALUES
(1, 'Barcelona', 1),
(2, 'Madrid', 2),
(3, 'Valencia', 3),
(4, 'Zaragoza', 4),
(5, 'Palencia', 5);
        
 -- Tabla Ciudades  
 CREATE TABLE ciudades (
    id_ciudad INT PRIMARY KEY,
    nombre_ciudad VARCHAR(50),
    id_provincia INT,
    CONSTRAINT fk_ciudad_provincia FOREIGN KEY (id_provincia) REFERENCES provincias(id_provincia)
);

INSERT INTO ciudades (id_ciudad, nombre_ciudad, id_provincia)
VALUES
(1, 'Barcelona', 1),
(2, 'Madrid', 2),
(3, 'Valencia', 3),
(4, 'Zaragoza', 4),
(5, 'Palencia', 5);   
    
-- Tabla Localizaciones
CREATE TABLE localizaciones (
    id_distrito INT PRIMARY KEY,
    nombre_distrito VARCHAR(50),
    id_ciudad INT,
    CONSTRAINT fk_loc_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
);

INSERT INTO localizaciones (id_distrito, nombre_distrito, id_ciudad)
VALUES
(1, 'Barceloneta', 1),   
(2, 'Vallecas', 2),      
(3, 'El Pla del Real', 3),  
(4, 'Delicias', 4),      
(5, 'Aguilar de Campoo', 5); 

-- Probamos consulta para ver que funcionan:
SELECT lo.nombre_distrito, ci.nombre_ciudad, pro.nombre_provincia, com.nombre_CCAA, pa.nombre_pais
FROM localizaciones AS lo
INNER JOIN ciudades AS ci
ON lo.id_ciudad = ci.id_ciudad
INNER JOIN provincias AS pro
ON ci.id_provincia = pro.id_provincia
INNER JOIN comunidades AS com
ON pro.id_ccaa = com.id_ccaa
INNER JOIN paises AS pa
ON com.id_pais = pa.id_pais;


----- Datos del Alojamiento -----

-- Tabla Tipo Alojamiento
CREATE TABLE tipo_alojamiento (
    id_tipo_alojamiento INT PRIMARY KEY,
    tipo_alojamiento VARCHAR(50)
);

INSERT INTO tipo_alojamiento (id_tipo_alojamiento, tipo_alojamiento)
VALUES
(1, 'Apartamento entero'),
(2, 'Habitación privada'),
(3, 'Habitación compartida'),
(4, 'Habitación de hotel'),
(5, 'Casa entera');

-- Tabla Anfitriones
CREATE TABLE anfitriones (
    id_anfitrion INT PRIMARY KEY,
    nombre_anfitrion VARCHAR(100)
);

INSERT INTO anfitriones (id_anfitrion, nombre_anfitrion)
VALUES
(1,'Alejandro'),
(2,'Daniel'),
(3,'Carlos'),
(4,'Menganito'),
(5,'Jaimito');

-- Tabla Anuncios
CREATE TABLE anuncios (
    id_anuncio INT PRIMARY KEY,
    id_tipo_alojamiento INT,
    id_distrito INT,
    id_anfitrion INT,
    precio_noche DECIMAL(10,2),
    CONSTRAINT fk_Anuncios_Localizaciones FOREIGN KEY (id_distrito) REFERENCES localizaciones(ID_distrito),
    CONSTRAINT fk_Anuncios_Tipo_Alojamiento FOREIGN KEY (id_tipo_alojamiento) REFERENCES tipo_alojamiento(id_tipo_alojamiento),
    CONSTRAINT fk_Anuncios_Anfitrion FOREIGN KEY (id_anfitrion) REFERENCES anfitriones(id_anfitrion)
);

INSERT INTO anuncios (id_anuncio, id_tipo_alojamiento, id_distrito, id_anfitrion, precio_noche)
VALUES
(1, 1 , 1 , 3, 80 ),
(2, 4 , 2 , 4, 200 ),
(3, 1 , 2 , 1, 70 ),
(4, 4 , 4 , 2, 180 ),
(5, 3 , 5 , 4, 40 );

SELECT *
FROM Anuncios;


-- Probamos algunas consultas:
-- Veo los anuncios pertenecientes a cada distrito, añadiendo la ciudad asociada:
SELECT lo.nombre_distrito, ci.nombre_ciudad, an.*
FROM localizaciones as lo
INNER JOIN ciudades AS ci
ON lo.id_ciudad = ci.id_ciudad
LEFT JOIN anuncios as an
ON lo.id_distrito = an.id_distrito;


-- Tipo de alojamiento, distrito perteneciente, precio noche y nombre de anfitrion por anuncio 
SELECT an.id_anuncio, al.tipo_alojamiento, lo.nombre_distrito, an.precio_noche, anf.nombre_anfitrion
FROM anuncios AS an
INNER JOIN tipo_alojamiento AS al
ON an.id_tipo_alojamiento = al.id_tipo_alojamiento
INNER JOIN localizaciones AS lo
ON an.id_distrito = lo.id_distrito
INNER JOIN anfitriones AS anf
ON an.id_anfitrion = anf.id_anfitrion;


-- Tabla Ratings
CREATE TABLE ratings (
	id_rating INT AUTO_INCREMENT PRIMARY KEY,
    id_anuncio INT,
    fecha_review DATE,
    rating_limpieza DECIMAL(4,2),
    rating_veracidad DECIMAL(4,2),
    rating_llegada DECIMAL(4,2),
    rating_comunicacion DECIMAL(4,2),
    rating_ubicacion DECIMAL(4,2),
    rating_calidad DECIMAL(4,2),
    CONSTRAINT fk_ratings_anuncios FOREIGN KEY (id_anuncio) REFERENCES anuncios(id_anuncio)
);

INSERT INTO ratings (id_anuncio, fecha_review, rating_limpieza, rating_veracidad, rating_llegada, rating_comunicacion, rating_ubicacion, rating_calidad)
VALUES
(1, '2024-05-22', 3.4, 5.6, 5.0, 6.5, 7.2, 8.1),
(2, '2023-09-10', 4.3, 6.5, 6.0, 7.5, 8.0, 8.5),
(1, '2022-12-31', 4.4, 5.6, 5.0, 5.5, 6.2, 7.1),
(4, '2024-01-10', 5.4, 6.6, 5.5, 6.5, 7.5, 8.0),
(5, '2023-11-30', 3.4, 5.0, 5.0, 6.5, 6.0, 7.5);

-- Probamos alguna consulta:
-- Cantidad de reseñas por anuncio
SELECT id_anuncio,
COUNT(*) AS reseñas_totales
FROM Ratings
GROUP BY id_anuncio;

-- Todos los anuncios junto sus reseñas (si tienen):
SELECT an.id_anuncio, rat.*
FROM Anuncios AS an
LEFT JOIN Ratings AS rat
ON an.ID_Anuncio = rat.ID_Anuncio;


-- Tabla Servicios
CREATE TABLE servicios (
    id_anuncio INT PRIMARY KEY,
    accommodates INT,
    beds INT,
    bedrooms INT,
    bathrooms INT,
    serv_playa BOOLEAN,
    serv_piscina BOOLEAN,
    serv_parking BOOLEAN,
    serv_wifi BOOLEAN,
    serv_aireacond BOOLEAN,
    serv_calefaccion BOOLEAN,
    CONSTRAINT fk_servicios_anuncios FOREIGN KEY (id_anuncio) REFERENCES anuncios(id_anuncio)
);

INSERT INTO servicios (id_anuncio, accommodates, beds, bedrooms, bathrooms, serv_playa, serv_piscina, serv_parking, serv_wifi, serv_aireacond, serv_calefaccion)
VALUES
(1, 4, 3, 3, 2, 1, 1, 1, 1, 1, 1),
(2, 5, 3, 3, 2, 1, 1, 1, 1, 1, 1),
(3, 5, 4, 2, 1, 1, 1, 1, 1, 1, 1),
(4, 3, 5, 3, 2, 0, 0, 1, 1, 0, 1),
(5, 1, 3, 2, 1, 1, 0, 1, 1, 1, 1);


-- Tabla Disponibilidad
CREATE TABLE disponibilidad (
    id_anuncio INT PRIMARY KEY,
    avail_30 INT,
    avail_60 INT,
    avail_90 INT,
    avail_365 INT,
    CONSTRAINT fk_disponibilidad_anuncios FOREIGN KEY (id_anuncio) REFERENCES anuncios(id_anuncio)
);

INSERT INTO disponibilidad (id_anuncio, avail_30, avail_60, avail_90, avail_365)
VALUES
(1, 23, 53, 83, 264),
(2, 20, 50, 89, 281),
(3, 10, 33, 61, 162),
(4, 15, 46, 64, 184),
(5, 8, 22, 50, 101);


-- Tabla Detalles
CREATE TABLE detalles (
    id_anuncio INT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT,
    CONSTRAINT fk_detalles_anuncios FOREIGN KEY (id_anuncio) REFERENCES anuncios(id_anuncio)
);

INSERT INTO detalles (id_anuncio, nombre, descripcion)
VALUES
(1, 'La casita', 'Amazing and cozy , under the beams'),
(2, 'Amazing hotel', 'The perfect choose for any visit'),
(3, 'Apartamento en el centro', 'espaciosa estancia para estar con los tuyos'),
(4, 'Recoletos', 'tienes todo lo necesario para descansar y disfrutar'),
(5, 'Park River', 'bright quiet and cosy');

-- Probamos consulta:
-- Añadimos nombre y descripcion del alojamiento
SELECT an.*, det.nombre, det.descripcion
FROM Anuncios AS an
INNER JOIN Detalles AS det
ON an.ID_Anuncio = det.ID_Anuncio;


----- Históricos de información turística  -----

-- Tabla Pernoctaciones
CREATE TABLE pernoctaciones (
    id_ccaa INT,
    año YEAR,
    promedio DECIMAL(4,2),
    PRIMARY KEY (id_ccaa, año),
    CONSTRAINT fk_ccaa_pern FOREIGN KEY (id_ccaa) REFERENCES comunidades(id_ccaa)
);

INSERT INTO pernoctaciones (id_ccaa, año, promedio)
VALUES
(1, 2024, 5.5),
(2, 2023, 4.5),
(3, 2022, 6.5),
(4, 2024, 7.5),
(5, 2023, 8.5);


-- Tabla Evolución Histórica Turismo
CREATE TABLE evolucion_historica_turismo (
    id_ccaa INT,
    año YEAR,
    variacion_turismo DECIMAL(5,2),
    PRIMARY KEY (id_ccaa, año),
    CONSTRAINT fk_ccaa_evtur FOREIGN KEY (id_ccaa) REFERENCES comunidades(id_ccaa)
);

INSERT INTO evolucion_historica_turismo (id_ccaa, año, variacion_turismo)
VALUES
(1, 2024, 5.5),
(2, 2023, 4.5),
(3, 2022, 6.5),
(4, 2024, 7.5),
(5, 2023, 8.5);

-- Probamos consultas:
-- Añadimos nombre de la CCAA, solo a ccaa con datos 
SELECT com.nombre_ccaa, ev.año, ev.variacion_turismo 
FROM evolucion_historica_turismo AS ev
INNER JOIN comunidades as com
ON ev.id_ccaa = com.id_ccaa; 


-- Tabla Precio Vivienda
CREATE TABLE precio_vivienda (
    id_provincia INT,
    año YEAR,
    precio DECIMAL(9,2),
    PRIMARY KEY (id_provincia, Año),
    CONSTRAINT fk_provincias_precviv FOREIGN KEY (id_provincia) REFERENCES provincias(id_provincia)
);

INSERT INTO precio_vivienda (id_provincia, año, precio)
VALUES
(1, 2024, 200),
(1, 2023, 150),
(1, 2022, 100),
(4, 2024, 80),
(5, 2023, 40);


-- Probamos consultas:
-- Nombres de provincia y datos precio si los hay 

SELECT prov.nombre_provincia, pre.año, pre.precio
FROM precio_vivienda AS pre
RIGHT JOIN provincias as prov
ON pre.id_provincia = prov.id_provincia; 


CREATE TABLE ocupacion_ciudad (
    id_ciudad INT, 
    fecha DATE,
    ocupacion DECIMAL(5,2),
    PRIMARY KEY (id_ciudad, fecha),
    CONSTRAINT fk_ciudad_ocuciu FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
);

INSERT INTO ocupacion_ciudad (id_ciudad, fecha, ocupacion)
VALUES
(1, '2024-01-10', 6.5),
(2, '2023-10-03', 7.5),
(3, '2022-11-11', 5.5),
(4, '2024-09-26', 6.0),
(5, '2023-11-01', 5.0);



#################################
# Notas sobre Inserción de Datos
#################################

-- En la tabla servicios 0 = False, 1 = True