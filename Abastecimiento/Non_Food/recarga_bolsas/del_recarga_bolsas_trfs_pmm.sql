DELETE FROM RepNonFood.dbo.recarga_bolsas_trfs_pmm
WHERE TRF_NUMBER IN (
	select TRF_NUMBER
	from OPENQUERY(pmm, '
		select *
		from trfhdree
		where to_char(TRF_ENTRY_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(TRF_APROV_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(TRF_SHIP_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(TRF_REC_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(TRF_PICK_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
			OR to_char(TRF_RLS_PICK_DATE, ''YYYY-MM-DD'') >= TO_CHAR(sysdate - 1, ''YYYY-MM-DD'')
	')
)