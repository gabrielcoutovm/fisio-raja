-- ============================================================
-- RLS: bloqueia acesso anônimo em todas as tabelas do sistema
-- Execute no SQL Editor do Supabase
-- ============================================================

-- ---- store (chave-valor legado) ----
ALTER TABLE public.store ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "store_select" ON public.store;
DROP POLICY IF EXISTS "store_upsert" ON public.store;
DROP POLICY IF EXISTS "store_delete" ON public.store;

CREATE POLICY "store_select" ON public.store
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "store_upsert" ON public.store
  FOR INSERT TO authenticated WITH CHECK (true);

CREATE POLICY "store_update" ON public.store
  FOR UPDATE TO authenticated USING (true);

-- ---- pacientes ----
ALTER TABLE public.pacientes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pacientes_all" ON public.pacientes;
CREATE POLICY "pacientes_all" ON public.pacientes
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---- guias ----
ALTER TABLE public.guias ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "guias_all" ON public.guias;
CREATE POLICY "guias_all" ON public.guias
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---- hist_procs ----
ALTER TABLE public.hist_procs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "hist_procs_all" ON public.hist_procs;
CREATE POLICY "hist_procs_all" ON public.hist_procs
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---- hist_status ----
ALTER TABLE public.hist_status ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "hist_status_all" ON public.hist_status;
CREATE POLICY "hist_status_all" ON public.hist_status
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---- hist_ims ----
ALTER TABLE public.hist_ims ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "hist_ims_all" ON public.hist_ims;
CREATE POLICY "hist_ims_all" ON public.hist_ims
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---- lotes ----
ALTER TABLE public.lotes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lotes_all" ON public.lotes;
CREATE POLICY "lotes_all" ON public.lotes
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---- glosas ----
ALTER TABLE public.glosas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "glosas_all" ON public.glosas;
CREATE POLICY "glosas_all" ON public.glosas
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ============================================================
-- Verificação: este SELECT deve retornar 0 rows se RLS estiver
-- correto (execute como role "anon" no SQL Editor):
--
--   SET ROLE anon;
--   SELECT count(*) FROM public.store;    -- deve dar erro ou 0
--   SET ROLE authenticated;
-- ============================================================
