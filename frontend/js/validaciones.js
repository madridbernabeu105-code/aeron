// frontend/js/validaciones.js — JS nativo, sin librerías. Se incluye en todas las páginas.
// Cubre: validación cliente, auth por fetch(), menú por rol con enlace activo
// y carga dinámica de los 3 módulos con credentials same-origin.
(function () {
  'use strict';

  // Regex de correo (defensa: chequeo cliente; el servidor revalida).
  var EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
  var PERFIL_KEY = 'bb_perfil'; // Perfil activo en localStorage (lo devuelve login.php).

  // Base del backend según profundidad (pages/ -> ../../backend, raíz -> backend).
  function baseBackend() {
    return window.location.pathname.indexOf('/frontend/') !== -1
      ? '../../backend' : 'backend';
  }
  function urlCtrl(path) { return baseBackend() + path; }

  // Lee el perfil activo (null si no hay sesión iniciada en este navegador).
  function leerPerfil() {
    try { return JSON.parse(localStorage.getItem(PERFIL_KEY) || 'null'); }
    catch (e) { return null; }
  }
  function guardarPerfil(u) {
    try {
      if (u) localStorage.setItem(PERFIL_KEY, JSON.stringify(u));
      else localStorage.removeItem(PERFIL_KEY);
    } catch (e) {}
  }

  // Muestra alerta de éxito/error en el DOM sin recargar la página.
  function mostrarAlerta(contenedor, tipo, mensaje) {
    var box = typeof contenedor === 'string'
      ? document.querySelector(contenedor) : contenedor;
    if (!box) return;
    box.innerHTML = '';
    var div = document.createElement('div');
    div.className = 'alerta ' + (tipo === 'exito' ? 'alerta--exito' : 'alerta--error');
    div.textContent = mensaje;
    box.appendChild(div);
  }

  // Escapa texto para inyectar filas de forma segura (evita XSS en innerHTML).
  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  // Badge visual según estado (whitelist de clases).
  function badgeEstado(estado) {
    var cls = 'badge--pendiente';
    if (estado === 'Aprobada') cls = 'badge--aprobada';
    else if (estado === 'Rechazada') cls = 'badge--rechazada';
    else if (estado === 'En Evaluacion') cls = 'badge--pendiente';
    return '<span class="badge ' + cls + '">' + esc(estado) + '</span>';
  }

  // Valida un formulario: requeridos + email + longitud de clave.
  function validarFormulario(form) {
    var requeridos = form.querySelectorAll('[required]');
    for (var i = 0; i < requeridos.length; i++) {
      if (!requeridos[i].value.trim()) {
        return { ok: false, mensaje: 'Complete todos los campos.' };
      }
    }
    var email = form.querySelector('input[type="email"], input[name="correo"]');
    if (email && !EMAIL_RE.test(email.value.trim())) {
      return { ok: false, mensaje: 'El correo no es válido.' };
    }
    var pass = form.querySelector('input[type="password"]');
    if (pass && pass.value.length < 6) {
      return { ok: false, mensaje: 'La contraseña debe tener al menos 6 caracteres.' };
    }
    return { ok: true, datos: new FormData(form) };
  }

  // POST genérico por fetch, espera JSON { ok, mensaje }.
  function enviar(url, formData, onOk) {
    return fetch(url, { method: 'POST', body: formData, credentials: 'same-origin' })
      .then(function (r) { return r.json(); })
      .then(function (json) {
        if (json.ok && typeof onOk === 'function') onOk(json);
        return json;
      });
  }

  // GET JSON genérico con sesión (credentials same-origin mantiene PHPSESSID).
  function getJSON(url) {
    return fetch(url, { credentials: 'same-origin' }).then(function (r) { return r.json(); });
  }

  // Manejador centralizado: forms con data-auth="registro" o data-auth="login".
  function initAuth() {
    document.querySelectorAll('form[data-auth]').forEach(function (form) {
      var box = form.parentElement.querySelector('[data-alertas]') || form;
      form.addEventListener('submit', function (e) {
        e.preventDefault(); // Sin recarga: todo por fetch + DOM.
        var v = validarFormulario(form);
        if (!v.ok) { mostrarAlerta(box, 'error', v.mensaje); return; }

        var esRegistro = form.getAttribute('data-auth') === 'registro';
        var url = urlCtrl(esRegistro ? '/auth/registro.php' : '/auth/login.php');

        enviar(url, v.datos, function (json) {
          mostrarAlerta(box, 'exito', json.mensaje);
          if (!esRegistro && json.usuario) {
            guardarPerfil(json.usuario); // Persiste perfil para renderizarMenu().
            setTimeout(function () { window.location.href = '../pages/dashboard.html'; }, 800);
          } else {
            form.reset();
          }
        }).then(function (json) {
          if (!json.ok) mostrarAlerta(box, 'error', json.mensaje || 'Ocurrió un error.');
        }).catch(function () {
          mostrarAlerta(box, 'error', 'No se pudo conectar con el servidor.');
        });
      });
    });
  }

  // Menú dinámico por rol: filtra enlaces [data-roles], muestra avatar/badge
  // del usuario activo y resalta el enlace actual (.navbar__link--active).
  function renderizarMenu() {
    var perfil = leerPerfil();
    var pagina = window.location.pathname.split('/').pop() || 'dashboard.html';
    document.querySelectorAll('.navbar__menu a[data-roles]').forEach(function (a) {
      var roles = (a.getAttribute('data-roles') || '').split(',');
      var visible = !perfil
        ? a.hasAttribute('data-public')            // Sin sesión: solo enlaces públicos.
        : roles.indexOf(perfil.rol) !== -1;        // Con sesión: según su rol.
      a.parentElement.style.display = visible ? '' : 'none';
      // Resalta la página actual para evitar cambios bruscos al navegar.
      if (a.getAttribute('href') === pagina) a.classList.add('navbar__link--active');
      else a.classList.remove('navbar__link--active');
    });
    var avatar = document.querySelector('[data-avatar]');
    var badge = document.querySelector('[data-rol-badge]');
    var salir = document.querySelector('[data-logout]');
    var entrar = document.querySelector('[data-login-link]');
    if (avatar) avatar.textContent = perfil ? perfil.nombre_completo.charAt(0).toUpperCase() : '?';
    if (badge) badge.textContent = perfil ? perfil.rol : 'Invitado';
    if (salir) salir.style.display = perfil ? '' : 'none';
    if (entrar) entrar.style.display = perfil ? 'none' : '';
    // Filtra botones laterales del dashboard (.dashboard__side [data-roles]) por rol.
    document.querySelectorAll('.dashboard__side [data-roles]').forEach(function (a) {
      var roles = (a.getAttribute('data-roles') || '').split(',');
      var visible = !perfil
        ? a.hasAttribute('data-public')            // Invitado: solo accesos públicos.
        : roles.indexOf(perfil.rol) !== -1;        // Estudiante no ve Evaluar/Reportes y viceversa.
      a.style.display = visible ? '' : 'none';
    });
    // Invitado: el banner invita a iniciar sesión en lugar de postular directo.
    var heroCta = document.querySelector('[data-hero-postular]');
    if (heroCta && !perfil) {
      heroCta.textContent = 'Iniciar sesión para postular';
      heroCta.setAttribute('href', 'login.html');
    }
  }

  // 1. Carga del Expediente (estado_solicitud.html): puebla #tbody-expediente.
  // Sin sesión o sin registros muestra un .empty-state elegante (no texto crudo).
  function initExpediente() {
    var tbody = document.getElementById('tbody-expediente');
    if (!tbody) return;
    var vacio = document.getElementById('expediente-vacio');
    var tabla = tbody.closest('.tabla-wrap');
    var candado = '<svg viewBox="0 0 24 24" fill="none" stroke="#b45309" stroke-width="2">' +
      '<rect x="4" y="10" width="16" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg>';
    function pintarVacio(titulo, texto, btnTexto, btnHref) {
      if (tabla) tabla.style.display = 'none';
      if (vacio) vacio.innerHTML = '<div class="empty-state"><div class="empty-state__icon">' + candado + '</div>' +
        '<h3>' + esc(titulo) + '</h3><p>' + esc(texto) + '</p>' +
        '<a class="btn btn--pill" href="' + btnHref + '">' + esc(btnTexto) + '</a></div>';
    }
    getJSON(urlCtrl('/controllers/reportes.php?accion=expediente'))
      .then(function (json) {
        if (!json.ok) {
          pintarVacio('Acceso restringido', 'Inicia sesión para consultar tu expediente oficial.', 'Ir a Iniciar Sesión', 'login.html');
          return;
        }
        if (!json.datos.length) {
          pintarVacio('Sin postulaciones', 'Aún no tienes postulaciones activas. Crea tu primera solicitud oficial.', 'Crear mi primera postulación', 'solicitar_beca.html');
          return;
        }
        if (tabla) tabla.style.display = '';
        if (vacio) vacio.innerHTML = '';
        tbody.innerHTML = json.datos.map(function (s) {
          return '<tr><td>' + esc(s.id_solicitud) + '</td><td>' + esc(s.institucion_educativa) +
            '</td><td>' + esc(s.carrera_o_bachillerato) + '</td><td>' + badgeEstado(s.estado) +
            '</td><td>' + esc(s.fecha_actualizacion) + '</td></tr>';
        }).join('') || '<tr><td colspan="5">Sin solicitudes.</td></tr>';
      })
      .catch(function () { pintarVacio('Error de conexión', 'No se pudo contactar al servidor. Intenta nuevamente.', 'Reintentar', 'estado_solicitud.html'); });
  }

  // 2. Envío de Postulación (solicitar_beca.html): POST a solicitud.php sin recargar.
  function initSolicitud() {
    var form = document.getElementById('form-solicitud');
    if (!form) return;
    var box = document.querySelector('[data-alertas]') || form;
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var fd = new FormData(form); // institucion, carrera, promedio, ingreso.
      enviar(urlCtrl('/controllers/solicitud.php'), fd, function (json) {
        mostrarAlerta(box, 'exito', json.mensaje + ' (ID ' + json.id_solicitud + ')');
        form.reset();
      }).then(function (json) {
        if (!json.ok) mostrarAlerta(box, 'error', json.mensaje || 'No se pudo registrar.');
      }).catch(function () {
        mostrarAlerta(box, 'error', 'No se pudo conectar con el servidor.');
      });
    });
  }

  // 3. Gestión de Evaluaciones (gestionar_solicitudes.html): lista + Guardar por fila.
  function initGestion() {
    var tabla = document.querySelector('table.tabla tbody');
    var enGestion = tabla && window.location.pathname.indexOf('gestionar_solicitudes') !== -1;
    if (!enGestion) return;
    var box = document.querySelector('[data-alertas]');
    var thead = document.querySelector('table.tabla thead tr');
    if (thead) thead.innerHTML = '<th>ID</th><th>Estudiante</th><th>Promedio</th>' +
      '<th>P.Soc (0-100)</th><th>P.Aca (0-100)</th><th>Dictamen</th><th>Observaciones</th><th></th>';

    function cargar() {
      getJSON(urlCtrl('/controllers/reportes.php?accion=expediente'))
        .then(function (json) {
          if (!json.ok) { mostrarAlerta(box, 'error', json.mensaje); return; }
          var pend = json.datos.filter(function (s) { return s.estado === 'Pendiente' || s.estado === 'En Evaluacion'; });
          tabla.innerHTML = pend.map(function (s) {
            return '<tr data-id="' + esc(s.id_solicitud) + '"><td>' + esc(s.id_solicitud) + '</td>' +
              '<td>' + esc(s.nombre_completo) + '</td><td>' + esc(s.promedio_academico) + '</td>' +
              '<td><input class="input" type="number" min="0" max="100" value="70" data-f="psoc"></td>' +
              '<td><input class="input" type="number" min="0" max="100" value="80" data-f="paca"></td>' +
              '<td><select class="input" data-f="dictamen"><option>Favorable</option>' +
              '<option>No Favorable</option><option>Observado</option></select></td>' +
              '<td><input class="input" type="text" data-f="obs" placeholder="Observación"></td>' +
              '<td><button class="btn btn--pill" type="button" data-guardar>Guardar</button></td></tr>';
          }).join('') || '<tr><td colspan="8">Sin solicitudes pendientes.</td></tr>';
        })
        .catch(function () { mostrarAlerta(box, 'error', 'Error al cargar solicitudes.'); });
    }

    // Click en Guardar: POST a evaluacion.php y recarga la tabla al éxito.
    tabla.addEventListener('click', function (e) {
      var btn = e.target.closest('[data-guardar]');
      if (!btn) return;
      var tr = btn.closest('tr');
      var q = function (f) { return tr.querySelector('[data-f="' + f + '"]'); };
      var fd = new FormData();
      fd.append('id_solicitud', tr.getAttribute('data-id'));
      fd.append('puntaje_socioeconomico', q('psoc').value);
      fd.append('puntaje_academico', q('paca').value);
      fd.append('dictamen', q('dictamen').value);
      fd.append('observaciones', q('obs').value);
      enviar(urlCtrl('/controllers/evaluacion.php'), fd, function (json) {
        mostrarAlerta(box, 'exito', json.mensaje + ' Nuevo estado: ' + json.nuevo_estado);
        cargar(); // Recarga la tabla al éxito.
      }).then(function (json) {
        if (!json.ok) mostrarAlerta(box, 'error', json.mensaje || 'No se pudo evaluar.');
      }).catch(function () {
        mostrarAlerta(box, 'error', 'No se pudo conectar con el servidor.');
      });
    });

    cargar();
  }

  // 4. Generación de Reportes (reportes.html): filtros -> #tabla-reporte.
  function initReportes() {
    var form = document.getElementById('form-reportes');
    var tabla = document.getElementById('tabla-reporte');
    if (!form || !tabla) return;
    var tbody = tabla.querySelector('tbody');
    form.addEventListener('submit', function (e) {
      e.preventDefault(); // Sin recarga.
      var qs = new URLSearchParams({
        accion: 'reporte',
        estado_beca: form.estado_beca.value,
        periodo: form.periodo.value
      }).toString();
      getJSON(urlCtrl('/controllers/reportes.php?' + qs))
        .then(function (json) {
          if (!json.ok) { tbody.innerHTML = '<tr><td colspan="5">' + esc(json.mensaje) + '</td></tr>'; return; }
          tbody.innerHTML = json.datos.map(function (b) {
            return '<tr><td>' + esc(b.codigo_beca) + '</td><td>' + esc(b.tipo_beca) + '</td>' +
              '<td>' + badgeEstado(b.estado_beca === 'Activa' ? 'Aprobada' : b.estado_beca) + ' ' + esc(b.estado_beca) + '</td>' +
              '<td>' + esc(b.monto_mensual) + '</td><td>' + esc(b.fecha_asignacion) + '</td></tr>';
          }).join('') || '<tr><td colspan="5">Sin resultados.</td></tr>';
        })
        .catch(function () { tbody.innerHTML = '<tr><td colspan="5">Error de conexión.</td></tr>'; });
    });
  }

  // 5. Indicadores del Dashboard: actualiza [data-stat] al cargar.
  function initDashboard() {
    var hay = document.querySelector('[data-stat]');
    if (!hay) return;
    var set = function (k, v) {
      var el = document.querySelector('[data-stat="' + k + '"]');
      if (el) el.textContent = v;
    };
    getJSON(urlCtrl('/controllers/reportes.php?accion=expediente')).then(function (json) {
      if (!json.ok) return;
      set('postulaciones', json.datos.length);
      set('evaluacion', json.datos.filter(function (s) { return s.estado === 'En Evaluacion'; }).length);
    }).catch(function () {});
    getJSON(urlCtrl('/controllers/reportes.php?accion=becas')).then(function (json) {
      if (!json.ok) return;
      set('activas', json.datos.filter(function (b) { return b.estado_beca === 'Activa'; }).length);
    }).catch(function () {});
  }

  // Postular desde becas.html: exige sesión; si no, avisa y redirige a login.
  function initPostularGuard() {
    document.querySelectorAll('[data-requiere-sesion]').forEach(function (el) {
      el.addEventListener('click', function (e) {
        if (leerPerfil()) return; // Con sesión: navegación normal.
        e.preventDefault();
        try { sessionStorage.setItem('bb_aviso', 'Inicia sesión o regístrate para postular a esta beca'); } catch (err) {}
        window.location.href = 'login.html';
      });
    });
    // Muestra el aviso pendiente al llegar a login.html (sin recarga extra).
    var aviso = null;
    try { aviso = sessionStorage.getItem('bb_aviso'); sessionStorage.removeItem('bb_aviso'); } catch (err) {}
    if (aviso) {
      var box = document.querySelector('main [data-alertas]');
      if (box) mostrarAlerta(box, 'error', aviso);
    }
  }

  // Cierre de sesión: limpia perfil local, destruye sesión PHP y redirige al login.
  function logout() {
    guardarPerfil(null);
    fetch(urlCtrl('/auth/logout.php'), { credentials: 'same-origin' })
      .then(function () { window.location.href = '../pages/login.html'; })
      .catch(function () { window.location.href = '../pages/login.html'; });
  }

  // Menú hamburguesa móvil: alterna .abierto (ver media query <767px).
  function initMenu() {
    var btn = document.querySelector('.navbar__toggle');
    var menu = document.querySelector('.navbar__menu');
    if (btn && menu) btn.addEventListener('click', function () {
      menu.classList.toggle('abierto');
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initMenu();
    initAuth();
    renderizarMenu();
    initExpediente();
    initSolicitud();
    initGestion();
    initReportes();
    initDashboard();
    initPostularGuard();
  });

  // Expone logout global para botones onclick="logout()".
  window.logout = logout;
})();
