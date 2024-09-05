USE elevadores_model;

-- Tables
CREATE TABLE Clientes(
	ID_cliente INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Denominacion VARCHAR (60),
    Tel_cliente VARCHAR (30),
    Mail_cliente VARCHAR (30)
);

CREATE TABLE Edificios(
	ID_edificio INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Nombre_edif VARCHAR (60),
    Direccion VARCHAR (60),
    Tel_edif VARCHAR (30),
    Encargado VARCHAR (60),
    ID_cliente INT NOT NULL,
    FOREIGN KEY (ID_cliente) REFERENCES Clientes(ID_cliente)
);

CREATE TABLE Elevadores(
	ID_elevador INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Marca VARCHAR (30),
    Modelo VARCHAR (30),
    Paradas INT NOT NULL,
    Carga INT NOT NULL,
    Velocidad INT NOT NULL,
    Proyecto VARCHAR (60),
    ID_edificio INT NOT NULL,
    FOREIGN KEY (ID_edificio) REFERENCES Edificios(ID_edificio)
);

CREATE TABLE Tecnicos(
	Legajo_tec INT NOT NULL PRIMARY KEY,
    Nombre_tec VARCHAR (30),
    Apellido_tec VARCHAR (30),
    Categoria VARCHAR (30),
    Antiguedad INT NOT NULL
);

CREATE TABLE Reclamos(
	ID_reclamo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Falla VARCHAR (300),
    Fecha DATE,
    ID_edificio INT NOT NULL,
    ID_elevador INT NOT NULL,
    Legajo_tec INT NOT NULL,
    FOREIGN KEY (ID_edificio) REFERENCES Edificios(ID_edificio),
    FOREIGN KEY (ID_elevador) REFERENCES Elevadores(ID_elevador),
    FOREIGN KEY (Legajo_tec) REFERENCES Tecnicos(Legajo_tec)
);

CREATE TABLE Reparaciones(
	ID_reparacion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Detalle VARCHAR (300),
	Costo FLOAT NOT NULL,
    Plazos INT NOT NULL,
    ID_reclamo INT NOT NULL,
    ID_cliente INT NOT NULL,
    FOREIGN KEY (ID_reclamo) REFERENCES Reclamos(ID_reclamo),
    FOREIGN KEY (ID_cliente) REFERENCES Clientes(ID_cliente)
);

-- Views
CREATE OR REPLACE VIEW reclamos_por_tec AS
(SELECT Legajo_tec, COUNT(*) AS Reclamos_atendidos FROM Reclamos GROUP BY Legajo_tec ORDER BY COUNT(*) DESC);
SELECT * FROM reclamos_por_tec;

CREATE OR REPLACE VIEW edificios_ordenados AS (SELECT ID_edificio, ID_cliente, Nombre_edif, Direccion FROM Edificios ORDER BY Nombre_edif ASC);
SELECT * FROM edificios_ordenados;

CREATE OR REPLACE VIEW elevadores_Mitsu AS (SELECT e.ID_elevador, d.Nombre_edif, e.Modelo, e.Paradas, e.Carga, e.Velocidad FROM Elevadores e
JOIN Edificios d ON e.ID_edificio = d.ID_edificio WHERE e.Marca = "Mitsubishi" ORDER BY e.ID_elevador ASC);
SELECT * FROM elevadores_Mitsu;

CREATE OR REPLACE VIEW reparaciones_urgencia AS (SELECT ID_reparacion, ID_cliente, ID_reclamo, Detalle, Plazos FROM Reparaciones ORDER BY Plazos ASC);
SELECT * FROM reparaciones_urgencia;

CREATE OR REPLACE VIEW encargados_clientes AS 
(SELECT e.ID_Cliente, e.ID_edificio, c.Denominacion, e.Encargado FROM Edificios e JOIN Clientes c ON c.ID_cliente = e.ID_cliente ORDER BY e.ID_cliente ASC);
SELECT * FROM encargados_clientes;

-- Functions
DELIMITER //
CREATE FUNCTION total_deuda_cliente (Busca INT) RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
DECLARE total FLOAT;
DECLARE resultado VARCHAR(20);
SET total = (SELECT SUM(Costo) FROM Reparaciones WHERE ID_cliente = Busca);
SET resultado = CONCAT('$', FORMAT(total,2));
RETURN resultado;
END; //
DELIMITER ;
SELECT total_deuda_cliente(1) AS Deuda_cliente;

DELIMITER //
CREATE FUNCTION total_recalmos_edificio (Busca INT) RETURNS FLOAT DETERMINISTIC
BEGIN
DECLARE total FLOAT;
SET total = (SELECT COUNT(ID_reclamo) FROM Reclamos WHERE ID_edificio = Busca);
RETURN total;
END;
//
DELIMITER ;
SELECT total_recalmos_edificio(16);

