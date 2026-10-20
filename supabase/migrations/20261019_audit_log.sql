-- Tabela de log imutável (INSERT-only via RLS) — LGPD rastreabilidade
CREATE TABLE IF NOT EXISTS public.audit_log (
  id          bigserial PRIMARY KEY,
  tipo        text NOT NULL,
  detalhes    text,
  guia_id     bigint,
  usuario     text,
  email       text,
  criado_em   timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

-- Qualquer usuário autenticado pode INSERIR — nunca UPDATE ou DELETE
DROP POLICY IF EXISTS "audit_log_insert" ON public.audit_log;
CREATE POLICY "audit_log_insert"
  ON public.audit_log
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Apenas usuários autenticados podem LER
DROP POLICY IF EXISTS "audit_log_select" ON public.audit_log;
CREATE POLICY "audit_log_select"
  ON public.audit_log
  FOR SELECT
  TO authenticated
  USING (true);

-- Bloqueia explicitamente UPDATE e DELETE para todos (incluindo service_role via RLS)
-- Nota: service_role bypassa RLS por padrão — a imutabilidade depende de não expor
-- a service_role key no cliente (o que já é garantido pelas Edge Functions).
