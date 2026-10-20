<?php
require 'includes/conexion.php';
require 'includes/funciones.php';

$titulo = "Aeron | Registro";
$error = "";

// cuando envian el formulario crea la cuenta
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
   $nombre = trim($_POST['nombre']);
   $correo = trim($_POST['correo']);
   $contrasena = $_POST['contrasena'];
   $contrasena2 = $_POST['contrasena2'];

   // revisa que no venga nada vacio y que sean iguales
   if ($nombre == "" || $correo == "" || $contrasena == "" || $contrasena2 == "") {
     $error = "Completa todos los campos.";
   } else if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
     $error = "El correo no es valido.";
   } else if (strlen($contrasena) < 4) {
     $error = "La contrasena debe tener al menos 4 caracteres.";
   } else if ($contrasena != $contrasena2) {
     $error = "Las contrasenas no coinciden.";
   } else {
     // revisa que el correo o el usuario no existan ya
     $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE correo = :correo OR nombre = :nombre LIMIT 1");
     $stmt->execute([':correo' => $correo, ':nombre' => $nombre]);

     if ($stmt->fetch()) {
       $error = "Ese correo o usuario ya esta registrado.";
     } else {
       // se guarda tal cual como la escribio
       $ins = $pdo->prepare("INSERT INTO usuarios (nombre, correo, password) VALUES (:nombre, :correo, :password)");
       $ins->execute([':nombre' => $nombre, ':correo' => $correo, ':password' => $contrasena]);
       redirigir('login.php?registro=1');
     }
   }
}

require 'includes/cabecera.php';
?>
<main>
 <div class="login-container">
  <h1 class="login-titulo">Crear cuenta</h1>

  <?php if ($error != "") { ?>
   <div class="login-error"><?php echo escapar($error) ?></div>
  <?php } ?>

  <form action="registro.php" method="POST" class="login-form">
   <div class="login-campo">
    <label for="nombre">Usuario</label>
    <input type="text" id="nombre" name="nombre" placeholder="Tu nombre de usuario" required>
   </div>
   <div class="login-campo">
    <label for="correo">Correo electronico</label>
    <input type="email" id="correo" name="correo" placeholder="tucorreo@ejemplo.com" required>
   </div>
   <div class="login-campo">
    <label for="contrasena">Contrasena</label>
    <input type="password" id="contrasena" name="contrasena" placeholder="Minimo 4 caracteres" required>
   </div>
   <div class="login-campo">
    <label for="contrasena2">Repite la contrasena</label>
    <input type="password" id="contrasena2" name="contrasena2" placeholder="Repite la contrasena" required>
   </div>
   <button type="submit" class="btn-solido btn-solido--compacto">CREAR CUENTA</button>
  </form>

  <p class="login-ayuda">
   Ya tienes cuenta? <a href="login.php"><strong>Inicia sesion aqui</strong></a>
  </p>
 </div>
</main>

<?php require 'includes/pie.php'; ?>
