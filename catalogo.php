<?php
require 'includes/conexion.php';
require 'includes/funciones.php';

$titulo = "Aeron | Catalogo";

// saco los productos de la base de datos
$productos = $pdo->query("SELECT * FROM productos WHERE imagen != '' ORDER BY id DESC")->fetchAll();

// quito los que no tienen la foto en la carpeta img
$productos = array_filter($productos, function($p){
   return file_exists($p['imagen']);
});
$productos = array_slice($productos, 0, 12);

require 'includes/cabecera.php';
?>
<main class="catalogo-container catalogo-pagina">
 <div class="catalogo-header">
   <h1 class="catalogo-titulo catalogo-titulo-grande">Catalogo Completo</h1>
   <div class="catalogo-contador"><?php echo count($productos) ?> productos disponibles</div>
 </div>

 <div class="grid-productos">
 <?php foreach ($productos as $row) { ?>
  <article class="producto-card">
   <div class="producto-img-box">
    <img src="<?php echo $row['imagen'] ?>" alt="<?php echo $row['nombre'] ?>">
   </div>
   <div class="producto-info">
    <span class="producto-nombre"><?php echo $row['nombre'] ?></span>
    <span class="producto-precio"><?php echo formatear_precio($row['precio']) ?></span>
   </div>
  </article>
 <?php } ?>
 </div>

</main>

<?php require 'includes/pie.php'; ?>
