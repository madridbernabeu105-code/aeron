<?php
// backend/auth/registro.php (RF-01: Registro de usuarios)
// Recibe por POST: nombre_completo, correo, password, rol.
// Seguridad: validación servidor + consulta preparada anti-duplicados +
// password_hash() (nunca guardar clave en claro) + respuesta JSON genérica.

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/conexion.php';

// Solo se acepta POST (defensa: evita registros por GET).
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'mensaje' => 'Método no permitido. Use POST.']);
    exit;
}

// Lectura y limpieza básica de entradas.
$nombre = trim($_POST['nombre_completo'] ?? '');
$correo = trim($_POST['correo'] ?? '');
$password = $_POST['password'] ?? '';
$rol = trim($_POST['rol'] ?? '');

// 1. Validación lado servidor: campos obligatorios.
if ($nombre === '' || $correo === '' || $password === '' || $rol === '') {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Complete todos los campos.']);
    exit;
}

// 2. Validación formato de correo.
if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'El correo no es válido.']);
    exit;
}

// 3. Validación rol contra ENUM de la BD (defensa: whitelist, evita valores arbitrarios).
$rolesPermitidos = ['Estudiante', 'Evaluador', 'Administrador'];
if (!in_array($rol, $rolesPermitidos, true)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Rol no válido.']);
    exit;
}

// 4. Longitud mínima de contraseña (defensa: evita claves triviales).
if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'La contraseña debe tener al menos 6 caracteres.']);
    exit;
}

try {
    $pdo = Conexion::obtener();

    // 5. Consulta preparada: ¿correo ya existe? (evita duplicados, UNIQUE en BD como respaldo).
    $stmt = $pdo->prepare('SELECT id_usuario FROM usuarios WHERE correo = :correo LIMIT 1');
    $stmt->execute([':correo' => $correo]);

    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['ok' => false, 'mensaje' => 'Ese correo ya está registrado.']);
        exit;
    }

    // 6. Hash seguro con PASSWORD_DEFAULT (bcrypt/argon2 según PHP). Nunca texto plano.
    $hash = password_hash($password, PASSWORD_DEFAULT);

    // 7. Inserción con consulta preparada PDO (previene inyección SQL).
    $ins = $pdo->prepare(
        'INSERT INTO usuarios (nombre_completo, correo, password_hash, rol)
         VALUES (:nombre, :correo, :hash, :rol)'
    );
    $ins->execute([
        ':nombre' => $nombre,
        ':correo' => $correo,
        ':hash'   => $hash,
        ':rol'    => $rol,
    ]);

    echo json_encode(['ok' => true, 'mensaje' => 'Usuario registrado correctamente.']);
} catch (PDOException $e) {
    // Defensa: log interno, respuesta genérica (código 23000 = duplicado por carrera).
    error_log('Error registro: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'mensaje' => 'No se pudo registrar el usuario.']);
}
