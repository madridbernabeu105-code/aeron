<?php
// pagina principal - aeron
$titulo = "Aeron | Perifericos"; // titulo de la pestaña
require 'includes/cabecera.php'; // carga el menu
?>
<main>
<!-- banner de arriba -->
  <section class="hero-section">
    <div class="slide slide-fondo-1 activa">
     <div class="slide-content">
      <H2>CONSTRUYE TU ESPACIO</H2>
      <p>Equipamiento disenado para dominar cada partida.</p>
      <a href="catalogo.php" class="btn-banner">Explorar Coleccion</a>
     </div>
    </div>
   <div class="slide slide-fondo-2">
    <div class="slide-content">
      <h2>CONTROL Y PRECISION</h2>
     <p>Velocidad de respuesta tactil en cada pulsacion.</p>
      <a href="catalogo.php" class="btn-banner">Ver Perifericos</a>
    </div>
   </div>
    <div class="slide slide-fondo-3">
     <div class="slide-content">
      <H2>INMERSION AUDITIVA</H2>
      <p>Escucha cada detalle. Comunícate sin limites.</p>
      <a href="catalogo.php" class="btn-banner">Descubrir Audio</a>
     </div>
    </div>
     <div class="slide slide-fondo-4">
      <div class="slide-content">
       <h2>VISION ULTRA PANORAMICA</h2>
       <p>Sin tirones, sin limites. Fluidez absoluta.</p>
       <a href="catalogo.php" class="btn-banner">Ver Monitores</a>
      </div>
     </div>
  </section>

<!-- las 3 cajitas de beneficios -->
<section class="features-bar">
  <div class="feature-item">
   <h3>Envio Nacional</h3>
   <p>Entrega rapida y rastreada a todo el pais.</p>
  </div>
  <div class="feature-item">
    <h3>Garantia Aeron</h3>
   <p>Soporte tecnico directo y respaldo total.</p>
  </div>
   <div class="feature-item">
    <H3>Pagos Seguros</H3>
    <p>Transacciones cifradas y protegidas.</p>
  </div>
</section>

<!-- categorias -->
  <section class="categories-section">
   <div class="section-header">
    <h2 class="section-title">CATEGORIAS DESTACADAS</h2>
   </div>
   <div class="categories-grid">
    <a href="catalogo.php" class="category-card categoria-audio">
     <div class="category-content">
      <div class="category-title">Audio Studio</div>
      <div class="category-sub">Auriculares & Microfonos</div>
     </div>
    </a>
    <a href="catalogo.php" class="category-card categoria-control">
     <div class="category-content">
      <div class="category-title">Control Tactil</div>
      <div class="category-sub">Teclados & Mouses</div>
     </div>
    </a>
     <a href="catalogo.php" class="category-card categoria-visual">
      <div class="category-content">
       <div class="category-title">Visual Setup</div>
       <div class="category-sub">Monitores & Pantallas</div>
      </div>
     </a>
   </div>
  </section>

<!-- productos destacados de la pagina principal -->
<div class="catalogo-container destacados-seccion">
 <div class="catalogo-header destacados-header">
  <h1 class="catalogo-titulo destacados-titulo">ARSENAL DESTACADO</h1>
  <div class="ver-todo"><a href="catalogo.php">Ver todo</a></div>
 </div>
 <div class="grid-productos">
  <a href="catalogo.php" class="producto-card producto-card--enlace">
   <div class="producto-img-box"><img src="img/superlight.webp" alt="Mouse Superlight V2"></div>
   <div class="producto-info">
    <span class="producto-nombre">Mouse Superlight V2</span>
    <span class="producto-precio">$140.00</span>
   </div>
  </a>
   <a href="catalogo.php" class="producto-card producto-card--enlace">
    <div class="producto-img-box"><img src="img/razer.jpg" alt="Razer DeathAdder V3 Pro"></div>
    <div class="producto-info">
     <span class="producto-nombre">Razer DeathAdder V3 Pro</span>
     <span class="producto-precio">$149.00</span>
    </div>
   </a>
  <a href="catalogo.php" class="producto-card producto-card--enlace">
   <div class="producto-img-box"><img src="img/lamzu.jpg" alt="Lamzu Atlantis V2"></div>
   <div class="producto-info">
    <span class="producto-nombre">Lamzu Atlantis V2</span>
    <span class="producto-precio">$99.00</span>
   </div>
  </a>
   <a href="catalogo.php" class="producto-card producto-card--enlace">
    <div class="producto-img-box"><img src="img/pulsar.jpg" alt="Pulsar X2V2"></div>
    <div class="producto-info">
     <span class="producto-nombre">Pulsar X2V2</span>
     <span class="producto-precio">$95.00</span>
    </div>
   </a>
 </div>
</div>

<!-- lo del correo para registrarse al club -->
<section class="cta-banner">
 <div class="cta-content">
  <H2>ELEVA TU SETUP AL SIGUIENTE NIVEL</H2>
  <p>Forma parte de la comunidad Aeron. Recibe avisos de lanzamientos exclusivos, ofertas privadas y acceso anticipado.</p>
  <form class="cta-form" onsubmit="event.preventDefault(); alert('Bienvenido al Club Aeron');">
   <input type="email" placeholder="Tu correo electronico..." required>
   <button type="submit">UNIRME</button>
  </form>
 </div>
</section>
</main>

<?php require 'includes/pie.php'; ?>
