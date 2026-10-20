<?php
require 'includes/conexion.php';
require 'includes/funciones.php';

$titulo = "Aeron | Acceso";
$error = "";

// para cerrar la sesion
if (isset($_GET['accion']) && $_GET['accion'] === 'salir') {
   session_unset();
   session_destroy();
   redirigir('login.php');
}

// cuando envian el formulario revisa el usuario y la contrasena
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
   $login = trim($_POST['usuario']);
   $contrasena = $_POST['contrasena'];

   // busca al usuario por nombre o por correo
   $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE nombre = :login OR correo = :login LIMIT 1");
   $stmt->execute([':login' => $login]);
   $fila = $stmt->fetch();

   // revisa que la contrasena coincida con la de la base de datos
   if ($fila && $fila['password'] === $contrasena) {
     $_SESSION['usuario_nombre'] = $fila['nombre'];
     redirigir('index.php');
   } else {
     $error = "Usuario o contrasena incorrectos.";
   }
}

require 'includes/cabecera.php';
?>
<main>
 <div class="login-container">

 <?php if (isset($_SESSION['usuario_nombre'])) { ?>
  <h1 class="login-titulo">Bienvenido</h1>
  <p class="login-bienvenida">
   Has iniciado sesion como <strong><?php echo escapar($_SESSION['usuario_nombre']) ?></strong>.
  </p>
  <a href="login.php?accion=salir" class="btn-solido btn-solido--compacto login-cerrar">Cerrar sesion</a>

 <?php } else { ?>
  <h1 class="login-titulo">Acceso</h1>

  <?php if ($error != "") { ?>
   <div class="login-error"><?php echo escapar($error) ?></div>
  <?php } ?>

  <?php if (isset($_GET['registro'])) { ?>
   <div class="login-exito">Cuenta creada con exito. Inicia sesion.</div>
  <?php } ?>

  <form action="login.php" method="POST" class="login-form">
   <div class="login-campo">
    <label for="usuario">Usuario o correo</label>
    <input type="text" id="usuario" name="usuario" placeholder="Tu usuario o correo" required>
   </div>
   <div class="login-campo">
    <label for="contrasena">Contrasena</label>
    <input type="password" id="contrasena" name="contrasena" placeholder="Tu contrasena" required>
   </div>
   <button type="submit" class="btn-solido btn-solido--compacto">INICIAR SESIÓN</button>
  </form>

  <p class="login-ayuda">
   No tienes cuenta? <a href="registro.php"><strong>Registrate aqui</strong></a><br>
   Usuario de prueba: <strong>Administrador</strong> / contrasena: <strong>admin123</strong>
  </p>
 <?php } ?>

 </div>
</main>

<?php require 'includes/pie.php'; ?>
