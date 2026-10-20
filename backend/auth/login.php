<?php
// backend/auth/login.php (RF-02: Inicio de sesión)
// Recibe por POST: correo y password. Verifica con password_verify().
// Seguridad: consulta preparada + mensaje de error genérico (no revela si
// falló el correo o la clave) + regeneración de ID de sesión anti-fixation.

session_start(); // RF: inicializa sesión PHP antes de usar $_SESSION.
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/conexion.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'mensaje' => 'Método no permitido. Use POST.']);
    exit;
}

$correo = trim($_POST['correo'] ?? '');
$password = $_POST['password'] ?? '';

// Validación mínima (formato). El mensaje final siempre es genérico.
if ($correo === '' || $password === '' || !filter_var($correo, FILTER_VALIDATE_EMAIL)) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'mensaje' => 'Correo o contraseña incorrectos.']);
    exit;
}

try {
    $pdo = Conexion::obtener();

    // Consulta preparada: busca usuario por correo (índice UNIQUE).
    $stmt = $pdo->prepare(
        'SELECT id_usuario, nombre_completo, correo, password_hash, rol
         FROM usuarios WHERE correo = :correo LIMIT 1'
    );
    $stmt->execute([':correo' => $correo]);
    $user = $stmt->fetch();

    // password_verify(): compara clave ingresada vs hash bcrypt/argon2 de la BD.
    if (!$user || !password_verify($password, $user['password_hash'])) {
        // Defensa: mismo mensaje para "no existe" y "clave mala" (no enumerar usuarios).
        http_response_code(401);
        echo json_encode(['ok' => false, 'mensaje' => 'Correo o contraseña incorrectos.']);
        exit;
    }

    // Éxito: regenera ID de sesión (previene session fixation).
    session_regenerate_id(true);

    // Guarda en sesión solo lo necesario para RF-03/RF-04 (control por rol).
    $_SESSION['id_usuario'] = (int) $user['id_usuario'];
    $_SESSION['nombre_completo'] = $user['nombre_completo'];
    $_SESSION['correo'] = $user['correo'];
    $_SESSION['rol'] = $user['rol'];

    echo json_encode([
        'ok' => true,
        'mensaje' => 'Autenticación exitosa.',
        'usuario' => [
            'id_usuario' => $_SESSION['id_usuario'],
            'nombre_completo' => $_SESSION['nombre_completo'],
            'correo' => $_SESSION['correo'],
            'rol' => $_SESSION['rol'],
        ],
    ]);
} catch (PDOException $e) {
    error_log('Error login: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'mensaje' => 'Error interno de autenticación.']);
}
