<?php
// esto inicia la sesion si no esta iniciada
if (session_status() === PHP_SESSION_NONE) {
   session_start();
}

// escapar sirve para que no metan codigo raro (xss)
function escapar($texto) {
   return htmlspecialchars($texto, ENT_QUOTES, 'UTF-8');
}

// le pone el $ y los decimales al precio
function formatear_precio($precio) {
   return '$' . number_format($precio, 2);
}

// redirige a otra pagina y ya
function redirigir($url) {
   header("Location: $url");
   exit();
}
