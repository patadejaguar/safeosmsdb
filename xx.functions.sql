SET GLOBAL log_bin_trust_function_creators = 1;

-- Abril/2016

DELIMITER $$

DROP FUNCTION IF EXISTS `mask`$$

CREATE FUNCTION mask (unformatted_value BIGINT, format_string CHAR(32))
	RETURNS CHAR(32) DETERMINISTIC

BEGIN

DECLARE input_len TINYINT;
DECLARE output_len TINYINT;
DECLARE temp_char CHAR;


SET input_len = LENGTH(unformatted_value);
SET output_len = LENGTH(format_string);


WHILE ( output_len > 0 ) DO

SET temp_char = SUBSTR(format_string, output_len, 1);
IF ( temp_char = '#' ) THEN
IF ( input_len > 0 ) THEN
SET format_string = INSERT(format_string, output_len, 1, SUBSTR(unformatted_value, input_len, 1));
SET input_len = input_len - 1;
ELSE
SET format_string = INSERT(format_string, output_len, 1, '0');
END IF;
END IF;

SET output_len = output_len - 1;
END WHILE;

RETURN format_string;
END $$

DELIMITER ;



DELIMITER $$

DROP FUNCTION IF EXISTS `getReciboByMorphedAnterior`$$

CREATE FUNCTION `getReciboByMorphedAnterior`(XLRecibo CHAR(30)) RETURNS INT(20)
BEGIN
	DECLARE SLRecibo INT(20) DEFAULT 0;
		SET	XLRecibo	= REPLACE(XLRecibo, "TMP_", "");
		SET SLRecibo	= (SELECT field_id2 FROM general_tmp WHERE field_id1=XLRecibo);
		IF ISNULL(SLRecibo) THEN
			SET SLRecibo = getUltimoRecibo();
		END IF;
	RETURN SLRecibo;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getSucursalBySocio`$$

CREATE FUNCTION `getSucursalBySocio`(IDSocio BIGINT(20)) RETURNS CHAR(20)
BEGIN
	DECLARE IDSucursal CHAR(20) DEFAULT "matriz";
	SET IDSucursal = (SELECT sucursal FROM socios_general WHERE codigo=IDSocio LIMIT 0,1);
		IF ISNULL(IDSucursal) THEN
			SET IDSucursal = "otra";
		END IF;
	RETURN IDSucursal;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getSucursalByUser`$$

CREATE FUNCTION `getSucursalByUser`(UserCode INT(4)) RETURNS CHAR(20)
BEGIN
	DECLARE RetSucursal CHAR(20) DEFAULT "matriz";
	 SET RetSucursal =(SELECT sucursal FROM t_03f996214fba4a1d05a68b18fece8e71 WHERE idusuarios=UserCode);
		IF ISNULL(RetSucursal) THEN
			SET RetSucursal = "matriz";
		END IF;
	RETURN RetSucursal;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getUltimoRecibo`$$

CREATE FUNCTION `getUltimoRecibo`() RETURNS INT(20)
BEGIN
	
	DECLARE intUltimoRecibo INT(20) DEFAULT 0;
	SET intUltimoRecibo = (SELECT MAX(numerorecibo) FROM general_folios);
	SET intUltimoRecibo = intUltimoRecibo + 1;
	
	INSERT INTO general_folios(numerorecibo) VALUES (intUltimoRecibo);
	RETURN intUltimoRecibo;
    END$$

DELIMITER ;



DELIMITER $$

DROP FUNCTION IF EXISTS `getReciboByAnterior`$$

CREATE FUNCTION `getReciboByAnterior`(ReciboAnterior BIGINT(20)) RETURNS BIGINT(20)
BEGIN
	DECLARE ByRec BIGINT(20) DEFAULT 0;
	 SET ByRec = (SELECT field_id2 FROM general_tmp WHERE field_id1=ReciboAnterior );
		IF ISNULL(ByRec) THEN
			SET ByRec = 0;
		END IF;
	RETURN ByRec;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getMenuNameById`$$

CREATE FUNCTION `getMenuNameById`(mIndex INT(10)) RETURNS VARCHAR(45)
BEGIN
	DECLARE mNAME VARCHAR(45) DEFAULT "NINGUNO";
		SET mNAME = (SELECT menu_title FROM general_menu WHERE idgeneral_menu=mIndex);
		IF mNAME = "" OR ISNULL(mNAME) THEN
			SET mNAME = mIndex;
		END IF;

	RETURN mNAME;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getCompromisosByDocto`$$

CREATE FUNCTION `getCompromisosByDocto`(mSolicitud INT(10), mEstatus CHAR(20) ) RETURNS INT(4)
BEGIN
	RETURN (SELECT COUNT(idseguimiento_compromisos) AS 'exists' FROM seguimiento_compromisos	WHERE credito_comprometido= mSolicitud AND estatus_compromiso=mEstatus);
    END$$

DELIMITER ;



-- -- 
-- -- Si / No Espanniol
-- -- 

DELIMITER $$


DROP FUNCTION IF EXISTS `getBooleanMX`$$

CREATE FUNCTION `getBooleanMX`(BOOLVALUE CHAR(20)) RETURNS CHAR(4)
BEGIN
	DECLARE MBOOLEAN CHAR(4) DEFAULT "NO";
	IF BOOLVALUE = "1" THEN
		SET MBOOLEAN = "SI";
	ELSE
		SET MBOOLEAN = "NO";
	END IF;
	RETURN MBOOLEAN;
    END$$

DELIMITER ;


DELIMITER $$

DROP FUNCTION IF EXISTS `getMorphosRecibo`$$

CREATE FUNCTION `getMorphosRecibo`(XLRecibo CHAR(30), NLRecibo INT(20) ) RETURNS INT(20)
BEGIN
	
	SET	XLRecibo	= REPLACE(XLRecibo, "TMP_", "");
	INSERT INTO general_tmp(field_id1, field_id2) VALUES(XLRecibo, NLRecibo);
	
	RETURN NLRecibo;
    END$$

DELIMITER ;


DELIMITER $$

DROP FUNCTION IF EXISTS `getVencimientoAdministrativo`$$

CREATE FUNCTION `getVencimientoAdministrativo`(fecha_ministracion DATE, fecha_ultimo_mvto DATE,
periocidad_de_pago INT(6), pagos_autorizados INT(10), dias_autorizados INT(10))
	RETURNS DATE
    BEGIN
	DECLARE DVencimiento DATE DEFAULT fecha_ultimo_mvto;
		IF fecha_ultimo_mvto = fecha_ministracion THEN
			SET DVencimiento = DATE_ADD(fecha_ministracion, INTERVAL ( (dias_autorizados - (periocidad_de_pago *  pagos_autorizados) ) + periocidad_de_pago) DAY);
		ELSE
			SET DVencimiento = DATE_ADD(fecha_ultimo_mvto, INTERVAL (periocidad_de_pago + 1)  DAY);
		END IF;
		RETURN DVencimiento;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getRiskClassified`$$

CREATE

    FUNCTION `getRiskClassified`(vDias INTEGER(6) )  RETURNS INTEGER(6)
    BEGIN
	DECLARE vClassified INTEGER(6) DEFAULT 1;
		IF ISNULL(vDias) THEN
			SET vClassified = 9999;
		END IF;

		IF ( vDias <= 1 ) THEN
		  SET vClassified = 1;
		END IF;

		IF ( vDias > 1 AND vDias <=7 ) THEN
		  SET vClassified = 7;
		END IF;

		IF ( vDias > 7 AND vDias <= 30) THEN
		  SET vClassified = 30;
		END IF;
		IF ( vDias > 30 AND vDias <= 60) THEN
		  SET vClassified = 30;
		END IF;
		IF ( vDias > 60 AND vDias <= 90 ) THEN
		  SET vClassified = 90;
		END IF;   
             		
		IF ( vDias > 90 AND vDias <= 120 ) THEN
		  SET vClassified = 120;
		END IF;

		IF ( vDias > 120 AND vDias <= 180 ) THEN
		  SET vClassified = 180;
		END IF;

		IF ( vDias > 180) THEN
		  SET vClassified = 9999;
		END IF;

	RETURN vClassified;
    END$$

DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `getInteresDevengadoNormal`$$

CREATE
    FUNCTION `getInteresDevengadoNormal`(vSaldoHistorico 	FLOAT(16,2), 
							vSaldoInsoluto 		FLOAT(16,2),
							vTasaInteres		FLOAT(6,4),
							vTipoDeCalculo 		INT(2),
							vFechaDeCalculo 	DATE,
							vFechaDeVencimiento 	DATE)
    RETURNS FLOAT(12,2)
    BEGIN
	DECLARE RINTERES FLOAT(12,2) DEFAULT 0;
	IF ( vFechaDeVencimiento >= vFechaDeCalculo ) THEN
		/* SI ES SALDO HISTORICO */
		IF vTipoDeCalculo = 1 THEN
			SET RINTERES = (vSaldoHistorico * vTasaInteres) / 360;
		ELSE
			SET RINTERES = (vSaldoInsoluto * vTasaInteres) / 360;
		END IF;
	END IF;
	RETURN RINTERES;
    END$$

DELIMITER ;

-- - Funcion que obtiene un nombre de usuario por Id

DELIMITER $$

DROP FUNCTION IF EXISTS `getUserByID`$$

CREATE FUNCTION `getUserByID`(UsrID VARCHAR(100) )
	RETURNS VARCHAR(100)
    BEGIN
	DECLARE NUser VARCHAR(100);
	
	IF UsrID = 'USUARIO_DESCONOCIDO' THEN
		SET UsrID =	'0';
	END IF;
	
	SET UsrID = CONVERT(UsrID, UNSIGNED);
	
	SET NUser = (SELECT nombrecompleto FROM usuarios WHERE idusuarios = UsrID);
	IF ISNULL(NUser) THEN
		SET NUser = "_NO_REGISTRADO_";
	END IF;
	RETURN NUser;
    END$$

DELIMITER ;

-- - Funcion que retorna Cero si es menor a Cero

DELIMITER $$

DROP FUNCTION IF EXISTS `setNoMenorCero`$$

CREATE FUNCTION `setNoMenorCero`(mCantidad FLOAT(16,2) ) RETURNS FLOAT(16,2)
BEGIN
	IF (mCantidad < 0) THEN
		RETURN 0;
	ELSE
		RETURN mCantidad;
	END IF;
    END$$

DELIMITER ;
-- - Funcion para Obtener la Ultima Operacion
-- - Actualizado al 2011-oct-02
DELIMITER $$

DROP FUNCTION IF EXISTS `getUltimaOperacion`$$

CREATE FUNCTION `getUltimaOperacion`() RETURNS INT(20)
BEGIN
	
	DECLARE intUltOperacion INT(20) DEFAULT 0;
	DECLARE intNumsFolios INT(20) DEFAULT 0;
	SET intUltOperacion = (SELECT MAX(numerooperacion) FROM general_folios) + 1;
	SET intNumsFolios	= ( SELECT COUNT(idgeneral_folios) FROM general_folios );
	IF intNumsFolios > 4000 THEN
		SET intNumsFolios = ( SELECT setFoliosAlMaximo() );
	END IF;
	INSERT INTO general_folios(numerooperacion) VALUES (intUltOperacion);
	RETURN intUltOperacion;
    END$$

DELIMITER ;
-- - Función para Obtener la Suma por Socio de un Tipo de Captacion
DELIMITER $$
DROP FUNCTION IF EXISTS `getCaptacionSocioByTipo`$$
CREATE
    FUNCTION `getCaptacionSocioByTipo`(IDSocio BIGINT(20), mTipo TINYINT(3) ) RETURNS FLOAT(12,2)
    BEGIN
	DECLARE mMonto FLOAT(12,2);
	SET mMonto = (SELECT SUM(saldo_cuenta) AS 'monto' FROM captacion_cuentas WHERE numero_socio= IDSocio AND tipo_cuenta= mTipo GROUP BY numero_socio);
	IF ISNULL(mMonto) THEN
		SET mMonto = 0;
	END IF;
	RETURN mMonto;
    END$$

DELIMITER ;
-- - Funciones mas

-- - Funcion que obtiene el Monto del Credito COMPACW
DELIMITER $$

DROP FUNCTION IF EXISTS `getCreditosCompac`$$

CREATE FUNCTION `getCreditosCompac`(IDSocio BIGINT(20)) RETURNS FLOAT(12,2)
BEGIN
	DECLARE mCreditos FLOAT(12,2) DEFAULT 0;
	SET mCreditos = (SELECT saldos FROM migracion_compac_creditos WHERE numero_de_socio = IDSocio LIMIT 0,1);
		IF ISNULL(mCreditos) THEN
			SET mCreditos = 0;
		END IF;
	RETURN mCreditos;
    END$$

DELIMITER ;

-- - Funciones 02Oct2011
-- - Funcion que executa folios al Maximo
-- - Correccion: 09 de Abril de 2012
-- - @fix : Alta prioridad
DELIMITER $$


DROP FUNCTION IF EXISTS `setFoliosAlMaximo`$$
CREATE FUNCTION  `setFoliosAlMaximo`() RETURNS TINYINT(1)
BEGIN
	CALL `sp_setFoliosAlMaximo`();
RETURN TRUE;
END$$

DELIMITER ;
-- - Cuenta Contable Formateada
-- - Modificado el 17Oct2011
DELIMITER $$

DROP FUNCTION IF EXISTS `setCuentaFmt`$$

CREATE FUNCTION `setCuentaFmt`(vCUENTA CHAR(32)) RETURNS CHAR(32)
BEGIN
DECLARE mMask CHAR(32) DEFAULT '';
	SET mMask = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'mascara_sql_de_cuenta_contable' LIMIT 0,1);
	RETURN mask(vCUENTA,mMask);
    END$$

DELIMITER ;

-- - Obtiene el recibo en un corte, el monto pagado
-- - 12mayo2012
DELIMITER $$

DROP FUNCTION IF EXISTS `getReciboEnCorte`$$

CREATE FUNCTION `getReciboEnCorte`(IdRecibo BIGINT(20) ) RETURNS FLOAT
BEGIN
DECLARE mMonto FLOAT(16,2) DEFAULT 0;
	SET mMonto = (SELECT pagado  FROM tesoreria_recibos_pagados WHERE recibo = IdRecibo LIMIT 0,1);
	IF ISNULL(mMonto) THEN
	SET mMonto = 0;
	END IF;
	RETURN mMonto;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getEsCancelado`$$

CREATE FUNCTION `getEsCancelado`(ClaveDeCredito BIGINT(20) )
    RETURNS INT

   BEGIN
	DECLARE intIsC INT(4) DEFAULT 0;
	SET intIsC = (SELECT COUNT(`idcreditos_rechazados`) FROM `creditos_rechazados` WHERE `numero_de_credito` = ClaveDeCredito);
	RETURN intIsC;
	
    END$$

DELIMITER ;

-- 08-octubre-2013
DELIMITER $$

DROP FUNCTION IF EXISTS `getFechaPrimeraLetra`$$

CREATE FUNCTION `getFechaPrimeraLetra`(vCredito BIGINT) RETURNS DATE
BEGIN
	DECLARE DVencimiento DATE DEFAULT CURDATE();
	RETURN (SELECT fecha_de_pago FROM primeras_letras WHERE docto_afectado = vCredito LIMIT 0,1);
    END$$

DELIMITER ;


-- 11-Octubre2013
-- Fix 16/06/2021

DELIMITER $$

DROP FUNCTION IF EXISTS `getFechaMX`$$

CREATE FUNCTION `getFechaMX`(mFecha VARCHAR(15)) RETURNS VARCHAR(20) CHARSET latin1
BEGIN
	DECLARE mFechaValida DATE;
	 -- DECLARE EXIT HANDLER FOR SQLSTATE '1292' RETURN NULL;
	IF mFecha = '0000-00-00' THEN
		RETURN '';
	END IF;
	SET mFechaValida = CAST(mFecha AS DATE);
	
	RETURN DATE_FORMAT(mFechaValida, "%d/%b/%y");
    END$$

DELIMITER ;

-- SET lc_time_names = 'es_MX';

-- comp SELECT * FROM creditos_solicitud WHERE (SELECT COUNT(idcreditos_destinos) FROM creditos_destinos WHERE idcreditos_destinos=creditos_solicitud.destino_credito) =0


DELIMITER $$

DROP FUNCTION IF EXISTS `getFechaByInt`$$

CREATE FUNCTION `getFechaByInt`(mFecha BIGINT) RETURNS DATE
BEGIN
	RETURN FROM_UNIXTIME(mFecha);
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `getFechaMXByInt`$$

CREATE FUNCTION `getFechaMXByInt`(mFecha BIGINT) RETURNS VARCHAR(20) CHARSET latin1
BEGIN
	RETURN DATE_FORMAT(FROM_UNIXTIME(mFecha), "%d/%b/%y");
    END$$

DELIMITER ;

-- --------------------------------------------------------------------


DELIMITER $$

DROP FUNCTION IF EXISTS `getSaldoInverso`$$

CREATE FUNCTION `getSaldoInverso`(ActualID BIGINT, AnteriorID BIGINT, SaldoArrastrado FLOAT(16,2), AbonoActual FLOAT(16,2))
    RETURNS FLOAT(16,2)

    BEGIN
	DECLARE Saldo FLOAT(16,2) DEFAULT 0;
	
	IF ISNULL(AnteriorID) THEN
		SET AnteriorID	= ActualID;
		SET SaldoArrastrado = NULL;
	END IF;
	IF AnteriorID <> ActualID THEN
		SET AnteriorID	= ActualID;
		SET SaldoArrastrado = NULL;
	END IF;
	
	IF ISNULL(SaldoArrastrado) THEN
		SET SaldoArrastrado	= (SELECT letra FROM letras_pendientes WHERE docto_afectado=ActualID LIMIT 0,1 );
	END IF;
	
	SET Saldo		= SaldoArrastrado - AbonoActual;	
	
	IF Saldo < 0 THEN
		SET @SaldoActual	= NULL;
		SET @CreditoActual	= NULL;
		SET Saldo		= 0;
	ELSE
		SET @SaldoActual	= Saldo;
		SET @CreditoActual	= ActualID;
	END IF;
			

	RETURN Saldo;
    END$$

DELIMITER ;

-- ----------------------

DELIMITER $$


DROP FUNCTION IF EXISTS `getParcialidadPorFecha`$$


CREATE FUNCTION `getParcialidadPorFecha`(ParcialidadID INT, VariacionID INT, FechaActual DATE, FechaPago DATE, FechaMinistracion DATE )
    RETURNS INT
    BEGIN
	DECLARE mPARC INT DEFAULT 1;
	IF ParcialidadID = 0 THEN
		IF FechaPago > FechaActual THEN
			IF FechaMinistracion > FechaActual THEN
				SET mPARC	= ParcialidadID + 1;
			ELSE
				SET mPARC	= ParcialidadID;
			END IF;
		END IF;
	ELSE 
		SET mPARC	= ParcialidadID + 1 + VariacionID;
	END IF;
	
	RETURN mPARC;
    END$$

DELIMITER ;


-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_saldos_al_cierre`$$

CREATE PROCEDURE `sp_saldos_al_cierre` (vDate DATE)
BEGIN

SELECT
	`creditos_solicitud`.`numero_solicitud`,
	`creditos_solicitud`.`fecha_solicitud`,
	`creditos_solicitud`.`fecha_autorizacion`,
	`creditos_solicitud`.`monto_solicitado`,
	`creditos_solicitud`.`monto_autorizado`,
	`creditos_solicitud`.`numero_socio`,
	`creditos_solicitud`.`docto_autorizacion`,
	`creditos_solicitud`.`plazo_en_dias`,
	`creditos_solicitud`.`numero_pagos`,
	`creditos_solicitud`.`tasa_interes`,
	`creditos_solicitud`.`periocidad_de_pago`,
	`creditos_solicitud`.`tipo_credito`,
	`creditos_solicitud`.`estatus_actual`,
	`creditos_solicitud`.`tipo_autorizacion`,
	`creditos_solicitud`.`oficial_credito`,
	`creditos_solicitud`.`fecha_vencimiento`,
	`creditos_solicitud`.`pagos_autorizados`,
	`creditos_solicitud`.`dias_autorizados`,
	`creditos_solicitud`.`periodo_solicitudes`,
	`creditos_solicitud`.`destino_credito`,
	`creditos_solicitud`.`idusuario`,
	`creditos_solicitud`.`nivel_riesgo`,
	`creditos_solicitud`.`saldo_actual`,
	`creditos_solicitud`.`fecha_ultimo_mvto`,
	`creditos_solicitud`.`tipo_convenio`,
	`creditos_solicitud`.`interes_diario`,
	`creditos_solicitud`.`ultimo_periodo_afectado`,
	`creditos_solicitud`.`tasa_moratorio`,
	`creditos_solicitud`.`observacion_solicitud`,
	`creditos_solicitud`.`tasa_ahorro`,
	`creditos_solicitud`.`grupo_asociado`,
	`creditos_solicitud`.`descripcion_aplicacion`,
	`creditos_solicitud`.`fecha_ministracion`,
	`creditos_solicitud`.`contrato_corriente_relacionado`,
	`creditos_solicitud`.`monto_parcialidad`,
	`creditos_solicitud`.`oficial_seguimiento`,
	`creditos_solicitud`.`sucursal`,
	`creditos_solicitud`.`interes_normal_devengado`,
	`creditos_solicitud`.`tipo_de_pago`,
	`creditos_solicitud`.`interes_normal_pagado`,
	`creditos_solicitud`.`interes_moratorio_devengado`,
	`creditos_solicitud`.`interes_moratorio_pagado`,
	`creditos_solicitud`.`fecha_mora`,
	`creditos_solicitud`.`fecha_vencimiento_dinamico`,
	`creditos_solicitud`.`causa_de_mora`,
	`creditos_solicitud`.`estatus_de_negociacion`,
	`creditos_solicitud`.`tipo_de_calculo_de_interes`,
	`creditos_solicitud`.`persona_asociada`,
	`creditos_solicitud`.`perfil_de_intereses`,
	`creditos_solicitud`.`fuente_de_fondeo`,
	`creditos_solicitud`.`fecha_de_primer_pago`,
	COUNT(`operaciones_mvtos`.`tipo_operacion`) AS `operaciones`,
	MAX(`operaciones_mvtos`.`fecha_afectacion`) AS `fecha`,
	SUM(`operaciones_mvtos`.`afectacion_real`)  AS `abonos`,
	(`creditos_solicitud`.`monto_autorizado` - SUM(`operaciones_mvtos`.`afectacion_real`))  AS `saldo`
FROM
	`operaciones_mvtos` `operaciones_mvtos` 
		RIGHT OUTER JOIN `creditos_solicitud` `creditos_solicitud` 
		ON `operaciones_mvtos`.`docto_afectado` = `creditos_solicitud`.
		`numero_solicitud` 
			INNER JOIN `operaciones_recibos` `operaciones_recibos` 
			ON `operaciones_mvtos`.`recibo_afectado` = `operaciones_recibos`.
			`idoperaciones_recibos` 
WHERE
	(`operaciones_mvtos`.`tipo_operacion` =120) AND
	(`operaciones_mvtos`.`fecha_afectacion` <= vDate) 
GROUP BY
	`operaciones_mvtos`.`docto_afectado`;


END$$

DELIMITER ;

/* Equivalencia de monedas */

DELIMITER $$
DROP FUNCTION IF EXISTS `getEquivalenciaDeMonedas`$$
CREATE
    FUNCTION `getEquivalenciaDeMonedas`(vMonto FLOAT(16,4), vMoneda VARCHAR(4))
    RETURNS FLOAT
    BEGIN
	DECLARE mValor FLOAT(12,4) DEFAULT 0.00;
	DECLARE mDollar FLOAT(12,4) DEFAULT 0.00;
	DECLARE mEquiv FLOAT(12,4) DEFAULT 0.00;
	SET mValor = (SELECT `quivalencia_en_moneda_local`  FROM `tesoreria_monedas` WHERE `clave_de_moneda` = vMoneda LIMIT 0,1);
	SET mDollar = (SELECT `quivalencia_en_moneda_local`  FROM `tesoreria_monedas` WHERE `clave_de_moneda` = 'USD' LIMIT 0,1);
	IF ISNULL(mValor) THEN
		SET mEquiv	= vMonto * mDollar;
	ELSE
		SET mEquiv	= vMonto * mValor;
	END IF;
	RETURN mEquiv;
    END$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS getMonedaLocal$$
CREATE

    FUNCTION `getMonedaLocal`()
    RETURNS CHAR(4)
    BEGIN
	DECLARE mMon CHAR(4) DEFAULT 'MXN';
		SET mMon = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'aml_clave_de_moneda_local' LIMIT 0,1);
	RETURN mMon;
    END$$

DELIMITER ;

DELIMITER $$

-- Obtiene el saldo de una Letra a un dia determinado
-- 

DROP FUNCTION IF EXISTS `getSaldoPendienteDesdeLetra`$$

CREATE  FUNCTION `getSaldoPendienteDesdeLetra`(CreditID BIGINT(20), PeriodoID INT(4) ) RETURNS FLOAT(16,2)
BEGIN
	DECLARE mMONTO FLOAT(16,2);
	SET mMONTO = (SELECT ROUND(SUM((`operaciones_mvtos`.`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`)),2)
FROM
	`operaciones_mvtos` `operaciones_mvtos` 
		INNER JOIN `creditos_solicitud` `creditos_solicitud` 
		ON `operaciones_mvtos`.`docto_afectado` = `creditos_solicitud`.
		`numero_solicitud` 
			INNER JOIN `eacp_config_bases_de_integracion_miembros` 
			`eacp_config_bases_de_integracion_miembros` 
			ON `operaciones_mvtos`.`tipo_operacion` = 
			`eacp_config_bases_de_integracion_miembros`.`miembro`
WHERE (`eacp_config_bases_de_integracion_miembros`.`codigo_de_base` = 2601)
AND `operaciones_mvtos`.`docto_afectado`=CreditID AND `operaciones_mvtos`.`periodo_socio`>PeriodoID
AND `operaciones_mvtos`.`tipo_operacion` != 420
AND `operaciones_mvtos`.`tipo_operacion` != 431
AND `operaciones_mvtos`.`tipo_operacion` != 146
GROUP BY `operaciones_mvtos`.`docto_afectado`
ORDER BY `eacp_config_bases_de_integracion_miembros`.`codigo_de_base`,`operaciones_mvtos`.`docto_afectado`, `operaciones_mvtos`.`periodo_socio`);
	
	IF ISNULL(mMONTO) THEN
		SET mMONTO = 0;
	END IF;
	RETURN mMONTO;
    END$$

DELIMITER ;
-- --------------------------------------- Listado de Ingresos
-- TODO: Modificar esta seccion
DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_listado_de_ingresos`$$

CREATE PROCEDURE `proc_listado_de_ingresos`()
BEGIN

UPDATE `operaciones_recibos` SET persona_asociada = getEmpresaPorDefecto() WHERE persona_asociada < getEmpresaPorDefecto();

DROP TABLE IF EXISTS `tmp_recibos_datos_bancarios`;

CREATE TABLE `tmp_recibos_datos_bancarios` AS SELECT
  `bancos_operaciones`.`recibo_relacionado` AS `recibo`,
  COUNT(`bancos_operaciones`.`idcontrol`)   AS `operaciones`,
  MAX(`bancos_operaciones`.`cuenta_bancaria`) AS `banco`,
  MAX(`bancos_operaciones`.`fecha_expedicion`) AS `fecha`,
  SUM(`bancos_operaciones`.`monto_real`)    AS `monto`
FROM `bancos_operaciones`
GROUP BY `bancos_operaciones`.`recibo_relacionado`;
ALTER TABLE `tmp_recibos_datos_bancarios` ADD INDEX `indexm` (`recibo` ASC, `banco` ASC);

-- DROP VIEW IF EXISTS `listado_de_ingresos`;
DROP TABLE IF EXISTS `listado_de_ingresos`;

CREATE TABLE `listado_de_ingresos` AS  
SELECT 
  `socios`.`iddependencia`                     AS `clave_empresa`,
  `socios`.`dependencia`                       AS `empresa`,
  `socios`.`codigo`                            AS `codigo`,
  `socios`.`nombre`                            AS `nombre`,
  `socios`.`sucursal`                          AS `sucursal`,
  `creditos_solicitud`.`tipo_convenio`         AS `producto`,
  `creditos_solicitud`.`numero_solicitud`      AS `credito`,
  `operaciones_mvtos`.`fecha_afectacion`        AS `fecha`,
  `operaciones_tipos`.`tipo_operacion`         AS `clave_de_operacion`,
  `operaciones_tipos`.`descripcion_operacion`  AS `operacion`,
  (IF(`eacp_config_bases_de_integracion_miembros`.`subclasificacion` = 2003,`operaciones_mvtos`.`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`,0)) AS `capital`,
  (IF(`eacp_config_bases_de_integracion_miembros`.`subclasificacion` = 2110,`operaciones_mvtos`.`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`,0)) AS `interes_normal`,
  (IF(`eacp_config_bases_de_integracion_miembros`.`subclasificacion` = 2210,`operaciones_mvtos`.`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`,0)) AS `interes_moratorio`,

  (IF(`eacp_config_bases_de_integracion_miembros`.`subclasificacion` = 7021,`operaciones_mvtos`.`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`,0)) AS `iva`,

  (IF(`eacp_config_bases_de_integracion_miembros`.`subclasificacion` = 10001,`operaciones_mvtos`.`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`,0)) AS `otros`,
  `operaciones_recibos`.`tipo_pago`            AS `tipo_de_pago`,
  `operaciones_mvtos`.`periodo_socio`          AS `parcialidad`,
	`creditos_solicitud`.`periocidad_de_pago`      AS `periocidad`,
`tmp_recibos_datos_bancarios`.`banco`,

`creditos_solicitud`.`oficial_seguimiento` AS `oficial_de_seguimiento`,
`creditos_solicitud`.`oficial_credito`     AS `oficial_de_credito`,
`operaciones_recibos`.`persona_asociada`            AS `persona_asociada`

FROM 

	`operaciones_recibos` `operaciones_recibos` 
		LEFT OUTER JOIN `tmp_recibos_datos_bancarios` `tmp_recibos_datos_bancarios` 
		ON `operaciones_recibos`.`idoperaciones_recibos` = 
		`tmp_recibos_datos_bancarios`.`recibo` 
			INNER JOIN `operaciones_mvtos` `operaciones_mvtos` 
			ON `operaciones_mvtos`.`recibo_afectado` = `operaciones_recibos`.
			`idoperaciones_recibos` 
				INNER JOIN `creditos_solicitud` `creditos_solicitud` 
				ON `operaciones_mvtos`.`docto_afectado` = `creditos_solicitud`.
				`numero_solicitud` 

					INNER JOIN `socios` `socios` 
					-- ON `creditos_solicitud`.`numero_socio` = `socios`.`codigo` 
						ON `operaciones_recibos`.`numero_socio` = `socios`.`codigo` 

						INNER JOIN `operaciones_tipos` `operaciones_tipos` 
						ON `operaciones_mvtos`.`tipo_operacion` = 
						`operaciones_tipos`.`idoperaciones_tipos` 
							INNER JOIN 
							`eacp_config_bases_de_integracion_miembros` 
							`eacp_config_bases_de_integracion_miembros` 
							ON `operaciones_tipos`.`idoperaciones_tipos` = 
							`eacp_config_bases_de_integracion_miembros`.
							`miembro` 
								INNER JOIN `operaciones_recibostipo` 
								`operaciones_recibostipo` 
								ON `operaciones_recibos`.`tipo_docto` = 
								`operaciones_recibostipo`.
								`idoperaciones_recibostipo`

WHERE ((`eacp_config_bases_de_integracion_miembros`.`codigo_de_base` = 10001)
	AND (`operaciones_recibostipo`.`mostrar_en_corte` <> '0')
	AND (`operaciones_mvtos`.`fecha_operacion` >= CONCAT((getEjercicioDeTrabajo()-3),'-01-01') )
)
ORDER BY `eacp_config_bases_de_integracion_miembros`.`codigo_de_base`,`operaciones_mvtos`.`fecha_operacion`,`socios`.`iddependencia`,`socios`.`nombre` ;

ALTER TABLE `listado_de_ingresos` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `banco`, ADD PRIMARY KEY (`indice`);
UPDATE `listado_de_ingresos` SET `banco` = 0 WHERE ISNULL(`banco`);
UPDATE `listado_de_ingresos` SET `clave_empresa` = `persona_asociada`, `empresa`=(SELECT IF(`nombre_corto` = '', `descripcion_dependencia`, `nombre_corto`) FROM `socios_aeconomica_dependencias` WHERE `idsocios_aeconomica_dependencias`=`listado_de_ingresos`.`persona_asociada`);

ALTER TABLE `listado_de_ingresos` ADD INDEX `persona` (`codigo`), ADD INDEX `credito` (`credito`), ADD INDEX `empresa` (`clave_empresa`), ADD INDEX `banco` (`banco`);

END$$

DELIMITER ;

-- -- Historial de pagos

DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_historial_de_pagos`$$

