<?php
// backend/config/conexion.php
// Propósito: conexión centralizada a MySQL (XAMPP) con PDO para `becas_bicentenario`.
// Seguridad: ERRMODE_EXCEPTION + EMULATE_PREPARES=false (consultas preparadas reales)
// + charset utf8mb4. El catch no expone credenciales ni detalles del motor.

// Patrón Singleton: una sola instancia PDO reutilizable en todo el backend.
class Conexion
{
    // Instancia única compartida.
    private static ?PDO $instancia = null;

    // Evita instanciación externa.
    private function __construct() {}

    // Obtiene la conexión PDO (la crea una sola vez).
    public static function obtener(): PDO
    {
        if (self::$instancia === null) {
            $host = 'localhost';
            $bd   = 'becas_bicentenario';
            $user = 'root';
            $pass = ''; // XAMPP por defecto sin contraseña.

            $dsn = "mysql:host={$host};dbname={$bd};charset=utf8mb4";

            $opciones = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, // RF: errores como excepciones.
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, // Arreglos asociativos.
                PDO::ATTR_EMULATE_PREPARES => false, // Preparadas reales: previene inyección SQL.
            ];

            try {
                self::$instancia = new PDO($dsn, $user, $pass, $opciones);
            } catch (PDOException $e) {
                // Defensa: mensaje genérico, nunca $e->getMessage() al cliente (filtraría credenciales/rutas).
                error_log('Error de conexión BD: ' . $e->getMessage());
                http_response_code(500);
                die('Error de conexión a la base de datos. Verifique que XAMPP/MySQL esté activo.');
            }
        }

        return self::$instancia;
    }
}
