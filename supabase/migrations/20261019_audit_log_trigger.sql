-- N7: Proteger audit_log contra falsificação de identidade
-- Problema: browser envia nome/email → qualquer usuário pode forjar a identidade
-- Solução: trigger que sobrescreve auth_uid com auth.uid() e bloqueia alteração
--          O nome/email ainda vêm do browser mas o auth_uid é garantido pelo banco

-- 1. Adiciona coluna auth_uid se não existir
ALTER TABLE public.audit_log
  ADD COLUMN IF NOT EXISTS auth_uid uuid;

-- 2. Cria trigger function que seta auth_uid = auth.uid() no INSERT
CREATE OR REPLACE FUNCTION public.audit_log_set_auth_uid()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Sobrescreve sempre com o UID real do JWT — não pode ser falsificado
  NEW.auth_uid := auth.uid();
  RETURN NEW;
END;
$$;

-- 3. Aplica trigger no INSERT
DROP TRIGGER IF EXISTS trg_audit_log_auth_uid ON public.audit_log;
CREATE TRIGGER trg_audit_log_auth_uid
  BEFORE INSERT ON public.audit_log
  FOR EACH ROW
  EXECUTE FUNCTION public.audit_log_set_auth_uid();

-- 4. Garante que a tabela seja append-only (sem UPDATE nem DELETE por autenticados)
DROP POLICY IF EXISTS "audit_log_update" ON public.audit_log;
DROP POLICY IF EXISTS "audit_log_delete" ON public.audit_log;

-- Apenas service_role pode modificar registros de auditoria
CREATE POLICY "audit_log_no_update"
  ON public.audit_log
  FOR UPDATE
  TO authenticated
  USING (false);

CREATE POLICY "audit_log_no_delete"
  ON public.audit_log
  FOR DELETE
  TO authenticated
  USING (false);
