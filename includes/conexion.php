<?php
// conexion a la base de datos con PDO (xampp)
$host = "localhost";
$usuario = "root";
$password = "";
$base_datos = "aeron_db";

try {
   $pdo = new PDO("mysql:host=$host;dbname=$base_datos;charset=utf8mb4", $usuario, $password, [
      PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
      PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
   ]);
} catch (PDOException $e) {
   // si xampp esta apagado sale esto
   die("Error de conexion a la base de datos. Verifica que XAMPP este activo.");
}