-- Stored Procedures
DELIMITER //
CREATE PROCEDURE `ordenar_reclamos`(IN campo CHAR(20))
BEGIN
	IF campo <> '' THEN
		SET @orden_por = CONCAT('ORDER BY ', campo);
	ELSE
		SET @orden_por = '';
	END IF;
    SET @clausula = CONCAT('SELECT * FROM elevadores_model.reclamos ', @orden_por);
    PREPARE accion FROM @clausula;
    EXECUTE accion;
    DEALLOCATE PREPARE accion;
END //
DELIMITER ;
CALL ordenar_reclamos('ID_edificio');

DELIMITER //
CREATE PROCEDURE `porcentaje_reclamos_edificio`(IN campo CHAR(20))
BEGIN
	DECLARE total INT;
    DECLARE suma INT;
    DECLARE porcentaje DECIMAL(5,2);
    SELECT COUNT(*) INTO total FROM Reclamos;
	SELECT COUNT(*) INTO suma FROM Reclamos WHERE ID_edificio = campo;
    IF total = 0 THEN
		SET porcentaje = 0.00;
	ELSE
		SET porcentaje = suma * 100.0 / total;
	END IF;
    SELECT campo AS ID_edificio, suma AS Total_edificio, total AS Total_reclamos, CONCAT(FORMAT(porcentaje, 2), '%') AS Porcentaje;
END //
DELIMITER ;
CALL porcentaje_reclamos_edificio('25');

-- Triggers
CREATE TABLE log_tecnicos(
	ID INT AUTO_INCREMENT PRIMARY KEY,
	Accion VARCHAR(20),
	Legajo_tec INT NOT NULL,
    Nombre_tec VARCHAR (30),
    Apellido_tec VARCHAR(30),
    Categoria VARCHAR(30),
    Antiguedad INT NOT NULL,
    Fecha DATE,
    Hora TIME,
    Usuario VARCHAR(20)
);

CREATE TRIGGER `tr_insert_tecnicos` 
AFTER INSERT ON `tecnicos` 
FOR EACH ROW 
INSERT INTO `log_tecnicos` (Accion, Legajo_tec, Nombre_tec, Apellido_tec, Categoria, Antiguedad, Fecha, Hora, Usuario) 
VALUES ('INSERT', NEW.Legajo_tec, NEW.Nombre_tec, NEW.Apellido_tec, NEW.Categoria, NEW.Antiguedad, NOW(), CURTIME(), CURRENT_USER());

CREATE TRIGGER `tr_update_tecnicos` 
BEFORE UPDATE ON `tecnicos` 
FOR EACH ROW 
INSERT INTO `log_tecnicos` (Accion, Legajo_tec, Nombre_tec, Apellido_tec, Categoria, Antiguedad, Fecha, Hora, Usuario) 
VALUES ('UPDATE', OLD.Legajo_tec, NEW.Nombre_tec, NEW.Apellido_tec, NEW.Categoria, NEW.Antiguedad, NOW(), CURTIME(), CURRENT_USER());

CREATE TRIGGER `tr_delete_tecnicos` 
AFTER DELETE ON `tecnicos` 
FOR EACH ROW 
INSERT INTO `log_tecnicos` (Accion, Legajo_tec, Fecha, Hora, Usuario) 
VALUES ('DELETE', OLD.Legajo_tec, NOW(), CURTIME(), CURRENT_USER());

INSERT INTO `tecnicos` (`Legajo_tec`, `Nombre_tec`, `Apellido_tec`, `Categoria`, `Antiguedad`) 
VALUES ('7', 'Julio', 'Freire', 'Medio Oficial', '1');

UPDATE tecnicos SET Categoria = 'Oficial' WHERE Legajo_tec = 6;

DELETE FROM tecnicos WHERE Legajo_tec = 7;

SELECT * FROM tecnicos;
SELECT * FROM log_tecnicos;

-- TOP10 - Reclamos por edificio 
SELECT e.Nombre_edif, COUNT(r.ID_edificio) AS cantidad_reclamos FROM Reclamos r 
JOIN edificios e ON r.ID_edificio = e.ID_edificio
GROUP BY e.ID_edificio ORDER BY cantidad_reclamos DESC LIMIT 10;

-- Reclamos totales por técnico 
SELECT t.Nombre_tec, COUNT(r.Legajo_tec) AS cantidad_reclamos FROM Reclamos r
JOIN tecnicos t ON r.Legajo_tec = t.Legajo_tec
GROUP BY r.Legajo_tec ORDER BY cantidad_reclamos DESC;

-- Total adeudado por cliente
SELECT r.ID_Cliente, c.Denominacion, SUM(r.Costo) AS deuda_total FROM Reparaciones r 
JOIN clientes c ON r.ID_cliente = c.ID_cliente GROUP BY r.ID_cliente ORDER BY deuda_total DESC;



