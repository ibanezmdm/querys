
-- Select rows from a Table or View '' in schema ''
SELECT COUNT(*)
	FROM [ACTUALIZABLES].dbo.[CT_SAP] AS S
		LEFT JOIN [MAESTRAS].dbo.[SURTIDO_LOCAL] M
			ON S.SKU_J = M.
	-- WHERE

SELECT TOP 1 * FROM