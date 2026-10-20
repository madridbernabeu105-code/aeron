<?php
require_once __DIR__ . '/funciones.php';

if (!isset($titulo)) $titulo = "Aeron | Perifericos";
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?php echo escapar($titulo) ?></title>
  <link rel="stylesheet" href="style.css?v=99">
  <script src="main.js"></script>
</head>
<body>

<header>
  <div class="nav-left">
   <a href="catalogo.php">Tienda</a>
   <a href="contacto.php">Contacto</a>
  </div>
  <div class="logo"><a href="index.php">Aeron</a></div>
  <div class="nav-right">
   <?php if (isset($_SESSION['usuario_nombre'])) { ?>
    <a href="login.php" class="nav-usuario">Hola, <?php echo escapar($_SESSION['usuario_nombre']) ?></a>
    <a href="login.php?accion=salir" class="nav-salir">Salir</a>
   <?php } else { ?>
    <a href="login.php">Cuenta</a>
    <a href="registro.php">Registrarse</a>
   <?php } ?>
  </div>
</header>
