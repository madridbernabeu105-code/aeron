-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: becas_bicentenario
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
-- Current Database: `becas_bicentenario`
--

/*!40000 DROP DATABASE IF EXISTS `becas_bicentenario`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `becas_bicentenario` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `becas_bicentenario`;

--
-- Table structure for table `becas`
--

DROP TABLE IF EXISTS `becas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `becas` (
  `id_beca` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_solicitud` int(10) unsigned NOT NULL COMMENT 'FK a solicitudes(id_solicitud), única por solicitud',
  `codigo_beca` varchar(20) NOT NULL COMMENT 'Ej.: BEC-2026-001',
  `monto_mensual` decimal(8,2) NOT NULL,
  `tipo_beca` varchar(50) NOT NULL COMMENT 'Ej.: Excelencia Académica, Apoyo Social',
  `estado_beca` enum('Activa','Suspendida','Finalizada') NOT NULL DEFAULT 'Activa',
  `fecha_asignacion` date NOT NULL,
  PRIMARY KEY (`id_beca`),
  UNIQUE KEY `uq_becas_solicitud` (`id_solicitud`),
  UNIQUE KEY `uq_becas_codigo` (`codigo_beca`),
  CONSTRAINT `fk_becas_solicitud` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitudes` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_becas_monto` CHECK (`monto_mensual` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `becas`
--

LOCK TABLES `becas` WRITE;
/*!40000 ALTER TABLE `becas` DISABLE KEYS */;
INSERT INTO `becas` VALUES (1,1,'BEC-2026-001',1200.00,'Excelencia Académica','Activa','2026-10-05');
/*!40000 ALTER TABLE `becas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluaciones`
--

DROP TABLE IF EXISTS `evaluaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluaciones` (
  `id_evaluacion` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_solicitud` int(10) unsigned NOT NULL COMMENT 'FK a solicitudes(id_solicitud)',
  `id_evaluador` int(10) unsigned DEFAULT NULL COMMENT 'FK a usuarios(id_usuario), rol Evaluador',
  `puntaje_socioeconomico` int(11) NOT NULL COMMENT 'Escala 0-100',
  `puntaje_academico` int(11) NOT NULL COMMENT 'Escala 0-100',
  `dictamen` enum('Favorable','No Favorable','Observado') NOT NULL,
  `observaciones` text DEFAULT NULL,
  `fecha_evaluacion` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_evaluacion`),
  KEY `idx_evaluaciones_solicitud` (`id_solicitud`),
  KEY `idx_evaluaciones_evaluador` (`id_evaluador`),
  CONSTRAINT `fk_evaluaciones_evaluador` FOREIGN KEY (`id_evaluador`) REFERENCES `usuarios` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_evaluaciones_solicitud` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitudes` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_evaluaciones_puntaje_socioeconomico` CHECK (`puntaje_socioeconomico` >= 0 and `puntaje_socioeconomico` <= 100),
  CONSTRAINT `chk_evaluaciones_puntaje_academico` CHECK (`puntaje_academico` >= 0 and `puntaje_academico` <= 100)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluaciones`
--

LOCK TABLES `evaluaciones` WRITE;
/*!40000 ALTER TABLE `evaluaciones` DISABLE KEYS */;
INSERT INTO `evaluaciones` VALUES (1,1,2,85,92,'Favorable','Evaluación de prueba: situación socioeconómica vulnerable y excelente rendimiento académico. Se recomienda aprobación.','2026-10-05 20:28:42');
/*!40000 ALTER TABLE `evaluaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_actualizar_estado_solicitud_evaluada`
AFTER INSERT ON `evaluaciones`
FOR EACH ROW
BEGIN
  IF NEW.`dictamen` = 'Favorable' THEN
    UPDATE `solicitudes`
       SET `estado` = 'Aprobada'
     WHERE `id_solicitud` = NEW.`id_solicitud`;
  ELSEIF NEW.`dictamen` = 'No Favorable' THEN
    UPDATE `solicitudes`
       SET `estado` = 'Rechazada'
     WHERE `id_solicitud` = NEW.`id_solicitud`;
  ELSE
    
    UPDATE `solicitudes`
       SET `estado` = 'En Evaluacion'
     WHERE `id_solicitud` = NEW.`id_solicitud`;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `solicitudes`
--

DROP TABLE IF EXISTS `solicitudes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `solicitudes` (
  `id_solicitud` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_usuario` int(10) unsigned NOT NULL COMMENT 'FK a usuarios(id_usuario)',
  `institucion_educativa` varchar(150) NOT NULL,
  `carrera_o_bachillerato` varchar(150) NOT NULL,
  `promedio_academico` decimal(4,2) NOT NULL COMMENT 'Ej.: 0.00 a 100.00',
  `ingreso_familiar_mensual` decimal(8,2) NOT NULL COMMENT 'En moneda local, ej.: 2500.00',
  `estado` enum('Pendiente','En Evaluacion','Aprobada','Rechazada') NOT NULL DEFAULT 'Pendiente',
  `fecha_postulacion` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Actualizada por trigger trg_actualizar_fecha_solicitud',
  PRIMARY KEY (`id_solicitud`),
  KEY `idx_solicitudes_usuario` (`id_usuario`),
  KEY `idx_solicitudes_estado` (`estado`),
  CONSTRAINT `fk_solicitudes_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_solicitudes_promedio` CHECK (`promedio_academico` >= 0 and `promedio_academico` <= 100),
  CONSTRAINT `chk_solicitudes_ingreso` CHECK (`ingreso_familiar_mensual` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `solicitudes`
--

LOCK TABLES `solicitudes` WRITE;
/*!40000 ALTER TABLE `solicitudes` DISABLE KEYS */;
INSERT INTO `solicitudes` VALUES (1,3,'Universidad Mayor de San Andrés','Ingeniería de Sistemas',92.50,2500.00,'Aprobada','2026-10-05 14:28:42','2026-10-05 20:28:42'),(2,3,'Colegio Nacional Ayacucho','Bachillerato en Ciencias',88.75,1800.00,'Pendiente','2026-10-05 14:28:42','2026-10-05 20:28:42');
/*!40000 ALTER TABLE `solicitudes` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_actualizar_fecha_solicitud`
BEFORE UPDATE ON `solicitudes`
FOR EACH ROW
BEGIN
  SET NEW.`fecha_actualizacion` = CURRENT_TIMESTAMP;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id_usuario` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nombre_completo` varchar(150) NOT NULL,
  `correo` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL COMMENT 'Hash generado con password_hash() de PHP',
  `rol` enum('Estudiante','Evaluador','Administrador') NOT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuarios_correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Ada Administradora','admin@bicentenario.bo','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Administrador','2026-10-05 20:28:42'),(2,'Eva Evaluadora','evaluador@bicentenario.bo','$2y$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHbqyEPOwc6Ew1W5Fv.4xT9.','Evaluador','2026-10-05 20:28:42'),(3,'Esteban Estudiante','estudiante@bicentenario.bo','$2y$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','Estudiante','2026-10-05 20:28:42');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'becas_bicentenario'
--

--
-- Dumping routines for database 'becas_bicentenario'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-05 14:30:47
