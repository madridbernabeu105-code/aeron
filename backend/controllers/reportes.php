<?php
// backend/controllers/reportes.php — Módulo 3 y Administración.
// Acepta GET o POST con filtros (estado_beca, periodo YYYY-MM, accion).
// Seguridad: exige sesión, whitelist de filtros, SELECT con JOINs preparados.
// Acciones: expediente (estado_solicitud.html), becas (becas.html), reporte (reportes.html).

session_start();
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../config/conexion.php';

// 1. Sesión activa para cualquier consulta (defensa: no exponer datos públicos).
if (empty($_SESSION['id_usuario'])) {
    http_response_code(401);
    echo json_encode(['ok' => false, 'mensaje' => 'Sesión requerida. Inicie sesión.']);
    exit;
}

$rol = $_SESSION['rol'] ?? '';
$idUsuario = (int) $_SESSION['id_usuario'];

// 2. Entrada unificada GET/POST + whitelist de acción y estados.
$src = array_merge($_GET, $_POST);
$accion = $src['accion'] ?? $src['vista'] ?? 'reporte';
$accion = in_array($accion, ['expediente', 'becas', 'reporte'], true) ? $accion : 'reporte';

$estadoBeca = trim($src['estado_beca'] ?? '');
$estadosBecaOk = ['Activa', 'Suspendida', 'Finalizada'];
if ($estadoBeca !== '' && !in_array($estadoBeca, $estadosBecaOk, true)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Filtro estado_beca no válido.']);
    exit;
}

// Periodo YYYY-MM: filtra por fecha_asignacion (defensa: regex, evita inyección en DATE_FORMAT).
$periodo = trim($src['periodo'] ?? '');
if ($periodo !== '' && !preg_match('/^\d{4}-(0[1-9]|1[0-2])$/', $periodo)) {
    http_response_code(400);
    echo json_encode(['ok' => false, 'mensaje' => 'Periodo inválido (YYYY-MM).']);
    exit;
}

try {
    $pdo = Conexion::obtener();

    // 3a. Expediente del estudiante: solicitudes + usuario (JOIN usuarios).
    if ($accion === 'expediente') {
        $sql = 'SELECT s.id_solicitud, s.institucion_educativa, s.carrera_o_bachillerato,
                       s.promedio_academico, s.estado, s.fecha_postulacion, s.fecha_actualizacion,
                       u.nombre_completo, u.correo
                FROM solicitudes s
                INNER JOIN usuarios u ON u.id_usuario = s.id_usuario
                WHERE 1 = 1';
        $p = [];
        // Estudiante solo ve lo suyo; Evaluador/Admin ve todo (control por rol).
        if ($rol === 'Estudiante') {
            $sql .= ' AND s.id_usuario = :u';
            $p[':u'] = $idUsuario;
        }
        $sql .= ' ORDER BY s.id_solicitud DESC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute($p);
        echo json_encode(['ok' => true, 'datos' => $stmt->fetchAll()]);
        exit;
    }

    // 3b/3c. Becas y reporte: JOIN becas + solicitudes + usuarios, con filtros preparados.
    $sql = 'SELECT b.id_beca, b.codigo_beca, b.tipo_beca, b.monto_mensual, b.estado_beca,
                   b.fecha_asignacion, s.id_solicitud, s.estado AS estado_solicitud,
                   s.institucion_educativa, u.nombre_completo, u.correo
            FROM becas b
            INNER JOIN solicitudes s ON s.id_solicitud = b.id_solicitud
            INNER JOIN usuarios u ON u.id_usuario = s.id_usuario
            WHERE 1 = 1';
    $p = [];
    if ($rol === 'Estudiante') {
        $sql .= ' AND s.id_usuario = :u';
        $p[':u'] = $idUsuario;
    }
    if ($estadoBeca !== '') {
        $sql .= ' AND b.estado_beca = :eb';
        $p[':eb'] = $estadoBeca;
    }
    if ($periodo !== '') {
        $sql .= ' AND DATE_FORMAT(b.fecha_asignacion, \'%Y-%m\') = :per';
        $p[':per'] = $periodo;
    }
    $sql .= ' ORDER BY b.fecha_asignacion DESC, b.id_beca DESC';

    $stmt = $pdo->prepare($sql); // Consulta preparada: filtros van como parámetros, no concatenados.
    $stmt->execute($p);
    echo json_encode(['ok' => true, 'datos' => $stmt->fetchAll()]);
} catch (PDOException $e) {
    error_log('Error reportes: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['ok' => false, 'mensaje' => 'No se pudo obtener el reporte.']);
}
