-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: aeron_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `mensajes`
--

DROP TABLE IF EXISTS `mensajes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mensajes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `correo` varchar(255) NOT NULL,
  `mensaje` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `metodos_pago`
--

DROP TABLE IF EXISTS `metodos_pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `metodos_pago` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `titular` varchar(100) DEFAULT NULL,
  `numero_tarjeta` varchar(20) DEFAULT NULL,
  `expiracion` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `metodos_pago_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `estado` varchar(50) DEFAULT 'En proceso',
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `categoria` varchar(50) NOT NULL,
  `imagen` varchar(255) DEFAULT '',
  `stock` int(11) DEFAULT 10,
  PRIMARY KEY (`id`),
  KEY `idx_productos_categoria` (`categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  `avatar` varchar(255) DEFAULT 'default.png',
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'aeron_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-07 17:21:58
-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: aeron_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `metodos_pago`
--

LOCK TABLES `metodos_pago` WRITE;
/*!40000 ALTER TABLE `metodos_pago` DISABLE KEYS */;
INSERT INTO `metodos_pago` VALUES (1,1,'Josue Gonzalez','4532123456789012','12/28');
/*!40000 ALTER TABLE `metodos_pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'Mouse Superlight V2','Mouse inal├ímbrico ultraligero para uso profesional.',140.00,'mouse','img/superlight.webp',10),(2,'Teclado Custom 65%','Teclado mec├ínico con switches lineales.',120.00,'teclados','img/teclado_custom.jpg',10),(3,'Monitor 27\" IPS 240Hz','Monitor sin bordes con calibraci├│n de color premium.',350.00,'monitores','img/4.avif',10),(4,'Aud├¡fonos Studio Pro','Audio de alta fidelidad con cancelaci├│n de ruido.',180.00,'audio','img/3.jpg',10),(5,'Mousepad Deskmat XL','Superficie de tela de alta densidad.',30.00,'mousepads','img/mousepad1.jpg',10),(6,'Micr├│fono Condensador','Micr├│fono USB para grabaciones n├¡tidas.',85.00,'micr├│fonos','img/mic_condensador.jpg',10),(7,'Razer DeathAdder V3 Pro','Mouse inal├ímbrico esports con sensor Focus Pro 30K y dise├▒o ergon├│mico cl├ísico.',149.00,'mouse','img/razer.jpg',10),(8,'Lamzu Atlantis V2','Mouse ligero de forma sim├®trica, gran autonom├¡a y acabado premium.',99.00,'mouse','img/lamzu.jpg',10),(9,'Pulsar X2V2','Mouse ultraligero inal├ímbrico con sensor ├│ptico de alta precisi├│n.',95.00,'mouse','img/pulsar.jpg',10),(10,'Zowie EC2-CW','Mouse ergon├│mico inal├ímbrico dise├▒ado para competir, sin software necesario.',149.00,'mouse','img/zowie.jpg',10),(11,'Ninjutso Sora V2','Mouse compacto ultraligero ideal para agarres claw y fingertip.',129.00,'mouse','img/ninjutso.jpg',10),(12,'Finalmouse UltralightX','Mouse profesional ultra ligero con construcci├│n de nueva generaci├│n.',189.00,'mouse','img/finalmouse.jpg',10),(13,'Wooting 60HE','Teclado mec├ínico anal├│gico 60% con actuaci├│n ajustable y Rapid Trigger.',175.00,'teclados','img/teclado1.jpg',10),(14,'Keychron Q1 Pro','Teclado mec├ínico de cuerpo completo en metal, inal├ímbrico y montaje gasket.',179.00,'teclados','img/teclado2.jpg',10),(15,'Razer Huntsman V3 Pro','Teclado esports con switches anal├│gicos ├│pticos y Rapid Trigger.',249.00,'teclados','img/teclado3.jpg',10),(16,'Logitech G Pro X 60','Teclado compacto 60% inal├ímbrico dise├▒ado junto a jugadores profesionales.',179.00,'teclados','img/teclado4.jpg',10),(17,'NuPhy Air75 V2','Teclado low-profile inal├ímbrico ultra delgado para trabajo y juego.',130.00,'teclados','img/teclado5.jpg',10),(18,'Epomaker RT100','Teclado mec├ínico 96% inal├ímbrico con perilla de volumen y bater├¡a extendida.',115.00,'teclados','img/teclado6.jpg',10),(19,'Asus ROG Azoth','Teclado custom 75% con pantalla OLED y montaje gasket premium.',249.00,'teclados','img/teclado7.jpg',10),(20,'LG UltraGear 27GR95QE-B OLED','Monitor gaming OLED de 27\" y 240Hz con tiempo de respuesta casi instant├íneo.',899.00,'monitores','img/monitor1.jpg',10),(21,'ASUS ROG Swift PG27AQN','Monitor esports 27\" TN 360Hz pensado para m├íxima fluidez competitiva.',999.00,'monitores','img/monitor2.jpg',10),(22,'Samsung Odyssey OLED G8','Monitor OLED 32\" 175Hz con dise├▒o ultra delgado y n├║cleo inteligente.',999.00,'monitores','img/monitor3.jpg',10),(23,'Alienware AW2725DF','Monitor QD-OLED 27\" 360Hz con color excepcional y latencia m├¡nima.',899.00,'monitores','img/monitor4.jpg',10),(24,'MSI MAG 271QPX QD-OLED','Monitor QD-OLED 27\" 240Hz con panel Samsung de ├║ltima generaci├│n.',749.00,'monitores','img/monitor5.jpg',10),(25,'Gigabyte M27Q X','Monitor 27\" IPS 240Hz con KVM integrado, ideal para gaming y multitarrea.',399.00,'monitores','img/monitor6.jpg',10),(26,'Acer Nitro XV272U F3','Monitor 27\" IPS 180Hz con HDR10 y cobertura amplia de color.',299.00,'monitores','img/monitor7.jpg',10),(27,'Acer Nitro XV272U F3','Monitor 27\" IPS 180Hz con HDR10 y cobertura amplia de color.',299.00,'monitores','img/monitor7.jpg',10),(28,'SteelSeries Arctis Nova Pro Wireless','Aud├¡fonos gamer inal├ímbricos con basestation, cancelaci├│n de ruido y audio de estudio.',349.00,'audio','img/audio1.jpg',10),(29,'HyperX Cloud III Wireless','Aud├¡fonos inal├ímbricos con hasta 120 horas de bater├¡a y comodidad premium.',169.00,'audio','img/audio2.jpg',10),(30,'Razer BlackShark V2 Pro (2023)','Aud├¡fonos esports inal├ímbricos ligeros con micr├│fono HyperClear desmontable.',199.00,'audio','img/audio3.jpg',10),(31,'Logitech G Pro X 2 Lightspeed','Aud├¡fonos profesionales inal├ímbricos con drivers h├¡bridos MAGNESIUM.',249.00,'audio','img/audio4.jpg',10),(32,'Beyerdynamic DT 990 Pro','Aud├¡fonos de estudio abiertos con sonido detallado y graves precisos.',149.00,'audio','img/audio5.jpg',10),(33,'Audio-Technica ATH-M50xBT2','Aud├¡fonos de monitoreo inal├ímbricos, referencia en estudios profesionales.',199.00,'audio','img/audio6.jpg',10),(34,'Corsair Virtuoso Pro','Aud├¡fonos de broadcast con alta fidelidad y micr├│fono estilo estudio.',199.00,'audio','img/audio7.jpg',10),(35,'Shure MV7+','Micr├│fono din├ímico USB/XLR inspirado en el legendario SM7B, ideal para streaming.',279.00,'micr├│fonos','img/microfonos1.jpg',10);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-07 17:21:59
