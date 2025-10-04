CREATE TABLE IF NOT EXISTS cliente(

    id SERIAL PRIMARY KEY, 
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    fecha_registro DATE DEFAULT CURRENT_DATE
);

INSERT INTO cliente (nombre, email) VALUES ('Juan Perez', 'juanp@example.com');
INSERT INTO cliente (nombre, email) VALUES ('Ana Gomez', 'ana@example.com');