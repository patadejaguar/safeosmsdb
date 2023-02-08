-- -------------------------------------------------- Vista de Letras
DELIMITER $$

DROP VIEW IF EXISTS `letras_compare`$$
DROP TABLE IF EXISTS `letras_compare`$$

CREATE  VIEW `letras_compare` AS (
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
		, 0 )),2) AS `int_corriente_letra`,
		
		SUM(IF((`tipo_operacion` = 410  AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `capital_nopagado`,
		SUM(IF((`tipo_operacion` = 411 AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `interes_nopagado`,
		SUM(IF((`tipo_operacion` = 413  AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `iva_nopagado`,
		SUM(IF((`tipo_operacion` = 412  AND `fecha_afectacion` > PRM.`fecha_corte`),`afectacion_real`,0)) 								AS `ahorro_nopagado`,
		SUM(IF(((`tipo_operacion` < 410 OR `tipo_operacion` > 413)  AND `fecha_afectacion` > PRM.`fecha_corte`) , `afectacion_real`,0)) AS `otros_nopagado`,
		IF((`tipo_operacion` = 410 AND `periodo_socio`= (`creditos_solicitud`.`ultimo_periodo_afectado`+1)),  MMC.`cargos_cbza`,0) 	AS `gastos_de_cobranza`,
		IF((`tipo_operacion` = 410 AND `periodo_socio`= (`creditos_solicitud`.`ultimo_periodo_afectado`+1)), ROUND(MMC.`cargos_cbza`*PRM.`tasa_iva`,2),0) 	AS `iva_gtos_cobranza`,
		
		MIN(IF(`afectacion_real`>0 AND `tipo_operacion` = 410,`periodo_socio`,`creditos_solicitud`.`pagos_autorizados`))	AS `letra_minima`,
		MAX(IF(`afectacion_real`>0 AND `tipo_operacion` = 410,`periodo_socio`,0))											AS `letra_maxima`,
		
		SUM(IF((`afectacion_real`>0 AND `tipo_operacion` = 410 AND `fecha_afectacion` <= PRM.`fecha_corte`),1,0))	AS `letra_pends`, 
		SUM(IF((`afectacion_real`>0 AND `tipo_operacion` = 410),1,0))	AS `letra_totales`,
		MIN(IF(`afectacion_real`>0 AND `tipo_operacion` = 410,`fecha_afectacion`,`creditos_solicitud`.`fecha_vencimiento`))			AS `fecha_primer_atraso`

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
)$$

DELIMITER ;
