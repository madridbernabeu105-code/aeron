<?php
require 'includes/conexion.php';
require 'includes/funciones.php';

$titulo = "Aeron | Contacto";
$mensaje_exito = "";

// cuando envian el formulario lo guarda en la base de datos
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
   $nombre = trim($_POST['nombre']);
   $correo = trim($_POST['correo']);
   $mensaje = trim($_POST['mensaje']);

   // que no venga nada vacio
   if ($nombre != "" && $correo != "" && $mensaje != "") {
     $stmt = $pdo->prepare("INSERT INTO mensajes (nombre, correo, mensaje) VALUES (?, ?, ?)");
     $stmt->execute([$nombre, $correo, $mensaje]);
     $mensaje_exito = "Gracias " . escapar($nombre) . "! Tu mensaje fue enviado.";
   }
}

require 'includes/cabecera.php';
?>
<main>
 <div class="contacto-container">
  <h1 class="contacto-titulo">Contacto</h1>

  <?php if ($mensaje_exito != "") { ?>
   <div class="contacto-exito"><?php echo $mensaje_exito ?></div>
  <?php } ?>

  <form action="contacto.php" method="POST" class="contacto-form">
   <div class="contacto-campo">
    <label for="nombre">Nombre</label>
    <input type="text" id="nombre" name="nombre" placeholder="Tu nombre completo" required>
   </div>
   <div class="contacto-campo">
    <label for="correo">Correo electronico</label>
    <input type="email" id="correo" name="correo" placeholder="tucorreo@ejemplo.com" required>
   </div>
   <div class="contacto-campo">
    <label for="mensaje">Mensaje</label>
    <textarea id="mensaje" name="mensaje" placeholder="Escribe tu mensaje aqui..." required></textarea>
   </div>
   <button type="submit" class="btn-solido btn-solido--compacto">ENVIAR MENSAJE</button>
  </form>
 </div>
</main>

<?php require 'includes/pie.php'; ?>