import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://gabrielcoutovm.github.io',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Não autenticado' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // Verifica o chamador e obtém seu perfil
    const supabaseUser = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authErr } = await supabaseUser.auth.getUser();
    if (authErr || !user) {
      return new Response(JSON.stringify({ error: 'Token inválido' }), {
        status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // Verifica se o chamador tem perfil Gestão ou Secretaria
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const { data: callerProfile } = await supabaseAdmin
      .from('profiles')
      .select('perfil')
      .eq('auth_uid', user.id)
      .single();

    if (!callerProfile || !['Gestão', 'Secretaria'].includes(callerProfile.perfil)) {
      return new Response(JSON.stringify({ error: 'Sem permissão. Apenas Gestão ou Secretaria podem alterar perfis.' }), {
        status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    const body = await req.json();
    const { profile_id, nome, perfil, ativo, auth_uid } = body;

    if (!profile_id) {
      return new Response(JSON.stringify({ error: 'profile_id obrigatório' }), {
        status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // Campos permitidos para atualização
    const allowedFields: Record<string, unknown> = {};
    if (nome     !== undefined) allowedFields.nome     = nome;
    if (perfil   !== undefined) allowedFields.perfil   = perfil;
    if (ativo    !== undefined) allowedFields.ativo    = ativo;
    if (auth_uid !== undefined) allowedFields.auth_uid = auth_uid;

    const { error: updateErr } = await supabaseAdmin
      .from('profiles')
      .update(allowedFields)
      .eq('id', profile_id);

    if (updateErr) {
      return new Response(JSON.stringify({ error: updateErr.message }), {
        status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });

  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }
});
