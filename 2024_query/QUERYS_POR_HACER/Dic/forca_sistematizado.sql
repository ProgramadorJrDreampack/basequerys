-- Tabla para Clientes/Proveedores
CREATE TABLE ClientesProveedores (
    ClienteProveedorID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255),
    ClienteEPM NVARCHAR(255)
);

-- Tabla para Ejecutivas
CREATE TABLE Ejecutivas (
    EjecutivaID INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(255)
);

-- Tabla para Artículos
CREATE TABLE Articulos (
    ArticuloID NVARCHAR(50) PRIMARY KEY,
    Descripcion NVARCHAR(255),
    Categoria NVARCHAR(50)
);

-- Tabla para Precios
CREATE TABLE Precios (
    PrecioID INT PRIMARY KEY IDENTITY(1,1),
    ArticuloID NVARCHAR(50),
    Mes NVARCHAR(20), -- Ejemplo: 'Ene. 2024'
    Precio DECIMAL(10, 4),
    FOREIGN KEY (ArticuloID) REFERENCES Articulos(ArticuloID)
);

-- Tabla para Unidades Vendidas
CREATE TABLE UnidadesVendidas (
    UnidadID INT PRIMARY KEY IDENTITY(1,1),
    ArticuloID NVARCHAR(50),
    Mes NVARCHAR(20), -- Ejemplo: 'Ene. 2024'
    Unidades INT,
    FOREIGN KEY (ArticuloID) REFERENCES Articulos(ArticuloID)
);