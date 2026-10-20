# AERON — Tienda de periféricos

Proyecto en PHP + MySQL (XAMPP).

## Requisitos
- XAMPP con Apache y MySQL
- PHP 8.x

## Instalación
1. Copiar la carpeta `aeron` dentro de `htdocs` de XAMPP.
2. Encender Apache y MySQL desde el panel de XAMPP.
3. Crear la base de datos importando `aeron_db.sql`
   (phpMyAdmin > Importar, o por consola:
   `mysql -u root < aeron_db.sql` y luego `USE aeron_db`).
   El dump trae la estructura completa + catálogo de productos y
   métodos de pago. Los usuarios se registran desde la propia app.
4. Abrir en el navegador: `http://localhost/aeron`

## Conexión
Ver `includes/conexion.php` (host `localhost`, base `aeron_db`).
