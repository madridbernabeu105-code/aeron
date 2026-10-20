<?php
// backend/controllers/solicitud.php — Módulo 1: Postulación de Estudiante.
// Seguridad: exige sesión (id_usuario), validación servidor, PDO preparado,
// estado forzado a 'Pendiente' (no viene del cliente).

session_start();
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/conexion.php';

// 1. Solo POST.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'mensaje' => 'Método no permitido. Use POST.']);
    exit;
}

// 2. Sesión activa: el id_usuario dueño sale de $_SESSION, nunca del POST (evita suplantar).
if (empty($_SESSION['id_usuario'])) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'mensaje' => 'Sesión requerida. Inicie sesión.']);
    exit;
}

$institucion = trim($_POST['institucion_educativa'] ?? '');
$carrera = trim($_POST['carrera_o_bachillerato'] ?? '');
$promedio = $_POST['promedio_academico'] ?? '';
$ingreso = $_POST['ingreso_familiar_mensual'] ?? '';

// 3. Validación: no vacíos.
if ($institucion === '' || $carrera === '' || $promedio === '' || $ingreso === '') {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Complete todos los campos.']);
    exit;
}

// 4. Validación numérica: promedio 0–100 (igual que CHECK BD), ingreso positivo.
if (!is_numeric($promedio) || $promedio < 0 || $promedio > 100) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Promedio inválido (0 a 100).']);
    exit;
}
if (!is_numeric($ingreso) || $ingreso < 0) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Ingreso familiar inválido.']);
    exit;
}

try {
    $pdo = Conexion::obtener();

    // 5. Inserción preparada: estado siempre 'Pendiente', fecha_postulacion = NOW().
    $stmt = $pdo->prepare(
        'INSERT INTO solicitudes
           (id_usuario, institucion_educativa, carrera_o_bachillerato,
            promedio_academico, ingreso_familiar_mensual, estado, fecha_postulacion)
         VALUES (:u, :inst, :car, :prom, :ing, \'Pendiente\', NOW())'
    );
    $stmt->execute([
        ':u'    => (int) $_SESSION['id_usuario'],
        ':inst' => $institucion,
        ':car'  => $carrera,
        ':prom' => $promedio,
        ':ing'  => $ingreso,
    ]);

    echo json_encode([
        'ok' => true,
        'mensaje' => 'Solicitud registrada correctamente.',
        'id_solicitud' => (int) $pdo->lastInsertId(),
    ]);
} catch (PDOException $e) {
    error_log('Error solicitud: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'mensaje' => 'No se pudo registrar la solicitud.']);
}
