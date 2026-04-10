-- ============================================
-- DANA JALECOS — V3: Cargos (admin, estoquista, costureira)
-- Cole no SQL Editor do Supabase e clique RUN
-- ============================================

-- Atualizar constraint de role para aceitar os novos cargos
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('admin', 'estoquista', 'costureira', 'user'));

-- Permitir que admin atualize qualquer perfil (para mudar cargos)
DROP POLICY IF EXISTS "Admin can update any profile" ON profiles;
CREATE POLICY "Admin can update any profile" ON profiles FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
