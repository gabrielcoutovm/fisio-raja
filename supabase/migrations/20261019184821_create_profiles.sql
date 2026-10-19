-- Tabela de perfis de usuários com RLS
CREATE TABLE IF NOT EXISTS public.profiles (
  id bigint PRIMARY KEY,
  auth_uid uuid UNIQUE REFERENCES auth.users(id) ON DELETE SET NULL,
  nome text NOT NULL,
  email text NOT NULL,
  perfil text NOT NULL DEFAULT 'Fisioterapeuta' CHECK (perfil IN ('Gestão', 'Fisioterapeuta', 'Secretaria')),
  ativo integer NOT NULL DEFAULT 1,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert" ON public.profiles;

-- Qualquer usuário autenticado pode ler todos os perfis
CREATE POLICY "profiles_select" ON public.profiles
  FOR SELECT TO authenticated USING (true);

-- Qualquer usuário Gestão/Secretaria pode inserir novos perfis
-- (INSERT sem restrição de linha — a Edge Function gerenciar-perfil valida o perfil do chamador)
CREATE POLICY "profiles_insert" ON public.profiles
  FOR INSERT TO authenticated WITH CHECK (true);

-- Usuário pode atualizar apenas seu próprio perfil, sem alterar perfil nem ativo
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE TO authenticated
  USING (auth_uid = auth.uid())
  WITH CHECK (
    auth_uid = auth.uid()
    AND perfil = (SELECT perfil FROM public.profiles WHERE auth_uid = auth.uid())
    AND ativo = (SELECT ativo FROM public.profiles WHERE auth_uid = auth.uid())
  );

-- Migrar dados existentes do store para profiles
INSERT INTO public.profiles (id, auth_uid, nome, email, perfil, ativo)
SELECT
  (elem->>'id')::bigint,
  CASE WHEN elem->>'auth_uid' IS NOT NULL AND elem->>'auth_uid' != 'null'
       THEN (elem->>'auth_uid')::uuid ELSE NULL END,
  elem->>'nome',
  COALESCE(elem->>'email', elem->>'login', 'sem-email@placeholder.local'),
  COALESCE(elem->>'perfil', 'Fisioterapeuta'),
  COALESCE((elem->>'ativo')::integer, 1)
FROM public.store,
     jsonb_array_elements(value) AS elem
WHERE key = 'usuarios'
  AND jsonb_typeof(value) = 'array'
ON CONFLICT (id) DO NOTHING;
