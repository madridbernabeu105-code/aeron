-- ============================================================================
-- Sistema de Gestión del Programa de Becas Bicentenario
-- Módulo 2.7: Base de Datos
-- Archivo: database/sql/database.sql
-- Motor: MySQL / MariaDB (InnoDB + utf8mb4_unicode_ci)
-- Descripción: Creación de BD, 4 tablas obligatorias, 2 triggers y seeds.
-- ============================================================================

-- Fijar codificación de la conexión para compatibilidad completa utf8mb4.
SET NAMES utf8mb4;

-- ----------------------------------------------------------------------------
-- 1. CONFIGURACIÓN DE BASE DE DATOS
-- Se crea la BD `becas_bicentenario` con codificación utf8mb4_unicode_ci
-- para soporte completo de tildes, ñ y emojis.
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS `becas_bicentenario`
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

USE `becas_bicentenario`;

-- ============================================================================
-- 2. CREACIÓN DE LAS 4 TABLAS OBLIGATORIAS (Motor InnoDB: transacciones + FK)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Tabla 1: `usuarios`
-- Propósito: Almacena a los actores del sistema (Estudiante, Evaluador,
-- Administrador). La columna `password_hash` es VARCHAR(255) para guardar
-- el resultado de password_hash() de PHP (bcrypt Argon2, 60+ caracteres).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre_completo` VARCHAR(150) NOT NULL,
  `correo` VARCHAR(150) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'Hash generado con password_hash() de PHP',
  `rol` ENUM('Estudiante', 'Evaluador', 'Administrador') NOT NULL,
  `fecha_registro` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuarios_correo` (`correo`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Tabla 2: `solicitudes` (Módulo 1: Postulaciones)
-- Propósito: Registra cada postulación a beca realizada por un Estudiante.
-- Restricción FK `fk_solicitudes_usuario`: cada solicitud pertenece a un
-- usuario; ON DELETE CASCADE elimina sus solicitudes si se borra el usuario,
-- ON UPDATE CASCADE propaga cambios de PK.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `solicitudes` (
  `id_solicitud` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_usuario` INT UNSIGNED NOT NULL COMMENT 'FK a usuarios(id_usuario)',
  `institucion_educativa` VARCHAR(150) NOT NULL,
  `carrera_o_bachillerato` VARCHAR(150) NOT NULL,
  `promedio_academico` DECIMAL(4, 2) NOT NULL COMMENT 'Ej.: 0.00 a 100.00',
  `ingreso_familiar_mensual` DECIMAL(8, 2) NOT NULL COMMENT 'En moneda local, ej.: 2500.00',
  `estado` ENUM('Pendiente', 'En Evaluacion', 'Aprobada', 'Rechazada') NOT NULL DEFAULT 'Pendiente',
  `fecha_postulacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Actualizada por trigger trg_actualizar_fecha_solicitud',
  PRIMARY KEY (`id_solicitud`),
  KEY `idx_solicitudes_usuario` (`id_usuario`),
  KEY `idx_solicitudes_estado` (`estado`),
  CONSTRAINT `fk_solicitudes_usuario`
    FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_solicitudes_promedio`
    CHECK (`promedio_academico` >= 0 AND `promedio_academico` <= 100),
  CONSTRAINT `chk_solicitudes_ingreso`
    CHECK (`ingreso_familiar_mensual` >= 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Tabla 3: `evaluaciones` (Módulo 2: Evaluación Socioeconómica y Académica)
-- Propósito: Registra la evaluación que un Evaluador hace de una solicitud.
-- Restricción FK `fk_evaluaciones_solicitud`: cada evaluación pertenece a una
-- solicitud; CASCADE para limpieza referencial.
-- Restricción FK `fk_evaluaciones_evaluador`: cada evaluación es realizada
-- por un usuario (rol Evaluador/Administrador); SET NULL preserva el historial
-- si el evaluador es eliminado; por eso `id_evaluador` admite NULL.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `evaluaciones` (
  `id_evaluacion` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_solicitud` INT UNSIGNED NOT NULL COMMENT 'FK a solicitudes(id_solicitud)',
  `id_evaluador` INT UNSIGNED NULL COMMENT 'FK a usuarios(id_usuario), rol Evaluador',
  `puntaje_socioeconomico` INT NOT NULL COMMENT 'Escala 0-100',
  `puntaje_academico` INT NOT NULL COMMENT 'Escala 0-100',
  `dictamen` ENUM('Favorable', 'No Favorable', 'Observado') NOT NULL,
  `observaciones` TEXT NULL,
  `fecha_evaluacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_evaluacion`),
  KEY `idx_evaluaciones_solicitud` (`id_solicitud`),
  KEY `idx_evaluaciones_evaluador` (`id_evaluador`),
  CONSTRAINT `fk_evaluaciones_solicitud`
    FOREIGN KEY (`id_solicitud`) REFERENCES `solicitudes` (`id_solicitud`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_evaluaciones_evaluador`
    FOREIGN KEY (`id_evaluador`) REFERENCES `usuarios` (`id_usuario`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT `chk_evaluaciones_puntaje_socioeconomico`
    CHECK (`puntaje_socioeconomico` >= 0 AND `puntaje_socioeconomico` <= 100),
  CONSTRAINT `chk_evaluaciones_puntaje_academico`
    CHECK (`puntaje_academico` >= 0 AND `puntaje_academico` <= 100)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ----------------------------------------------------------------------------
-- Tabla 4: `becas` (Módulo 3: Asignación y Control de Becas)
-- Propósito: Registra la beca asignada a una solicitud aprobada.
-- Restricción FK `fk_becas_solicitud`: cada beca deriva de una solicitud;
-- UNIQUE(`id_solicitud`) garantiza una sola beca por solicitud;
-- UNIQUE(`codigo_beca`) evita duplicados de código (ej.: BEC-2026-001).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `becas` (
  `id_beca` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `id_solicitud` INT UNSIGNED NOT NULL COMMENT 'FK a solicitudes(id_solicitud), única por solicitud',
  `codigo_beca` VARCHAR(20) NOT NULL COMMENT 'Ej.: BEC-2026-001',
  `monto_mensual` DECIMAL(8, 2) NOT NULL,
  `tipo_beca` VARCHAR(50) NOT NULL COMMENT 'Ej.: Excelencia Académica, Apoyo Social',
  `estado_beca` ENUM('Activa', 'Suspendida', 'Finalizada') NOT NULL DEFAULT 'Activa',
  `fecha_asignacion` DATE NOT NULL,
  PRIMARY KEY (`id_beca`),
  UNIQUE KEY `uq_becas_solicitud` (`id_solicitud`),
  UNIQUE KEY `uq_becas_codigo` (`codigo_beca`),
  CONSTRAINT `fk_becas_solicitud`
    FOREIGN KEY (`id_solicitud`) REFERENCES `solicitudes` (`id_solicitud`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `chk_becas_monto`
    CHECK (`monto_mensual` > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- ============================================================================
-- 3. TRIGGERS AUTOMATIZADOS (2 TRIGGERS OBLIGATORIOS)
-- ============================================================================

DELIMITER //

-- ----------------------------------------------------------------------------
-- Trigger 1: `trg_actualizar_fecha_solicitud`
-- Propósito (defensa): Auditoría automática. BEFORE UPDATE en `solicitudes`.
-- Cada vez que se modifica un registro (cambio de estado, corrección de datos),
-- actualiza `fecha_actualizacion` a CURRENT_TIMESTAMP sin intervención de PHP.
-- Se usa NEW.fecha_actualizacion porque es un trigger BEFORE UPDATE.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_actualizar_fecha_solicitud` //
CREATE TRIGGER `trg_actualizar_fecha_solicitud`
BEFORE UPDATE ON `solicitudes`
FOR EACH ROW
BEGIN
  SET NEW.`fecha_actualizacion` = CURRENT_TIMESTAMP;
END //

-- ----------------------------------------------------------------------------
-- Trigger 2: `trg_actualizar_estado_solicitud_evaluada`
-- Propósito (defensa): Automatización del flujo Módulo 1 -> Módulo 2.
-- AFTER INSERT en `evaluaciones`. Según el `dictamen` registrado, actualiza
-- el `estado` de la solicitud correspondiente en `solicitudes`:
--   'Favorable'    -> 'Aprobada'
--   'No Favorable' -> 'Rechazada'
--   'Observado'    -> 'En Evaluacion' (requiere revisión / subsanación)
-- Se usa NEW.id_solicitud y NEW.dictamen (fila recién insertada).
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS `trg_actualizar_estado_solicitud_evaluada` //
CREATE TRIGGER `trg_actualizar_estado_solicitud_evaluada`
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
    -- 'Observado': queda en seguimiento por el evaluador.
    UPDATE `solicitudes`
       SET `estado` = 'En Evaluacion'
     WHERE `id_solicitud` = NEW.`id_solicitud`;
  END IF;
END //

DELIMITER ;

-- ============================================================================
-- 4. DATOS DE PRUEBA (SEEDS)
-- Los `password_hash` son hashes bcrypt de prueba compatibles con
-- password_verify() de PHP (generados con password_hash(), costo 10):
--   admin@bicentenario.bo     -> clave: Admin123*
--   evaluador@bicentenario.bo -> clave: Evaluador123*
--   estudiante@bicentenario.bo -> clave: Estudiante123*
-- NOTA DEFENSA: regenerar con password_hash($clave, PASSWORD_DEFAULT) en prod.
-- ============================================================================

-- -- 4.1 Al menos 3 usuarios iniciales (Admin, Evaluador y Estudiante) --
INSERT INTO `usuarios` (`nombre_completo`, `correo`, `password_hash`, `rol`) VALUES
('Ada Administradora', 'admin@bicentenario.bo', '$2y$10$xbBKHA5TwFGLLtEOBZ6Ie.cpgqPg8iOOMV59ZA9kQoN7SdOZbUHau', 'Administrador'),
('Eva Evaluadora', 'evaluador@bicentenario.bo', '$2y$10$CrNMy2NMvezYHRt.7NG9d.1s9p6upYy4.zQ/.Olc1cV7R3iOlvz5W', 'Evaluador'),
('Esteban Estudiante', 'estudiante@bicentenario.bo', '$2y$10$29eflBmwGweBR1xSticQxuGHE9CwMgo4ZbZQ8cp.HHE6nan9wYDaa', 'Estudiante');

-- -- 4.2 Al menos 2 registros en `solicitudes` (ambas del Estudiante id 3) --
INSERT INTO `solicitudes`
  (`id_usuario`, `institucion_educativa`, `carrera_o_bachillerato`, `promedio_academico`, `ingreso_familiar_mensual`, `estado`, `fecha_postulacion`) VALUES
(3, 'Universidad Mayor de San Andrés', 'Ingeniería de Sistemas', 92.50, 2500.00, 'Pendiente', NOW()),
(3, 'Colegio Nacional Ayacucho', 'Bachillerato en Ciencias', 88.75, 1800.00, 'Pendiente', NOW());

-- -- 4.3 Al menos 1 registro en `evaluaciones` --
-- Al insertar, el trigger `trg_actualizar_estado_solicitud_evaluada`
-- cambiará automáticamente solicitudes(id_solicitud=1) a 'Aprobada'.
INSERT INTO `evaluaciones`
  (`id_solicitud`, `id_evaluador`, `puntaje_socioeconomico`, `puntaje_academico`, `dictamen`, `observaciones`) VALUES
(1, 2, 85, 92, 'Favorable', 'Evaluación de prueba: situación socioeconómica vulnerable y excelente rendimiento académico. Se recomienda aprobación.');

-- -- 4.4 Al menos 1 registro en `becas` (vinculado a la solicitud aprobada id 1) --
INSERT INTO `becas`
  (`id_solicitud`, `codigo_beca`, `monto_mensual`, `tipo_beca`, `estado_beca`, `fecha_asignacion`) VALUES
(1, 'BEC-2026-001', 1200.00, 'Excelencia Académica', 'Activa', CURDATE());
