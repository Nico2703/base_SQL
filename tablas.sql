USE elevadores_model;

CREATE TABLE Clientes(
	ID_cliente INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Denominacion VARCHAR (30),
    Tel_cliente VARCHAR (30),
    Mail_cliente VARCHAR (30)
);

CREATE TABLE Edificios(
	ID_edificio INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Nombre_edif VARCHAR (30),
    Direccion VARCHAR (30),
    Tel_edif VARCHAR (30),
    Encargado VARCHAR (30),
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
    Proyecto VARCHAR (30),
    ID_edificio INT NOT NULL,
    FOREIGN KEY (ID_edificio) REFERENCES Edificios(ID_edificio)
);

CREATE TABLE Reclamos(
	ID_reclamo INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Falla VARCHAR (100),
    Fecha DATE,
    ID_edificio INT NOT NULL,
    ID_elevador INT NOT NULL,
    Legajo_tec INT NOT NULL,
    FOREIGN KEY (ID_edificio) REFERENCES Edificios(ID_edificio),
    FOREIGN KEY (ID_elevador) REFERENCES Elevadores(ID_edificio),
    FOREIGN KEY (Legajo_tec) REFERENCES Tecnicos(Legajo_tec)
);

CREATE TABLE Tecnicos(
	Legajo_tec INT NOT NULL PRIMARY KEY,
    Nombre_tec VARCHAR (30),
    Apellido_tec VARCHAR (30),
    Categoria VARCHAR (30),
    Antiguedad INT NOT NULL
);

CREATE TABLE Reparaciones(
	ID_reparacion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Detalle VARCHAR (100),
	Costo INT NOT NULL,
    Plazo INT NOT NULL,
    ID_reclamo INT NOT NULL,
    ID_cliente INT NOT NULL,
    FOREIGN KEY (ID_reclamo) REFERENCES Reclamos(ID_reclamo),
    FOREIGN KEY (ID_cliente) REFERENCES Clientes(ID_cliente)
);