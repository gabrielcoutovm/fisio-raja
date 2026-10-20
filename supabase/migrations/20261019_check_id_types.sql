-- N4: Verificar tipos das colunas 'id' nas tabelas principais
-- Esperado: bigint (para suportar Date.now() ~1.7 trilhão)
-- Se retornar 'integer' em alguma tabela, rode o script de correção abaixo

SELECT
  table_name,
  column_name,
  data_type,
  CASE WHEN data_type = 'bigint' THEN '✅ OK' ELSE '⚠️ PRECISA CORRIGIR' END AS status
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name = 'id'
  AND table_name IN (
    'guias','pacientes','hist_procs','hist_status',
    'hist_ims','lotes','glosas','convenios',
    'profissionais','profiles'
  )
ORDER BY table_name;

-- ============================================================
-- SE ALGUMA COLUNA RETORNAR 'integer', execute o bloco abaixo
-- (Substitua TABLE_NAME pelo nome real da tabela)
-- ============================================================
-- ALTER TABLE public.TABLE_NAME ALTER COLUMN id TYPE bigint;
