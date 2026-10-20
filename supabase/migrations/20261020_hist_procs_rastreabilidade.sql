-- Rastreabilidade: adiciona usuario_id (auth.uid) e crefito ao hist_procs
-- Permite identificar qual profissional registrou cada procedimento

ALTER TABLE public.hist_procs
  ADD COLUMN IF NOT EXISTS usuario_id uuid,
  ADD COLUMN IF NOT EXISTS crefito text;

-- Índice para buscas por profissional
CREATE INDEX IF NOT EXISTS hist_procs_usuario_id_idx ON public.hist_procs (usuario_id);
