# Laboratorios de PostgreSQL con Docker

Entorno local de **PostgreSQL 15 + pgAdmin 4** levantado con Docker Compose, y una serie de laboratorios SQL para practicar el diseño de bases de datos relacionales: creación de tablas, tipos de datos, valores por defecto, restricciones (`UNIQUE`, `CHECK`, `NOT NULL`) y llaves foráneas.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker_Compose-2496ED?logo=docker&logoColor=white)
![pgAdmin](https://img.shields.io/badge/pgAdmin-4-336791)

## Qué incluye

| Componente | Descripción |
|---|---|
| `docker-compose.yml` | Servicio `postgres` (PostgreSQL 15, volumen persistente y *healthcheck* con `pg_isready`) y servicio `pgadmin`, que arranca solo cuando la base de datos está saludable. |
| `.env.example` | Plantilla de variables de entorno (usuario, contraseña, base de datos y puertos). Las credenciales reales **no** se versionan. |
| `labs/` | Scripts SQL de cada laboratorio. |

## Laboratorios

| Laboratorio | Temas |
|---|---|
| [`lab_fundamentos`](labs/lab_fundamentos/script.sql) | `CREATE TABLE`, `SERIAL PRIMARY KEY`, `NOT NULL`, `DEFAULT CURRENT_DATE`, inserción de registros. |
| [`lab_restricciones`](labs/lab_restricciones/script.sql) | `UNIQUE`, `CHECK` (precios y stock no negativos, totales mayores a 0), `REFERENCES` (llave foránea de `pedidos` a `cliente`), `DEFAULT now()`. |
| [`lab_claves`](labs/lab_claves/script.sql) | Llaves primarias y foráneas. |
| [`lab_integridad`](labs/lab_integridad/script.sql) | Integridad referencial. |

## Cómo ejecutarlo

Requisitos: [Docker](https://docs.docker.com/get-docker/) con Docker Compose.

```bash
# 1. Configura las variables de entorno
cp .env.example .env    # y edita las contraseñas

# 2. Levanta PostgreSQL y pgAdmin
docker compose up -d

# 3. Ejecuta los laboratorios en orden
docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < labs/lab_fundamentos/script.sql
docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < labs/lab_restricciones/script.sql
```

pgAdmin queda disponible en `http://localhost:8080` (o el puerto que definas en `PGADMIN_PORT`). Para registrar el servidor usa el host `postgres` y el puerto `5432`.

> `lab_restricciones` depende de la tabla `cliente` creada en `lab_fundamentos`, por eso deben ejecutarse en ese orden.

## Autora

**Dayan Lorena Mape Forero**, estudiante de Tecnología en Análisis y Desarrollo de Software, Bogotá, Colombia. [GitHub](https://github.com/mpdayan1804)