CREATE PROCEDURE `proc_historial_de_pagos`()
BEGIN

-- DROP VIEW IF EXISTS historial_de_pagos;
DROP TABLE IF EXISTS historial_de_pagos;

CREATE TABLE historial_de_pagos AS  
SELECT 
	`operaciones_mvtos`.`socio_afectado` AS `persona`,
	`operaciones_mvtos`.`docto_afectado` AS `credito` ,
	`operaciones_mvtos`.`periodo_socio`  AS `periodo` ,
	MAX(`operaciones_mvtos`.`fecha_afectacion`) AS `fecha`,
	MAX(IF(`tipo_operacion` =120, `operaciones_mvtos`.`recibo_afectado`, 0)) AS `recibo`,
	SUM( IF(`tipo_operacion` =410, `operaciones_mvtos`.`afectacion_real`, 0)) AS `capital`,
	SUM( IF(`tipo_operacion` =120, `operaciones_mvtos`.`afectacion_real`, 0)) AS `pagos`,
	SUM( IF(`tipo_operacion` =140, `operaciones_mvtos`.`afectacion_real`, 0)) AS `interes_pagado`,
	SUM( IF(`tipo_operacion` =411, `operaciones_mvtos`.`afectacion_real`, 0)) AS `interes`
	

FROM
	`operaciones_mvtos` `operaciones_mvtos` 
WHERE
	(`operaciones_mvtos`.`tipo_operacion` =120 OR `operaciones_mvtos`.`tipo_operacion` =410 OR `operaciones_mvtos`.`tipo_operacion` =411 OR `operaciones_mvtos`.`tipo_operacion` =140   )
GROUP BY
	`operaciones_mvtos`.`docto_afectado`,
	`operaciones_mvtos`.`periodo_socio`	
ORDER BY
	`operaciones_mvtos`.`docto_afectado`, 
	`operaciones_mvtos`.`periodo_socio` ;

ALTER TABLE `historial_de_pagos` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `pagos`, ADD PRIMARY KEY (`indice`);

ALTER TABLE `historial_de_pagos` ADD INDEX `persona` (`persona`), ADD INDEX `credito` (`credito`), ADD INDEX `periodo` (`periodo`);

END$$

DELIMITER ;





DELIMITER $$

DROP FUNCTION IF EXISTS `func_DoubleMetaphone`$$
CREATE FUNCTION `func_DoubleMetaphone`(st VARCHAR(55)) RETURNS varchar(128) CHARSET utf8
    NO SQL
