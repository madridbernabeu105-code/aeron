<?php
// backend/auth/logout.php (RF-02 complemento: Cierre de sesión)
// Limpia $_SESSION, destruye la sesión y su cookie, y redirige al login.
// Seguridad: si se llamó por fetch/AJAX devuelve JSON; si es navegación,
// redirige para no dejar páginas autenticadas en caché.

session_start();

// 1. Vacía el arreglo de sesión.
$_SESSION = [];

// 2. Borra la cookie de sesión del navegador (si existe).
if (ini_get('session.use_cookies')) {
    $params = session_get_cookie_params();
    setcookie(
        session_name(),
        '',
        time() - 42000,
        $params['path'],
        $params['domain'],
        $params['secure'],
        $params['httponly']
    );
}

// 3. Destruye la sesión en el servidor.
session_destroy();

// 4. Respuesta según el tipo de petición.
$accept = $_SERVER['HTTP_ACCEPT'] ?? '';
if (stripos($accept, 'application/json') !== false) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['ok' => true, 'mensaje' => 'Sesión cerrada correctamente.']);
    exit;
}

// Redirección a la página de login del frontend (ajustar si cambia la ruta).
header('Location: /frontend/pages/login.html');
exit;
