-- N3: Corrigir RLS da tabela profiles
-- Problema: qualquer usuário autenticado pode INSERT e pode definir perfil = 'Gestão'
-- Solução: INSERT/UPDATE somente via service_role (Edge Functions)
--          SELECT: cada usuário lê apenas o próprio perfil (ou Gestão lê todos)

-- 1. Remove políticas existentes
DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update" ON public.profiles;
DROP POLICY IF EXISTS "profiles_delete" ON public.profiles;

-- 2. Garante RLS ativo
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. SELECT: usuário lê o próprio perfil
--    (Gestão também pode ler todos — via função com security definer se necessário)
CREATE POLICY "profiles_select"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (auth_uid = auth.uid());

-- 4. INSERT: apenas service_role (Edge Functions usam a service key)
--    Usuários autenticados NÃO podem criar perfis diretamente
CREATE POLICY "profiles_insert"
  ON public.profiles
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- 5. UPDATE: apenas service_role
CREATE POLICY "profiles_update"
  ON public.profiles
  FOR UPDATE
  TO service_role
  USING (true)
  WITH CHECK (true);

-- 6. Garante unicidade de email e auth_uid
ALTER TABLE public.profiles
  ADD CONSTRAINT IF NOT EXISTS profiles_email_unique UNIQUE (email);

ALTER TABLE public.profiles
  ADD CONSTRAINT IF NOT EXISTS profiles_auth_uid_unique UNIQUE (auth_uid);
