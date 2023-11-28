-- Crear la tabla para almacenar los resultados
DROP TABLE IF EXISTS Resultado; -- Elimina la tabla si ya existe
CREATE TABLE Resultado ( -- Crea la tabla Resultado para almacenar resultados
    Cadena_1 VARCHAR(3999), -- Columna para la primera cadena
    Cadena_2 VARCHAR(3999), -- Columna para la segunda cadena
    Cantidad INT, -- Columna para almacenar la cantidad de operaciones de edición
    Porcentaje_Similitud DECIMAL(5, 2) -- Columna para almacenar el porcentaje de similitud
);

-- Crear la función para calcular la distancia y el porcentaje
DROP FUNCTION IF EXISTS CalcularDistanciaYPorcentaje; -- Elimina la función si ya existe
DELIMITER //
CREATE FUNCTION CalcularDistanciaYPorcentaje(s1 VARCHAR(3999), s2 VARCHAR(3999))
RETURNS DECIMAL(5, 2)
BEGIN
    -- Declaración de variables
    DECLARE s1_longitud, s2_longitud INT; -- Variables para almacenar la longitud de las cadenas
    DECLARE i, j, c, c_temp INT; -- Variables para índices y conteo de operaciones
    DECLARE s1_caracter CHAR(1); -- Variable para almacenar caracteres individuales
    DECLARE cv0, cv1 VARBINARY(8000); -- Variables para matrices binarias
    DECLARE porcentaje DECIMAL(5, 2); -- Variable para el porcentaje de similitud

    -- Obtener la longitud de las cadenas de texto
    SET s1_longitud = CHAR_LENGTH(s1); -- Longitud de la primera cadena
    SET s2_longitud = CHAR_LENGTH(s2); -- Longitud de la segunda cadena
    
    -- Inicialización de variables
    SET cv1 = 0x0000; -- Inicializa la matriz binaria
    SET j = 1; -- Inicializa el índice j
    SET i = 1; -- Inicializa el índice i
    SET c = 0; -- Inicializa el contador de operaciones

    -- Generar valores iniciales para la matriz utilizada en el algoritmo de Levenshtein
    WHILE j <= s2_longitud DO -- Inicializa la primera fila de la matriz
        SET cv1 = CONCAT(cv1, UNHEX(HEX(j)));
        SET j = j + 1;
    END WHILE;

    -- Algoritmo de Levenshtein para calcular la distancia entre las cadenas
    WHILE i <= s1_longitud DO
        SET s1_caracter = SUBSTRING(s1, i, 1);
        SET c = i;
        SET cv0 = UNHEX(HEX(i));
        SET j = 1;

        WHILE j <= s2_longitud DO
            SET c = c + 1;
            SET c_temp = CAST(SUBSTRING(cv1, (j + j - 1), 2) AS UNSIGNED) +
                CASE WHEN s1_caracter = SUBSTRING(s2, j, 1) THEN 0 ELSE 1 END;

            IF c > c_temp THEN
                SET c = c_temp;
            END IF;

            SET c_temp = CAST(SUBSTRING(cv1, (j + j + 1), 2) AS UNSIGNED) + 1;

            IF c > c_temp THEN
                SET c = c_temp;
            END IF;

            SET cv0 = CONCAT(cv0, UNHEX(HEX(c)));
            SET j = j + 1;
        END WHILE;

        SET cv1 = cv0;
        SET i = i + 1;
    END WHILE;

    -- Calcular porcentaje de similitud entre las cadenas
    SET porcentaje = ROUND(100.0 - ((CAST(c AS DECIMAL(5, 2)) / GREATEST(s1_longitud, s2_longitud)) * 100.0), 2);

    -- Insertar en la tabla de resultados
    INSERT INTO Resultado (Cadena_1, Cadena_2, Cantidad, Porcentaje_Similitud)
    VALUES (s1, s2, c, porcentaje);

    RETURN porcentaje; -- Devolver el porcentaje de similitud entre las cadenas
END//
DELIMITER ;


-- Ejecutar la función para los datos de ejemplo
SELECT CalcularDistanciaYPorcentaje('abraham', 'abran');
SELECT CalcularDistanciaYPorcentaje('azul', 'rojo');
SELECT CalcularDistanciaYPorcentaje('guitarra', 'guitarrista');
SELECT CalcularDistanciaYPorcentaje('casa', 'calle');
SELECT CalcularDistanciaYPorcentaje('programacion', 'programando');
SELECT CalcularDistanciaYPorcentaje('openai', 'openi');
SELECT CalcularDistanciaYPorcentaje('playa', 'montaña');
SELECT CalcularDistanciaYPorcentaje('ordenador', 'computadora');
SELECT CalcularDistanciaYPorcentaje('zanahoria', 'anaoria');
SELECT CalcularDistanciaYPorcentaje('computadora', 'ordenador');