BEGIN
    DECLARE length, first, last, pos, prevpos, is_slavo_germanic SMALLINT;
    DECLARE pri, sec VARCHAR(45) DEFAULT '';
    DECLARE ch CHAR(1);
                    SET first = 3;
    SET length = CHAR_LENGTH(st);
    SET last = first + length -1;
    SET st = CONCAT(REPEAT('-', first -1), UCASE(st), REPEAT(' ', 5));  SET is_slavo_germanic = (st LIKE '%W%' OR st LIKE '%K%' OR st LIKE '%CZ%');     SET pos = first;        IF SUBSTRING(st, first, 2) IN ('GN', 'KN', 'PN', 'WR', 'PS') THEN
        SET pos = pos + 1;
    END IF;
        IF SUBSTRING(st, first, 1) = 'X' THEN
        SET pri = 'S', sec = 'S', pos = pos  + 1;   END IF;
        WHILE pos <= last DO
            SET prevpos = pos;
        SET ch = SUBSTRING(st, pos, 1);         CASE
        WHEN ch IN ('A', 'E', 'I', 'O', 'U', 'Y') THEN
            IF pos = first THEN                 SET pri = CONCAT(pri, 'A'), sec = CONCAT(sec, 'A'), pos = pos  + 1;             ELSE
                SET pos = pos + 1;
            END IF;
        WHEN ch = 'B' THEN
                        IF SUBSTRING(st, pos+1, 1) = 'B' THEN
                SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos  + 1;             END IF;
        WHEN ch = 'C' THEN
                        IF (pos > (first + 1) AND SUBSTRING(st, pos-2, 1) NOT IN ('A', 'E', 'I', 'O', 'U', 'Y') AND SUBSTRING(st, pos-1, 3) = 'ACH' AND
               (SUBSTRING(st, pos+2, 1) NOT IN ('I', 'E') OR SUBSTRING(st, pos-2, 6) IN ('BACHER', 'MACHER'))) THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                         ELSEIF pos = first AND SUBSTRING(st, first, 6) = 'CAESAR' THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos  + 2;             ELSEIF SUBSTRING(st, pos, 4) = 'CHIA' THEN              SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;             ELSEIF SUBSTRING(st, pos, 2) = 'CH' THEN
                                IF pos > first AND SUBSTRING(st, pos, 4) = 'CHAE' THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'X'), pos = pos  + 2;                 ELSEIF pos = first AND (SUBSTRING(st, pos+1, 5) IN ('HARAC', 'HARIS') OR
                   SUBSTRING(st, pos+1, 3) IN ('HOR', 'HYM', 'HIA', 'HEM')) AND SUBSTRING(st, first, 5) != 'CHORE' THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                                 ELSEIF SUBSTRING(st, first, 4) IN ('VAN ', 'VON ') OR SUBSTRING(st, first, 3) = 'SCH'
                   OR SUBSTRING(st, pos-2, 6) IN ('ORCHES', 'ARCHIT', 'ORCHID')
                   OR SUBSTRING(st, pos+2, 1) IN ('T', 'S')
                   OR ((SUBSTRING(st, pos-1, 1) IN ('A', 'O', 'U', 'E') OR pos = first)
                   AND SUBSTRING(st, pos+2, 1) IN ('L', 'R', 'N', 'M', 'B', 'H', 'F', 'V', 'W', ' ')) THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                 ELSE
                    IF pos > first THEN
                        IF SUBSTRING(st, first, 2) = 'MC' THEN
                            SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                         ELSE
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                         END IF;
                    ELSE
                        SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos  + 2;                     END IF;
                END IF;
                        ELSEIF SUBSTRING(st, pos, 2) = 'CZ' AND SUBSTRING(st, pos-2, 4) != 'WICZ' THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X'), pos = pos  + 2;                         ELSEIF SUBSTRING(st, pos+1, 3) = 'CIA' THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos  + 3;                         ELSEIF SUBSTRING(st, pos, 2) = 'CC' AND NOT (pos = (first +1) AND SUBSTRING(st, first, 1) = 'M') THEN
                                IF SUBSTRING(st, pos+2, 1) IN ('I', 'E', 'H') AND SUBSTRING(st, pos+2, 2) != 'HU' THEN
                                        IF (pos = first +1 AND SUBSTRING(st, first) = 'A') OR
                       SUBSTRING(st, pos-1, 5) IN ('UCCEE', 'UCCES') THEN
                        SET pri = CONCAT(pri, 'KS'), sec = CONCAT(sec, 'KS'), pos = pos  + 3;                                       ELSE
                        SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos  + 3;                     END IF;
                ELSE
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                 END IF;
            ELSEIF SUBSTRING(st, pos, 2) IN ('CK', 'CG', 'CQ') THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;             ELSEIF SUBSTRING(st, pos, 2) IN ('CI', 'CE', 'CY') THEN
                                IF SUBSTRING(st, pos, 3) IN ('CIO', 'CIE', 'CIA') THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X'), pos = pos  + 2;                 ELSE
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos  + 2;                 END IF;
            ELSE 
                                IF SUBSTRING(st, pos+1, 2) IN (' C', ' Q', ' G') THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 3;                 ELSE
                    IF SUBSTRING(st, pos+1, 1) IN ('C', 'K', 'Q') AND SUBSTRING(st, pos+1, 2) NOT IN ('CE', 'CI') THEN
                        SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                     ELSE                        SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 1;                     END IF;
                END IF;
            END IF;
                            WHEN ch = 'D' THEN
            IF SUBSTRING(st, pos, 2) = 'DG' THEN
                IF SUBSTRING(st, pos+2, 1) IN ('I', 'E', 'Y') THEN                  SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos  + 3;                 ELSE
                    SET pri = CONCAT(pri, 'TK'), sec = CONCAT(sec, 'TK'), pos = pos  + 2;               END IF;
            ELSEIF SUBSTRING(st, pos, 2) IN ('DT', 'DD') THEN
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos  + 1;             END IF;
        WHEN ch = 'F' THEN
            IF SUBSTRING(st, pos+1, 1) = 'F' THEN
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos  + 1;             END IF;
        WHEN ch = 'G' THEN
            IF SUBSTRING(st, pos+1, 1) = 'H' THEN
                IF (pos > first AND SUBSTRING(st, pos-1, 1) NOT IN ('A', 'E', 'I', 'O', 'U', 'Y')) 
                    OR ( pos = first AND SUBSTRING(st, pos+2, 1) != 'I') THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                 ELSEIF pos = first AND SUBSTRING(st, pos+2, 1) = 'I' THEN
                     SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos  + 2;                                ELSEIF (pos > (first + 1) AND SUBSTRING(st, pos-2, 1) IN ('B', 'H', 'D') )
                   OR (pos > (first + 2) AND SUBSTRING(st, pos-3, 1) IN ('B', 'H', 'D') )
                   OR (pos > (first + 3) AND SUBSTRING(st, pos-4, 1) IN ('B', 'H') ) THEN
                    SET pos = pos + 2;              ELSE
                                        IF pos > (first + 2) AND SUBSTRING(st, pos-1, 1) = 'U'
                       AND SUBSTRING(st, pos-3, 1) IN ('C', 'G', 'L', 'R', 'T') THEN
                        SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos  + 2;                     ELSEIF pos > first AND SUBSTRING(st, pos-1, 1) != 'I' THEN
                        SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;           ELSE
              SET pos = pos + 1;
                    END IF;
                END IF;
            ELSEIF SUBSTRING(st, pos+1, 1) = 'N' THEN
                IF pos = (first +1) AND SUBSTRING(st, first, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') AND NOT is_slavo_germanic THEN
                    SET pri = CONCAT(pri, 'KN'), sec = CONCAT(sec, 'N'), pos = pos  + 2;                ELSE
                                        IF SUBSTRING(st, pos+2, 2) != 'EY' AND SUBSTRING(st, pos+1, 1) != 'Y'
                        AND NOT is_slavo_germanic THEN
                        SET pri = CONCAT(pri, 'N'), sec = CONCAT(sec, 'KN'), pos = pos  + 2;                    ELSE
                        SET pri = CONCAT(pri, 'KN'), sec = CONCAT(sec, 'KN'), pos = pos  + 2;                   END IF;
                END IF;
                        ELSEIF SUBSTRING(st, pos+1, 2) = 'LI' AND NOT is_slavo_germanic THEN
                SET pri = CONCAT(pri, 'KL'), sec = CONCAT(sec, 'L'), pos = pos  + 2;                        ELSEIF pos = first AND (SUBSTRING(st, pos+1, 1) = 'Y'
               OR SUBSTRING(st, pos+1, 2) IN ('ES', 'EP', 'EB', 'EL', 'EY', 'IB', 'IL', 'IN', 'IE', 'EI', 'ER')) THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'J'), pos = pos  + 2;                         ELSEIF (SUBSTRING(st, pos+1, 2) = 'ER' OR SUBSTRING(st, pos+1, 1) = 'Y')
               AND SUBSTRING(st, first, 6) NOT IN ('DANGER', 'RANGER', 'MANGER')
               AND SUBSTRING(st, pos-1, 1) not IN ('E', 'I') AND SUBSTRING(st, pos-1, 3) NOT IN ('RGY', 'OGY') THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'J'), pos = pos  + 2;                         ELSEIF SUBSTRING(st, pos+1, 1) IN ('E', 'I', 'Y') OR SUBSTRING(st, pos-1, 4) IN ('AGGI', 'OGGI') THEN
                                IF SUBSTRING(st, first, 4) IN ('VON ', 'VAN ') OR SUBSTRING(st, first, 3) = 'SCH'
                   OR SUBSTRING(st, pos+1, 2) = 'ET' THEN
                    SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                 ELSE
                                        IF SUBSTRING(st, pos+1, 4) = 'IER ' THEN
                        SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos  + 2;                     ELSE
                        SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'K'), pos = pos  + 2;                     END IF;
                END IF;
            ELSEIF SUBSTRING(st, pos+1, 1) = 'G' THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 1;             END IF;
        WHEN ch = 'H' THEN
                        IF (pos = first OR SUBSTRING(st, pos-1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y')) 
                AND SUBSTRING(st, pos+1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') THEN
                SET pri = CONCAT(pri, 'H'), sec = CONCAT(sec, 'H'), pos = pos  + 2;             ELSE                SET pos = pos + 1;          END IF;
        WHEN ch = 'J' THEN
                        IF SUBSTRING(st, pos, 4) = 'JOSE' OR SUBSTRING(st, first, 4) = 'SAN ' THEN
                IF (pos = first AND SUBSTRING(st, pos+4, 1) = ' ') OR SUBSTRING(st, first, 4) = 'SAN ' THEN
                    SET pri = CONCAT(pri, 'H'), sec = CONCAT(sec, 'H');                 ELSE
                    SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'H');                 END IF;
            ELSEIF pos = first AND SUBSTRING(st, pos, 4) != 'JOSE' THEN
                SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'A');             ELSE
                                IF SUBSTRING(st, pos-1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') AND NOT is_slavo_germanic
                   AND SUBSTRING(st, pos+1, 1) IN ('A', 'O') THEN
                    SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'H');                 ELSE
                    IF pos = last THEN
                        SET pri = CONCAT(pri, 'J');                     ELSE
                        IF SUBSTRING(st, pos+1, 1) not IN ('L', 'T', 'K', 'S', 'N', 'M', 'B', 'Z')
                           AND SUBSTRING(st, pos-1, 1) not IN ('S', 'K', 'L') THEN
                            SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J');                         END IF;
                    END IF;
                END IF;
            END IF;
            IF SUBSTRING(st, pos+1, 1) = 'J' THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
        WHEN ch = 'K' THEN
            IF SUBSTRING(st, pos+1, 1) = 'K' THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 1;             END IF;
        WHEN ch = 'L' THEN
            IF SUBSTRING(st, pos+1, 1) = 'L' THEN
                                IF (pos = (last - 2) AND SUBSTRING(st, pos-1, 4) IN ('ILLO', 'ILLA', 'ALLE'))
                   OR ((SUBSTRING(st, last-1, 2) IN ('AS', 'OS') OR SUBSTRING(st, last) IN ('A', 'O'))
                   AND SUBSTRING(st, pos-1, 4) = 'ALLE') THEN
                    SET pri = CONCAT(pri, 'L'), pos = pos  + 2;                 ELSE
                    SET pri = CONCAT(pri, 'L'), sec = CONCAT(sec, 'L'), pos = pos  + 2;                 END IF;
            ELSE
                SET pri = CONCAT(pri, 'L'), sec = CONCAT(sec, 'L'), pos = pos  + 1;             END IF;
        WHEN ch = 'M' THEN
            IF SUBSTRING(st, pos-1, 3) = 'UMB'
               AND (pos + 1 = last OR SUBSTRING(st, pos+2, 2) = 'ER')
               OR SUBSTRING(st, pos+1, 1) = 'M' THEN
                SET pri = CONCAT(pri, 'M'), sec = CONCAT(sec, 'M'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'M'), sec = CONCAT(sec, 'M'), pos = pos  + 1;             END IF;
        WHEN ch = 'N' THEN
            IF SUBSTRING(st, pos+1, 1) = 'N' THEN
                SET pri = CONCAT(pri, 'N'), sec = CONCAT(sec, 'N'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'N'), sec = CONCAT(sec, 'N'), pos = pos  + 1;             END IF;
                            WHEN ch = 'P' THEN
            IF SUBSTRING(st, pos+1, 1) = 'H' THEN
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos  + 2;             ELSEIF SUBSTRING(st, pos+1, 1) IN ('P', 'B') THEN               SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'P'), sec = CONCAT(sec, 'P'), pos = pos  + 1;             END IF;
        WHEN ch = 'Q' THEN
            IF SUBSTRING(st, pos+1, 1) = 'Q' THEN
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'K'), sec = CONCAT(sec, 'K'), pos = pos  + 1;             END IF;
        WHEN ch = 'R' THEN
                        IF pos = last AND not is_slavo_germanic
               AND SUBSTRING(st, pos-2, 2) = 'IE' AND SUBSTRING(st, pos-4, 2) NOT IN ('ME', 'MA') THEN
                SET sec = CONCAT(sec, 'R');             ELSE
                SET pri = CONCAT(pri, 'R'), sec = CONCAT(sec, 'R');             END IF;
            IF SUBSTRING(st, pos+1, 1) = 'R' THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
        WHEN ch = 'S' THEN
                        IF SUBSTRING(st, pos-1, 3) IN ('ISL', 'YSL') THEN
                SET pos = pos + 1;
                        ELSEIF pos = first AND SUBSTRING(st, first, 5) = 'SUGAR' THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'S'), pos = pos  + 1;             ELSEIF SUBSTRING(st, pos, 2) = 'SH' THEN
                                IF SUBSTRING(st, pos+1, 4) IN ('HEIM', 'HOEK', 'HOLM', 'HOLZ') THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos  + 2;                 ELSE
                    SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos  + 2;                 END IF;
                        ELSEIF SUBSTRING(st, pos, 3) IN ('SIO', 'SIA') OR SUBSTRING(st, pos, 4) = 'SIAN' THEN
                IF NOT is_slavo_germanic THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X'), pos = pos  + 3;                 ELSE
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos  + 3;                 END IF;
                                    ELSEIF (pos = first AND SUBSTRING(st, pos+1, 1) IN ('M', 'N', 'L', 'W')) OR SUBSTRING(st, pos+1, 1) = 'Z' THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'X');                 IF SUBSTRING(st, pos+1, 1) = 'Z' THEN
                    SET pos = pos + 2;
                ELSE
                    SET pos = pos + 1;
                END IF;
            ELSEIF SUBSTRING(st, pos, 2) = 'SC' THEN
                                IF SUBSTRING(st, pos+2, 1) = 'H' THEN
                                        IF SUBSTRING(st, pos+3, 2) IN ('OO', 'ER', 'EN', 'UY', 'ED', 'EM') THEN
                                                IF SUBSTRING(st, pos+3, 2) IN ('ER', 'EN') THEN
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'SK'), pos = pos  + 3;                        ELSE
                            SET pri = CONCAT(pri, 'SK'), sec = CONCAT(sec, 'SK'), pos = pos  + 3;                       END IF;
                    ELSE
                        IF pos = first AND SUBSTRING(st, first+3, 1) not IN ('A', 'E', 'I', 'O', 'U', 'Y') AND SUBSTRING(st, first+3, 1) != 'W' THEN
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'S'), pos = pos  + 3;                         ELSE
                            SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos  + 3;                         END IF;
                    END IF;
                ELSEIF SUBSTRING(st, pos+2, 1) IN ('I', 'E', 'Y') THEN
                    SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S'), pos = pos  + 3;                 ELSE
                    SET pri = CONCAT(pri, 'SK'), sec = CONCAT(sec, 'SK'), pos = pos  + 3;               END IF;
                        ELSEIF pos = last AND SUBSTRING(st, pos-2, 2) IN ('AI', 'OI') THEN
                SET sec = CONCAT(sec, 'S'), pos = pos  + 1;             ELSE
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S');                 IF SUBSTRING(st, pos+1, 1) IN ('S', 'Z') THEN
                    SET pos = pos + 2;
                ELSE
                    SET pos = pos + 1;
                END IF;
            END IF;
        WHEN ch = 'T' THEN
            IF SUBSTRING(st, pos, 4) = 'TION' THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos  + 3;             ELSEIF SUBSTRING(st, pos, 3) IN ('TIA', 'TCH') THEN
                SET pri = CONCAT(pri, 'X'), sec = CONCAT(sec, 'X'), pos = pos  + 3;             ELSEIF SUBSTRING(st, pos, 2) = 'TH' OR SUBSTRING(st, pos, 3) = 'TTH' THEN
                                IF SUBSTRING(st, pos+2, 2) IN ('OM', 'AM') OR SUBSTRING(st, first, 4) IN ('VON ', 'VAN ')
                   OR SUBSTRING(st, first, 3) = 'SCH' THEN
                    SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos  + 2;                 ELSE
                    SET pri = CONCAT(pri, '0'), sec = CONCAT(sec, 'T'), pos = pos  + 2;                 END IF;
            ELSEIF SUBSTRING(st, pos+1, 1) IN ('T', 'D') THEN
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'T'), sec = CONCAT(sec, 'T'), pos = pos  + 1;             END IF;
        WHEN ch = 'V' THEN
            IF SUBSTRING(st, pos+1, 1) = 'V' THEN
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos  + 2;             ELSE
                SET pri = CONCAT(pri, 'F'), sec = CONCAT(sec, 'F'), pos = pos  + 1;             END IF;
        WHEN ch = 'W' THEN
                        IF SUBSTRING(st, pos, 2) = 'WR' THEN
                SET pri = CONCAT(pri, 'R'), sec = CONCAT(sec, 'R'), pos = pos  + 2;             ELSEIF pos = first AND (SUBSTRING(st, pos+1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y')
                OR SUBSTRING(st, pos, 2) = 'WH') THEN
                                IF SUBSTRING(st, pos+1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y') THEN
                    SET pri = CONCAT(pri, 'A'), sec = CONCAT(sec, 'F'), pos = pos  + 1;                 ELSE
                    SET pri = CONCAT(pri, 'A'), sec = CONCAT(sec, 'A'), pos = pos  + 1;                 END IF;
                        ELSEIF (pos = last AND SUBSTRING(st, pos-1, 1) IN ('A', 'E', 'I', 'O', 'U', 'Y'))
               OR SUBSTRING(st, pos-1, 5) IN ('EWSKI', 'EWSKY', 'OWSKI', 'OWSKY')
               OR SUBSTRING(st, first, 3) = 'SCH' THEN
                SET sec = CONCAT(sec, 'F'), pos = pos  + 1;                                     ELSEIF SUBSTRING(st, pos, 4) IN ('WICZ', 'WITZ') THEN
                SET pri = CONCAT(pri, 'TS'), sec = CONCAT(sec, 'FX'), pos = pos  + 4;           ELSE                SET pos = pos + 1;
            END IF;
        WHEN ch = 'X' THEN
                        IF not(pos = last AND (SUBSTRING(st, pos-3, 3) IN ('IAU', 'EAU')
               OR SUBSTRING(st, pos-2, 2) IN ('AU', 'OU'))) THEN
                SET pri = CONCAT(pri, 'KS'), sec = CONCAT(sec, 'KS');           END IF;
            IF SUBSTRING(st, pos+1, 1) IN ('C', 'X') THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
        WHEN ch = 'Z' THEN
                        IF SUBSTRING(st, pos+1, 1) = 'H' THEN
                SET pri = CONCAT(pri, 'J'), sec = CONCAT(sec, 'J'), pos = pos  + 1;             ELSEIF SUBSTRING(st, pos+1, 3) IN ('ZO', 'ZI', 'ZA')
               OR (is_slavo_germanic AND pos > first AND SUBSTRING(st, pos-1, 1) != 'T') THEN
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'TS');            ELSE
                SET pri = CONCAT(pri, 'S'), sec = CONCAT(sec, 'S');             END IF;
            IF SUBSTRING(st, pos+1, 1) = 'Z' THEN
                SET pos = pos + 2;
            ELSE
                SET pos = pos + 1;
            END IF;
        ELSE
            SET pos = pos + 1;      END CASE;
    IF pos = prevpos THEN
       SET pos = pos +1;
       SET pri = CONCAT(pri,'<didnt incr>');     END IF;
    END WHILE;
    IF pri != sec THEN
        SET pri = CONCAT(pri, ';', sec);
  END IF;
    RETURN (pri);
END
$$

DELIMITER ;



DELIMITER $$
DROP FUNCTION IF EXISTS `jaro_winkler_similarity`$$

CREATE FUNCTION `jaro_winkler_similarity`(
in1 VARCHAR(255),
in2 VARCHAR(255)
) RETURNS FLOAT
DETERMINISTIC
BEGIN
#finestra:= search window, curString:= scanning cursor for the original string, curSub:= scanning cursor for the compared string
DECLARE finestra, curString, curSub, maxSub, trasposizioni, prefixlen, maxPrefix INT;
DECLARE char1, char2 CHAR(1);
DECLARE common1, common2, old1, old2 VARCHAR(255);
DECLARE trovato BOOLEAN;
DECLARE returnValue, jaro FLOAT;
SET maxPrefix=6; #from the original jaro - winkler algorithm
SET common1="";
SET common2="";
SET finestra=(LENGTH(in1)+LENGTH(in2)-ABS(LENGTH(in1)-LENGTH(in2))) DIV 4
+ ((LENGTH(in1)+LENGTH(in2)-ABS(LENGTH(in1)-LENGTH(in2)))/2) MOD 2;
SET old1=in1;
SET old2=in2;

#calculating common letters vectors
SET curString=1;
WHILE curString<=LENGTH(in1) AND (curString<=(LENGTH(in2)+finestra)) DO
SET curSub=curstring-finestra;
IF (curSub)<1 THEN
SET curSub=1;
END IF;
SET maxSub=curstring+finestra;
IF (maxSub)>LENGTH(in2) THEN
SET maxSub=LENGTH(in2);
END IF;
SET trovato = FALSE;
WHILE curSub<=maxSub AND trovato=FALSE DO
IF SUBSTR(in1,curString,1)=SUBSTR(in2,curSub,1) THEN
SET common1 = CONCAT(common1,SUBSTR(in1,curString,1));
SET in2 = CONCAT(SUBSTR(in2,1,curSub-1),CONCAT("0",SUBSTR(in2,curSub+1,LENGTH(in2)-curSub+1)));
SET trovato=TRUE;
END IF;
SET curSub=curSub+1;
END WHILE;
SET curString=curString+1;
END WHILE;
#back to the original string
SET in2=old2;
SET curString=1;
WHILE curString<=LENGTH(in2) AND (curString<=(LENGTH(in1)+finestra)) DO
SET curSub=curstring-finestra;
IF (curSub)<1 THEN
SET curSub=1;
END IF;
SET maxSub=curstring+finestra;
IF (maxSub)>LENGTH(in1) THEN
SET maxSub=LENGTH(in1);
END IF;
SET trovato = FALSE;
WHILE curSub<=maxSub AND trovato=FALSE DO
IF SUBSTR(in2,curString,1)=SUBSTR(in1,curSub,1) THEN
SET common2 = CONCAT(common2,SUBSTR(in2,curString,1));
SET in1 = CONCAT(SUBSTR(in1,1,curSub-1),CONCAT("0",SUBSTR(in1,curSub+1,LENGTH(in1)-curSub+1)));
SET trovato=TRUE;
END IF;
SET curSub=curSub+1;
END WHILE;
SET curString=curString+1;
END WHILE;
#back to the original string
SET in1=old1;

#calculating jaro metric
IF LENGTH(common1)<>LENGTH(common2)
THEN SET jaro=0;
ELSEIF LENGTH(common1)=0 OR LENGTH(common2)=0
THEN SET jaro=0;
ELSE
#calcolo la distanza di winkler
#passo 1: calcolo le trasposizioni
SET trasposizioni=0;
SET curString=1;
WHILE curString<=LENGTH(common1) DO
IF(SUBSTR(common1,curString,1)<>SUBSTR(common2,curString,1)) THEN
SET trasposizioni=trasposizioni+1;
END IF;
SET curString=curString+1;
END WHILE;
SET jaro=
(
LENGTH(common1)/LENGTH(in1)+
LENGTH(common2)/LENGTH(in2)+
(LENGTH(common1)-trasposizioni/2)/LENGTH(common1)
)/3;

END IF; #end if for jaro metric

#calculating common prefix for winkler metric
SET prefixlen=0;
WHILE (SUBSTRING(in1,prefixlen+1,1)=SUBSTRING(in2,prefixlen+1,1)) AND (prefixlen<6) DO
SET prefixlen= prefixlen+1;
END WHILE;


#calculate jaro-winkler metric
RETURN jaro+(prefixlen*0.1*(1-jaro));
END
$$
DELIMITER ;




-- 2014-12-12


DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_clonar_actividades`$$

CREATE  PROCEDURE `sp_clonar_actividades`()
BEGIN

DELETE FROM `socios_aeconomica_tipos`;

INSERT INTO `socios_aeconomica_tipos` (`idsocios_aeconomica_tipos`, `nombre_taeconomica`) SELECT `clave_interna`,`nombre_de_la_actividad` FROM `personas_actividad_economica_tipos`;

END$$

DELIMITER ;

-- Base de recibos para AML

DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_perfil_egresos_por_persona`$$

CREATE PROCEDURE `proc_perfil_egresos_por_persona`()
BEGIN

DROP VIEW IF EXISTS aml_perfil_egresos_por_persona;
DROP TABLE IF EXISTS aml_perfil_egresos_por_persona;

CREATE TABLE aml_perfil_egresos_por_persona AS  
(
SELECT 
  `eacp_config_bases_de_integracion_miembros`.`codigo_de_base` AS `codigo_de_base`,
  `operaciones_recibos`.`numero_socio`                         AS `socio_afectado`,
  DATE_FORMAT(`operaciones_recibos`.`fecha_operacion`,'%Y%m')  AS `periodo`,
  `operaciones_recibos`.`clave_de_moneda`                      AS `moneda`,
  `operaciones_recibos`.`tipo_pago`                      AS `tipo`,
  COUNT(`operaciones_recibos`.`idoperaciones_recibos`)         AS `operaciones`,
  SUM(`operaciones_recibos`.`unidades_en_moneda`)              AS `original`,
  ROUND(SUM(
	IF(UPPER(`operaciones_recibos`.`clave_de_moneda`) != getMonedaLocal(), getEquivalenciaDeMonedas(`operaciones_recibos`.`unidades_en_moneda`, `operaciones_recibos`.`clave_de_moneda`),
	`operaciones_recibos`.`total_operacion`)
	),2)                 AS `monto`,

  IF (`personas_perfil_transaccional_tipos`.`idpersonas_perfil_transaccional_tipos` IS NULL, LCASE(`operaciones_recibos`.`tipo_pago`), LCASE(`personas_perfil_transaccional_tipos`.`tipo_de_exhibicion` )) AS 'perfil',
	`operaciones_recibos`.`idoperaciones_recibos`                      AS `recibo`
FROM 

	`eacp_config_bases_de_integracion_miembros` 
	`eacp_config_bases_de_integracion_miembros` 
		INNER JOIN `operaciones_recibos` `operaciones_recibos` 
		ON `eacp_config_bases_de_integracion_miembros`.`miembro` = 
		`operaciones_recibos`.`tipo_docto` 
			LEFT OUTER JOIN `personas_perfil_transaccional_tipos` 
			`personas_perfil_transaccional_tipos` 
			ON `operaciones_recibos`.`origen_aml` = 
			`personas_perfil_transaccional_tipos`.
			`idpersonas_perfil_transaccional_tipos`
     
     
WHERE (`eacp_config_bases_de_integracion_miembros`.`codigo_de_base` = 30210)
GROUP BY `operaciones_recibos`.`numero_socio`,
`operaciones_recibos`.`fecha_operacion`,

`operaciones_recibos`.`origen_aml`,


`operaciones_recibos`.`clave_de_moneda`
ORDER BY `eacp_config_bases_de_integracion_miembros`.`codigo_de_base`

) ;

ALTER TABLE `aml_perfil_egresos_por_persona` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `recibo`, ADD PRIMARY KEY (`indice`);

ALTER TABLE `aml_perfil_egresos_por_persona` ADD INDEX `socio_afectado` (`socio_afectado`), ADD INDEX `recibo` (`recibo`);

END$$

DELIMITER ;

-- AML Operaciones por Nucleo

DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_personas_operaciones_recursivas`$$

CREATE PROCEDURE `proc_personas_operaciones_recursivas`()
BEGIN

CREATE TABLE IF NOT EXISTS`personas_relaciones_recursivas` (
	`clave_interna` int (11),
	`persona` bigint (25),
	`relacion` bigint (25),
	`nivel` int (4),
	`proxy` bigint (25)
); 

DROP VIEW IF EXISTS personas_operaciones_recursivas;
DROP TABLE IF EXISTS personas_operaciones_recursivas;

CREATE TABLE personas_operaciones_recursivas AS  
(
SELECT
    `personas_relaciones_recursivas`.`persona`     AS `persona`,
    `operaciones_recibos`.`idusuario`                    AS `usuario`,
       
    CEIL( COUNT(`operaciones_recibos`.`idoperaciones_recibos`) /
    (DATEDIFF( MAX(`operaciones_recibos`.`fecha_operacion`), MIN(`operaciones_recibos`.`fecha_operacion`))
     + 1)
     ) AS `operaciones`,
    CEIL(SUM(`operaciones_recibos`.`total_operacion`) /
    ( DATEDIFF( MAX(`operaciones_recibos`.`fecha_operacion`), MIN(`operaciones_recibos`.`fecha_operacion`)) + 1)
    ) AS `monto`
FROM
    `operaciones_recibos` `operaciones_recibos`
        INNER JOIN `personas_relaciones_recursivas`
        `personas_relaciones_recursivas`
        ON `operaciones_recibos`.`numero_socio` =
        `personas_relaciones_recursivas`.`persona`
WHERE
    (`operaciones_recibos`.`origen_aml` >0)        
    GROUP BY
        `personas_relaciones_recursivas`.`persona`,
        `operaciones_recibos`.`idusuario`

) ;

ALTER TABLE `personas_operaciones_recursivas` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `monto`, ADD PRIMARY KEY (`indice`);

ALTER TABLE `personas_operaciones_recursivas` ADD INDEX `persona` (`persona`);

END$$

DELIMITER ;

-- ------------ function de ejercico actual
DELIMITER $$

DROP FUNCTION IF EXISTS `getEjercicioDeTrabajo`$$

CREATE FUNCTION `getEjercicioDeTrabajo`() RETURNS INT(11)
    NO SQL
    DETERMINISTIC
BEGIN
	IF ISNULL(@ejercicio) THEN
	SET @ejercicio = YEAR(NOW());
	END IF;
	RETURN @ejercicio;
    END$$

DELIMITER ;

-- Limite de UDIS
DELIMITER $$

DROP FUNCTION IF EXISTS `getLimitePersonasVigiladas`$$
CREATE
    FUNCTION `getLimitePersonasVigiladas`()
    RETURNS FLOAT(14,2)
    BEGIN
	DECLARE mUDI FLOAT(12,6) DEFAULT 0;
	DECLARE mLIMITE FLOAT(12,2) DEFAULT 0;    
	IF ISNULL(@limite_personas_vigiladas)  THEN

		SET mUDI = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'valor_actual_de_la_udi' LIMIT 0,1);
		SET mLIMITE = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'limite_inferior_para_personas_bloqueadas' LIMIT 0,1);
		SET @limite_personas_vigiladas = (mUDI * mLIMITE);
	END IF;
	RETURN @limite_personas_vigiladas;
    END$$

DELIMITER ;


-- ------------ function fecha de corte
DELIMITER $$

DROP FUNCTION IF EXISTS `getFechaDeCorte`$$

CREATE FUNCTION `getFechaDeCorte`() RETURNS DATE
    NO SQL
BEGIN
	IF ISNULL(@fecha_de_corte) THEN
	SET @fecha_de_corte = NOW();
	END IF;
	RETURN @fecha_de_corte;
    END$$

DELIMITER ;


-- Divisor de  Interes
DELIMITER $$
DROP FUNCTION IF EXISTS `getDivisorDeInteres`$$
CREATE
    FUNCTION `getDivisorDeInteres`()
    RETURNS INT(4)
    BEGIN
	DECLARE mDIV INT(4) DEFAULT 0;
		IF ISNULL(@divisor_de_interes)  THEN

		SET mDIV = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'divisor_en_dias_del_interes' LIMIT 0,1);

		SET @divisor_de_interes = mDIV;
	END IF;
	RETURN @divisor_de_interes;
    END$$

DELIMITER ;


-- -- Letras pendientes de pago.- Actualizado Julio/2016
-- -- Esta funcion tiene version en RT
DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_creditos_letras_pendientes`$$

CREATE PROCEDURE `proc_creditos_letras_pendientes`()
BEGIN

-- DROP VIEW IF EXISTS `creditos_letras_pendientes`;
DROP TABLE IF EXISTS `creditos_letras_pendientes`;

CREATE TABLE `creditos_letras_pendientes` AS  
(
SELECT
		`eacp_config_bases_de_integracion_miembros`.`codigo_de_base`	AS `codigo_de_base`,
		`socio_afectado`												AS `socio_afectado`,
		
		`socio_afectado`												AS `persona`,
		`docto_afectado`												AS `credito`,
		`periodo_socio`													AS `parcialidad`,
		
		`docto_afectado`												AS `docto_afectado`,
		`periodo_socio`													AS `periodo_socio`,
		MIN(`fecha_afectacion`)											AS `fecha_de_pago`,
		MAX(`fecha_afectacion`)											AS `fecha_de_vencimiento`,
		
		`creditos_solicitud`.`monto_solicitado` 						AS `monto_original`,
		`creditos_solicitud`.`saldo_actual`     						AS `saldo_principal`,
		
		SUM(IF(`tipo_operacion` = 410,`afectacion_real`,0))				AS `capital`,
		SUM(IF(`tipo_operacion` = 411,`afectacion_real`,0))				AS `interes`,
		SUM(IF(`tipo_operacion` = 413,`afectacion_real`,0))				AS `iva`,
		SUM(IF(`tipo_operacion` = 412,`afectacion_real`,0))				AS `ahorro`,

		SUM(IF((`tipo_operacion` = 410  AND `fecha_afectacion` <= PRM.`fecha_corte`) ,`afectacion_real`,0)) 								AS `capital_exigible`,
		SUM(IF((`tipo_operacion` = 411 AND `fecha_afectacion` <= PRM.`fecha_corte`),`afectacion_real`,0)) 									AS `interes_exigible`,
		SUM(IF((`tipo_operacion` = 413  AND `fecha_afectacion` <= PRM.`fecha_corte`),`afectacion_real`,0)) 									AS `iva_exigible`,
		SUM(IF((`tipo_operacion` = 412  AND `fecha_afectacion` <= PRM.`fecha_corte`),`afectacion_real`,0)) 									AS `ahorro_exigible`,
		SUM(IF(((`tipo_operacion` < 410 OR `tipo_operacion` > 413)  AND `fecha_afectacion` <= PRM.`fecha_corte`) , `afectacion_real`,0)) 	AS `otros_exigible`,
		SUM(IF((`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`)>0 AND (`fecha_afectacion` <= PRM.`fecha_corte`) AND `tipo_operacion` = 410,1,0)) AS `letras_exigibles`,
		
		ROUND(SUM(
		IF((`tipo_operacion` = 410  AND `fecha_afectacion` <= PRM.`fecha_corte` AND `afectacion_real`>0),
		((`afectacion_real` * DATEDIFF(PRM.`fecha_corte`, `fecha_afectacion`) * (`tasa_moratorio`) ) / PRM.`divisor_interes`)
		, 0 )),2) AS `interes_moratorio`,
		
		ROUND(SUM(
		IF((`tipo_operacion` = 410  AND `fecha_afectacion` <= PRM.`fecha_corte` AND `afectacion_real`>0),
		((`afectacion_real` * DATEDIFF(PRM.`fecha_corte`, `fecha_afectacion`) * (`tasa_moratorio`) ) / PRM.`divisor_interes`)
		, 0 )),2) AS `mora`,
		
		ROUND(
		(SUM(
		IF((`tipo_operacion` = 410  AND `fecha_afectacion` <= PRM.`fecha_corte` AND `afectacion_real`>0),
		((`afectacion_real` * DATEDIFF(PRM.`fecha_corte`, `fecha_afectacion`) * (`tasa_moratorio`) ) / PRM.`divisor_interes`)
		, 0 ))*PRM.`tasa_iva`),2) AS `iva_moratorio`,
		
		IF(SUM(IF((`tipo_operacion` < 410 OR `tipo_operacion` > 413),0, `afectacion_real`))<=0,0,
		MAX(
		IF((`tipo_operacion` = 410  AND `fecha_afectacion` <= PRM.`fecha_corte` AND `afectacion_real`>0),
		(DATEDIFF(PRM.`fecha_corte`, `fecha_afectacion`))
		, 0 ))
		) AS `dias`,
		
		SUM(IF((`tipo_operacion` < 410 OR `tipo_operacion` > 413), `afectacion_real`,0)) 		AS `otros`,
		
		SUM((`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`)) 	AS `letra`,
		
		SUM(IF((`tipo_operacion` < 410 OR `tipo_operacion` > 413),0, `afectacion_real`)) 		AS `total_sin_otros`,
		
		MAX(IF((`tipo_operacion` < 410 OR `tipo_operacion` > 413),`tipo_operacion`,0)) 			AS `clave_otros`
		
		,ROUND(
		(SUM(
		IF((`tipo_operacion` = 410  AND `fecha_afectacion` <= PRM.`fecha_corte` AND `creditos_solicitud`.`pagos_autorizados`=`periodo_socio`),
		((`creditos_solicitud`.`saldo_actual` * DATEDIFF(PRM.`fecha_corte`, `fecha_afectacion`) * (`creditos_solicitud`.`tasa_interes`) ) / PRM.`divisor_interes`)
		, 0 )) ),2) AS `int_corriente`,
		
		ROUND(SUM(
		IF((`tipo_operacion` = 410  AND `fecha_afectacion` <= PRM.`fecha_corte` AND `afectacion_real`>0),
		((`afectacion_real` * DATEDIFF(PRM.`fecha_corte`, `fecha_afectacion`) * (`creditos_solicitud`.`tasa_interes`) ) / PRM.`divisor_interes`)
		, 0 )),2) AS `int_corriente_letra`
		
		,SUM(IF((`tipo_operacion` = 410  AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `capital_nopagado`,
		SUM(IF((`tipo_operacion` = 411 AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `interes_nopagado`,
		SUM(IF((`tipo_operacion` = 413  AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `iva_nopagado`,
		SUM(IF((`tipo_operacion` = 412  AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `ahorro_nopagado`,
		SUM(IF(((`tipo_operacion` < 410 OR `tipo_operacion` > 413)  AND `fecha_afectacion` > PRM.`fecha_corte`) , `afectacion_real`,0)) AS `otros_nopagado`
		,IF((`tipo_operacion` = 410 AND `periodo_socio`= (`creditos_solicitud`.`ultimo_periodo_afectado`+1)),  MMC.`cargos_cbza`,0) 	AS `gastos_de_cobranza`

		FROM
			`operaciones_mvtos` `operaciones_mvtos` 
				INNER JOIN `creditos_solicitud` `creditos_solicitud` 
				ON `operaciones_mvtos`.`docto_afectado` = `creditos_solicitud`.
				`numero_solicitud` 
					INNER JOIN `eacp_config_bases_de_integracion_miembros` 
					`eacp_config_bases_de_integracion_miembros` 
					ON `operaciones_mvtos`.`tipo_operacion` = 
					`eacp_config_bases_de_integracion_miembros`.`miembro`
		INNER JOIN ( SELECT getTasaIVAGeneral() AS `tasa_iva`, getDivisorDeInteres() AS `divisor_interes`,getFechaDeCorte() AS  `fecha_corte`) PRM
		INNER JOIN (SELECT   `clave_de_credito`,`cargos_cbza` FROM `creditos_montos`) MMC ON MMC.`clave_de_credito` = `creditos_solicitud`.`numero_solicitud`

		WHERE (`eacp_config_bases_de_integracion_miembros`.`codigo_de_base` = 2601)
		AND `operaciones_mvtos`.`tipo_operacion` != 420
		AND `operaciones_mvtos`.`tipo_operacion` != 431
		AND `operaciones_mvtos`.`tipo_operacion` != 146 /*gastos de cobranza*/ 
		AND `creditos_solicitud`.`saldo_actual`  > 0
		-- AND `operaciones_mvtos`.`docto_afectado` != 200187901
		GROUP BY `operaciones_mvtos`.`docto_afectado`,`operaciones_mvtos`.`periodo_socio`
		ORDER BY
		`eacp_config_bases_de_integracion_miembros`.`codigo_de_base`,
		`operaciones_mvtos`.`docto_afectado`, `operaciones_mvtos`.`periodo_socio`
) ;

ALTER TABLE `creditos_letras_pendientes` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `saldo_principal`, ADD PRIMARY KEY (`indice`);
ALTER TABLE `creditos_letras_pendientes` ADD INDEX `socio_afectado` (`socio_afectado`), ADD INDEX `docto_afectado` (`docto_afectado`);
ALTER TABLE `creditos_letras_pendientes` CHANGE `letra` `letra` DOUBLE(19,2) NULL, CHANGE `interes_moratorio` `interes_moratorio` DOUBLE(19,2) NULL; 
END$$

DELIMITER ;
-- Creditos a Final de Plazo

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_creditos_a_final_de_plazo`$$

CREATE
    PROCEDURE `proc_creditos_a_final_de_plazo`()
    BEGIN

--	DROP VIEW IF EXISTS `creditos_a_final_de_plazo`;
	DROP TABLE IF EXISTS `creditos_a_final_de_plazo`;

CREATE TABLE `creditos_a_final_de_plazo` AS  
(

SELECT
	`creditos_solicitud`.`numero_solicitud` AS `credito`,
	`creditos_solicitud`.`numero_socio`     AS `persona`, 
	`creditos_solicitud`.`periocidad_de_pago`,
	`creditos_solicitud`.`saldo_actual`
	
FROM
	`creditos_solicitud` `creditos_solicitud` 
WHERE
	(`creditos_solicitud`.`periocidad_de_pago` = 360) 
ORDER BY
	`creditos_solicitud`.`numero_solicitud`

) ;

	ALTER TABLE `creditos_a_final_de_plazo` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `credito`, ADD PRIMARY KEY (`indice`);
	ALTER TABLE `creditos_a_final_de_plazo` ADD INDEX `credito` (`credito`);
	
    END$$

DELIMITER ;

-- Creditos a Final de Plazo

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_creditos_abonos_por_mes`$$

CREATE
    PROCEDURE `proc_creditos_abonos_por_mes`()
    BEGIN

	DROP VIEW IF EXISTS `creditos_abonos_por_mes`;
	DROP TABLE IF EXISTS `creditos_abonos_por_mes`;

CREATE TABLE `creditos_abonos_por_mes` AS  
(

SELECT `credito`, `periodo`, SUM(`abonos`) AS `abonos`, MAX(`fecha`) AS `fecha` FROM `creditos_operaciones_en_periodos_detalle` GROUP BY `credito`, `periodo`

) ;

	ALTER TABLE `creditos_abonos_por_mes` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `credito`, ADD PRIMARY KEY (`indice`);
	ALTER TABLE `creditos_abonos_por_mes` ADD INDEX `credito` (`credito`);
	ALTER TABLE `creditos_abonos_por_mes` CHANGE COLUMN `periodo` `periodo` INT(8) NULL DEFAULT NULL ;
    END$$

DELIMITER ;


-- reg exp

DELIMITER $$
DROP FUNCTION IF EXISTS `regex_replace`$$

CREATE FUNCTION  `regex_replace`(pattern VARCHAR(1000),replacement VARCHAR(1000),original VARCHAR(1000))

RETURNS VARCHAR(1000)
DETERMINISTIC
BEGIN 
 DECLARE temp VARCHAR(1000); 
 DECLARE ch VARCHAR(1); 
 DECLARE i INT;
 SET i = 1;
 SET temp = '';
 IF original REGEXP pattern THEN 
  loop_label: LOOP 
   IF i>CHAR_LENGTH(original) THEN
    LEAVE loop_label;  
   END IF;
   SET ch = SUBSTRING(original,i,1);
   IF NOT ch REGEXP pattern THEN
    SET temp = CONCAT(temp,ch);
   ELSE
    SET temp = CONCAT(temp,replacement);
   END IF;
   SET i=i+1;
  END LOOP;
 ELSE
  SET temp = original;
 END IF;
 RETURN temp;
END$$
DELIMITER ;



-- creditos_letras_del_dia mora del dia siguiente

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_creditos_letras_del_dia`$$

CREATE
    PROCEDURE `proc_creditos_letras_del_dia`()
    BEGIN

-- 	DROP VIEW IF EXISTS `creditos_letras_del_dia`;
	DROP TABLE IF EXISTS `creditos_letras_del_dia`;



-- Cambiar fecha

SET @fecha_de_corte = DATE_ADD(NOW(), INTERVAL 10 HOUR);

CREATE TABLE `creditos_letras_del_dia` AS  
(

SELECT
		`letras`.`socio_afectado` AS `persona`,
		`letras`.`docto_afectado` AS `credito`,
		`letras`.`periodo_socio`  AS `parcialidad`,
		`letras`.`fecha_de_pago`,
		
		`letras`.`capital`,
		`letras`.`interes`,
		`letras`.`iva`,
		`letras`.`ahorro`,
		`letras`.`otros`,
		ROUND(`letras`.`letra`,2) AS `letra`,
		
		ROUND((`creditos_solicitud`.`tasa_moratorio`*100),2) AS `tasa_de_mora`,
		ROUND((`creditos_solicitud`.`tasa_interes`*100),2)   AS `tasa_de_interes` ,

		DATEDIFF(PRM.`fecha_corte`, `letras`.`fecha_de_pago`) AS `dias`,
		`letras`.`interes_moratorio` AS `mora`,
		`letras`.`interes_moratorio` AS  `interes_moratorio`,
		`letras`.`iva_moratorio` AS `iva_moratorio`
		
FROM
	`letras` `letras` 
		INNER JOIN `creditos_solicitud` `creditos_solicitud` 
		ON `letras`.`docto_afectado` = `creditos_solicitud`.`numero_solicitud` 
			INNER JOIN `creditos_tipo_de_pago` `creditos_tipo_de_pago` 
			ON `creditos_solicitud`.`tipo_de_pago` = `creditos_tipo_de_pago`.
			`idcreditos_tipo_de_pago`
INNER JOIN ( SELECT getTasaIVAGeneral() AS `tasa_iva`, getDivisorDeInteres() AS `divisor_interes`,getFechaDeCorte() AS  `fecha_corte`) PRM
		WHERE IF((`creditos_tipo_de_pago`.`con_capital`=1 AND `letras`.`capital` <=0), 0, 1) >0 AND `fecha_de_pago` <= getFechaDeCorte() AND `creditos_solicitud`.`saldo_actual`>0

) ;

CREATE TABLE IF NOT EXISTS `creditos_letras_del_dia` (
	`persona` bigint (20),
	`credito` bigint (20),
	`indice` int (10),
	`parcialidad` int (4),
	`fecha_de_pago` date ,
	`capital` double ,
	`interes` double ,
	`iva` double ,
	`ahorro` double ,
	`otros` double ,
	`letra` double ,
	`tasa_de_mora` double ,
	`tasa_de_interes` double ,
	`dias` int (7),
	`mora` double ,
	`iva_moratorio` double 
); 

	ALTER TABLE `creditos_letras_del_dia` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `credito`, ADD PRIMARY KEY (`indice`);
	ALTER TABLE `creditos_letras_del_dia` ADD INDEX `personacredito` (`persona`, `credito`,`parcialidad`) ;
	UPDATE `creditos_letras_del_dia` SET `dias` = 0 WHERE ISNULL(`dias`);
	UPDATE `creditos_letras_del_dia` SET `mora` = 0 WHERE ISNULL(`mora`);
    END$$

DELIMITER ;


-- Cambiar Palabras

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_lenguaje_cambiar_palabras`$$

CREATE
    PROCEDURE `proc_lenguaje_cambiar_palabras`(PAnterior VARCHAR(50), PNueva VARCHAR(50) )
    BEGIN
	
	IF ISNULL(@sistema_lenguaje_actual) THEN
		SET @sistema_lenguaje_actual = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'system_language' LIMIT 0,1);
	END IF;
	
	UPDATE sistema_lenguaje SET `traduccion` = REPLACE (`traduccion`,PAnterior,PNueva) WHERE `idioma`=UPPER(@sistema_lenguaje_actual);
	UPDATE general_menu SET menu_title = REPLACE(menu_title,PAnterior,PNueva);
    END$$

DELIMITER ;

-- Veces salario Mnimo
DELIMITER $$
DROP FUNCTION IF EXISTS `getMontoSalarioMinimo`$$
CREATE
    FUNCTION `getMontoSalarioMinimo`()
    RETURNS FLOAT(8,3)
    BEGIN
	DECLARE mDIV FLOAT(8,3) DEFAULT 0;
		IF ISNULL(@vsmdf)  THEN

		SET mDIV = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'salario_vigente_en_el_df' LIMIT 0,1);

		SET @vsmdf = mDIV;
	END IF;
	RETURN @vsmdf;
    END$$

DELIMITER ;


-- ------------ function de empresa por defecto
DELIMITER $$

DROP FUNCTION IF EXISTS `getEmpresaPorDefecto`$$

CREATE FUNCTION `getEmpresaPorDefecto`() RETURNS INT(11)
    NO SQL
    DETERMINISTIC
BEGIN
	IF ISNULL(@empresa_por_defecto) THEN
	SET @empresa_por_defecto = 99;
	END IF;
	RETURN @empresa_por_defecto;
    END$$

DELIMITER ;



-- Colonias Activas



DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_colonias_activas`$$

CREATE
    PROCEDURE `proc_colonias_activas`()
    BEGIN

	DROP VIEW IF EXISTS `tmp_colonias_activas`;
	DROP TABLE IF EXISTS `tmp_colonias_activas`;


CREATE TABLE `tmp_colonias_activas` AS  
(

SELECT
	`general_colonias`.`codigo_postal`,
	MAX(`general_colonias`.`nombre_colonia`) AS `nombre`,
	COUNT(`general_colonias`.`idgeneral_colonia`) AS `numero`,
	`general_colonias`.`codigo_de_estado`,
	`general_colonias`.`codigo_de_municipio`,
	`general_colonias`.`municipio_colonia`        AS `nombre_municipio`,
	`general_estados`.`clave_alfanumerica`,
	`general_estados`.`nombre`                    AS `nombre_estado`,
	`general_estados`.`clave_en_sic` 
FROM
	`general_colonias` `general_colonias` 
		INNER JOIN `general_estados` `general_estados` 
		ON `general_colonias`.`codigo_de_estado` = `general_estados`.
		`clave_numerica` 
WHERE
	(`general_estados`.`operacion_habilitada` = 1)
GROUP BY
	`general_colonias`.`codigo_postal`

) ;

	
	ALTER TABLE `tmp_colonias_activas` ADD PRIMARY KEY (`codigo_postal`);
	ALTER TABLE `tmp_colonias_activas` ADD COLUMN `idlocalidad` INT NULL DEFAULT 0 AFTER `clave_en_sic`;
	ALTER TABLE `tmp_colonias_activas` ADD COLUMN `nombre_localidad` VARCHAR(100) NULL DEFAULT '' AFTER `idlocalidad`;

	UPDATE `tmp_colonias_activas` SET `idlocalidad`= (SELECT `clave_unica` FROM `catalogos_localidades` WHERE `nombre_de_la_localidad` LIKE CONCAT("%", `tmp_colonias_activas`.`nombre_municipio`, "%") AND `tmp_colonias_activas`.`codigo_de_estado`=`catalogos_localidades`.`clave_de_estado` LIMIT 0,1) WHERE ISNULL(idlocalidad) OR  idlocalidad = 0;

	UPDATE `tmp_colonias_activas` SET `idlocalidad`= (SELECT `clave_unica` FROM `catalogos_localidades` WHERE `tmp_colonias_activas`.`codigo_de_estado`=`catalogos_localidades`.`clave_de_estado` LIMIT 0,1) WHERE ISNULL(idlocalidad) OR  idlocalidad = 0;

	UPDATE `tmp_colonias_activas` SET `nombre_localidad`= (SELECT `nombre_de_la_localidad` FROM `catalogos_localidades` WHERE `clave_unica`= `tmp_colonias_activas`.`idlocalidad` LIMIT 0,1);
    END$$

DELIMITER ;


--

-- Personas extranjeras y guardado en la DB

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_personas_extranjeras`$$

CREATE
    PROCEDURE `proc_personas_extranjeras`()
    BEGIN

	DROP VIEW IF EXISTS `tmp_personas_extranjeras`;
	DROP TABLE IF EXISTS `tmp_personas_extranjeras`;


CREATE TABLE `tmp_personas_extranjeras` AS  
(

SELECT
	`socios_otros_parametros`.`clave_de_persona`,
	`socios_otros_parametros`.`clave_del_parametro`,
	`socios_otros_parametros`.`fecha_de_expiracion` 
FROM
	`socios_otros_parametros` `socios_otros_parametros` 
WHERE
	(`socios_otros_parametros`.`clave_del_parametro` ='PERSONAS_ES_EXTRANJERO') 
	AND
	(`socios_otros_parametros`.`fecha_de_expiracion` >=NOW())

) ;

	
	ALTER TABLE `tmp_personas_extranjeras` ADD PRIMARY KEY (`clave_de_persona`);
	UPDATE `socios_general` SET `nacionalidad_extranjera` = 1 WHERE (SELECT COUNT(*) FROM `tmp_personas_extranjeras` WHERE `tmp_personas_extranjeras`.`clave_de_persona`=`socios_general`.`codigo` ) >0;
    END$$

DELIMITER ;



-- Rago de Ingresos VSM
DELIMITER $$
DROP FUNCTION IF EXISTS `getRangoDeSalario`$$
CREATE
    FUNCTION `getRangoDeSalario`(SALARIO_MENSUAL FLOAT(13,2) )
    RETURNS INT(4)
    BEGIN
	DECLARE vRANGO INT(4) DEFAULT 0;
	SET SALARIO_MENSUAL = (SALARIO_MENSUAL/30.41666666666666666);

	IF ISNULL(@vsmdf1)  THEN
		SET @vsmdf1 = (SELECT (`limite_superior`*getMontoSalarioMinimo()) AS `superior` FROM `personas_rango_de_ingresos` WHERE `idpersonas_rango_de_ingresos`=1);
	END IF;
	IF ISNULL(@vsmdf2)  THEN
		SET @vsmdf2 = (SELECT (`limite_superior`*getMontoSalarioMinimo()) AS `superior` FROM `personas_rango_de_ingresos` WHERE `idpersonas_rango_de_ingresos`=2);
	END IF;
	IF ISNULL(@vsmdf3)  THEN
		SET @vsmdf3 = (SELECT (`limite_superior`*getMontoSalarioMinimo()) AS `superior` FROM `personas_rango_de_ingresos` WHERE `idpersonas_rango_de_ingresos`=3);
	END IF;
	IF ISNULL(@vsmdf4)  THEN
		SET @vsmdf4 = (SELECT (`limite_superior`*getMontoSalarioMinimo()) AS `superior` FROM `personas_rango_de_ingresos` WHERE `idpersonas_rango_de_ingresos`=4);
	END IF;
	

	IF SALARIO_MENSUAL <= @vsmdf1 THEN
		SET vRANGO=1;
	ELSEIF (SALARIO_MENSUAL > @vsmdf1) AND (SALARIO_MENSUAL <= @vsmdf2) THEN
		SET vRANGO=2;
	ELSEIF (SALARIO_MENSUAL > @vsmdf2) AND (SALARIO_MENSUAL <= @vsmdf3) THEN
		SET vRANGO=3;
	ELSEIF (SALARIO_MENSUAL > @vsmdf3) AND (SALARIO_MENSUAL <= @vsmdf4) THEN
		SET vRANGO=4;
	ELSE 
		SET vRANGO=5;
	END IF;
	
	RETURN vRANGO;
    END$$

DELIMITER ;



-- Rango de salario por persona
DELIMITER $$
DROP FUNCTION IF EXISTS `getRangoDeSalariosPorPersona`$$
CREATE
    FUNCTION `getRangoDeSalariosPorPersona`(IDPERSONA BIGINT(20))
    RETURNS INT(4)
    BEGIN
	DECLARE mSAL DOUBLE(14,2) DEFAULT 0;
	DECLARE mID INT(4) DEFAULT 0;
	SET mSAL = (SELECT  `monto_percibido_ae` FROM `socios_aeconomica` WHERE `socio_aeconomica` = IDPERSONA ORDER BY `fecha_alta` DESC LIMIT 0,1);
	IF ISNULL(mSAL)  THEN
		SET mID = 0;
	ELSE 
		SET mID = getRangoDeSalario(mSAL);
	END IF;
	RETURN mID;
    END$$

DELIMITER ;

-- Consulta TABLA TMP de rango de salarios
-- Saldos Mensuales con rango de ingresos

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_creditos_mensuales_cnivelsalarial`$$

CREATE
    PROCEDURE `proc_creditos_mensuales_cnivelsalarial`()
    BEGIN

	DROP VIEW IF EXISTS `tmp_creditos_mensuales_cnivelsalarial`;
	DROP TABLE IF EXISTS `tmp_creditos_mensuales_cnivelsalarial`;


CREATE TABLE `tmp_creditos_mensuales_cnivelsalarial` AS  
(

SELECT
`creditos_solicitud`.`numero_socio` AS `persona`,
`creditos_solicitud`.`numero_solicitud` AS `credito`,
`creditos_solicitud`.`periocidad_de_pago`,
`creditos_solicitud`.`tipo_convenio` ,
COUNT(`operaciones_mvtos`.`tipo_operacion`) AS `operaciones`,
MAX(`operaciones_mvtos`.`fecha_afectacion`) AS `fecha`,

getRangoDeSalariosPorPersona(`creditos_solicitud`.`numero_socio`) AS `nivel_salarial`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-01-31') ,0, `monto_autorizado`) -

 SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-01-31'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `enero`,

IF(`fecha_ministracion` > LAST_DAY(CONCAT(getEjercicioDeTrabajo(),'-02-01')), 0, `monto_autorizado`)  - 

SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= LAST_DAY(CONCAT(getEjercicioDeTrabajo(),'-02-01')))),`operaciones_mvtos`.`afectacion_real`,0)) AS `febrero`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-03-31'),0, `monto_autorizado`)  - 

SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-03-31'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `marzo`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-04-30'),0, `monto_autorizado`)  - 

SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-04-30'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `abril`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-05-31'),0, `monto_autorizado`)  - 
SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-05-31'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `mayo`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-06-30'),0, `monto_autorizado`)  - 
SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-06-30'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `junio`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-07-31'),0, `monto_autorizado`)  - 
SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-07-31'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `julio`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-08-31'),0, `monto_autorizado`)  - 
SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-08-31'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `agosto`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-09-30'),0, `monto_autorizado`)  -
 SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-09-30'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `septiembre`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-10-31'),0, `monto_autorizado`)  -
 SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-10-31'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `octubre`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-11-30'),0, `monto_autorizado`)  -
 SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-11-30'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `noviembre`,

IF(`fecha_ministracion` > CONCAT(getEjercicioDeTrabajo(),'-12-31'),0, `monto_autorizado`)  - 
SUM(IF(((`operaciones_mvtos`.`tipo_operacion` = 120) AND (`operaciones_mvtos`.`fecha_afectacion` <= CONCAT(getEjercicioDeTrabajo(),'-12-31'))),`operaciones_mvtos`.`afectacion_real`,0)) AS `diciembre`

FROM 
	`operaciones_mvtos` `operaciones_mvtos` 
		RIGHT OUTER JOIN `creditos_solicitud` `creditos_solicitud` 
		ON `operaciones_mvtos`.`docto_afectado` = `creditos_solicitud`.
		`numero_solicitud`

WHERE ((`operaciones_mvtos`.`tipo_operacion` = 120)
        OR (`operaciones_mvtos`.`tipo_operacion` = 110)
	OR (`operaciones_mvtos`.`tipo_operacion` = 117)
)
		AND `fecha_ministracion` <= CONCAT(getEjercicioDeTrabajo(),'-12-31')	
GROUP BY `creditos_solicitud`.`numero_solicitud`

) ;

	ALTER TABLE `tmp_creditos_mensuales_cnivelsalarial` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `persona`, ADD PRIMARY KEY (`indice`);
	ALTER TABLE `tmp_creditos_mensuales_cnivelsalarial` ADD INDEX `personacredito` (`persona`, `credito`) ;	
	UPDATE `tmp_creditos_mensuales_cnivelsalarial` SET `nivel_salarial` = IF((SELECT `personalidad_juridica` FROM `socios_general` WHERE `codigo`=`tmp_creditos_mensuales_cnivelsalarial`.`persona` LIMIT 0,1)=2, 0, `nivel_salarial`);
    END$$

DELIMITER ;


-- funcion traducir
DELIMITER $$
DROP FUNCTION IF EXISTS `setTraducir`$$
CREATE
    FUNCTION `setTraducir`(TXTPALABRA VARCHAR(100), TXTLANG VARCHAR(4))
    RETURNS VARCHAR(100)
    BEGIN
	DECLARE mTXT VARCHAR(100) DEFAULT "";

	SET mTXT = (SELECT `traduccion` FROM `sistema_lenguaje` WHERE `idioma`=TXTLANG AND `equivalente`=TXTPALABRA LIMIT 0,1);
	IF ISNULL(mTXT)  THEN
		SET mTXT = "NO_TRADUCIDO";
	END IF;
	RETURN mTXT;
    END$$

DELIMITER ;

-- - Function getTasaIVAGeneral

DELIMITER $$
DROP FUNCTION IF EXISTS `getTasaIVAGeneral`$$
CREATE

    FUNCTION `getTasaIVAGeneral`()
    RETURNS FLOAT(8,4)
    BEGIN
	IF ISNULL(@tasa_de_iva_general) THEN
		SET @tasa_de_iva_general = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'tasa_del_iva' LIMIT 0,1);
	END IF;
	RETURN @tasa_de_iva_general;


    END$$

DELIMITER ;

-- -- Actualizar Seguimiento
DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_actualizar_seguimiento`$$
CREATE  PROCEDURE `sp_actualizar_seguimiento`()
BEGIN
	UPDATE `creditos_solicitud` SET `omitir_seguimiento`= (SELECT`omitir_seguimiento` FROM `creditos_tipoconvenio` WHERE `idcreditos_tipoconvenio`=`creditos_solicitud`.`tipo_convenio` LIMIT 0,1 ) WHERE `omitir_seguimiento`=0;
END$$
DELIMITER ;

-- --


DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_correcciones`$$
CREATE  PROCEDURE `sp_correcciones`()
BEGIN

UPDATE `creditos_solicitud` AS CS INNER JOIN
(
SELECT MIN(`fecha_de_pago`) AS `fecha_de_pago_rt` ,`credito` AS `credito` FROM `creditos_letras_pendientes_rt` WHERE `letra`>0  GROUP BY `credito` ORDER BY `periodo_socio`
) AS CLP ON CLP.`credito`= CS.`numero_solicitud`
SET `fecha_de_proximo_pago`=CLP.`fecha_de_pago_rt`;

UPDATE `creditos_solicitud` SET `fecha_de_proximo_pago`=DATE_ADD(`fecha_ultimo_mvto`, INTERVAL `periocidad_de_pago` DAY) WHERE  `fecha_de_proximo_pago`='0000-00-00' AND `periocidad_de_pago` != 360;
UPDATE `creditos_solicitud` SET `fecha_de_proximo_pago`=`fecha_vencimiento` WHERE  `fecha_de_proximo_pago`='0000-00-00' AND `periocidad_de_pago` = 360;
UPDATE `creditos_solicitud` SET `fecha_ultimo_capital` = `fecha_ultimo_mvto` WHERE `fecha_ultimo_capital`='0000-00-00';
UPDATE `socios_region` SET `region`=`idsocios_region` WHERE ISNULL(`region`);


DROP TABLE IF EXISTS `fly_ultimos_recibos`;
CREATE TEMPORARY TABLE `fly_ultimos_recibos` (INDEX(`credito`))
AS (
SELECT
	`operaciones_recibos`.`docto_afectado`        AS `credito`,
	MAX(`operaciones_recibos`.`fecha_operacion`)       AS `fecha`,
	MAX(`operaciones_recibos`.`idoperaciones_recibos`) AS `recibo`
FROM
	`operaciones_recibos` `operaciones_recibos` 
WHERE
	(`operaciones_recibos`.`tipo_docto` =2)
GROUP BY `operaciones_recibos`.`docto_afectado`);

UPDATE `creditos_solicitud`,`fly_ultimos_recibos` SET `fecha_ultimo_capital` = `fly_ultimos_recibos`.`fecha`, `recibo_ultimo_capital`=`fly_ultimos_recibos`.`recibo` WHERE `fly_ultimos_recibos`.`credito`=`creditos_solicitud`.`numero_solicitud`
AND (`creditos_solicitud`.`fecha_ultimo_capital`='0000-00-00' OR `recibo_ultimo_capital`=0) ;


DELETE FROM `creditos_rechazados` WHERE `numero_de_credito`=0;

INSERT INTO `creditos_rechazados` (`numero_de_credito`,`fecha_de_rechazo`,`razones`)
SELECT `numero_solicitud`,`fecha_autorizacion`,`notas_auditoria`
FROM   `creditos_solicitud` WHERE `monto_autorizado`=0 AND `estatus_actual`=50 AND (SELECT COUNT(*) FROM `creditos_rechazados` WHERE  `numero_de_credito`=`creditos_solicitud`. `numero_solicitud`) <=0;


UPDATE `t_03f996214fba4a1d05a68b18fece8e71` SET `alias`= CONCAT(SUBSTRING_INDEX(`nombres`, ' ', 1), ' ',`apellidopaterno`) WHERE `alias`='' OR ISNULL(`alias`);

UPDATE `socios_vivienda` SET `clave_de_municipio`= (SELECT `codigo_de_municipio` FROM `tmp_colonias_activas`  WHERE  `codigo_postal`=`socios_vivienda`.`codigo_postal` LIMIT 0,1) WHERE `clave_de_municipio`=0;
UPDATE `socios_vivienda` SET `clave_de_entidadfederativa`= (SELECT `codigo_de_estado` FROM `tmp_colonias_activas`  WHERE  `codigo_postal`=`socios_vivienda`.`codigo_postal` LIMIT 0,1) WHERE `clave_de_entidadfederativa`=0;
UPDATE `socios_vivienda` SET `clave_de_municipio`= (
SELECT `valor_del_parametro` FROM `entidad_configuracion`  WHERE  `nombre_del_parametro`= 'domicilio.clave_de_municipio' LIMIT 0,1
) WHERE ISNULL(`clave_de_municipio`);
UPDATE `socios_vivienda` SET `clave_de_entidadfederativa`= (
SELECT `valor_del_parametro` FROM `entidad_configuracion`  WHERE  `nombre_del_parametro`= 'domicilio.clave_numerica_del_estado' LIMIT 0,1
) WHERE ISNULL(`clave_de_entidadfederativa`);

UPDATE `socios_general` SET `tipo_de_identificacion`=800 WHERE (SELECT COUNT(*) FROM `personas_documentacion_tipos` WHERE `clave_de_control`=`socios_general`.`tipo_de_identificacion`)<=0;

UPDATE `creditos_solicitud` SET `tipo_credito`= (SELECT `tipo_de_credito` FROM `creditos_tipoconvenio` WHERE `idcreditos_tipoconvenio`=`creditos_solicitud`.`tipo_convenio` LIMIT 0,1);


UPDATE `creditos_solicitud` SET `iva_interes`=( getTasaIVAPorApp(`destino_credito`)*(`interes_moratorio_devengado`-`interes_moratorio_pagado`)),
`iva_otros`=(getTasaIVAGeneral()*((`interes_moratorio_devengado`-`interes_moratorio_pagado`)+`gastoscbza`-`bonificaciones`));


UPDATE `creditos_solicitud` SET `ultimo_periodo_afectado` =
((SELECT  `parcialidad` FROM `vw_creditos_letras_actuales`  WHERE `vw_creditos_letras_actuales`.`credito`=`creditos_solicitud`.`numero_solicitud`)-1) WHERE 
(SELECT  COUNT(*) FROM `vw_creditos_letras_actuales`  WHERE `vw_creditos_letras_actuales`.`credito`=`creditos_solicitud`.`numero_solicitud`) > 0
AND `ultimo_periodo_afectado` != ((SELECT  `parcialidad` FROM `vw_creditos_letras_actuales`  WHERE `vw_creditos_letras_actuales`.`credito`=`creditos_solicitud`.`numero_solicitud`)-1) AND `periocidad_de_pago`!=360;

UPDATE `creditos_solicitud` SET saldo_actual = 0 WHERE `estatus_actual`=99 OR `estatus_actual`=98;

UPDATE `socios_vivienda` SET `principal` = '0' WHERE ISNULL(`principal`) OR `principal` ='';

UPDATE `creditos_solicitud` SET `ultimo_periodo_afectado` = 0 WHERE `ultimo_periodo_afectado` > 0 AND `monto_autorizado`=`saldo_actual` AND `recibo_ultimo_capital`<=0 AND `periocidad_de_pago`=360;

UPDATE `creditos_solicitud` SET `persona_asociada`=99 WHERE `persona_asociada`<=0;

UPDATE `operaciones_recibos`, `historial_de_pagos` SET `periodo_de_documento` =`periodo`  WHERE `periodo_de_documento`=0 AND `tipo_docto`=2 AND `historial_de_pagos`.`recibo`=`operaciones_recibos`.`idoperaciones_recibos`;


UPDATE `operaciones_mvtos` SET `socio_afectado` = (SELECT `numero_socio` FROM `creditos_solicitud` WHERE `numero_solicitud`= `operaciones_mvtos`.`docto_afectado` LIMIT 0,1 ) WHERE `socio_afectado`=`docto_afectado` AND `docto_afectado`>1;

UPDATE `empresas_cobranza` SET  `estado`= 1 WHERE `recibo`<=0;

UPDATE `empresas_cobranza`, `operaciones_recibos` SET `recibo`= `operaciones_recibos`.`idoperaciones_recibos`, `tiempocobro`=UNIX_TIMESTAMP(`operaciones_recibos`.`fecha_operacion`), `estado`=0 
WHERE `empresas_cobranza`.`recibo`=0 AND `operaciones_recibos`.`docto_afectado`=`empresas_cobranza`.`clave_de_credito` 
AND `operaciones_recibos`.`periodo_de_documento`=`empresas_cobranza`.`parcialidad` AND `operaciones_recibos`.`tipo_docto`= 2;


UPDATE `operaciones_recibos`,`tesoreria_tipos_de_pago` SET `operaciones_recibos`.`origen_aml` = `tesoreria_tipos_de_pago`.`equivalente_aml` WHERE `operaciones_recibos`.`tipo_pago` = `tesoreria_tipos_de_pago`.`tipo_de_pago` AND `operaciones_recibos`.`origen_aml`=0;


UPDATE `socios_relaciones`, `socios_general` SET `apellido_paterno`=`apellidopaterno`, `apellido_materno`=`apellidomaterno`, `socios_relaciones`.`nombres`=`socios_general`.`nombrecompleto`, 
`fecha_nacimiento`=`fechanacimiento`, `telefono_movil`=`telefono_principal`,`socios_relaciones`.`curp`=`socios_general`.`curp` WHERE `socios_relaciones`.`numero_socio`=`socios_general`.`codigo`;

UPDATE `eacp_config_bases_de_integracion_miembros` SET `subclasificacion` =10001 WHERE `subclasificacion` =0 AND `codigo_de_base` = '10001';



UPDATE `socios_general` SET `nss` = (SELECT `numero_de_seguridad_social` FROM `socios_aeconomica` WHERE `socios_aeconomica`.`socio_aeconomica`= `socios_general`.`codigo` AND `estado_actual`!=0 AND `numero_de_seguridad_social`!='' LIMIT 0,1) WHERE `nss` = '' OR ISNULL(`nss`);
UPDATE `socios_general` SET `nss` = '' WHERE ISNULL(`nss`);




UPDATE `creditos_rechazados` SET `claverechazo`=999 WHERE `claverechazo`=0;
UPDATE `creditos_rechazados` SET `idusuario`=1 WHERE `idusuario`=0;
UPDATE `creditos_rechazados` SET `tiempo`= UNIX_TIMESTAMP() WHERE `tiempo`=0;


UPDATE `creditos_solicitud` SET `fecha_ultimo_mvto`=`fecha_solicitud` WHERE `fecha_ultimo_mvto`='0000-00-00';
UPDATE `creditos_solicitud` SET `fecha_de_proximo_pago`=`fecha_de_primer_pago` WHERE ISNULL(`fecha_de_proximo_pago`);
UPDATE `creditos_solicitud` SET `fecha_conciliada`=`fecha_solicitud` WHERE `fecha_conciliada`='0000-00-00';


UPDATE `socios_general` SET `xclasificacion`=1 WHERE `xclasificacion`=0;
UPDATE `socios_general` SET `yclasificacion`=1 WHERE `yclasificacion`=0;
UPDATE `socios_general` SET `zclasificacion`=1 WHERE `zclasificacion`=0;


UPDATE `socios_vivienda` SET `calle`=UC_FIRST(`calle`),`numero_exterior`=UC_FIRST(`numero_exterior`),`colonia` = UC_FIRST(`colonia`), `estado`=UC_FIRST(`estado`),`municipio`=UC_FIRST(`municipio`),`referencia`=UC_FIRST(`referencia`),`nombre_de_pais`=UC_FIRST(`nombre_de_pais`);

UPDATE `general_estados` SET `nombre` = UC_FIRST(`nombre`);


UPDATE `socios_aeconomica` SET `domicilio_ae`=UC_FIRST(`domicilio_ae`), `nombre_ae`=UC_FIRST(`nombre_ae`), `localidad_ae`=UC_FIRST(`localidad_ae`), `municipio_ae`=UC_FIRST(`municipio_ae`), `estado_ae`=UC_FIRST(`estado_ae`), `departamento_ae`=UC_FIRST(`departamento_ae`), `puesto`=UC_FIRST(`puesto`), `descripcion`=UC_FIRST(`descripcion`);

END$$

DELIMITER ;


-- -- Proceso de Correccion en Base de Datos
DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_setFoliosAlMaximo`$$
CREATE  PROCEDURE `sp_setFoliosAlMaximo`()
BEGIN
	TRUNCATE `general_folios`;
	INSERT INTO `general_folios` (
				`idgeneral_folios`,
				`numerooperacion`, 
				`numerocredito`, 
				`numerosocio`, 
				`numerocontrato` , 
				`numeroestadistico`, 
				`numerorecibo`, 
				`numerogposolidario` , 
				`polizacontable`) 
			VALUES( 
				1,
				COALESCE( ( SELECT MAX(idoperaciones_mvtos) FROM operaciones_mvtos ),0), 
				COALESCE( ( SELECT MAX(numero_solicitud) FROM creditos_solicitud ),0 ), 
				COALESCE( ( SELECT MAX(codigo) FROM socios_general ),0), 
				COALESCE( ( SELECT MAX(numero_cuenta)  FROM captacion_cuentas ),0),
				0, 
				COALESCE( ( SELECT MAX(idoperaciones_recibos) FROM operaciones_recibos ),0), 
				COALESCE( ( SELECT MAX(idsocios_grupossolidarios) FROM socios_grupossolidarios ),0),
				'');
END$$
DELIMITER ;

-- funcion redondeo
DELIMITER $$
DROP FUNCTION IF EXISTS `EnMiles`$$
CREATE
    FUNCTION `EnMiles`(cCant DOUBLE)
    RETURNS INT
    BEGIN
	RETURN ROUND((cCant/1000),0);
    END$$

DELIMITER ;
-- -------------------------------
-- -------------------------------
-- funcion traducir
DELIMITER $$
DROP FUNCTION IF EXISTS `getTrad`$$
CREATE
    FUNCTION `getTrad`(TXTPALABRA VARCHAR(100))
    RETURNS VARCHAR(100)
    BEGIN
	DECLARE mTXT VARCHAR(100) DEFAULT "";

	IF ISNULL(@sistema_lenguaje_actual) THEN
		SET @sistema_lenguaje_actual = (SELECT valor_del_parametro  FROM entidad_configuracion WHERE nombre_del_parametro = 'system_language' LIMIT 0,1);
	END IF;


	SET mTXT = (SELECT `traduccion` FROM `sistema_lenguaje` WHERE `idioma`=UPPER(@sistema_lenguaje_actual) AND `equivalente`=TXTPALABRA LIMIT 0,1);
	IF ISNULL(mTXT)  THEN
		SET mTXT = "NO_TRADUCIDO";
	END IF;
	RETURN mTXT;
    END$$

DELIMITER ;

-- Operadores de Fechas

DELIMITER $$
DROP FUNCTION IF EXISTS `getDiaMes`$$
CREATE
    FUNCTION `getDiaMes`(vDia VARCHAR(3), vMes VARCHAR(3))
    RETURNS DATE
    BEGIN
	DECLARE mLimit INT(3) DEFAULT 1;
	SET mLimit = DAY(LAST_DAY(CONCAT(getEjercicioDeTrabajo(), '-', vMes , '-01')));
	IF vDia IS NULL THEN
		SET vDia = mLimit;
	ELSE 
		SET vDia = CAST(vDia AS UNSIGNED);

		IF vDia > mLimit OR  vDia <= 0 THEN
			SET vDia = mLimit;
		END IF;
	
	END IF;
 RETURN STR_TO_DATE(CONCAT(getEjercicioDeTrabajo(), ',', vMes, ',',vDia),'%Y,%m,%d');

    END$$

DELIMITER ;

DELIMITER $$
DROP FUNCTION IF EXISTS `getProxMes`$$
CREATE
    FUNCTION `getProxMes`(vFecha DATE)
    RETURNS DATE
    BEGIN
	RETURN DATE_ADD(vFecha, INTERVAL 1 MONTH);

    END$$

DELIMITER ;



-- Tabla de Aportaciones

DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_tabla_cal_aports`$$
CREATE  PROCEDURE `sp_tabla_cal_aports`()
BEGIN

DROP TABLE IF EXISTS `tmp_personas_aport_cal`;

CREATE TABLE `tmp_personas_aport_cal` AS  
(

SELECT
	`entidad_pagos_perfil`.`tipo_de_operacion`,
	`socios_general`.`codigo` AS `persona`,
	1 AS `tipo`,
	
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,1) ,0, `entidad_pagos_perfil`.`monto`) AS `enero`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,2) ,0, `entidad_pagos_perfil`.`monto`) AS `febrero`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,3) ,0, `entidad_pagos_perfil`.`monto`) AS `marzo`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,4) ,0, `entidad_pagos_perfil`.`monto`) AS `abril`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,5) ,0, `entidad_pagos_perfil`.`monto`) AS `mayo`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,6) ,0, `entidad_pagos_perfil`.`monto`) AS `junio`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,7) ,0, `entidad_pagos_perfil`.`monto`) AS `julio`,
	
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,8) ,0, `entidad_pagos_perfil`.`monto`) AS `agosto`,

	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,9) ,0, `entidad_pagos_perfil`.`monto`) AS `septiembre`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,10) ,0, `entidad_pagos_perfil`.`monto`) AS `octubre`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,11) ,0, `entidad_pagos_perfil`.`monto`) AS `noviembre`,
	IF(getProxMes(`socios_general`.`fechaalta`) > getDiaMes(`personas_datos_colegiacion`.`dia_de_pago`,12) ,0, `entidad_pagos_perfil`.`monto`) AS `diciembre`

FROM
	`entidad_pagos_perfil` `entidad_pagos_perfil` 
		INNER JOIN `personas_datos_colegiacion` `personas_datos_colegiacion` 
		ON `entidad_pagos_perfil`.`tipo_de_membresia` = 
		`personas_datos_colegiacion`.`tipo_de_afiliacion` 
			INNER JOIN `socios_general` `socios_general` 
			ON `personas_datos_colegiacion`.`clave_de_persona` = 
			`socios_general`.`codigo`


WHERE
	(`entidad_pagos_perfil`.`periocidad` =30)

) ;

	ALTER TABLE `tmp_personas_aport_cal` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `diciembre`, ADD PRIMARY KEY (`indice`);
	ALTER TABLE `tmp_personas_aport_cal` ADD INDEX `personaitem` (`persona`, `tipo_de_operacion`) ;	
	



INSERT INTO `tmp_personas_aport_cal`(`tipo_de_operacion`,`persona`,`tipo`,`enero`,`febrero`,`marzo`,`abril`,`mayo`,`junio`,`julio`,`agosto`,`septiembre`,`octubre`,`noviembre`,`diciembre`) 

SELECT

	`operaciones_mvtos`.`tipo_operacion` AS `tipo_de_operacion`,
	`operaciones_mvtos`.`socio_afectado` AS `persona`,
	-1 AS `tipo`,
	SUM(IF((`fecha_operacion`>=getAntMes(getDiaMes(`dia_de_pago`,1)) 
	AND `operaciones_mvtos`.`periodo_socio` =1 
	AND `operaciones_mvtos`.`fecha_operacion` <=getDiaMes(`dia_de_pago`,12)), `afectacion_real`,0)) AS `pago_enero`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 2, `afectacion_real`,0)) AS `febrero`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 3, `afectacion_real`,0)) AS `marzo`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 4, `afectacion_real`,0)) AS `abril`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 5, `afectacion_real`,0)) AS `mayo`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 6, `afectacion_real`,0)) AS `junio`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 7, `afectacion_real`,0)) AS `julio`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 8, `afectacion_real`,0)) AS `agosto`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 9, `afectacion_real`,0)) AS `septiembre`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 10, `afectacion_real`,0)) AS `octubre`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 11, `afectacion_real`,0)) AS `noviembre`,
	SUM(IF(`operaciones_mvtos`.`periodo_socio` = 12, `afectacion_real`,0)) AS `diciembre`
	
FROM
	`personas_datos_colegiacion` `personas_datos_colegiacion` 
		INNER JOIN `operaciones_mvtos` `operaciones_mvtos` 
		ON `personas_datos_colegiacion`.`clave_de_persona` = `operaciones_mvtos`
		.`socio_afectado` 
			INNER JOIN `eacp_config_bases_de_integracion_miembros` 
			`eacp_config_bases_de_integracion_miembros` 
			ON `operaciones_mvtos`.`tipo_operacion` = 
			`eacp_config_bases_de_integracion_miembros`.`miembro` 
WHERE
	(`eacp_config_bases_de_integracion_miembros`.`codigo_de_base` =101) 
	AND
	(`operaciones_mvtos`.`fecha_operacion` >=CONCAT((getEjercicioDeTrabajo()-1),'-12-01') )
	AND
	(`operaciones_mvtos`.`fecha_operacion` <=CONCAT((getEjercicioDeTrabajo()+1),'-01-01') )
GROUP BY

	`operaciones_mvtos`.`tipo_operacion`,
	`operaciones_mvtos`.`socio_afectado`
		
ORDER BY
	`eacp_config_bases_de_integracion_miembros`.`codigo_de_base`;




END$$
DELIMITER ;


DELIMITER $$
DROP FUNCTION IF EXISTS `getAntMes`$$
CREATE
    FUNCTION `getAntMes`(vFecha DATE)
    RETURNS DATE
    BEGIN
	RETURN DATE_ADD(vFecha, INTERVAL -1 MONTH);

    END$$

DELIMITER ;

-- --

DELIMITER $$
DROP PROCEDURE IF EXISTS `sp_tmp_personas_geografia`$$
CREATE  PROCEDURE `sp_tmp_personas_geografia`()
BEGIN

	IF ISNULL(@entidad_clave_de_municipio) THEN
		SET @entidad_clave_de_municipio = (SELECT `valor_del_parametro` FROM `entidad_configuracion`  WHERE  `nombre_del_parametro`= 'domicilio.clave_de_municipio' LIMIT 0,1);
	END IF;
	IF ISNULL(@entidad_clave_de_estado) THEN
		SET @entidad_clave_de_estado = (SELECT `valor_del_parametro` FROM `entidad_configuracion`  WHERE  `nombre_del_parametro`= 'domicilio.clave_numerica_del_estado' LIMIT 0,1);
	END IF;
	IF ISNULL(@entidad_codigo_postal) THEN
		SET @entidad_codigo_postal = (SELECT `valor_del_parametro` FROM `entidad_configuracion`  WHERE  `nombre_del_parametro`= 'domicilio.codigo_postal' LIMIT 0,1);
	END IF;
	IF ISNULL(@entidad_clave_de_localidad) THEN
		SET @entidad_clave_de_localidad = (SELECT `valor_del_parametro` FROM `entidad_configuracion`  WHERE  `nombre_del_parametro`= 'domicilio.clave_de_localidad' LIMIT 0,1);
	END IF;
	IF ISNULL(@entidad_clave_de_pais) THEN
		SET @entidad_clave_de_pais = (SELECT `valor_del_parametro` FROM `entidad_configuracion`  WHERE  `nombre_del_parametro`= 'domicilio.clave_de_pais' LIMIT 0,1);
	END IF;	

DROP TABLE IF EXISTS `tmp_personas_geografia`;

CREATE TABLE `tmp_personas_geografia` AS  
(
SELECT
	`tvw_personas_geografia`.`codigo` AS `persona`,
	COALESCE(`tvw_personas_geografia`.`codigo_postal`, @entidad_codigo_postal) AS `codigo_postal`,
	COALESCE(`tvw_personas_geografia`.`clave_de_localidad`, @entidad_clave_de_localidad) AS `clave_de_localidad`,
	COALESCE(`tvw_personas_geografia`.`clave_de_pais`, @entidad_clave_de_pais) AS `clave_de_pais`,
	COALESCE(`tvw_personas_geografia`.`clave_de_municipio`, @entidad_clave_de_municipio) AS `clave_de_municipio`,
	COALESCE(`tvw_personas_geografia`.`clave_de_entidadfederativa` , @entidad_clave_de_estado) AS `clave_de_entidadfederativa`
FROM
	`tvw_personas_geografia`
GROUP BY
	`tvw_personas_geografia`.`codigo`
) ;

	ALTER TABLE `tmp_personas_geografia` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `clave_de_entidadfederativa`, ADD PRIMARY KEY (`indice`);
	ALTER TABLE `tmp_personas_geografia` ADD INDEX `personaitem` (`persona`) ;
	ALTER TABLE `tmp_personas_geografia` CHANGE `codigo_postal` `codigo_postal` INT(8) NULL, CHANGE `clave_de_localidad` `clave_de_localidad` INT(10) NULL, CHANGE `clave_de_pais` `clave_de_pais` VARCHAR(10) NULL, CHANGE `clave_de_municipio` `clave_de_municipio` INT(10) NULL, CHANGE `clave_de_entidadfederativa` `clave_de_entidadfederativa` INT(10) NULL;	
	

END$$
DELIMITER ;



-- - Function getTasaIVAPor Aplicacion

DELIMITER $$
DROP FUNCTION IF EXISTS `getTasaIVAPorApp`$$
CREATE

    FUNCTION `getTasaIVAPorApp`(IDAPP INT(10))
    RETURNS FLOAT(8,4)
    BEGIN
	DECLARE mIVA FLOAT(6,3) DEFAULT 0;
	SET mIVA = (SELECT `tasa_de_iva`  FROM `creditos_destinos` WHERE `idcreditos_destinos` = IDAPP LIMIT 0,1);
	
	IF ISNULL(mIVA) THEN
		SET mIVA = 0;
	END IF;
	RETURN mIVA;


    END$$

DELIMITER ;

-- - Descuentos en cheques y monto del cheque por recibo

DELIMITER $$

DROP FUNCTION IF EXISTS `getMChequeXRecibo`$$

CREATE FUNCTION `getMChequeXRecibo`(IdRecibo BIGINT(20) ) RETURNS FLOAT
BEGIN
DECLARE mMonto FLOAT(16,2) DEFAULT 0;
	SET mMonto = (SELECT `monto_real` FROM `bancos_operaciones` WHERE `recibo_relacionado`=IdRecibo LIMIT 0,1);
	IF ISNULL(mMonto) THEN
	SET mMonto = 0;
	END IF;
	RETURN mMonto;
    END$$

DELIMITER ;


DELIMITER $$

DROP FUNCTION IF EXISTS `getDChequeXDocto`$$

CREATE FUNCTION `getDChequeXDocto`(IdDocto BIGINT(20) ) RETURNS FLOAT
BEGIN
DECLARE mMonto FLOAT(16,2) DEFAULT 0;
	SET mMonto = (SELECT SUM(`monto_real`) FROM `bancos_operaciones` WHERE `documento_de_origen`=IdDocto AND `tipo_de_exhibicion`='descuento');
	IF ISNULL(mMonto) THEN
	SET mMonto = 0;
	END IF;
	RETURN mMonto;
    END$$

DELIMITER ;



DELIMITER $$

DROP FUNCTION IF EXISTS `getMChequeXRecibo`$$

CREATE FUNCTION `getMChequeXRecibo`(IdRecibo BIGINT(20) ) RETURNS FLOAT
BEGIN
DECLARE mMonto FLOAT(16,2) DEFAULT 0;
	SET mMonto = (SELECT `monto_real` FROM `bancos_operaciones` WHERE `recibo_relacionado`=IdRecibo LIMIT 0,1);
	IF ISNULL(mMonto) THEN
	SET mMonto = 0;
	END IF;
	RETURN mMonto;
    END$$

DELIMITER ;


DELIMITER $$

DROP FUNCTION IF EXISTS `getDChequeXCheq`$$

CREATE FUNCTION `getDChequeXCheq`( IdCheque VARCHAR(20) ) RETURNS FLOAT
BEGIN
DECLARE mMonto FLOAT(16,2) DEFAULT 0;
	SET mMonto = (SELECT SUM(`monto_real`) FROM `bancos_operaciones` WHERE `numero_de_documento` = IdCheque AND`tipo_de_exhibicion`='descuento'  );
	IF ISNULL(mMonto) THEN
	SET mMonto = 0;
	END IF;

	IF setNoMenorCero(IdCheque) <=0 THEN
	SET mMonto = 0;
	END IF;	
	RETURN mMonto;
    END$$

DELIMITER ;


-- Tabla de estadísticas de personas.
-- Mod: Nov/2016


DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_personas_estadisticas`$$
CREATE  PROCEDURE `sp_personas_estadisticas`()
BEGIN

DECLARE NumeroCreditos INT(6) DEFAULT 0;
DECLARE NumeroConSaldo INT(6) DEFAULT 0;
DECLARE TotalAutorizado DOUBLE(18,2) DEFAULT 0;
DECLARE TotalSolicitado DOUBLE(18,2) DEFAULT 0;
DECLARE TotalActual DOUBLE(18,2) DEFAULT 0;
DECLARE CreditoActivo BIGINT(20) DEFAULT 0;
DECLARE IDPersona BIGINT(20) DEFAULT 0;
DECLARE done INT DEFAULT FALSE;
DECLARE cur1 CURSOR FOR SELECT `numero_socio`, COUNT(`numero_solicitud`) AS `creditos`, SUM(IF(`saldo_actual`>1, 1, 0)) AS `con_saldo`, MAX(IF(`saldo_actual`>1,`numero_solicitud`,0)) AS `activo`,
SUM(`monto_autorizado`) AS `TotalAutorizado`, SUM(`monto_solicitado`) AS `TotalSolicitado`, SUM(`saldo_actual`) AS `TotalActual`
 FROM `creditos_solicitud` GROUP BY `numero_socio`
ORDER BY `numero_socio`,`creditos_solicitud`.`saldo_actual` DESC,`creditos_solicitud`.`fecha_ministracion` DESC;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;


DROP TABLE IF EXISTS `tmp_personas_estadisticas`;

CREATE TABLE `tmp_personas_estadisticas` AS  
(
SELECT `codigo` AS `persona`, 0 AS `creditos`, 0 AS `cuentas`, 0 AS `credito_activo`, 0 AS `creditos_con_saldo`, 0 AS `total_autorizado`, 0 AS `total_solicitado`, 0 AS `total_actual`,
0 AS `ingreso_mensual`,0 AS `num_refpersonales`, '' AS `inf_creditos`
FROM `socios_general`
) ;
ALTER TABLE `tmp_personas_estadisticas` 
CHANGE COLUMN `persona` `persona` BIGINT(20) UNSIGNED NOT NULL COMMENT '' ,
CHANGE COLUMN `creditos` `creditos` INT(4) NOT NULL DEFAULT '0' COMMENT '' ,
CHANGE COLUMN `cuentas` `cuentas` INT(4) NOT NULL DEFAULT '0' COMMENT '' ,
CHANGE COLUMN `creditos_con_saldo` `creditos_con_saldo` INT(4) NOT NULL DEFAULT '0' COMMENT '' ,
CHANGE COLUMN `total_autorizado` `total_autorizado` DOUBLE(18,2) DEFAULT 0 NULL,
CHANGE COLUMN `total_solicitado` `total_solicitado` DOUBLE(18,2) DEFAULT 0 NULL,
CHANGE COLUMN `total_actual` `total_actual` DOUBLE(18,2) DEFAULT 0 NULL,
CHANGE COLUMN `credito_activo` `credito_activo` BIGINT(20) UNSIGNED NOT NULL COMMENT '' ,

CHANGE COLUMN `ingreso_mensual` `ingreso_mensual` DOUBLE(18,2) DEFAULT 0 NULL,
CHANGE COLUMN `num_refpersonales` `num_refpersonales` BIGINT(20) UNSIGNED NOT NULL COMMENT '' ,
CHANGE COLUMN `inf_creditos` `inf_creditos` VARCHAR(250) DEFAULT '',

ADD PRIMARY KEY (`persona`);








OPEN cur1;

read_loop: LOOP
    FETCH cur1 INTO IDPersona, NumeroCreditos, NumeroConSaldo,CreditoActivo, TotalAutorizado, TotalSolicitado, TotalActual ;
    IF done THEN
      LEAVE read_loop;
    END IF;
	UPDATE `tmp_personas_estadisticas` SET `creditos` =NumeroCreditos, `creditos_con_saldo`=NumeroConSaldo, `total_autorizado`=TotalAutorizado, `total_solicitado`=TotalSolicitado, `total_actual` =TotalActual, `credito_activo`=CreditoActivo WHERE `persona`=IDPersona;
  END LOOP;

  CLOSE cur1;
  
UPDATE `tmp_personas_estadisticas` SET `num_refpersonales` = (SELECT   COUNT(`socios_relacionestipos`.`subclasificacion`)  FROM     `socios_relaciones` INNER JOIN `socios_relacionestipos`  ON `socios_relaciones`.`tipo_relacion` = `socios_relacionestipos`.`idsocios_relacionestipos`  WHERE    ( `socios_relaciones`.`estatus` = 10 ) AND ( `socios_relaciones`.`socio_relacionado` = `tmp_personas_estadisticas`.`persona` ) );

UPDATE `tmp_personas_estadisticas` SET `ingreso_mensual` = (SELECT SUM(`monto_percibido_ae`)  FROM `socios_aeconomica` WHERE `estado_actual`!=0 AND `socio_aeconomica`=`tmp_personas_estadisticas`.`persona`);

UPDATE `tmp_personas_estadisticas` SET `cuentas` = (SELECT COUNT(*) FROM `captacion_cuentas` WHERE `captacion_cuentas`.`numero_socio`= `tmp_personas_estadisticas`.`persona` );

UPDATE `tmp_personas_estadisticas` SET `ingreso_mensual`=0 WHERE ISNULL(`ingreso_mensual`);



END$$


DELIMITER ;

-- -- Domicilios de personas, una al dia, actualizables al cierre del dia
DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_personas_domicilios`$$

CREATE PROCEDURE `proc_personas_domicilios`()
BEGIN

-- DROP VIEW IF EXISTS `tmp_personas_domicilios`;
DROP TABLE IF EXISTS `tmp_personas_domicilios`;

CREATE TABLE `tmp_personas_domicilios` AS  
(
SELECT `codigo`, '' AS `domicilio` FROM `socios_general`
) ;

ALTER TABLE `tmp_personas_domicilios` ADD PRIMARY KEY (`codigo`);
ALTER TABLE `tmp_personas_domicilios` CHANGE COLUMN `domicilio` `domicilio` VARCHAR(200) NULL DEFAULT '';
ALTER TABLE `tmp_personas_domicilios` CHANGE COLUMN `codigo` `codigo` BIGINT(20) UNSIGNED NOT NULL ,ADD COLUMN `idlocalidad` INT(8) NULL DEFAULT '0' AFTER `domicilio`,ADD COLUMN `idmunicipio` INT(3) NULL DEFAULT '0' AFTER `idlocalidad`,ADD COLUMN `identidadfed` INT(3) NULL DEFAULT '0' AFTER `idmunicipio`, ADD COLUMN `idcodigopostal` INT(8) NULL DEFAULT '0' AFTER `identidadfed`,
ADD COLUMN `iddomicilio` INT(8) NULL DEFAULT '0' AFTER `idcodigopostal`,ADD COLUMN `idunicomun` VARCHAR(8) NULL DEFAULT '' AFTER `iddomicilio`;

-- 04jul2019
ALTER TABLE `tmp_personas_domicilios` ADD COLUMN `nestado` VARCHAR(80) NULL DEFAULT '' AFTER `idunicomun`, ADD COLUMN `nmunicipio` VARCHAR(100) NULL DEFAULT '' AFTER `nestado`,  ADD COLUMN `nlocalidad` VARCHAR(100) NULL DEFAULT '' AFTER `nestado`;
--

UPDATE `tmp_personas_domicilios` SET `iddomicilio` = (SELECT `idsocios_vivienda` FROM `socios_vivienda` WHERE `socios_vivienda`.`socio_numero`=`tmp_personas_domicilios`.`codigo` ORDER BY `principal` DESC LIMIT 0,1 );

UPDATE `tmp_personas_domicilios`,`socios_vivienda`
SET `tmp_personas_domicilios`.`domicilio`=CONCAT(
UCASE(`socios_vivienda`.`tipo_de_acceso`),' ',`socios_vivienda`.`calle`, 
IF(TRIM(`socios_vivienda`.`numero_exterior`) = '', '', CONCAT(',', `socios_vivienda`.`numero_exterior`)),
IF(TRIM(`socios_vivienda`.`numero_interior`) = '', '', CONCAT(',', `socios_vivienda`.`numero_interior`)),
',',`socios_vivienda`.`colonia`,',',`socios_vivienda`.`municipio`,',',`socios_vivienda`.`estado`,',',`socios_vivienda`.`codigo_postal`),
`tmp_personas_domicilios`.`idlocalidad`=`socios_vivienda`.`clave_de_localidad`,
`tmp_personas_domicilios`.`idmunicipio`=`socios_vivienda`.`clave_de_municipio`,
`tmp_personas_domicilios`.`identidadfed`=`socios_vivienda`.`clave_de_entidadfederativa`,
`tmp_personas_domicilios`.`idcodigopostal`=`socios_vivienda`.`codigo_postal`,
`tmp_personas_domicilios`.`idunicomun`=CONCAT(LPAD(`socios_vivienda`.`clave_de_entidadfederativa`,2,0),LPAD(`socios_vivienda`.`clave_de_municipio`,4,0) ),
`tmp_personas_domicilios`.`nestado`=`socios_vivienda`.`estado`,
`tmp_personas_domicilios`.`nmunicipio`=`socios_vivienda`.`municipio`,
`tmp_personas_domicilios`.`nlocalidad`=`socios_vivienda`.`localidad`

WHERE `tmp_personas_domicilios`.`iddomicilio`=`socios_vivienda`.`idsocios_vivienda`;


UPDATE `tmp_personas_domicilios` SET `domicilio` =  '', `iddomicilio` =  0 WHERE ISNULL(`iddomicilio`);

END$$

DELIMITER ;



-- Obtiene vivienda, no recomendado
DELIMITER $$

DROP FUNCTION IF EXISTS `getViviendaPorPersona`$$

CREATE FUNCTION `getViviendaPorPersona`( IdP BIGINT(20) ) RETURNS VARCHAR(200)
BEGIN
DECLARE mViv VARCHAR(200) DEFAULT '';
	SET mViv = (SELECT `domicilio` FROM `tmp_personas_domicilios` WHERE `codigo` = IdP LIMIT 0,1 );
	IF ISNULL(mViv) THEN
	SET mViv = '';
	END IF;

	RETURN mViv;
    END$$

DELIMITER ;

-- Dias de Mora por Crédito.

-- Operadores de Fechas

DELIMITER $$
DROP FUNCTION IF EXISTS `getDiasDeMora`$$
CREATE
    FUNCTION `getDiasDeMora`(vCredito BIGINT(20), vPeriocidad INT(4))
    RETURNS INT
    BEGIN
	DECLARE mDias INT(5) DEFAULT 0;
	DECLARE vFecha DATE DEFAULT getFechaDeCorte();
	IF vPeriocidad  = 360 THEN
		SET vFecha = (SELECT `fecha_vencimiento` FROM `creditos_solicitud` WHERE `numero_solicitud`=vCredito LIMIT 0,1);
	ELSE 
		SET vFecha = (SELECT `fecha_de_pago` FROM `creditos_letras_pendientes` WHERE `docto_afectado`=vCredito LIMIT 0,1);

	END IF;
	
	SET mDias = DATEDIFF(getFechaDeCorte(), vFecha);
	SET mDias = setNoMenorCero(mDias);
	IF ISNULL(mDias) THEN
		SET mDias = 0;
	END IF;
	RETURN mDias;

    END$$

DELIMITER ;


-- - Saldos Activos de Nominas


DELIMITER $$
DROP FUNCTION IF EXISTS `getNominaMontoAct`$$
CREATE
    FUNCTION `getNominaMontoAct`(vNomina BIGINT(20))
    RETURNS DOUBLE(12,2)
    BEGIN
	DECLARE mMonto DOUBLE(12,2) DEFAULT 0;
	
	SET mMonto = (SELECT SUM(`monto_enviado`)  FROM `empresas_cobranza` WHERE `clave_de_nomina`= vNomina AND `estado`=1);
	
	IF ISNULL(mMonto) THEN
		SET mMonto = 0;
	END IF;
	
	RETURN mMonto;

    END$$

DELIMITER ;

-- Split Mysql

DELIMITER $$
DROP FUNCTION IF EXISTS `getElementInStr`$$
CREATE
    FUNCTION `getElementInStr`(vStr VARCHAR(255), vDelim VARCHAR(4), vPos INT(2) )
    RETURNS VARCHAR(255)
    BEGIN
	
	RETURN REPLACE(SUBSTRING(SUBSTRING_INDEX(vStr, vDelim, vPos),
	       LENGTH(SUBSTRING_INDEX(vStr, vDelim, vPos -1)) + 1),
	       vDelim, '');

    END$$

DELIMITER ;


--  Funcion que traza los permisos superiores

DELIMITER $$

DROP FUNCTION IF EXISTS `getTraceParent`$$

CREATE FUNCTION `getTraceParent`(IDMenu INT(10)) RETURNS VARCHAR(50)
BEGIN
	DECLARE mParent INT DEFAULT 0;
	DECLARE mNombre VARCHAR(50) DEFAULT '';
	
	SET mParent = (SELECT `menu_parent` FROM `general_menu` WHERE `idgeneral_menu`=IDMenu LIMIT 0,1);
	IF ISNULL(mParent) THEN
		SET mParent = 0;
	END IF;
	
	
	
	IF mParent >0 THEN
		SET mNombre = (SELECT `menu_title` FROM `general_menu` WHERE `idgeneral_menu`=mParent LIMIT 0,1);
		SET mParent = (SELECT `menu_parent` FROM `general_menu` WHERE `idgeneral_menu`=mParent LIMIT 0,1);
		IF ISNULL(mParent) THEN
			SET mParent = 0;
		END IF;
				
		IF mParent >0 THEN
			SET mNombre = (SELECT `menu_title` FROM `general_menu` WHERE `idgeneral_menu`=mParent LIMIT 0,1);
		END IF;

	END IF;

		
	RETURN mNombre;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion que obtiene ultima letra registrada
-- - 02 de Agosto 2016
-- - --------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS `getUltimaLetraEnviada`$$

CREATE FUNCTION `getUltimaLetraEnviada`( IdCredito BIGINT(20) ) RETURNS INT(6)
BEGIN
DECLARE mLetra INT(6) DEFAULT 0;
	SET mLetra = (SELECT `periodo` FROM `vw_emp_ultimas_letras` WHERE `credito` = IdCredito LIMIT 0,1 );
	IF ISNULL(mLetra) THEN
		SET mLetra = 0;
	END IF;

	RETURN mLetra;
    END$$

DELIMITER ;






-- - --------------------------------
-- - Funcion que obtiene las letras pendientes de pago
-- - 02 de Agosto 2016
-- - --------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS `getLetrasPorPagarNomina`$$

CREATE FUNCTION `getLetrasPorPagarNomina`( IdCredito BIGINT(20), IdParc INT(4) ) RETURNS INT(6)
BEGIN
DECLARE mLetra INT(6) DEFAULT 0;
	SET mLetra = (SELECT SUM(IF(`empresas_cobranza`.`recibo`<=0 AND `empresas_cobranza`.`estado`=1,1,0)) AS `pendientes` 
	FROM `empresas_cobranza` WHERE `empresas_cobranza`.`clave_de_credito` = IdCredito AND `empresas_cobranza`.`parcialidad`!=IdParc AND `empresas_cobranza`.`estado`=1 );
	IF ISNULL(mLetra) THEN
		SET mLetra = 0;
	END IF;

	RETURN mLetra;
    END$$

DELIMITER ;


-- -- Letras proximas de pago .- Actualizado Agosto/2016
-- -- 
DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_creds_prox_letras`$$

CREATE PROCEDURE `proc_creds_prox_letras`()
BEGIN

-- DROP VIEW IF EXISTS `tmp_creds_prox_letras`;
DROP TABLE IF EXISTS `tmp_creds_prox_letras`;

CREATE TABLE `tmp_creds_prox_letras` AS  
(
SELECT
  `eacp_config_bases_de_integracion_miembros`.`codigo_de_base` AS `codigo_de_base`,
  `operaciones_mvtos`.`socio_afectado`                         AS `socio_afectado`,
  `operaciones_mvtos`.`docto_afectado`                         AS `docto_afectado`,
MIN(`operaciones_mvtos`.`periodo_socio`)                     AS `periodo_socio`,
MAX(`operaciones_mvtos`.`periodo_socio`)                     AS `ultimo_periodo`,

MIN(`operaciones_mvtos`.`fecha_afectacion`)                  AS `fecha_de_pago`,
MAX(`operaciones_mvtos`.`fecha_vcto`)                  AS `fecha_de_vencimiento`,
SUM(IF(`operaciones_mvtos`.`tipo_operacion` = 410,`operaciones_mvtos`.`afectacion_real`,0)) AS `capital`,

SUM(IF(`operaciones_mvtos`.`tipo_operacion` = 411,`operaciones_mvtos`.`afectacion_real`,0)) AS `interes`,
SUM(IF(`operaciones_mvtos`.`tipo_operacion` = 413,`operaciones_mvtos`.`afectacion_real`,0)) AS `iva`,
SUM(IF(`operaciones_mvtos`.`tipo_operacion` = 412,`operaciones_mvtos`.`afectacion_real`,0)) AS `ahorro`,
SUM(IF((`operaciones_mvtos`.`tipo_operacion` < 410 OR `operaciones_mvtos`.`tipo_operacion` > 413) , `operaciones_mvtos`.`afectacion_real`,0)) AS `otros`,

ROUND(SUM((`operaciones_mvtos`.`afectacion_real` * `eacp_config_bases_de_integracion_miembros`.`afectacion`)),2) AS `letra`,


SUM(IF((`operaciones_mvtos`.`tipo_operacion` = 410  AND `operaciones_mvtos`.`fecha_afectacion` < getFechaDeCorte()) ,`operaciones_mvtos`.`afectacion_real`,0)) AS `capital_exigible`,
SUM(IF((`operaciones_mvtos`.`tipo_operacion` = 411 AND `operaciones_mvtos`.`fecha_afectacion` < getFechaDeCorte()),`operaciones_mvtos`.`afectacion_real`,0)) AS `interes_exigible`,
SUM(IF((`operaciones_mvtos`.`tipo_operacion` = 413  AND `operaciones_mvtos`.`fecha_afectacion` < getFechaDeCorte()),`operaciones_mvtos`.`afectacion_real`,0)) AS `iva_exigible`,
SUM(IF((`operaciones_mvtos`.`tipo_operacion` = 412  AND `operaciones_mvtos`.`fecha_afectacion` < getFechaDeCorte()),`operaciones_mvtos`.`afectacion_real`,0)) AS `ahorro_exigible`,
SUM(IF(((`operaciones_mvtos`.`tipo_operacion` < 410 OR `operaciones_mvtos`.`tipo_operacion` > 413)  AND `operaciones_mvtos`.`fecha_afectacion` < getFechaDeCorte()) , `operaciones_mvtos`.`afectacion_real`,0)) AS `otros_exigible`,

ROUND(SUM(
IF((`operaciones_mvtos`.`tipo_operacion` = 410  AND `operaciones_mvtos`.`fecha_afectacion` < getFechaDeCorte()),
((`operaciones_mvtos`.`afectacion_real` * DATEDIFF(getFechaDeCorte(), `operaciones_mvtos`.`fecha_afectacion`) * (`creditos_solicitud`.`tasa_moratorio` + `creditos_solicitud`.`tasa_interes`) ) / getDivisorDeInteres())
, 0 )),2) AS `interes_moratorio`,

	`creditos_solicitud`.`monto_solicitado` AS `monto_original`,
	`creditos_solicitud`.`saldo_actual`     AS `saldo_principal` 
	
FROM 

	`operaciones_mvtos` `operaciones_mvtos` 
		INNER JOIN `creditos_solicitud` `creditos_solicitud` 
		ON `operaciones_mvtos`.`docto_afectado` = `creditos_solicitud`.
		`numero_solicitud` 
			INNER JOIN `eacp_config_bases_de_integracion_miembros` 
			`eacp_config_bases_de_integracion_miembros` 
			ON `operaciones_mvtos`.`tipo_operacion` = 
			`eacp_config_bases_de_integracion_miembros`.`miembro`
			
     
WHERE (`eacp_config_bases_de_integracion_miembros`.`codigo_de_base` = 2601)
AND `operaciones_mvtos`.`tipo_operacion` != 420 
AND `operaciones_mvtos`.`tipo_operacion` != 431
AND `creditos_solicitud`.`saldo_actual`  > 0
GROUP BY `operaciones_mvtos`.`periodo_socio`, `operaciones_mvtos`.`docto_afectado`
ORDER BY `eacp_config_bases_de_integracion_miembros`.`codigo_de_base`,`operaciones_mvtos`.`docto_afectado`
) ;

ALTER TABLE `tmp_creds_prox_letras` ADD COLUMN `indice` INT(10) NOT NULL AUTO_INCREMENT AFTER `saldo_principal`, ADD PRIMARY KEY (`indice`);
ALTER TABLE `tmp_creds_prox_letras` ADD INDEX `creditoletra` (`docto_afectado` ASC, `periodo_socio` ASC)  COMMENT '',ADD INDEX `idpersona` (`socio_afectado` ASC)  COMMENT '';
ALTER TABLE `tmp_creds_prox_letras` CHANGE `letra` `letra` DOUBLE(19,2) NULL, CHANGE `interes_moratorio` `interes_moratorio` DOUBLE(19,2) NULL; 
END$$

DELIMITER ;



-- -- Letras de recibos bancarios .- Actualizado Agosto/2016
-- -- 
DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_recs_datos_bancarios`$$

CREATE PROCEDURE `proc_recs_datos_bancarios`()
BEGIN

DROP TABLE IF EXISTS `tmp_recibos_datos_bancarios`;

CREATE TABLE `tmp_recibos_datos_bancarios` AS ( SELECT
  `bancos_operaciones`.`recibo_relacionado` AS `recibo`,
  COUNT(`bancos_operaciones`.`idcontrol`)   AS `operaciones`,
  MAX(`bancos_operaciones`.`cuenta_bancaria`) AS `banco`,
  MAX(`bancos_operaciones`.`fecha_expedicion`) AS `fecha`,
  SUM(`bancos_operaciones`.`monto_real`)    AS `monto`
FROM `bancos_operaciones`
GROUP BY `bancos_operaciones`.`recibo_relacionado`
) ;

ALTER TABLE `tmp_recibos_datos_bancarios` ADD INDEX `indexm` (`recibo` ASC, `banco` ASC);
END$$

DELIMITER ;



-- - --------------------------------
-- - Funcion devuelve un hash
-- - 17 de Octubre de 2016
-- - --------------------------------
DELIMITER $$

DROP FUNCTION IF EXISTS `getHash`$$

CREATE FUNCTION `getHash`( vPwd VARCHAR(62) ) RETURNS VARCHAR(62)
BEGIN
DECLARE mPWD VARCHAR(62) DEFAULT '';
	SET mPWD = (SHA1(UNHEX(SHA1(MD5(vPwd)))) ); 

	RETURN mPWD;
END$$

DELIMITER ;



-- -- Ultimos Recibos
-- -- 04 Abril 2017
-- -- 
DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_creditos_ultimos_recs`$$

CREATE PROCEDURE `proc_creditos_ultimos_recs`()
BEGIN

DROP TABLE IF EXISTS `tmp_creditos_ultimos_recs`;

CREATE TABLE `tmp_creditos_ultimos_recs` ENGINE=INNODB AS ( 

SELECT   
         `operaciones_mvtos`.`docto_afectado` AS `documento`,
         
         MAX(IF(`operaciones_mvtos`.`tipo_operacion`= 120, `operaciones_mvtos`.`recibo_afectado`, 0)) AS `recibo_120`,
         MAX(IF(`operaciones_mvtos`.`tipo_operacion`= 140, `operaciones_mvtos`.`recibo_afectado`, 0)) AS `recibo_140`,
         MAX(IF(`operaciones_mvtos`.`tipo_operacion`= 110, `operaciones_mvtos`.`recibo_afectado`, 0)) AS `recibo_110`
FROM     `operaciones_mvtos`
WHERE    ( `operaciones_mvtos`.`afectacion_real` >0 )
GROUP BY docto_afectado
ORDER BY `operaciones_mvtos`.`fecha_operacion` DESC

) ;

ALTER TABLE `tmp_creditos_ultimos_recs` ADD INDEX `idxrcs` (`documento` ASC, `recibo_120` ASC, `recibo_140` ASC, `recibo_110` ASC);

END$$

DELIMITER ;


-- -- Capital y Operaciones por Recibo
-- -- 04 Abril 2017
-- -- 
DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_recibos_distrib`$$

CREATE PROCEDURE `proc_recibos_distrib`()
BEGIN

DROP TABLE IF EXISTS `tmp_recibos_distrib`;

CREATE TABLE `tmp_recibos_distrib` ENGINE=INNODB AS ( 

SELECT   
	`operaciones_mvtos`.`recibo_afectado` AS `recibo`,
         `operaciones_mvtos`.`docto_afectado` AS `documento`,
         `operaciones_mvtos`.`fecha_operacion` AS `fecha`,
         
         SUM(IF(`operaciones_mvtos`.`tipo_operacion`= 120, `operaciones_mvtos`.`afectacion_real`, 0)) AS `monto_120`,
         SUM(IF(`operaciones_mvtos`.`tipo_operacion`= 140, `operaciones_mvtos`.`afectacion_real`, 0)) AS `monto_140`,
         SUM(IF(`operaciones_mvtos`.`tipo_operacion`= 110, `operaciones_mvtos`.`afectacion_real`, 0)) AS `monto_110`
FROM     `operaciones_mvtos`
WHERE    ( `operaciones_mvtos`.`afectacion_real` >0 )
GROUP BY `recibo_afectado`
ORDER BY `operaciones_mvtos`.`docto_afectado`, `operaciones_mvtos`.`fecha_operacion` DESC

) ;

ALTER TABLE `tmp_recibos_distrib` ADD INDEX `idxrcs` (`documento` ASC, `recibo` ASC);

END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion devuelve un monto por el recibo segun un tipo de operacion
-- - 04/abril/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getMontoOpPorRecibo`$$

CREATE FUNCTION `getMontoOpPorRecibo`(IDRecibo BIGINT(20), IDOperacion INT(10)) RETURNS DOUBLE(18,2)
BEGIN
	DECLARE MMonto FLOAT(18,2) DEFAULT 0;
	
	IF IDOperacion = 120 THEN
		SET MMonto = ( SELECT `monto_120` FROM `tmp_recibos_distrib` WHERE `recibo`=IDRecibo );
	ELSEIF IDOperacion = 140 THEN
		SET MMonto = ( SELECT `monto_140` FROM `tmp_recibos_distrib` WHERE `recibo`=IDRecibo );
	END IF;
	 
	IF ISNULL(MMonto) THEN
		SET MMonto = 0;
	END IF;
	RETURN MMonto;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion devuelve un monto por el recibo segun un tipo de operacion
-- - 04/abril/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getUltimoReciboPorOp`$$

CREATE FUNCTION `getUltimoReciboPorOp`(IDDocto BIGINT(20), IDOperacion INT(10)) RETURNS BIGINT(20)
BEGIN
	DECLARE IDRec BIGINT(20) DEFAULT 0;
	
	IF IDOperacion = 120 THEN
		SET IDRec = ( SELECT `recibo` FROM `tmp_recibos_distrib` WHERE `monto_120`>0 AND `documento`=IDDocto ORDER BY `fecha` DESC LIMIT 0,1 );
	ELSEIF IDOperacion = 140 THEN
		SET IDRec = ( SELECT `recibo` FROM `tmp_recibos_distrib` WHERE `monto_140`>0 AND `documento`=IDDocto ORDER BY `fecha` DESC LIMIT 0,1 );
	END IF;
	 
	IF ISNULL(IDRec) THEN
		SET IDRec = 0;
	END IF;
	RETURN IDRec;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion devuelve un monto por el Credito segun un tipo de operacion
-- - 04/abril/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getUltimoMontoPorOp`$$

CREATE FUNCTION `getUltimoMontoPorOp`(IDDocto BIGINT(20), IDOperacion INT(10)) RETURNS DOUBLE(18,2)
BEGIN
	DECLARE MMonto FLOAT(18,2) DEFAULT 0;
	
	IF IDOperacion = 120 THEN
		SET MMonto = ( SELECT `monto_120` FROM `tmp_recibos_distrib` WHERE `monto_120`>0 AND `documento`=IDDocto ORDER BY `fecha` DESC LIMIT 0,1 );
	ELSEIF IDOperacion = 140 THEN
		SET MMonto = ( SELECT `monto_140` FROM `tmp_recibos_distrib` WHERE `monto_140`>0 AND `documento`=IDDocto ORDER BY `fecha` DESC LIMIT 0,1 );
	END IF;
	 
	IF ISNULL(MMonto) THEN
		SET MMonto = 0;
	END IF;
	RETURN MMonto;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion devuelve un monto por el Credito segun la Ultima Operacion
-- - 04/abril/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getUltimoMontoPagado`$$

CREATE FUNCTION `getUltimoMontoPagado`(IDDocto BIGINT(20), IDOperacion INT(10)) RETURNS DOUBLE(18,2)
BEGIN
	DECLARE MMonto FLOAT(18,2) DEFAULT 0;
	
	IF IDOperacion = 120 THEN
		SET MMonto = ( SELECT `monto_120` FROM `tmp_recibos_distrib` WHERE `documento`=IDDocto ORDER BY `fecha` DESC LIMIT 0,1 );
	ELSEIF IDOperacion = 140 THEN
		SET MMonto = ( SELECT `monto_140` FROM `tmp_recibos_distrib` WHERE `documento`=IDDocto ORDER BY `fecha` DESC LIMIT 0,1 );
	END IF;
	 
	IF ISNULL(MMonto) THEN
		SET MMonto = 0;
	END IF;
	RETURN MMonto;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion devuelve un monto cobrado en un mes por el Credito segun la Ultima Operacion
-- - 04/abril/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getMontoPagadoMexFecha`$$

CREATE FUNCTION `getMontoPagadoMexFecha`(IDDocto BIGINT(20), DFecha DATE) RETURNS DOUBLE(18,2)
BEGIN
	
	DECLARE MMonto FLOAT(18,2) DEFAULT 0;
	DECLARE MFechaI DATE DEFAULT '2017-01-01';
	DECLARE MFechaF DATE DEFAULT '2017-12-31';
	
	SET MFechaI = CONCAT(DATE_FORMAT(DFecha, "%Y-%m-"), '01');
	SET MFechaF = LAST_DAY(MFechaI);
	
	SET MMonto = ( SELECT SUM(`monto_120`)+SUM(`monto_140`) AS `cobrado`  FROM `tmp_recibos_distrib` WHERE `documento`=IDDocto AND `fecha` >= MFechaI AND `fecha` <= MFechaF);
	

	 
	IF ISNULL(MMonto) THEN
		SET MMonto = 0;
	END IF;
	RETURN MMonto;
    END$$

DELIMITER ;


-- -- 
-- -- Genera una consulta de pagos hechos a creditos
-- -- 04 Abril 2017
-- -- 
DELIMITER $$
DROP PROCEDURE IF EXISTS `proc_creditos_abonos_parciales`$$

CREATE PROCEDURE `proc_creditos_abonos_parciales`()
BEGIN

DROP TABLE IF EXISTS `tmp_creditos_abonos_parciales`;

CREATE TABLE `tmp_creditos_abonos_parciales` ENGINE=INNODB AS ( 

SELECT
  `eacp_config_bases_de_integracion_miembros`.`codigo_de_base` AS `codigo_de_base`,
  `operaciones_mvtos`.`socio_afectado`                         AS `socio_afectado`,
  `operaciones_mvtos`.`docto_afectado`                         AS `docto_afectado`,
  `operaciones_mvtos`.`periodo_socio`                          AS `periodo_socio`,
  MAX(`operaciones_mvtos`.`fecha_afectacion`)                  AS `fecha_de_pago`,
  MAX(`operaciones_mvtos`.`fecha_vcto`)                        AS `fecha_de_vencimiento`,
  SUM((CASE WHEN (`subclasificacion` = 120) THEN (`operaciones_mvtos`.`afectacion_real` * `afectacion`) ELSE 0 END)) AS `capital`,
  SUM((CASE WHEN (`subclasificacion` = 140) THEN (`operaciones_mvtos`.`afectacion_real` * `afectacion`) ELSE 0 END)) AS `interes_normal`,
SUM((CASE WHEN (`subclasificacion` = 141) THEN (`operaciones_mvtos`.`afectacion_real` * `afectacion`) ELSE 0 END)) AS `interes_moratorio`,
SUM((CASE WHEN (`subclasificacion` = 0) THEN (`operaciones_mvtos`.`afectacion_real` * `afectacion`) ELSE 0 END)) AS `otros`,
SUM((CASE WHEN (`subclasificacion` = 151) THEN (`operaciones_mvtos`.`afectacion_real` * `afectacion`) ELSE 0 END)) AS `impuesto`,

SUM(`operaciones_mvtos`.`afectacion_real` * `afectacion`) AS `total`,
SUM((CASE WHEN (`subclasificacion` = 120) THEN 1 ELSE 0 END)) AS `numero_pagos`

FROM (`operaciones_mvtos`
   JOIN `eacp_config_bases_de_integracion_miembros`
     ON ((`operaciones_mvtos`.`tipo_operacion` = `eacp_config_bases_de_integracion_miembros`.`miembro`)))
WHERE (`eacp_config_bases_de_integracion_miembros`.`codigo_de_base` = 15000)
GROUP BY `operaciones_mvtos`.`docto_afectado`,`operaciones_mvtos`.`periodo_socio`

	ORDER BY
		`eacp_config_bases_de_integracion_miembros`.`codigo_de_base`,
		`operaciones_mvtos`.`docto_afectado`,
		`operaciones_mvtos`.`periodo_socio`

) ;

ALTER TABLE `tmp_creditos_abonos_parciales` CHANGE COLUMN `capital` `capital` DOUBLE(18,2) NULL DEFAULT 0 ,CHANGE COLUMN `interes_normal` `interes_normal` DOUBLE(18,2) NULL DEFAULT 0 ,CHANGE COLUMN `interes_moratorio` `interes_moratorio` DOUBLE(18,2) NULL DEFAULT 0 ,CHANGE COLUMN `otros` `otros` DOUBLE(18,2) NULL DEFAULT 0 ,CHANGE COLUMN `impuesto` `impuesto` DOUBLE(18,2) NULL DEFAULT 0 ,CHANGE COLUMN `total` `total` DOUBLE(18,2) NULL DEFAULT 0 ;

ALTER TABLE `tmp_creditos_abonos_parciales` ADD INDEX `imdx` (`docto_afectado` ASC, `socio_afectado` ASC, `periodo_socio` ASC);


END$$

DELIMITER ;


-- -- 
-- -- Genera una consulta de pagos hechos a creditos
-- -- 04 Abril 2017
-- -- 
DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_creditos_abonos_totales`$$

CREATE PROCEDURE `proc_creditos_abonos_totales`()
BEGIN

DROP TABLE IF EXISTS `tmp_creditos_abonos_totales`;

CREATE TABLE `tmp_creditos_abonos_totales` ENGINE=INNODB AS ( 

SELECT
	`operaciones_mvtos`.`docto_afectado` AS `docto_afectado`,
	`operaciones_mvtos`.`socio_afectado` AS `socio_afectado`,
	
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 110,`operaciones_mvtos`.`afectacion_real`,0)) AS 'desembolso',
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 117,`operaciones_mvtos`.`afectacion_real`,0)) AS 'disposicion',
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 120,`operaciones_mvtos`.`afectacion_real`,0)) AS 'abonos',
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 410,`operaciones_mvtos`.`afectacion_real`,0)) AS 'pendiente',
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 411,`operaciones_mvtos`.`afectacion_real`,0)) AS 'pendiente_interes',
				
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 802,`operaciones_mvtos`.`afectacion_real`,0)) AS 'bon_int',
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 801,`operaciones_mvtos`.`afectacion_real`,0)) AS 'bon_mora',
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 803,`operaciones_mvtos`.`afectacion_real`,0)) AS 'bon_otros',
				
				
	MIN(IF(`operaciones_mvtos`.`tipo_operacion`  = 410 AND `operaciones_mvtos`.`afectacion_real` >0,`operaciones_mvtos`.`periodo_socio`,99999)) AS 'letra_capital',
	MIN(IF(`operaciones_mvtos`.`tipo_operacion`  = 411 AND `operaciones_mvtos`.`afectacion_real` >0,`operaciones_mvtos`.`periodo_socio`,99999)) AS 'letra_interes',
	SUM(IF(`operaciones_mvtos`.`tipo_operacion`  = 120,1,0)) AS 'num_abonos',
	MAX(IF(`operaciones_mvtos`.`tipo_operacion`  = 410,`operaciones_mvtos`.`periodo_socio`,0)) AS 'letra_capital_u',
	MAX(IF(`operaciones_mvtos`.`tipo_operacion`  = 411,`operaciones_mvtos`.`periodo_socio`,0)) AS 'letra_interes_u'				
			FROM
				`operaciones_mvtos` `operaciones_mvtos` 

			GROUP BY
				`operaciones_mvtos`.`docto_afectado` 
);

ALTER TABLE `tmp_creditos_abonos_totales` ADD INDEX `imdxx` (`docto_afectado` ASC, `socio_afectado` ASC);


END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion el monto actual de creditos por tipo de originacion
-- - 04/Junio/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getMontoActualPorOrigen`$$

CREATE FUNCTION `getMontoActualPorOrigen`(IDOrigen INT, IDTipoOrigen INT) RETURNS DOUBLE(18,2)
BEGIN
	
	DECLARE MMonto FLOAT(18,2) DEFAULT 0;
	
	SET MMonto = ( SELECT SUM(`saldo_actual`) FROM `vw_originacion_sumas` WHERE `clave` = IDOrigen AND `tipo_de_origen`=IDTipoOrigen);
	

	 
	IF ISNULL(MMonto) THEN
		SET MMonto = 0;
	END IF;
	RETURN MMonto;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion Que checa si existe una estructura
-- - 21/Julio/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `setNuevaEstructura`$$

CREATE FUNCTION `setNuevaEstructura`(IDTabla VARCHAR(40), IDCampo VARCHAR(40), mValor VARCHAR(20), mTipo VARCHAR(20), vTamannio INT(4), vTitulo VARCHAR(40), vTipo VARCHAR(20) ) RETURNS INT(4)
BEGIN
	
	DECLARE MExiste INT(4) DEFAULT 0;
	
	SET MExiste = ( SELECT COUNT(`index_struct`) FROM `general_structure` WHERE `tabla`=IDTabla AND `campo`=IDCampo);
	

	 
	IF ISNULL(MExiste) THEN
		SET MExiste = 0;
	END IF;
	
	IF MExiste <1 THEN
		INSERT INTO general_structure(tabla, campo, valor, tipo, longitud, titulo, control) VALUES (IDTabla, IDCampo, mValor, mTipo, vTamannio, vTitulo, vTipo);
	END IF;
	
	RETURN MExiste;
    END$$

DELIMITER ;

-- - --------------------------------
-- - Funcion Que checa si existe una estructura
-- - 21/Julio/2017
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `setNuevoPermisoX`$$

CREATE FUNCTION `setNuevoPermisoX`(IDArchivo VARCHAR(60)) RETURNS INT(8)
BEGIN
	
	DECLARE MExiste INT(4) DEFAULT 0;
	
	SET MExiste = ( SELECT COUNT(`idgeneral_menu`) FROM `general_menu` WHERE `menu_file` LIKE CONCAT('%', IDArchivo, '%'));
	

	 
	IF ISNULL(MExiste) THEN
		SET MExiste = 0;
	END IF;
	
	IF MExiste <1 THEN
		INSERT INTO `general_menu` (`menu_title`,`menu_file`) VALUES (IDArchivo, IDArchivo);
	END IF;
	
	RETURN MExiste;
    END$$

DELIMITER ;



-- -- 
-- -- Genera las cuotas anuales
-- -- 20 Octubre 2017
-- -- 
DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_crear_cuotas_anuales`$$

CREATE PROCEDURE `proc_crear_cuotas_anuales`( IDAnnio INT(6) )
BEGIN

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 1, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;


INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 2, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 3, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 4, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 5, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 6, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 7, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 8, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 9, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 10, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 11, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

INSERT INTO `personas_pagos_plan`(`ejercicio`,`periodo`, `persona`,`periocidad`,`monto`,`tipo_de_membresia`,`fecha_de_cancelacion`) SELECT IDAnnio, 12, `clave_de_persona`,`periocidad`,`monto`,`membresia`, `fecha_de_aplicacion` FROM `personas_pagos_perfil` WHERE `estatus`=1;

END$$

DELIMITER ;


-- -- 
-- -- Genera El ID de Pagos por Empresas
-- -- 20 Octubre 2017
-- -- 
DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_crear_id_opempresas`$$

CREATE PROCEDURE `proc_crear_id_opempresas`(  )
BEGIN

UPDATE `empresas_operaciones` SET `unid`=CONCAT(DATE_FORMAT(`fecha_final`, '%Y'), '-', `clave_de_empresa`, '-',`periocidad`, '-', `periodo_marcado`) WHERE `unid`='';

END$$

DELIMITER ;



-- -- 
-- -- Purga Valores de Recibos
-- -- 31 Octubre 2017
-- -- Las fechas 0000-00-00 no funcionan en ubuntu 16.04
-- -- 
DELIMITER $$

DROP TRIGGER IF EXISTS `operaciones_recibos_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `operaciones_recibos_BEFORE_INSERT` BEFORE INSERT ON `operaciones_recibos` FOR EACH ROW

BEGIN
IF NEW.tiempo <= 0 THEN
	SET NEW.tiempo = UNIX_TIMESTAMP();
END IF;

IF CONVERT(NEW.fecha_operacion, CHAR(12)) = '0000-00-00' THEN
	SET NEW.fecha_operacion = CURDATE();
END IF;


IF CONVERT(NEW.fecha_de_registro, CHAR(12))= '0000-00-00' THEN
	SET NEW.fecha_de_registro = CURDATE();
END IF;


IF CONVERT(NEW.fecha_valor, CHAR(12))= '0000-00-00' THEN
	SET NEW.fecha_valor = CURDATE();
END IF;

END $$

DELIMITER ;





-- -- 
-- -- Actualizacion de Valores de Credito
-- -- 28 Noviembre 2017
-- -- 
DELIMITER $$

DROP TRIGGER IF EXISTS `creditos_solicitud_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `creditos_solicitud_BEFORE_INSERT` BEFORE INSERT ON `creditos_solicitud` FOR EACH ROW

BEGIN
-- actualizar numero de Creditos

UPDATE `tmp_personas_estadisticas` SET `creditos`=`creditos`+1 WHERE `persona`= NEW.numero_socio;



END $$

DELIMITER ;

-- -- 17 Noviembre 2019
-- -- Creditos Montos

DELIMITER $$

DROP TRIGGER IF EXISTS `creditos_montos_BEFORE_UPDATE`$$

CREATE DEFINER = CURRENT_USER TRIGGER `creditos_montos_BEFORE_UPDATE` BEFORE UPDATE ON `creditos_montos` FOR EACH ROW

BEGIN

SET NEW.modified_at = CURRENT_TIMESTAMP();

END $$

DELIMITER ;


-- -- 
-- -- Actualizacion de Valores de Captacion
-- -- 28 Noviembre 2017
-- -- 
DELIMITER $$

DROP TRIGGER IF EXISTS `captacion_cuentas_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `captacion_cuentas_BEFORE_INSERT` BEFORE INSERT ON `captacion_cuentas` FOR EACH ROW

BEGIN
-- actualizar numero de Creditos

UPDATE `tmp_personas_estadisticas` SET `cuentas`=`cuentas`+1 WHERE `persona`= NEW.numero_socio;



END $$

DELIMITER ;

-- -- 17 Noviembre 2019
DELIMITER $$

DROP TRIGGER IF EXISTS `captacion_cuentas_BEFORE_UPDATE`$$

CREATE DEFINER = CURRENT_USER TRIGGER `captacion_cuentas_BEFORE_UPDATE` BEFORE UPDATE ON `captacion_cuentas` FOR EACH ROW
BEGIN

SET NEW.modified_at = CURRENT_TIMESTAMP();

END $$

DELIMITER ;



-- -- 
-- -- Purga SDPM de Creditos Pagados
-- -- Enero/2018
-- -- 
DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_purge_sdpm`$$

CREATE PROCEDURE `proc_purge_sdpm`( )
BEGIN

DELETE FROM `creditos_sdpm_historico` WHERE (SELECT `saldo_actual` FROM `creditos_solicitud` WHERE  `creditos_solicitud`.`numero_solicitud`=`creditos_sdpm_historico`.`numero_de_credito`) <=0.99;

END$$

DELIMITER ;



-- -- 
-- -- Get Clave de Municipio
-- -- Febrero/2018
-- -- 
DELIMITER $$

DROP FUNCTION IF EXISTS `getIDUMun`$$

CREATE FUNCTION `getIDUMun`( IdEE VARCHAR(2), IdMU VARCHAR(4) ) RETURNS VARCHAR(8)
BEGIN
DECLARE IDD VARCHAR(8) DEFAULT '';

DECLARE mMonto FLOAT(16,2) DEFAULT 0;
	SET IDD = CONCAT(LPAD(IdEE,2,0), '', LPAD(IdMU,4,0));
RETURN IDD;
END$$

DELIMITER ;



-- - --------------------------------
-- - Funcion que obtiene la clave de ID de municipio por persona
-- - 10/Feb/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getMunicipioByIDPers`$$

CREATE FUNCTION `getMunicipioByIDPers`(IDPers BIGINT(25)) RETURNS VARCHAR(8)
BEGIN
	
	DECLARE IDMuns VARCHAR(8) DEFAULT '';
	
	SET IDMuns = ( SELECT `idunicomun` FROM `tmp_personas_domicilios` WHERE `codigo`=IDPers LIMIT 0,1);
	

	 
	IF ISNULL(IDMuns) THEN
		SET IDMuns = '';
	END IF;
	RETURN IDMuns;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion que obtiene la ultima accion de seguimiento por persona
-- - 16/Feb/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getLastActByIDPers`$$

CREATE FUNCTION `getLastActByIDPers`(IDPers BIGINT(25)) RETURNS VARCHAR(100)
BEGIN
	
	DECLARE IDAct VARCHAR(100) DEFAULT '';
	
	SET IDAct = ( SELECT CONCAT(`fecha`, '-', `tipo`,'-', `credito`, '-#', `clave`) FROM `vw_seguimiento` WHERE `persona`=IDPers ORDER BY `fecha` DESC LIMIT 0,1);
	

	 
	IF ISNULL(IDAct) THEN
		SET IDAct = '';
	END IF;
	RETURN IDAct;
    END$$

DELIMITER ;

-- - --------------------------------
-- - Funcion que obtiene la ultima accion de seguimiento por persona
-- - 16/Feb/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getLastActByIDCred`$$

CREATE FUNCTION `getLastActByIDCred`(IDCred BIGINT(25)) RETURNS VARCHAR(100)
BEGIN
	
	DECLARE IDAct VARCHAR(100) DEFAULT '';
	
	SET IDAct = ( SELECT CONCAT(`fecha`, '-', `tipo`,'-', `credito`, '-#', `clave`) FROM `vw_seguimiento` WHERE `credito`=IDCred ORDER BY `fecha` DESC LIMIT 0,1);
	

	 
	IF ISNULL(IDAct) THEN
		SET IDAct = '';
	END IF;
	RETURN IDAct;
    END$$

DELIMITER ;


-- -- 
-- -- Genera el NSS de Personas
-- -- 01 Marzo 2018
-- -- 
DELIMITER $$

DROP TRIGGER IF EXISTS `socios_aeconomica_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `socios_aeconomica_BEFORE_INSERT` BEFORE INSERT ON `socios_aeconomica` FOR EACH ROW

BEGIN
-- Actualizar NSS
IF NEW.numero_de_seguridad_social != '' THEN
	UPDATE `socios_general` SET `nss`=NEW.numero_de_seguridad_social WHERE `codigo`=NEW.socio_aeconomica AND `nss` = '';
END IF;

END $$

DELIMITER ;


DELIMITER $$

DROP TRIGGER IF EXISTS `socios_aeconomica_BEFORE_UPDATE`$$

CREATE DEFINER = CURRENT_USER TRIGGER `socios_aeconomica_BEFORE_UPDATE` BEFORE UPDATE ON `socios_aeconomica` FOR EACH ROW

BEGIN
-- Actualizar NSS
IF NEW.numero_de_seguridad_social != '' THEN
	UPDATE `socios_general` SET `nss`=NEW.numero_de_seguridad_social WHERE `codigo`=NEW.socio_aeconomica AND `nss` = '';
END IF;

END $$

DELIMITER ;

-- -- 17 Noviembre 2019
-- -- Socios Memo

DELIMITER $$

DROP TRIGGER IF EXISTS `socios_memo_BEFORE_UPDATE`$$

CREATE DEFINER = CURRENT_USER TRIGGER `socios_memo_BEFORE_UPDATE` BEFORE UPDATE ON `socios_memo` FOR EACH ROW

BEGIN

SET NEW.modified_at = CURRENT_TIMESTAMP();

END $$

DELIMITER ;

-- -- 
-- -- genera-tiempo usuarios web notas 
-- -- 07-marzo-2018
-- -- 
DELIMITER $$

DROP TRIGGER IF EXISTS `usuarios_web_notas_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `usuarios_web_notas_BEFORE_INSERT` BEFORE INSERT ON `usuarios_web_notas` FOR EACH ROW

BEGIN
IF NEW.tiempo <= 0 THEN
	SET NEW.tiempo = UNIX_TIMESTAMP();
END IF;

END $$

DELIMITER ;

-- -- 
-- -- llena datos del plan de pagos
-- -- 21-marzo-2018
-- -- 
DELIMITER $$

DROP TRIGGER IF EXISTS `creditos_plan_de_pagos_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `creditos_plan_de_pagos_BEFORE_INSERT` BEFORE INSERT ON `creditos_plan_de_pagos` FOR EACH ROW

BEGIN

SET NEW.iva_castigos = getTasaIVAGeneral() * (NEW.penas+NEW.mora+NEW.gtoscbza);


SET NEW.total_base=NEW.capital+NEW.interes+NEW.impuesto;

SET NEW.total_c_otros=NEW.total_base+NEW.ahorro+NEW.otros;

SET NEW.total_c_castigos=NEW.total_c_otros+NEW.penas+NEW.gtoscbza+NEW.mora+NEW.iva_castigos-NEW.descuentos;

SET NEW.estatusactivo = 1;

END $$

DELIMITER ;

-- -- Actualizar Sumas de Planes de Pagos

DELIMITER $$

DROP TRIGGER IF EXISTS `creditos_plan_de_pagos_BEFORE_UPDATE`$$

CREATE DEFINER = CURRENT_USER TRIGGER `creditos_plan_de_pagos_BEFORE_UPDATE` BEFORE UPDATE ON `creditos_plan_de_pagos` FOR EACH ROW

BEGIN

SET NEW.iva_castigos = getTasaIVAGeneral() * (NEW.penas+NEW.mora+NEW.gtoscbza);


SET NEW.total_base=NEW.capital+NEW.interes+NEW.impuesto;

SET NEW.total_c_otros=NEW.total_base+NEW.ahorro+NEW.otros;

SET NEW.total_c_castigos=NEW.total_c_otros+NEW.penas+NEW.gtoscbza+NEW.mora+NEW.iva_castigos-NEW.descuentos;

END $$

DELIMITER ;



-- -- 
-- -- Genera el backup de un recibo
-- -- 23 Marzo 2018
-- -- 
DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_backup_recibo`$$

CREATE PROCEDURE `proc_backup_recibo`(IDRec BIGINT(25))
BEGIN

INSERT INTO `operaciones_mvtos_arch` SELECT * FROM `operaciones_mvtos` WHERE `recibo_afectado`=IDREC;
INSERT INTO `operaciones_recibos_arch` SELECT * FROM `operaciones_recibos` WHERE `idoperaciones_recibos`=IDRec;


END$$

DELIMITER ;


-- -- Actualiza otras tablas en los cambios que haya

DELIMITER $$

DROP TRIGGER IF EXISTS `leasing_usuarios_BEFORE_UPDATE`$$

CREATE DEFINER = CURRENT_USER TRIGGER `leasing_usuarios_BEFORE_UPDATE` BEFORE UPDATE ON `leasing_usuarios` FOR EACH ROW

BEGIN
IF NEW.correo_electronico != OLD.correo_electronico THEN
	UPDATE `t_03f996214fba4a1d05a68b18fece8e71` SET `f_28fb96d57b21090705cfdf8bc3445d2a`=NEW.correo_electronico WHERE  `f_28fb96d57b21090705cfdf8bc3445d2a`=OLD.correo_electronico;
END IF; 

END $$

DELIMITER ;



-- - --------------------------------
-- - Funcion que obtiene busca si un recibo existe en nomina
-- - 14/Abril/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getExistsInNomina`$$

CREATE FUNCTION `getExistsInNomina`(IDNom INT(10), IDRec BIGINT(25)) RETURNS BOOLEAN
BEGIN
	
	DECLARE IDCnt INT(4) DEFAULT 0;
	DECLARE IDRes BOOLEAN DEFAULT FALSE;
	
	SET IDCnt = ( SELECT COUNT(`idempresas_cobranza`) FROM `empresas_cobranza` WHERE `clave_de_nomina`=IDNom AND `recibo`= IDRec );
	 
	IF ISNULL(IDCnt) THEN
		SET IDCnt = 0;
	END IF;
	IF IDCnt > 0 THEN
		SET IDRes = TRUE;
	END IF;
	
	RETURN IDRes;
    END$$

DELIMITER ;


-- -- 
-- -- Actualiza el recibo si es de empresa
-- -- 14 Abril 2018
-- -- 

DELIMITER $$

DROP TRIGGER IF EXISTS `operaciones_recibos_BEFORE_UPDATE`$$

CREATE DEFINER = CURRENT_USER TRIGGER `operaciones_recibos_BEFORE_UPDATE` BEFORE UPDATE ON `operaciones_recibos` FOR EACH ROW


BEGIN

DECLARE myDiff FLOAT(12,2) DEFAULT 0;
DECLARE mSumRec DOUBLE(12,2) DEFAULT 0;

SET NEW.modified_at = CURRENT_TIMESTAMP();

IF NEW.persona_asociada >0 AND OLD.total_operacion != NEW.total_operacion THEN

	SET myDiff = NEW.total_operacion - OLD.total_operacion;
	IF myDiff != 0 THEN
		SET myDiff = 0;
		-- UPDATE `empresas_cobranza` SET `monto_enviado`=setNoMenorCero((`monto_enviado`-myDiff)) WHERE `recibo`=NEW.idoperaciones_recibos;
	END IF;


END IF;

END $$

DELIMITER ;

-- -- Actualizar Cobranza

DELIMITER $$

DROP TRIGGER IF EXISTS `empresas_cobranza_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `empresas_cobranza_BEFORE_INSERT` BEFORE INSERT ON `empresas_cobranza` FOR EACH ROW

BEGIN

IF NEW.monto_arch <= 0 THEN

SET NEW.monto_arch = NEW.monto_enviado;

END IF;


END $$

DELIMITER ;

-- - --------------------------------
-- - Funcion que obtiene el Alias de la empresa
-- - 14/Abril/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getAliasEmpresa`$$

CREATE FUNCTION `getAliasEmpresa`(IDEmp INT(8)) RETURNS VARCHAR(40)
BEGIN
	
	DECLARE IDNe VARCHAR(40) DEFAULT '';
	
	
	SET IDNe = ( SELECT `nombre_corto` FROM `socios_aeconomica_dependencias` WHERE `idsocios_aeconomica_dependencias`=IDEmp LIMIT 0,1 );
	 
	IF ISNULL(IDNe) THEN
		SET IDNe = '';
	END IF;

	RETURN IDNe;
    END$$

DELIMITER ;



-- --
-- -- funcion nueva traduccion
-- -- 
DELIMITER $$
DROP FUNCTION IF EXISTS `setNuevaTrad`$$
CREATE
    FUNCTION `setNuevaTrad`(TXTLANG VARCHAR(4), TXTPALABRA VARCHAR(100), TXTTRAD VARCHAR(100))
    RETURNS VARCHAR(100)
    BEGIN
	DECLARE mTXT VARCHAR(100) DEFAULT "";

	SET mTXT = (SELECT `traduccion` FROM `sistema_lenguaje` WHERE `idioma`=TXTLANG AND `equivalente`=TXTPALABRA LIMIT 0,1);
	IF ISNULL(mTXT)  THEN
		SET mTXT = 'new';
		INSERT INTO `sistema_lenguaje` (`equivalente`, `traduccion`, `extension`, `idioma`) VALUES (TXTPALABRA, TXTTRAD, '', TXTLANG);
	ELSE
		UPDATE `sistema_lenguaje` SET `traduccion` = TXTTRAD WHERE `idioma`=TXTLANG AND `equivalente`=TXTPALABRA;
	END IF;
	RETURN mTXT;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion que obtiene si el credito ya esta pagado
-- - 4/Junio/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getEsCreditoPagado`$$

CREATE FUNCTION `getEsCreditoPagado`(IDCred BIGINT(25)) RETURNS BOOLEAN
BEGIN
	
	DECLARE IDNe BOOLEAN DEFAULT FALSE;
	
	
	SET IDNe = ( SELECT IF((`saldo_actual` <=0 AND `monto_autorizado`>0 AND `estatus_actual` != 98 AND `estatus_actual` != 99), TRUE, FALSE) FROM `creditos_solicitud` WHERE `numero_solicitud`=IDCred LIMIT 0,1);
	 
	IF ISNULL(IDNe) THEN
		SET IDNe = FALSE;
	END IF;

	RETURN IDNe;
    END$$

DELIMITER ;


-- - --------------------------------
-- - Funcion que obtiene si un documento es activo por persona
-- - 20/Junio/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getEsDoctoEntregadoByP`$$

CREATE FUNCTION `getEsDoctoEntregadoByP`(IDPers BIGINT(25), vTipo INT(8)) RETURNS BOOLEAN
BEGIN
	
	DECLARE IDNe BOOLEAN DEFAULT FALSE;
	DECLARE EsMult BOOLEAN DEFAULT FALSE;
	DECLARE nActs INT(4) DEFAULT 0;
	
	SET nActs = ( SELECT COUNT(*) FROM `personas_documentacion` WHERE `clave_de_persona`=IDPers AND `estatus`=1 AND `tipo_de_documento`=vTipo );
	
	SET EsMult = ( SELECT IF(`es_mult`=1, TRUE, FALSE) AS `result` FROM `personas_documentacion_tipos` WHERE `clave_de_control`=vTipo );

	IF ISNULL(EsMult) THEN
		SET EsMult = FALSE;
	END IF;
	IF ISNULL(nActs) THEN
		SET nActs = 0;
	END IF;
	
	IF nActs > 0 THEN
		SET IDNe = TRUE;
	END IF;

	IF EsMult = TRUE THEN
		SET IDNe = FALSE;
	END IF;

	RETURN IDNe;
    END$$

DELIMITER ;



-- -- 
-- -- Inserta un Numero de cuenta Valido 
-- -- 16 Julio 2018
-- -- 
-- -- 

DELIMITER $$

DROP TRIGGER IF EXISTS `tesoreria_cajas_movimientos_BEFORE_INSERT`$$

CREATE DEFINER = CURRENT_USER TRIGGER `tesoreria_cajas_movimientos_BEFORE_INSERT` BEFORE INSERT ON `tesoreria_cajas_movimientos` FOR EACH ROW

BEGIN
DECLARE IDBanco INT(4) DEFAULT 0;
IF NEW.cuenta_bancaria > 0 THEN
	SET IDBanco = (SELECT `entidad_bancaria` FROM `bancos_cuentas` WHERE `idbancos_cuentas`=NEW.cuenta_bancaria LIMIT 0,1);
	IF ISNULL(IDBanco) THEN
		SET IDBanco = 2;
	END IF;
	SET NEW.banco = IDBanco;
END IF;



END $$

DELIMITER ;






-- - --------------------------------
-- - Funcion que obtiene un saldo a una fecha determinada
-- - 20/Junio/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getSaldoAFecha`$$

CREATE FUNCTION `getSaldoAFecha`(IDCred BIGINT(25), mMinistrado DOUBLE(18,2), vFecha DATE) RETURNS DOUBLE(18,2)
BEGIN
	DECLARE Abonos DOUBLE(18,2) DEFAULT 0;
	DECLARE Saldo DOUBLE(18,2) DEFAULT 0;
	
	SET Abonos = ( SELECT SUM((`afectacion_real` * `valor_afectacion`)) FROM `operaciones_mvtos` WHERE `tipo_operacion` =120 AND `fecha_afectacion` <= vFecha AND `docto_afectado`=IDCred);
	 
	IF ISNULL(Abonos) THEN
		SET Abonos = 0;
	END IF;
	
	SET Saldo = mMinistrado - Abonos;
	
	RETURN Saldo;
    END$$

DELIMITER ;

-- - --------------------------------
-- - Funcion que obtiene el monto de una cuota determinada
-- - 14/Agosto/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getMontoCuotaCred`$$

CREATE FUNCTION `getMontoCuotaCred`(IDCred BIGINT(25),IDParc INT(6) ) RETURNS DOUBLE(18,2)
BEGIN
	
	DECLARE Saldo DOUBLE(18,2) DEFAULT 0;
	
	SET Saldo = ( SELECT SUM(`letra`) FROM `tmp_creds_prox_letras` WHERE `docto_afectado`=IDCred AND `periodo_socio`=IDParc);
	 
	IF ISNULL(Saldo) THEN
		SET Saldo = 0;
	END IF;
	RETURN Saldo;
    END$$

DELIMITER ;

-- - --------------------------------
-- - Funcion que obtiene un mail por persona
-- - 21/dic/2018
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getMailByPersona`$$

CREATE FUNCTION `getMailByPersona`(IDPers BIGINT(25) ) RETURNS VARCHAR(80)
BEGIN
	
	DECLARE mMail VARCHAR(100) DEFAULT '';
	
	SET mMail = ( SELECT `correo_electronico` FROM `socios_general` WHERE `codigo`=IDPers LIMIT 0,1);
	 
	IF ISNULL(mMail) THEN
		SET mMail = '';
	END IF;
	RETURN mMail;
    END$$

DELIMITER ;


-- --------------------------------
-- - Funcion devuelve un plan de pago por Credito
-- - 11/Enero/2019
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getPlanDePagoByCred`$$

CREATE FUNCTION `getPlanDePagoByCred`(IDDocto BIGINT(20)) RETURNS BIGINT(20)
BEGIN
	DECLARE IDRec BIGINT(20) DEFAULT 0;
	
	SET IDRec = ( SELECT `idoperaciones_recibos` FROM `operaciones_recibos` WHERE `docto_afectado`=IDDocto AND  `tipo_docto`=11 ORDER BY `fecha_operacion` DESC LIMIT 0,1 );
	
	 
	IF ISNULL(IDRec) THEN
		SET IDRec = 0;
	END IF;
	RETURN IDRec;
    END$$

DELIMITER ;

-- Tabla de Obtener Avales.
-- Mod: Nov/2016


DELIMITER $$

DROP FUNCTION IF EXISTS `getDatosDeAvales`$$

CREATE FUNCTION `getDatosDeAvales`( IdCredito BIGINT(20) ) RETURNS VARCHAR(250) LANGUAGE SQL

BEGIN

	DECLARE done INTEGER DEFAULT 0;
	DECLARE  mStr VARCHAR(250) DEFAULT "";
	DECLARE  mTxt VARCHAR(250) DEFAULT "";
	DECLARE Nombre VARCHAR(150) DEFAULT "";
	DECLARE Correo VARCHAR(50) DEFAULT "";
	DECLARE Telefono VARCHAR(20) DEFAULT "";

	DECLARE cur1 CURSOR FOR SELECT `personas`.`nombre`, `personas`.`correo_electronico`, `personas`.`telefono`
	FROM `socios_relaciones` INNER JOIN `socios_relacionestipos`  ON `socios_relaciones`.`tipo_relacion` = `socios_relacionestipos`.`idsocios_relacionestipos` 
	INNER JOIN `personas`  ON `socios_relaciones`.`numero_socio` = `personas`.`codigo` WHERE ( `socios_relacionestipos`.`subclasificacion` = 5 ) AND ( `socios_relaciones`.`credito_relacionado` = IdCredito );
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN cur1;

	read_loop: LOOP
		FETCH cur1 INTO Nombre,Correo,Telefono;
			IF done THEN
				LEAVE read_loop;
			END IF;
			SET mTxt = Nombre;
			
			IF Correo != "" THEN
				SET mTxt = CONCAT(mTxt, ', Correo: ', Correo);
			END IF;
			IF Telefono != "" THEN
				SET mTxt = CONCAT(mTxt, ', Tel: ', Telefono);
			END IF;
			
			IF mStr = "" THEN
				SET mStr = mTxt;
			ELSE
				SET mStr  = CONCAT(mStr,'. ' , mTxt);
			END IF;
	END LOOP;

	CLOSE cur1;
  
RETURN mStr;



END$$

DELIMITER ;


-- --------------------------------
-- - Funcion devuelve si aplica el producto a la sucursal
-- - 11/Enero/2019
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getAplicaCredPdtoPorSuc`$$

CREATE FUNCTION `getAplicaCredPdtoPorSuc`(IDPdto INT(8), mSuc VARCHAR(40)) RETURNS BOOLEAN
BEGIN
	DECLARE mIncluir BOOLEAN DEFAULT FALSE;
	DECLARE IdHay INT(4) DEFAULT 0;
	
	SET IdHay = ( SELECT COUNT(`clave_del_parametro`) FROM `creditos_productos_otros_parametros` WHERE    (( `clave_del_parametro` = 'APLICA_SUCURSALES' ) AND ( `clave_del_producto` = IDPdto )) AND (INSTR (`valor_del_parametro`, mSuc)>0 OR INSTR (`valor_del_parametro`, 'todas')>0) AND (INSTR (`valor_del_parametro`, CONCAT('-',mSuc))<=0) );
	 
	IF ISNULL(IdHay) THEN
		SET IdHay = 0;
		SET mIncluir = FALSE;
	END IF;
	
	IF IdHay > 0 THEN
		SET mIncluir = TRUE;
	END IF;
	
	
	RETURN mIncluir;
	
    END$$

DELIMITER ;



-- --------------------------------
-- - Funcion devuelve el Numero de Creditos Procesados
-- - junio/2019
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getNumCredsByPersona`$$

CREATE FUNCTION `getNumCredsByPersona`(IDPersona BIGINT(20)) RETURNS INT(8)
BEGIN
	DECLARE NumId BIGINT(20) DEFAULT 0;
	
	SET NumId = ( SELECT COUNT(`numero_solicitud`) FROM `creditos_solicitud` WHERE `numero_socio`=IDPersona );
	
	 
	IF ISNULL(NumId) THEN
		SET NumId = 0;
	END IF;
	RETURN NumId;
    END$$

DELIMITER ;

-- --------------------------------
-- - Funcion devuelve el Numero de Creditos Sdo
-- - junio/2019
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getNumCredsSdoByPersona`$$

CREATE FUNCTION `getNumCredsSdoByPersona`(IDPersona BIGINT(20)) RETURNS INT(8)
BEGIN
	DECLARE NumId BIGINT(20) DEFAULT 0;
	
	SET NumId = ( SELECT COUNT(`numero_solicitud`) FROM `creditos_solicitud` WHERE `saldo_actual`>0 AND `estatus_actual` != 50 AND `numero_socio`=IDPersona );
	
	 
	IF ISNULL(NumId) THEN
		SET NumId = 0;
	END IF;
	RETURN NumId;
    END$$

DELIMITER ;


-- --------------------------------
-- Purgar Tabla de Montos.
-- --------------------------------


DELIMITER $$

DROP PROCEDURE IF EXISTS `setPurgeTablaMontos`$$

CREATE PROCEDURE `setPurgeTablaMontos`( ) 

BEGIN

	DECLARE done INTEGER DEFAULT 0;
	DECLARE  mStr VARCHAR(10) DEFAULT "";
	DECLARE IDCredito BIGINT(25) DEFAULT 0;
	DECLARE Numero INTEGER(4) DEFAULT 0;
	DECLARE Clave INTEGER(11) DEFAULT 0;
	DECLARE cur1 CURSOR FOR (SELECT `clave_de_credito`, COUNT(`idcreditos_montos`) AS `repetidos`, MIN(`idcreditos_montos`) AS `clave`  FROM `creditos_montos` GROUP BY `clave_de_credito` HAVING repetidos >1);

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN cur1;

	read_loop: LOOP
		FETCH cur1 INTO IDCredito,Numero,Clave;
			IF done THEN
				LEAVE read_loop;
			END IF;
			IF Numero > 1 THEN
				DELETE FROM `creditos_montos` WHERE `clave_de_credito` = IDCredito AND `idcreditos_montos` != Clave;
			END IF;

			
	END LOOP;

	CLOSE cur1;

END$$


-- --------------------------------
-- - Funcion devuelve los gastos de cobranza por mes, echale financiamiento
-- - Febrero/2020
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `getMtoGtosCbzaMes`$$

CREATE FUNCTION `getMtoGtosCbzaMes`(FechaVcto DATE) RETURNS DOUBLE(12,2)
BEGIN
	DECLARE NumMeses INT(4) DEFAULT 0;
	DECLARE MtoGtos DOUBLE(12,2) DEFAULT 0;
	SET NumMeses = ( SELECT TIMESTAMPDIFF(MONTH, FechaVcto, CURDATE()) );
	
	 
	IF ISNULL(NumMeses) THEN
		SET NumMeses = 0;
	END IF;
	
	SET MtoGtos = 300 * NumMeses;
	
	RETURN MtoGtos;
    END$$

DELIMITER ;




-- --------------------------------
-- - Funcion que setea permisos a objeto formulario
-- - Agosto/2020
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `setDenegarFormObj`$$

CREATE FUNCTION `setDenegarFormObj`(objFrm VARCHAR(40), obj VARCHAR(40), denegarTodos BOOLEAN ) RETURNS BOOLEAN
BEGIN
	DECLARE ClaveObj VARCHAR(25) DEFAULT '';
	DECLARE Existen INT DEFAULT 0;
	DECLARE Permisos VARCHAR(200) DEFAULT '2@rw,3@rw,4@rw,5@rw,6@rw,7@rw,8@rw,9@rw,10@rw,11@rw,12@rw,13@rw,14@rw,15@rw,31@rw,41@rw,71@rw,72@rw,73@rw,81@rw,99@rw';
	SET ClaveObj	= (SELECT CONCAT(CRC32(objFrm),'-f-',CRC32(obj)) );
	SET Existen 	= (SELECT COUNT(*) FROM `sistema_permisos` WHERE `accion`=ClaveObj);
	
	
	IF Existen>0 THEN
		IF denegarTodos = TRUE THEN
			UPDATE `sistema_permisos` SET `denegado`= Permisos WHERE `accion`=ClaveObj;
		END IF;
	ELSE
		IF denegarTodos = TRUE THEN
			INSERT INTO `sistema_permisos`(`idsistema_permisos`,`accion`,`denegado`,`descripcion`,`tipo_objeto`,`nombre_objeto`,`estatus`)
			VALUES (NULL,ClaveObj,Permisos,obj,'FORM',objFrm,1);

		ELSE
			INSERT INTO `sistema_permisos`(`idsistema_permisos`,`accion`,`denegado`,`descripcion`,`tipo_objeto`,`nombre_objeto`,`estatus`)
			VALUES (NULL,ClaveObj,'',obj,'FORM',objFrm,1);
		END IF;
	END IF;
	
	
	RETURN TRUE;
    END$$

DELIMITER ;



DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_fix_pago_planes`$$
CREATE  PROCEDURE `sp_fix_pago_planes`()
BEGIN

DECLARE mFechaOperacion 	DATE DEFAULT CURDATE();
DECLARE mToleranciaPagos 	DOUBLE(6,2) DEFAULT 2;
DECLARE mCreditoId		BIGINT(20) DEFAULT 0;
DECLARE mClave			BIGINT(20) DEFAULT 0;
DECLARE mCapital	 	DOUBLE(18,2) DEFAULT 0;
DECLARE mFechaPago	 	DATE DEFAULT CURDATE();
DECLARE mPeriodo		INT(4) DEFAULT 0;

DECLARE mMontoPagado 	DOUBLE(18,2) DEFAULT 0;
DECLARE mMontoObligado 	DOUBLE(18,2) DEFAULT 0;
DECLARE mDiferencia	DOUBLE(18,2) DEFAULT 0;

DECLARE done INT DEFAULT FALSE;

DECLARE cur1 CURSOR FOR SELECT `plan_de_pago`, `clave_de_credito`, `capital`,`fecha_de_pago`,`numero_de_parcialidad`
FROM `creditos_plan_de_pagos` 
WHERE `fecha_de_pago`<=mFechaOperacion AND (`capital`-`pag_cap`)>= mToleranciaPagos;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;


-- DROP TABLE IF EXISTS `tmp_personas_estadisticas`;



OPEN cur1;

read_loop: LOOP
    FETCH cur1 INTO mClave,mCreditoId,mCapital,mFechaPago,mPeriodo;
    IF done THEN
      LEAVE read_loop;
    END IF;

	
	SET mMontoPagado = (SELECT SUM(`afectacion_real`) AS `capital_pagado` FROM `operaciones_mvtos` 
	WHERE `tipo_operacion`=120 AND `fecha_operacion`<=mFechaOperacion AND `docto_afectado`=mCreditoId GROUP BY `docto_afectado`);
	SET mMontoObligado = (SELECT SUM(`capital`) AS `capital_obligado` FROM `creditos_plan_de_pagos` 
		WHERE `clave_de_credito`=mCreditoId AND `numero_de_parcialidad`<=mPeriodo AND `estatusactivo`=1 GROUP BY `clave_de_credito`);
	IF mMontoPagado >= mMontoObligado THEN
		UPDATE `creditos_plan_de_pagos` SET `pag_cap`=`capital` WHERE `plan_de_pago`=mClave;
	ELSE 
		SET mDiferencia = (mMontoPagado - mMontoObligado);
		IF mDiferencia > 0 THEN
			UPDATE `creditos_plan_de_pagos` SET `pag_cap`=mDiferencia WHERE `plan_de_pago`=mClave;
		ELSE
			UPDATE `creditos_plan_de_pagos` SET `pag_cap`=0 WHERE `plan_de_pago`=mClave;
		END IF;
	END IF;
  END LOOP;

  CLOSE cur1;
  




END$$


DELIMITER ;


-- --------------------------------
-- - Devengar Intereses de Letras
-- - Enero/2020
-- - --------------------------------


DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_letras_dev_sdpm`$$
CREATE  PROCEDURE `sp_letras_dev_sdpm`()
BEGIN

DECLARE mFechaOperacion 	DATE DEFAULT CURDATE();

DECLARE mToleranciaPagos 	DOUBLE(6,2) DEFAULT 2;
DECLARE mClave				BIGINT(20) DEFAULT 0;
DECLARE mCreditoId			BIGINT(20) DEFAULT 0;
DECLARE mPeriodo			INT(4) DEFAULT 0;
DECLARE mCapital	 		DOUBLE(18,2) DEFAULT 0;
DECLARE mCapitalPagado	 	DOUBLE(18,2) DEFAULT 0;
DECLARE mCapitalExigible 	DOUBLE(18,2) DEFAULT 0;
DECLARE mInteresExigible 	DOUBLE(18,2) DEFAULT 0;
DECLARE mDiasAtraso			INT(4) DEFAULT 0;
DECLARE mTasaNormal			DOUBLE(18,2) DEFAULT 0;
DECLARE mTasaMora			DOUBLE(18,2) DEFAULT 0;
DECLARE mSaldoCredito		DOUBLE(18,2) DEFAULT 0;
DECLARE mDivisorInt			INT(4) DEFAULT 0;
DECLARE mExistentes			INT(4) DEFAULT 0;

DECLARE mIntNormal			DOUBLE(18,2) DEFAULT 0;
DECLARE mIntMora			DOUBLE(18,2) DEFAULT 0;

DECLARE done INT DEFAULT FALSE;

DECLARE cur1 CURSOR FOR SELECT 
CPP.`plan_de_pago` 		AS `clave`,
CPP.`clave_de_credito` 	AS `credito`,
CPP.`numero_de_parcialidad`, CPP.`capital`,
IF(MVTO.`evaluador`>0, MVTO.`capital_pagado`,0) 							AS `capital_pagado`,
IF(MVTO.`evaluador`>0, (CPP.`capital`-MVTO.`capital_pagado`),CPP.`capital`) AS `capital_exigible`,
IF(MVTO.`evaluador`>0, (CPP.`interes`-MVTO.`interes_pagado`),CPP.`interes`) AS `interes_exigible`,	
setNoMenorCero(IF(MVTO.`evaluador`>0,
DATEDIFF(MVTO.`fecha_pagado`, CPP.`fecha_de_pago`),
DATEDIFF(PRM.`fecha_corte`, CPP.`fecha_de_pago`)
)) AS `dias_vencidos`,
CS.`tasa_interes`, CS.`tasa_moratorio`,PRM.`divisor_interes`,CS.`saldo_actual`
FROM
`creditos_plan_de_pagos` CPP 
INNER JOIN (SELECT mFechaOperacion AS `fecha_corte`,getDivisorDeInteres() AS `divisor_interes`) PRM
INNER JOIN `creditos_solicitud` CS ON CS.`numero_solicitud`=CPP.`clave_de_credito`
LEFT JOIN
(SELECT 
	`docto_afectado`,
	`periodo_socio`,
	SUM(IF(`tipo_operacion`=120,`afectacion_real`,0)) AS `capital_pagado`,
	SUM(IF(`tipo_operacion`=140,`afectacion_real`,0)) AS `interes_pagado`,
	MAX(`fecha_operacion`) AS `fecha_pagado`,
	1 AS `evaluador`
FROM 
`operaciones_mvtos`
INNER JOIN (SELECT mFechaOperacion AS `fecha_corte`) PRM
WHERE 

(`tipo_operacion`=140 OR `tipo_operacion`=120)

AND `fecha_afectacion`<=PRM.`fecha_corte`

GROUP BY 
    `docto_afectado`,`periodo_socio`
) MVTO ON MVTO.`docto_afectado` = CPP.`clave_de_credito` AND MVTO.`periodo_socio` = CPP.`numero_de_parcialidad`;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur1;

read_loop: LOOP
    FETCH cur1 INTO mClave,mCreditoId,mPeriodo,mCapital,mCapitalPagado,mCapitalExigible,mInteresExigible,mDiasAtraso,mTasaNormal,mTasaMora,mDivisorInt,mSaldoCredito;
    IF done THEN
      LEAVE read_loop;
    END IF;

	
	SET mIntNormal		= (mTasaNormal * 1 * mCapitalExigible) / mDivisorInt;
	IF mDiasAtraso >= 1 THEN
		SET mIntMora	= (mTasaMora * 1 * mCapitalExigible) / mDivisorInt;
	END IF;
	SET mExistentes		= (SELECT COUNT(*) FROM `creditos_letras_sdpm` WHERE `fecha`=mFechaOperacion AND `credito` = mCreditoId AND `periodo`=mPeriodo);
	
	IF mExistentes > 0 THEN
		-- - Actualizar el registro
		UPDATE `creditos_letras_sdpm` SET
		`mora_devengado` = mIntMora,`normal_devengado` = mIntNormal,`saldo_letra` = mCapitalExigible,`dias_atraso` = mDiasAtraso
		WHERE `credito` = mCreditoId AND `periodo` = mPeriodo AND `fecha` = mFechaOperacion;
	ELSE
		-- - Inserta el Registro
		INSERT INTO `creditos_letras_sdpm` (`idcreditos_letras_sdpm`,`credito`,`periodo`,`fecha`,`mora_devengado`,`normal_devengado`,`saldo_letra`,`dias_atraso`)
		VALUES (NULL, mCreditoId,mPeriodo,mFechaOperacion,mIntMora,mIntNormal,mCapitalExigible,mDiasAtraso);
	END IF;

  END LOOP;


CLOSE cur1;
  

END$$

DELIMITER ;


-- --------------------------------
-- - Guardar Reporte de Credito Diario
-- - Enero/2020
-- - --------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_dev_reporte_credito`$$
CREATE  PROCEDURE `sp_dev_reporte_credito`()
BEGIN

DECLARE mFechaOperacion 	DATE DEFAULT CURDATE();

DELETE FROM `creditos_reporte_general` WHERE `fecha_reporte`= mFechaOperacion;

INSERT INTO `creditos_reporte_general` (`sucursal`,`codigo`,`nombre`,`empresa`,`credito`,`producto`,`frecuencia`,`estado_actual`,`autorizacion`,`fecha_de_desembolso`,`forma_de_pagos`,`tasa_interes`,`tasa_moratorio`,`total_pagos`,
`pago`,`ultimo_pago`,`monto_original`,`saldo_capital`,`oficial`,`monto_parcialidad`,`interes_pagado`,`mora_pagado`,`capital_pagado`,`financiador`,`interes_vencido_del_mes`,`capital_vigente`,`capital_vencido`,
`interes_vencido`,`capital_del_mes`,`interes_del_mes`,`capital_pagado_del_mes`,`interes_pagado_del_mes`,`interes_moratorio`,`otros_exigible`,`dias_vencidos`,`fecha_reporte`)
SELECT
	`personas`.`sucursal` 							AS `sucursal`, 
	`personas`.`codigo`,
	`personas`.`nombre`,
	`personas`.`iddependencia` 						AS `empresa`, 
	`creditos_solicitud`.`numero_solicitud`                            	AS `credito`,
	`creditos_solicitud`.`tipo_convenio` 					AS `producto`, 
	`creditos_solicitud`.`periocidad_de_pago`           			AS `frecuencia`,
	`creditos_solicitud`.`estatus_actual`					AS `estado_actual`,
	`creditos_solicitud`.`tipo_autorizacion` 				AS `autorizacion`,
	`creditos_solicitud`.`fecha_ministracion`     		    		AS `fecha_de_desembolso`,
	`creditos_solicitud`.`tipo_de_pago`                              	AS `forma_de_pagos`,
	ROUND((`creditos_solicitud`.`tasa_interes`*100),2)			AS `tasa_interes`,
	ROUND((`creditos_solicitud`.`tasa_moratorio`*100),2)			AS `tasa_moratorio`,
	`creditos_solicitud`.`pagos_autorizados`				AS `total_pagos`,	
	OPS.`pago`								AS `pago`,
	IF(OPS.`ultimo_pago` = NULL, NULL, OPS.`ultimo_pago`)   		AS `ultimo_pago`,
	`creditos_solicitud`.`monto_autorizado`                            	AS `monto_original`,
	(`creditos_solicitud`.`monto_autorizado` - OPS.`capital_pagado`) 	AS `saldo_capital`,
	`creditos_solicitud`.`oficial_credito` 					AS `oficial`,
	IF(`creditos_tipo_de_pago`.`con_capital`= 0, getMontoCuotaCred(`numero_solicitud`, (`ultimo_periodo_afectado`+1)),
	`creditos_solicitud`.`monto_parcialidad`) 				AS `monto_parcialidad`,

	OPS.`interes_pagado`,
	OPS.`mora_pagado`,
	OPS.`capital_pagado`,
	CO.`persona` AS `financiador`,
	
	setNoMenorcero(SVC.`interes_del_mes` - SVC.`interes_pagado_del_mes`) 	AS `interes_vencido_del_mes`,
	SVC.`capital_exigible` 							AS `capital_vigente`,	
	SVC.`capital_vencido`,
	SVC.`interes_vencido`,
	SVC.`capital_del_mes`,
	SVC.`interes_del_mes`,
	SVC.`capital_pagado_del_mes`,
	SVC.`interes_pagado_del_mes`,
	LP.`interes_moratorio`,

	LP.`otros_exigible`,

	CAST(LP.`dias_vencidos` AS UNSIGNED) 					AS `dias_vencidos`,
	mFechaOperacion											AS `fecha_reporte`
FROM
	`creditos_solicitud` `creditos_solicitud` 
		INNER JOIN `oficiales` `oficiales` 
		ON `creditos_solicitud`.`oficial_seguimiento` = `oficiales`.`id` 
			INNER JOIN `creditos_tipoconvenio` `creditos_tipoconvenio` 
			ON `creditos_solicitud`.`tipo_convenio` = `creditos_tipoconvenio`.
			`idcreditos_tipoconvenio` 
				INNER JOIN `creditos_tipo_de_autorizacion` 
				`creditos_tipo_de_autorizacion` 
				ON `creditos_solicitud`.`tipo_autorizacion` = 
				`creditos_tipo_de_autorizacion`.
				`idcreditos_tipo_de_autorizacion` 
					INNER JOIN `personas` `personas` 
					ON `creditos_solicitud`.`numero_socio` = `personas`.`codigo` 
						INNER JOIN `creditos_estatus` `creditos_estatus` 
						ON `creditos_solicitud`.`estatus_actual` = 
						`creditos_estatus`.`idcreditos_estatus` 
							INNER JOIN `creditos_tipo_de_pago` 
							`creditos_tipo_de_pago` 
							ON `creditos_solicitud`.`tipo_de_pago` = 
							`creditos_tipo_de_pago`.`idcreditos_tipo_de_pago` 
								INNER JOIN `creditos_periocidadpagos` 
								`creditos_periocidadpagos` 
								ON `creditos_solicitud`.`periocidad_de_pago` = 
								`creditos_periocidadpagos`.
								`idcreditos_periocidadpagos`
		LEFT JOIN `creditos_montos` `creditos_montos`
		ON `creditos_montos`.`clave_de_credito` = `creditos_solicitud`.`numero_solicitud`
		LEFT JOIN 
(SELECT DISTINCT  `creditos_datos_originacion`.`credito` AS `originacion_credito`,`personas_financiadores`.`alias` AS `originacion_financiador`,`personas_financiadores`.`persona` 
FROM  `creditos_datos_originacion` INNER JOIN `personas_financiadores`  ON `creditos_datos_originacion`.`persona_titular` = `personas_financiadores`.`persona` ) CO
ON CO.`originacion_credito` = `creditos_solicitud`.`numero_solicitud`
LEFT JOIN 
(SELECT  `docto_afectado` AS `credito_id`,
MAX( IF(`operaciones_mvtos`.`tipo_operacion` = 120 OR `operaciones_mvtos`.`tipo_operacion` = 140,`operaciones_mvtos`.`fecha_afectacion`, NULL) )  AS `ultimo_pago`,
MAX( IF(`operaciones_mvtos`.`tipo_operacion` = 120 OR `operaciones_mvtos`.`tipo_operacion` = 140,`operaciones_mvtos`.`periodo_socio`, 0) )  AS `pago`,
SUM(IF(`operaciones_mvtos`.`tipo_operacion` = 120,`operaciones_mvtos`.`afectacion_real`,0)) AS `capital_pagado`,
SUM(IF(`operaciones_mvtos`.`tipo_operacion` = 140,`operaciones_mvtos`.`afectacion_real`,0)) AS `interes_pagado`,
SUM(IF(`operaciones_mvtos`.`tipo_operacion` = 141,`operaciones_mvtos`.`afectacion_real`,0)) AS `mora_pagado`
FROM `operaciones_mvtos` 
WHERE `operaciones_mvtos`.`fecha_operacion` <=mFechaOperacion
GROUP BY `docto_afectado`) OPS ON OPS.`credito_id` = `creditos_solicitud`.`numero_solicitud`

LEFT JOIN (SELECT CS.`numero_solicitud` AS `vclave_de_credito`,
SUM(CPP.`capital_exigible`) AS `capital_exigible`,
SUM(CPP.`interes_exigible`) AS `interes_exigible`,
SUM(CPP.`otros_exigible`) 	AS `otros_exigible`,

SUM(IF(CPP.`dias_vencidos`> 0,CPP.`capital_exigible`,0)) AS `capital_vencido`,
SUM(IF(CPP.`dias_vencidos`> 0,CPP.`interes_exigible`,0)) AS `interes_vencido`,
SUM(IF(CPP.`dias_vencidos`> 0, 
((CPP.`capital_exigible` * CS.`tasa_moratorio`*CPP.`dias_vencidos`) / PRM.`divisor_interes`)
,0)) AS `interes_moratorio`,

SUM(
IF(CPP.`del_mes` = 1, CPP.`capital`, 0)
) AS `capital_del_mes`,
SUM(
IF(CPP.`del_mes` = 1, CPP.`capital_pagado`, 0)
) AS `capital_pagado_del_mes`,
SUM(
IF(CPP.`del_mes` = 1, CPP.`interes`, 0)
) AS `interes_del_mes`,
SUM(
IF(CPP.`del_mes` = 1, CPP.`interes_pagado`, 0)
) AS `interes_pagado_del_mes`,
MAX(CPP.`dias_vencidos`) AS `vdias_vencidos`,
IF(MAX(CPP.`dias_vencidos`)>0,'Vencido', 'Vigente') AS `vnombre_estatus_actual`

FROM `creditos_solicitud` CS 
INNER JOIN (SELECT getDivisorDeInteres() AS `divisor_interes`) PRM
LEFT JOIN (
SELECT 
CPP.`plan_de_pago` 		AS `clave`,
CPP.`clave_de_credito` 		AS `credito`,
CPP.`numero_de_parcialidad`,
CPP.`capital`,
	CPP.`interes`,
	CPP.`fecha_de_pago`,
	MVTO.`capital_pagado`,
	MVTO.`interes_pagado`,
	MVTO.`fecha_pagado`,
	PRM.`fecha_corte` AS `fecha_corte`,
	IF(MVTO.`evaluador`>0, 1,0) AS `tiene_pago`,

	IF(MVTO.`evaluador`>0, (CPP.`capital`-MVTO.`capital_pagado`),CPP.`capital`) AS `capital_exigible`,
	IF(MVTO.`evaluador`>0, (CPP.`interes`-MVTO.`interes_pagado`),CPP.`interes`) AS `interes_exigible`,	

	IF(LIN.`otros_pagado`>0, (CPP.`otros`-LIN.`otros_pagado`),CPP.`otros`) AS `otros_exigible`,

	setNoMenorCero(IF(MVTO.`evaluador`>0,
	DATEDIFF(MVTO.`fecha_pagado`, CPP.`fecha_de_pago`),
	DATEDIFF(PRM.`fecha_corte`, CPP.`fecha_de_pago`)
	)) AS `dias_vencidos`,
	
	IF(DATE_FORMAT(CPP.`fecha_de_pago`, '%Y') = DATE_FORMAT(PRM.`fecha_corte`, '%Y'), 1, 0) AS `del_mes`

	
FROM
`creditos_plan_de_pagos` CPP 
INNER JOIN (SELECT mFechaOperacion AS `fecha_corte`) PRM
LEFT JOIN
(SELECT 
	`docto_afectado`,
	`periodo_socio`,
	SUM(IF(`tipo_operacion`=120,`afectacion_real`,0)) AS `capital_pagado`,
	SUM(IF(`tipo_operacion`=140,`afectacion_real`,0)) AS `interes_pagado`,
	MAX(`fecha_operacion`) AS `fecha_pagado`,
	1 AS `evaluador`
FROM 
`operaciones_mvtos`
INNER JOIN (SELECT mFechaOperacion AS `fecha_corte`) PRM
WHERE 

(`tipo_operacion`=140 OR `tipo_operacion`=120)

AND `fecha_afectacion`<=PRM.`fecha_corte`

GROUP BY 
    `docto_afectado`,`periodo_socio`
    
) MVTO ON MVTO.`docto_afectado` = CPP.`clave_de_credito` AND MVTO.`periodo_socio` = CPP.`numero_de_parcialidad`

LEFT JOIN (
SELECT `credito`,`parcialidad`,SUM(`otros`) AS `otros_pagado` FROM `listado_de_ingresos` WHERE `fecha`<=mFechaOperacion
GROUP BY `credito`,`parcialidad`
) LIN ON LIN.`credito` = CPP.`clave_de_credito` AND LIN.`parcialidad` = CPP.`numero_de_parcialidad`

) CPP ON CPP.credito = CS.numero_solicitud
GROUP BY CS.numero_solicitud) SVC ON SVC.`vclave_de_credito` = `creditos_solicitud`.`numero_solicitud`
LEFT JOIN (
SELECT LP.`credito`,SUM(LP.`interes_moratorio`) AS `interes_moratorio`,SUM(LP.`otros`) AS `otros_exigible`, MAX(IF(`capital_exigible`<=0,0,DATEDIFF(mFechaOperacion, LP.`fecha_de_pago`))
) AS `dias_vencidos` FROM `letras` LP GROUP BY LP.`credito`
) AS LP ON LP.`credito` = `creditos_solicitud`.`numero_solicitud`

	WHERE (creditos_solicitud.numero_solicitud != 0)
	 AND ( creditos_solicitud.fecha_ministracion <= mFechaOperacion) 
	
	AND (`creditos_solicitud`.`estatus_actual`!=50)	
	AND (creditos_solicitud.estatus_actual != 98) 
	AND (creditos_solicitud.estatus_actual != 99)

	HAVING saldo_capital != 0

	ORDER BY `creditos_solicitud`.`tipo_convenio`, `personas`.`nombre` ;

END$$

DELIMITER ;

-- --------------------------------
-- - Guardar Reporte de Letras Vencidas
-- - Enero/2020
-- - --------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_dev_letras_vencidas`$$
CREATE  PROCEDURE `sp_dev_letras_vencidas`()
BEGIN

DECLARE mFechaOperacion 	DATE DEFAULT CURDATE();

DELETE FROM `creditos_reporte_letras_venc` WHERE `fecha_corte`= mFechaOperacion;

INSERT INTO `creditos_reporte_letras_venc`(`persona`,`nombre`,`sucursal`,`credito`,`fecha_ministracion`,`pagos`,`periocidad`,`numero_con_atraso`,`fecha_de_atraso`,`dias`,
`monto_ministrado`,`capital`,`interes`,`iva`,`otros`,`letra_original`,`moratorio`,`iva_moratorio`,`total`,`capital_vigente`,`total_vigente`,`gastos_de_cobranza`,`total_con_gastos`,
`fecha_corte`)
SELECT
	`letras`.`persona`,
	`personas`.`nombre`,
	`personas`.`sucursal`,
	`letras`.`credito`,

	`creditos_solicitud`.`fecha_ministracion` 	AS `fecha_ministracion`,
        
	`creditos_solicitud`.`pagos_autorizados` 	AS `pagos`,
        `creditos_solicitud`.`periocidad_de_pago` 	AS `periocidad`,
	COUNT(`letras`.`parcialidad`)  	 		AS `numero_con_atraso`,
	MIN(`letras`.`fecha_de_pago`) 			AS `fecha_de_atraso`,
	MAX(`letras`.`dias`)          			AS `dias`,
	
	`creditos_solicitud`.`monto_autorizado` 	AS `monto_ministrado`,
	
	
	SUM(`letras`.`capital`)       AS `capital`,
	SUM(`letras`.`interes`)       AS `interes`,
	SUM(`letras`.`iva`)           AS `iva`,
	
	
	
	SUM(`letras`.`otros`)         AS `otros`,
	SUM(`letras`.`letra`)         AS `letra_original`,
	
	SUM(`letras`.`mora`)          AS `moratorio`,
	SUM(`letras`.`iva_moratorio`) AS `iva_moratorio`,
	
	SUM(`capital`+`interes`+`iva`+`ahorro`+`otros`+`mora`+`iva_moratorio`) AS `total` 
		,LV.capital_vigente, LV.total_vigente,
	getMtoGtosCbzaMes(MIN(`letras`.`fecha_de_pago`)) AS `gastos_de_cobranza`,

	(getMtoGtosCbzaMes(MIN(`letras`.`fecha_de_pago`)) + SUM(`capital`+`interes`+`iva`+`ahorro`+`otros`+`mora`+`iva_moratorio`)) AS `total_con_gastos`,
	mFechaOperacion AS `fecha_corte`
FROM
	`letras` `letras` 
		INNER JOIN `creditos_solicitud` `creditos_solicitud` 
		ON `letras`.`credito` = `creditos_solicitud`.
		`numero_solicitud` 
			INNER JOIN `creditos_tipoconvenio` `creditos_tipoconvenio` 
			ON `creditos_solicitud`.`tipo_convenio` = `creditos_tipoconvenio`.
			`idcreditos_tipoconvenio` 
				INNER JOIN `personas` `personas` 
				ON `letras`.`persona` = `personas`.`codigo` 
INNER JOIN `creditos_periocidadpagos` `creditos_periocidadpagos` ON `creditos_periocidadpagos`.`idcreditos_periocidadpagos` = `creditos_solicitud`.`periocidad_de_pago`
		LEFT OUTER JOIN (
		SELECT `letras`.`credito`,
SUM(`capital`+`interes`+`iva`+`ahorro`+`otros`+`mora`+`iva_moratorio`) AS `total_vigente`,SUM(`capital`) AS `capital_vigente` FROM `letras`
WHERE `letras`.`parcialidad` > 0 AND `letras`.`fecha_de_pago` > mFechaOperacion
GROUP BY `letras`.`credito`
		) LV ON LV.credito = `creditos_solicitud`.`numero_solicitud` 
		WHERE `letras`.`parcialidad` > 0 AND `letras`.`fecha_de_pago` <= mFechaOperacion AND `letras`.`total_sin_otros`>0
		AND `creditos_solicitud`.`estatus_actual`!= 50
		
		
		 
		 AND (creditos_solicitud.saldo_actual > 1)  AND (`creditos_tipoconvenio`.`omitir_seguimiento`=0) 
		GROUP BY `letras`.`credito`

HAVING total > 1
	
		ORDER BY MAX(`letras`.`dias`) DESC, `personas`.`nombre`;
		

END$$

DELIMITER ;




-- --------------------------------
-- - Funcion que crear un RFC Valido
-- - Febrero/2021
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `setCrearRFC`$$

CREATE FUNCTION `setCrearRFC`(ApPaterno VARCHAR(80), ApMaterno VARCHAR(80), Nombre VARCHAR(80), FechaNac DATE) RETURNS VARCHAR(13)
BEGIN
	DECLARE PrimeraParte VARCHAR(4) DEFAULT '';
	DECLARE SegundaParte VARCHAR(6) DEFAULT '';
	
	DECLARE A1 VARCHAR(1) DEFAULT '';
	DECLARE A2 VARCHAR(1) DEFAULT '';
	DECLARE A3 VARCHAR(1) DEFAULT '';
	DECLARE A4 VARCHAR(1) DEFAULT '';

	SET A1 = SUBSTR(TRIM(ApPaterno),1,1);	
	SET A2 = SUBSTR(regex_replace("[^aeiou]","", TRIM(ApPaterno)),1,1);
	SET A3 = SUBSTR(TRIM(ApMaterno),1,1);
	SET A4 = SUBSTR(TRIM(Nombre),1,1);

	SET PrimeraParte = UPPER(CONCAT(A1,A2,A3,A4));
	SET SegundaParte = (SELECT DATE_FORMAT(FechaNac, "%y%m%d"));
	
	IF PrimeraParte IN ("BUEI", "BUEY", "CACA", "CACO", "CAGA", "CAGO", "CAKA",
"CAKO", "COGE", "COJA", "KOGE", "KOJO", "KAKA", "KULO", "MAME",
"MAMO", "MEAR", "MEAS", "MEON", "MION", "COJE", "COJI", "COJO",
"CULO", "FETO", "GUEY", "JOTO", "KACA", "KACO", "KAGA", "KAGO",
"MOCO", "MULA", "PEDA", "PEDO", "PENE", "PUTA", "PUTO", "QULO",
"RATA", "RUIN") THEN
	SET PrimeraParte = CONCAT(SUBSTR(PrimeraParte,1,1),'X',SUBSTR(PrimeraParte,3,2));
	END IF;
	

				
	RETURN CONCAT(PrimeraParte,SegundaParte);

    END$$

DELIMITER ;

-- --------------------------------
-- - Funcion UCWORDS
-- - Abril/2021
-- - Credits: http://joezack.com/2008/10/20/mysql-capitalize-function/
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `UC_FIRST`$$

CREATE FUNCTION `UC_FIRST`(input VARCHAR(255)) RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN

	DECLARE len INT;
	DECLARE i INT;

	SET len   = CHAR_LENGTH(input);
	SET input = LOWER(input);
	SET i = 0;

	WHILE (i < len) DO
		IF (MID(input,i,1) = ' ' OR i = 0) THEN
			IF (i < len) THEN
				SET input = CONCAT(
					LEFT(input,i),
					UPPER(MID(input,i + 1,1)),
					RIGHT(input,len - i - 1)
				);
			END IF;
		END IF;
		SET i = i + 1;
	END WHILE;

	RETURN input;


    END$$

DELIMITER ;

-- --------------------------------
-- - Procedimiento Sanear Tabla de Localidades
-- - Abril/2021
-- - --------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `sanear_tlocalidades`$$

CREATE PROCEDURE `sanear_tlocalidades`()

BEGIN

DECLARE done 				INT DEFAULT FALSE;
DECLARE vEstado				VARCHAR(255) DEFAULT '';
DECLARE vEstado2			VARCHAR(255) DEFAULT '';
DECLARE vLocalidad			VARCHAR(255) DEFAULT '';
DECLARE vIDLocalidad			INT DEFAULT 0;

DECLARE cur1 CURSOR FOR SELECT `catalogos_localidades`.`clave_unica`,LOWER(`catalogos_localidades`.`nombre_de_la_localidad`) AS `nombre_localidad`, LOWER(`general_estados`.`clave_en_sic`) AS `nombre_estado` FROM     `general_estados` INNER JOIN `catalogos_localidades`  ON `general_estados`.`clave_numerica` = `catalogos_localidades`.`clave_de_estado`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;





UPDATE `catalogos_localidades` SET `nombre_de_la_localidad`=UC_FIRST(`nombre_de_la_localidad`);

UPDATE `catalogos_localidades` SET `nombre_de_la_localidad`=REPLACE(`nombre_de_la_localidad`, "Municipio", "(Municipio)");

UPDATE `catalogos_localidades` SET `nombre_de_la_localidad`=REPLACE(`nombre_de_la_localidad`, "Localidad", "(Localidad)");

-- Limpiar estados de Localidad




OPEN cur1;

read_loop: LOOP
    FETCH cur1 INTO vIDLocalidad, vLocalidad, vEstado;
    
    IF done THEN
      LEAVE read_loop;
    END IF;

    SET vEstado2 = UC_FIRST(vEstado);
    
    IF INSTR(vLocalidad, CONCAT(" de ", vEstado)) > 0 THEN
	UPDATE `catalogos_localidades` SET `nombre_de_la_localidad`=REPLACE(`nombre_de_la_localidad`, CONCAT(" De ", vEstado2), "") WHERE `clave_unica`=vIDLocalidad;
    ELSE 
	IF INSTR(vLocalidad, CONCAT(" ", vEstado)) > 0 THEN
	    UPDATE `catalogos_localidades` SET `nombre_de_la_localidad`=REPLACE(`nombre_de_la_localidad`, CONCAT(" ", vEstado2), " ") WHERE `clave_unica`=vIDLocalidad;
	END IF;    
    
    END IF;
    


  END LOOP;



UPDATE `catalogos_localidades` SET `nombre_de_la_localidad`=TRIM(`nombre_de_la_localidad`);

UPDATE `socios_vivienda` SET `localidad` = (SELECT `nombre_de_la_localidad` FROM `catalogos_localidades` WHERE `clave_unica`=`socios_vivienda`.`clave_de_localidad`);


END$$

DELIMITER ;


-- --------------------------------
-- - Funcion que setea principal si es verdadero a otros falso
-- - Mayo/2021
-- - --------------------------------

-- DELIMITER $$


DROP TRIGGER IF EXISTS `socios_vivienda_BEFORE_UPDATE`;

-- DROP TRIGGER IF EXISTS `socios_vivienda_BEFORE_UPDATE`$$

-- CREATE DEFINER = CURRENT_USER TRIGGER `socios_vivienda_BEFORE_UPDATE` BEFORE UPDATE ON `socios_vivienda` FOR EACH ROW
-- BEGIN

-- IF OLD.principal != NEW.principal THEN

-- 	IF (SELECT COUNT(*) FROM `socios_vivienda` WHERE `socio_numero`=NEW.socio_numero AND `idsocios_vivienda` != NEW.idsocios_vivienda) > 0 THEN
--		UPDATE `socios_vivienda` SET principal = '0' WHERE `socio_numero`=NEW.socio_numero  AND `idsocios_vivienda` != NEW.idsocios_vivienda;
-- 	END IF;

-- END IF;



-- END$$


-- DELIMITER ;


-- DELIMITER $$

-- DROP TRIGGER IF EXISTS `socios_vivienda_BEFORE_INSERT`$$
DROP TRIGGER IF EXISTS `socios_vivienda_BEFORE_INSERT`;

-- CREATE DEFINER = CURRENT_USER TRIGGER `socios_vivienda_BEFORE_INSERT` BEFORE INSERT ON `socios_vivienda` FOR EACH ROW
-- BEGIN

-- IF NEW.principal IS NULL THEN
--	SET NEW.principal = '1';
-- END IF;

-- IF NEW.principal = '1' THEN
--	IF (SELECT COUNT(*) FROM `socios_vivienda` WHERE `socio_numero`=NEW.socio_numero AND `idsocios_vivienda` != NEW.idsocios_vivienda) > 0 THEN
--		UPDATE `socios_vivienda` SET principal = '0' WHERE `socio_numero`=NEW.socio_numero  AND `idsocios_vivienda` != NEW.idsocios_vivienda;
--	END IF;
-- END IF;

-- END$$


-- DELIMITER ;






-- --------------------------------
-- - Funcion que setea id municipio por id de persona
-- - y actualiza en catalogo externo si no existe
-- - Aplica para Echale
-- - Mayo/2021
-- - --------------------------------

DELIMITER $$

DROP FUNCTION IF EXISTS `setIdMunicipioByIDPersona`$$

CREATE FUNCTION `setIdMunicipioByIDPersona`(IDPersona BIGINT(20)) RETURNS INT(8)
BEGIN
	DECLARE IDMunicipio INT DEFAULT 0;
	DECLARE IDEstado INT DEFAULT 0;
	
	DECLARE IDRelacionado INT DEFAULT 0;
	DECLARE IDRelCNT INT DEFAULT 0;
	DECLARE NombreMun VARCHAR(100);
	DECLARE IDRelUQ INT DEFAULT 0;
	
	SET IDMunicipio = (SELECT `clave_de_municipio` FROM `socios_vivienda` WHERE `socio_numero`=IDPersona ORDER BY `principal` DESC LIMIT 0,1);
	SET IDEstado = (SELECT `clave_de_entidadfederativa` FROM `socios_vivienda` WHERE `socio_numero`=IDPersona ORDER BY `principal` DESC LIMIT 0,1);
	
	IF IDMunicipio IS NOT NULL THEN
		-- Crear Llave Unica
		SET IDRelUQ = CAST(CONCAT(IDEstado, RIGHT(CONCAT('000',IDMunicipio),3)) AS UNSIGNED);
		-- Validar si existe en xcatalogo
		SET IDRelCNT = (SELECT COUNT(*) FROM `personas_xclasificacion` WHERE `idpersonas_xclasificacion`=IDRelUQ);
		IF ISNULL(IDRelCNT) OR IDRelCNT<=0 THEN
			-- Insertar nuevo registro municipio
			SET NombreMun = (SELECT `nombre_del_municipio` FROM `general_municipios` WHERE `clave_unica`=IDRelUQ LIMIT 0,1);
			INSERT INTO `personas_xclasificacion`(`idpersonas_xclasificacion`,`descripcion_xclasificacion`) VALUES (IDRelUQ,NombreMun);
		END IF;
	END IF;

	RETURN IDRelUQ;

    END$$

DELIMITER ;





-- --------------------------------
-- - Procedimiento Crea Saldo por Operacion
-- - Mayo/2021
-- - --------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_rebuild_cta_sdos`$$

CREATE PROCEDURE `proc_rebuild_cta_sdos`()

BEGIN

DECLARE done 				INT DEFAULT FALSE;
DECLARE vIDMvto				INT DEFAULT 0;
DECLARE vIDCta				BIGINT(20) DEFAULT 0;
DECLARE vIDCta2				BIGINT(20) DEFAULT 0;
DECLARE vMonto				DOUBLE(12,2) DEFAULT 0;
DECLARE vSdo				DOUBLE(12,2) DEFAULT 0;
DECLARE vAfecta				INT DEFAULT 0;


DECLARE cur1 CURSOR FOR SELECT `idcaptacion_cuentas_sdos`,`cuenta`,`afectacion_real`,`afectacion` FROM `captacion_cuentas_sdos` ORDER BY `cuenta`,`fecha`,`recibo`;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;



OPEN cur1;

read_loop: LOOP
    FETCH cur1 INTO vIDMvto, vIDCta, vMonto, vAfecta;
    
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF vIDCta2 != vIDCta THEN
	SET vSdo = 0;
    END IF;
    
    SET vSdo = vSdo + (vMonto * vAfecta);

    UPDATE `captacion_cuentas_sdos` SET `saldo_diario`=vSdo WHERE `idcaptacion_cuentas_sdos`=vIDMvto;


    SET vIDCta2 = vIDCta;


  END LOOP;


END$$

DELIMITER ;



-- --------------------------------
-- - Procedimiento Crea Saldo por Operacion - Por Cuenta
-- - Mayo/2021
-- - --------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_rebuild_cta_sdos_id`$$

CREATE PROCEDURE `proc_rebuild_cta_sdos_id`(IDCuenta BIGINT(20))

BEGIN

DECLARE done 				INT DEFAULT FALSE;
DECLARE vIDMvto				INT DEFAULT 0;
DECLARE vIDCta				BIGINT(20) DEFAULT 0;
DECLARE vIDCta2				BIGINT(20) DEFAULT 0;
DECLARE vMonto				DOUBLE(12,2) DEFAULT 0;
DECLARE vSdo				DOUBLE(12,2) DEFAULT 0;
DECLARE vAfecta				INT DEFAULT 0;


DECLARE cur1 CURSOR FOR SELECT `idcaptacion_cuentas_sdos`,`cuenta`,`afectacion_real`,`afectacion` FROM `captacion_cuentas_sdos` WHERE `cuenta`=IDCuenta ORDER BY `cuenta`,`fecha`,`recibo`;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;



OPEN cur1;

read_loop: LOOP
    FETCH cur1 INTO vIDMvto, vIDCta, vMonto, vAfecta;
    
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF vIDCta2 != vIDCta THEN
	SET vSdo = 0;
    END IF;
    
    SET vSdo = vSdo + (vMonto * vAfecta);

    UPDATE `captacion_cuentas_sdos` SET `saldo_diario`=vSdo WHERE `idcaptacion_cuentas_sdos`=vIDMvto;


    SET vIDCta2 = vIDCta;


  END LOOP;


END$$

DELIMITER ;


-- --------------------------------
-- - Procedimiento Rebuild Sdo x Cred
-- - Mayo/2021
-- - --------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_rbd_cta_sdos_bycta`$$

CREATE PROCEDURE `proc_rbd_cta_sdos_bycta`(IDCta BIGINT(20))
BEGIN

DELETE FROM `captacion_cuentas_sdos` WHERE `cuenta` = IDCta;

INSERT INTO `captacion_cuentas_sdos`(`cuenta`,`fecha`,`recibo`,`afectacion_real`,`valor_afectacion`,`afectacion`)
SELECT 
									`operaciones_mvtos`.`docto_afectado` AS `cuenta`,
									`operaciones_mvtos`.`fecha_operacion`  AS `fecha`,
									`operaciones_mvtos`.`recibo_afectado` AS `recibo`,
									
									SUM((`operaciones_mvtos`.`afectacion_real` * BASES.`afectacion`)) AS `afectacion_real`,
									1 AS `valor_afectacion`,
									1 AS `afectacion`
	FROM     `operaciones_mvtos` 
	INNER JOIN `operaciones_tipos` ON `operaciones_tipos`.`idoperaciones_tipos` = `operaciones_mvtos`.`tipo_operacion` 
	INNER JOIN (
	SELECT   `eacp_config_bases_de_integracion_miembros`.`miembro`,
			 `eacp_config_bases_de_integracion_miembros`.`afectacion`
		FROM     `eacp_config_bases_de_integracion_miembros`
		WHERE    ( `eacp_config_bases_de_integracion_miembros`.`codigo_de_base` = 3100 )
	) BASES ON BASES.`miembro` = `operaciones_tipos`.`idoperaciones_tipos`
WHERE `operaciones_mvtos`.`docto_afectado` = IDCta
GROUP BY `operaciones_mvtos`.`recibo_afectado`					
				ORDER BY
					`operaciones_mvtos`.`docto_afectado`,
					`operaciones_mvtos`.`fecha_afectacion`,
					BASES.`afectacion` DESC;


CALL proc_rebuild_cta_sdos_id(IDCta);


END$$

DELIMITER ;


-- --------------------------------
-- - Procedimiento Echale, estatus operativo
-- - Mayo/2021
-- - --------------------------------


DELIMITER $$

DROP FUNCTION IF EXISTS `getCredEstadoOperativo`$$

CREATE FUNCTION `getCredEstadoOperativo`(IDCredito BIGINT(20),Saldo DOUBLE(18,2)) RETURNS VARCHAR(20)
BEGIN
	DECLARE mEstadoOperativo VARCHAR(20) DEFAULT '';
	DECLARE mReest INTEGER DEFAULT 0;
	
	IF Saldo <= 0.99 THEN
		SET mEstadoOperativo = 'LIQUIDADO';
		
		SET mReest = (SELECT COUNT(*) FROM `creditos_datos_originacion` WHERE `clave_vinculada`=IDCredito AND `tipo_originacion`=4);
		
		IF mReest > 0 THEN
			SET mEstadoOperativo = 'REESTRUCTURADO';
		END IF;
		
	ELSE
	
		SET mEstadoOperativo = 'ACTIVO';
	
	END IF;
	

	RETURN mEstadoOperativo;

    END$$

DELIMITER ;


-- --------------------------------
-- - Procedimiento Perfil de Avisos por Producto
-- - Junio/2021
-- - --------------------------------

DELIMITER $$

DROP PROCEDURE IF EXISTS `proc_crear_perfil_avisos_p`$$

CREATE PROCEDURE `proc_crear_perfil_avisos_p`(IDProducto INT(4))

BEGIN

DECLARE done 				INT DEFAULT FALSE;

DECLARE vIDPersona			BIGINT(20) DEFAULT 0;
DECLARE vNumCreds			INT DEFAULT 0;
DECLARE vSucursal			VARCHAR(20) DEFAULT 'matriz';

DECLARE vExist1				INT DEFAULT 0;
DECLARE vExist2				INT DEFAULT 0;
DECLARE vHorarioI			VARCHAR(10) DEFAULT '';
DECLARE vHorarioF			VARCHAR(10) DEFAULT '';



DECLARE cur1 CURSOR FOR SELECT `creditos_solicitud`.`numero_socio` AS `persona`,`creditos_solicitud`.`sucursal`, COUNT( `creditos_solicitud`.`numero_solicitud` )  AS `creditos` FROM `creditos_solicitud` WHERE ( `creditos_solicitud`.`saldo_actual` >0.99 ) AND ( `creditos_solicitud`.`tipo_convenio` = IDProducto ) AND (`creditos_solicitud`.`estatus_actual` != 50) GROUP BY `persona`;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur1;

read_loop: LOOP
    FETCH cur1 INTO vIDPersona,vSucursal,vNumCreds;
    
    IF done THEN
      LEAVE read_loop;
    END IF;
    SET vHorarioI = (SELECT CONCAT(`hora_de_inicio_de_operaciones`,':00') FROM `general_sucursales` WHERE `codigo_sucursal`=vSucursal LIMIT 0,1);
    SET vHorarioF = (SELECT CONCAT(`hora_de_fin_de_operaciones`,':00') FROM `general_sucursales` WHERE `codigo_sucursal`=vSucursal LIMIT 0,1);
    
    SET vExist1 = (SELECT COUNT(*) FROM `personas_perfil_avisos` WHERE `persona`=vIDPersona AND `canal_de_envio`='sms');
    SET vExist2 = (SELECT COUNT(*) FROM `personas_perfil_avisos` WHERE `persona`=vIDPersona AND `canal_de_envio`='email');
    
    IF vExist1 <=0 THEN
	INSERT INTO `personas_perfil_avisos` (`persona`,`canal_de_envio`,`horario_inicial`,`horario_final`) VALUES (vIDPersona, 'sms', vHorarioI, vHorarioF);
    END IF;

    IF vExist2 <=0 THEN
	INSERT INTO `personas_perfil_avisos` (`persona`,`canal_de_envio`,`horario_inicial`,`horario_final`) VALUES (vIDPersona, 'email', vHorarioI, vHorarioF);
    END IF;
    
  END LOOP;


END$$

DELIMITER ;

