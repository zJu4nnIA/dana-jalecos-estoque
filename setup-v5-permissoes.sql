-- ============================================
-- DANA JALECOS — V5: Cargo Gerente + Permissões Dinâmicas
-- Cole no SQL Editor do Supabase e clique RUN
-- ============================================

-- Adicionar cargo 'gerente'
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('admin', 'gerente', 'estoquista', 'costureira', 'user'));

-- Tabela de permissões por cargo (uma única linha com JSON)
CREATE TABLE IF NOT EXISTS role_permissions (
  id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  permissions JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Inserir permissões padrão
INSERT INTO role_permissions (id, permissions) VALUES (1, '{
  "gerente": {"dashboard":true,"estoque":true,"alertas":true,"historico":true,"cadastro":true,"entrada":true,"saida":true,"compras":true,"excluir_mov":false},
  "estoquista": {"dashboard":true,"estoque":true,"alertas":true,"historico":true,"cadastro":true,"entrada":true,"saida":true,"compras":false,"excluir_mov":false},
  "costureira": {"dashboard":true,"estoque":true,"alertas":false,"historico":true,"cadastro":false,"entrada":false,"saida":true,"compras":false,"excluir_mov":false}
}') ON CONFLICT (id) DO NOTHING;

-- RLS
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view permissions" ON role_permissions FOR SELECT USING (true);
CREATE POLICY "Admin can update permissions" ON role_permissions FOR UPDATE USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admin can insert permissions" ON role_permissions FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
