<?php
// backend/controllers/evaluacion.php — Módulo 2: Evaluación (Evaluador/Admin).
// Seguridad: control por rol, validación de rangos 0–100 y dictamen whitelist,
// PDO preparado. El trigger trg_actualizar_estado_solicitud_evaluada
// actualiza solicitudes.estado automáticamente al INSERT.

session_start();
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/conexion.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false, 'mensaje' => 'Método no permitido. Use POST.']);
    exit;
}

// 1. Sesión + rol: solo Evaluador o Administrador (defensa: autorización).
if (empty($_SESSION['id_usuario'])) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'mensaje' => 'Sesión requerida. Inicie sesión.']);
    exit;
}
if (!in_array($_SESSION['rol'] ?? '', ['Evaluador', 'Administrador'], true)) {
    http_response_code(403);
    echo json_encode(['ok' => false, 'mensaje' => 'Acceso denegado. Requiere rol Evaluador o Administrador.']);
    exit;
}

$idSol = $_POST['id_solicitud'] ?? '';
$pSoc = $_POST['puntaje_socioeconomico'] ?? '';
$pAca = $_POST['puntaje_academico'] ?? '';
$dictamen = trim($_POST['dictamen'] ?? '');
$obs = trim($_POST['observaciones'] ?? '');

// 2. Validación: id entero positivo, puntajes 0–100 (igual que CHECK BD).
if (!ctype_digit((string) $idSol) || (int) $idSol <= 0) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Solicitud inválida.']);
    exit;
}
foreach (['socioeconómico' => $pSoc, 'académico' => $pAca] as $nombre => $v) {
    if (!is_numeric($v) || $v < 0 || $v > 100) {
        http_response_code(400);
        echo json_encode(['ok' => false, 'mensaje' => "Puntaje $nombre inválido (0 a 100)."]);
        exit;
    }
}

// 3. Whitelist del ENUM dictamen (defensa: evita estados arbitrarios).
if (!in_array($dictamen, ['Favorable', 'No Favorable', 'Observado'], true)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Dictamen no válido.']);
    exit;
}

try {
    $pdo = Conexion::obtener();

    // 4. Verifica que la solicitud exista (evita evaluaciones huérfanas).
    $chk = $pdo->prepare('SELECT id_solicitud FROM solicitudes WHERE id_solicitud = :id LIMIT 1');
    $chk->execute([':id' => (int) $idSol]);
    if (!$chk->fetch()) {
        http_response_code(404);
        echo json_encode(['ok' => false, 'mensaje' => 'La solicitud no existe.']);
        exit;
    }

    // 5. INSERT preparado. id_evaluador sale de la sesión (auditoría confiable).
    $ins = $pdo->prepare(
        'INSERT INTO evaluaciones
           (id_solicitud, id_evaluador, puntaje_socioeconomico, puntaje_academico, dictamen, observaciones)
         VALUES (:sol, :eva, :ps, :pa, :dic, :obs)'
    );
    $ins->execute([
        ':sol' => (int) $idSol,
        ':eva' => (int) $_SESSION['id_usuario'],
        ':ps'  => (int) $pSoc,
        ':pa'  => (int) $pAca,
        ':dic' => $dictamen,
        ':obs' => ($obs === '' ? null : $obs),
    ]);

    // 6. Lee el estado que el TRIGGER ya actualizó (Favorable→Aprobada, etc.).
    $est = $pdo->prepare('SELECT estado FROM solicitudes WHERE id_solicitud = :id');
    $est->execute([':id' => (int) $idSol]);
    $nuevoEstado = $est->fetchColumn();

    echo json_encode([
        'ok' => true,
        'mensaje' => 'Evaluación registrada. Estado actualizado automáticamente.',
        'id_evaluacion' => (int) $pdo->lastInsertId(),
        'nuevo_estado' => $nuevoEstado,
    ]);
} catch (PDOException $e) {
    error_log('Error evaluacion: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'mensaje' => 'No se pudo registrar la evaluación.']);
}
