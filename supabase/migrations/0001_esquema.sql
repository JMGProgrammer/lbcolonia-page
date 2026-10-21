-- ============================================================================
-- 0001 · Esquema base de LBC Web
-- Fuente: Docs/02 (datos) + Docs/03 (roles/RLS). Multi-liga desde el día 1:
-- toda tabla de contenido lleva org_id. Las policies de Postgres son la única
-- barrera: la app nunca se confía a sí misma (Docs/03 §1).
-- Convención (Docs/02 §6): esta migración no se vuelve a editar.
-- ============================================================================

create extension if not exists pgcrypto;

-- Función de sellado temporal, definida antes de los triggers que la usan
create or replace function public.updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- ---------- enums ----------

create type plan_org as enum ('piloto', 'licencia', 'suspendido');
create type rol_org as enum ('liga_admin', 'liga_ayudante', 'delegado');
create type formato_torneo as enum ('liga', 'liga_playoffs', 'torneo');
create type estado_torneo as enum ('proximo', 'en_curso', 'finalizado');
create type estado_partido as enum ('programado', 'en_juego', 'finalizado', 'postergado', 'suspendido', 'walkover');
create type estado_planilla as enum ('borrador', 'disputada', 'verificada', 'anulada');
create type estado_ficha as enum ('solicitada', 'confirmada', 'baja');
create type nivel_auspicio as enum ('oro', 'plata', 'bronce', 'colaborador');
create type persona_sancion as enum ('jugador', 'tecnico', 'club');
create type estado_sancion as enum ('activa', 'cumplida', 'levantada');

-- ---------- organizaciones y personas ----------

-- Config global mínimo de la plataforma (org activa del dominio, MVP una sola).
-- Multi-dominio real entra con la Fase 8 (Docs/07): ahí cada dominio mapea su org.
create table app_config (
  clave     text primary key,
  valor     text not null,
  updated_at timestamptz not null default now()
);

create table orgs (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz,
  slug            text not null unique,
  nombre          text not null,
  logo_url        text,
  color_primario  text,
  color_secundario text,
  dominio_custom  text unique,
  plan            plan_org not null default 'piloto',
  config_json     jsonb not null default '{}',
  licencia_hasta  date
);
create trigger orgs_touch_updated before update on orgs
  for each row execute function public.updated_at();

-- Espejo de auth.users. Disparador abajo (on_auth_user_created).
create table profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  created_at    timestamptz not null default now(),
  nombre        text,
  foto_url      text,
  is_superadmin boolean not null default false
);

-- Circuito: org ↔ club (para el fk de org_members, se declara después de clubes).
create table clubes (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  org_id     uuid not null references orgs (id) on delete cascade,
  nombre     text not null,
  slug       text not null,
  escudo_url text,
  color1     text,
  color2     text,
  gimnasio   text,
  redes_json jsonb not null default '{}',
  activo     boolean not null default true,
  unique (org_id, slug)
);

create table org_members (
  org_id  uuid not null references orgs (id) on delete cascade,
  user_id uuid not null references profiles (id) on delete cascade,
  rol     rol_org not null,
  -- obligatorio si rol = 'delegado': es su club
  club_id uuid references clubes (id) on delete set null,
  primary key (org_id, user_id)
);

-- ---------- competencia ----------

create table categorias (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  org_id      uuid not null references orgs (id) on delete cascade,
  nombre      text not null,
  acronimo    text,
  orden       int not null default 0,
  es_formativa boolean not null default false,
  activa      boolean not null default true
);
create index categorias_org on categorias (org_id);

create table torneos (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  org_id      uuid not null references orgs (id) on delete cascade,
  categoria_id uuid not null references categorias (id) on delete restrict,
  temporada   int not null,
  nombre      text not null,
  formato     formato_torneo not null default 'liga',
  estado      estado_torneo not null default 'proximo',
  -- defaults FIBA (Docs/02 §2): los reales por competencia [a confirmar con la liga]
  reglas_json jsonb not null default
    '{"puntos_victoria": 2, "puntos_derrota": 1, "puntos_victoria_walkover": 1,
      "puntos_derrota_walkover": 0, "score_walkover": "20-0",
      "tiebreakers": ["matchup_individual", "dif_puntos", "puntos_favor"]}',
  estadisticas_detalladas boolean not null default false
);
create index torneos_org on torneos (org_id, temporada);

create table equipos (
  id            uuid primary key default gen_random_uuid(),
  created_at    timestamptz not null default now(),
  org_id        uuid not null references orgs (id) on delete cascade,
  club_id       uuid not null references clubes (id) on delete cascade,
  categoria_id  uuid not null references categorias (id) on delete cascade,
  -- "PLAZA - Primera" por defecto; la APP lo arma al crear (Docs/05)
  nombre_mostrar text,
  activo        boolean not null default true,
  unique (org_id, club_id, categoria_id)
);

create table jugadores (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  org_id          uuid not null references orgs (id) on delete cascade,
  nombre_completo text not null,
  fecha_nacimiento date,
  foto_url        text,
  notas           text
);
-- Control de duplicados (aviso en el panel, no bloqueo: hay homónimos reales)
create index jugadores_anti_duplicado on jugadores (org_id, lower(nombre_completo), fecha_nacimiento);

create table fichas (
  id        uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  org_id    uuid not null references orgs (id) on delete cascade,
  jugador_id uuid not null references jugadores (id) on delete cascade,
  equipo_id uuid not null references equipos (id) on delete cascade,
  torneo_id uuid not null references torneos (id) on delete cascade,
  dorsal    int,
  estado    estado_ficha not null default 'solicitada',
  desde     date not null,
  hasta     date
);
create index fichas_jugador_torneo on fichas (jugador_id, torneo_id);
create index fichas_equipo on fichas (equipo_id);
-- Una ficha viva por jugador y torneo (a la baja se puede re-fichar en otra fila)
create unique index fichas_unica_viva on fichas (jugador_id, torneo_id, equipo_id)
  where estado <> 'baja';

-- ---------- partidos y planillas ----------

create table partidos (
  id              uuid primary key default gen_random_uuid(),
  created_at      timestamptz not null default now(),
  org_id          uuid not null references orgs (id) on delete cascade,
  torneo_id       uuid not null references torneos (id) on delete cascade,
  ronda           text not null,
  fecha_hora      timestamptz not null,
  sede            text,
  equipo_local_id uuid not null references equipos (id) on delete cascade,
  equipo_visitante_id uuid not null references equipos (id) on delete cascade,
  estado          estado_partido not null default 'programado',
  puntos_local    int,
  puntos_visitante int,
  -- parciales por cuarto si el torneo los pide (config por torneo)
  cuartos_local   int[],
  cuartos_visitante int[],
  walkover_ganador_id uuid references equipos (id) on delete set null,
  nota_publica    text,
  publicado       boolean not null default false,
  publicado_at    timestamptz,
  check (equipo_local_id <> equipo_visitante_id),
  check (
    estado <> 'finalizado'
    or (puntos_local is not null and puntos_visitante is not null)
  ),
  check (
    estado <> 'walkover'
    or (walkover_ganador_id is not null
        and walkover_ganador_id in (equipo_local_id, equipo_visitante_id))
  ),
  check (not publicado or estado in ('finalizado', 'walkover'))
);
create index partidos_torneo_fecha on partidos (torneo_id, fecha_hora);
create index partidos_local on partidos (equipo_local_id);
create index partidos_visitante on partidos (equipo_visitante_id);
create index partidos_org_agenda on partidos (org_id, fecha_hora);

create table planillas (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz,
  org_id     uuid not null references orgs (id) on delete cascade,
  partido_id uuid not null unique references partidos (id) on delete cascade,
  estado     estado_planilla not null default 'borrador',
  -- foto del papel firmado: bucket privado 'planillas' (Docs/03 §3)
  foto_url   text,
  cargada_por uuid references profiles (id) on delete set null,
  disputada_por_club uuid references clubes (id) on delete set null,
  motivo_disputa text,
  verificada_por uuid references profiles (id) on delete set null,
  verificada_at  timestamptz
);
create trigger planillas_touch_updated before update on planillas
  for each row execute function public.updated_at();

create table planilla_stats (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  org_id     uuid not null references orgs (id) on delete cascade,
  planilla_id uuid not null references planillas (id) on delete cascade,
  ficha_id   uuid not null references fichas (id) on delete cascade,
  -- redundante con la ficha a propósito: agiliza la carga contra el papel
  dorsal     int,
  minutos    int,
  puntos     int not null default 0,
  faltas     int not null default 0,
  rebotes    int,
  asistencias int,
  tapas      int,
  robos      int,
  check (puntos >= 0 and faltas >= 0),
  check (minutos is null or minutos >= 0)
);
create index planilla_stats_planilla on planilla_stats (planilla_id);
create index planilla_stats_ficha on planilla_stats (ficha_id);

-- ---------- sanciones (Docs/06 §4) ----------

create table sanciones (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  org_id     uuid not null references orgs (id) on delete cascade,
  tipo       persona_sancion not null,
  -- tipo jugador → jugador_id; tecnico → nombre_libre; club → club_id
  jugador_id uuid references jugadores (id) on delete set null,
  club_id    uuid references clubes (id) on delete set null,
  nombre_libre text,
  motivo     text not null,
  partidos_cumplir int not null default 1,
  fecha_alta date not null default current_date,
  estado     estado_sancion not null default 'activa',
  publicado  boolean not null default false,
  -- baja anticipada: solo la liga, con nota (transparencia, Docs/06 §4)
  nota_baja  text
);
create index sanciones_org on sanciones (org_id, estado);

-- ---------- contenido editorial ----------

create table noticias (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  org_id      uuid not null references orgs (id) on delete cascade,
  slug        text not null,
  titulo      text not null,
  bajada      text,
  cuerpo_md   text,
  portada_url text,
  destacado   boolean not null default false,
  publicado   boolean not null default false,
  publicado_at timestamptz,
  etiquetas   text[] not null default '{}',
  unique (org_id, slug)
);
create index noticias_org_publicadas on noticias (org_id, publicado_at desc);

create table auspiciantes (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  org_id     uuid not null references orgs (id) on delete cascade,
  nombre     text not null,
  logo_url   text,
  link       text,
  nivel      nivel_auspicio not null default 'bronce',
  activo     boolean not null default true,
  orden      int not null default 0,
  vigencia_hasta date
);
create index auspiciantes_org on auspiciantes (org_id, nivel, orden);

create table paginas (
  id         uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  org_id     uuid not null references orgs (id) on delete cascade,
  slug       text not null,
  titulo     text not null,
  cuerpo_md  text,
  publicado  boolean not null default false,
  unique (org_id, slug)
);

-- ============================================================================
-- Helpers (SECURITY DEFINER: las policies los usan sin autoreferencia rota)
-- ============================================================================

create or replace function public.org_activa_id() returns uuid
language sql stable security definer set search_path = public as $$
  select valor::uuid from app_config where clave = 'org_activa'
$$;

create or replace function public.es_superadmin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select p.is_superadmin from profiles p where p.id = auth.uid()), false)
$$;

create or replace function public.rol_en_org(_org_id uuid) returns rol_org
language sql stable security definer set search_path = public as $$
  select om.rol from org_members om where om.org_id = _org_id and om.user_id = auth.uid()
$$;

create or replace function public.es_organizador(_org_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select es_superadmin() or coalesce(rol_en_org(_org_id) in ('liga_admin', 'liga_ayudante'), false)
$$;

create or replace function public.es_liga_admin(_org_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select es_superadmin() or coalesce(rol_en_org(_org_id) = 'liga_admin', false)
$$;

-- Club del delegado que consulta (null si no es delegado ahí)
create or replace function public.mi_club_de(_org_id uuid) returns uuid
language sql stable security definer set search_path = public as $$
  select om.club_id from org_members om
  where om.org_id = _org_id and om.user_id = auth.uid() and om.rol = 'delegado'
$$;

-- ¿El delegado autenticado es del club LOCAL de ese partido?
create or replace function public.es_delegado_local(_partido_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from partidos p
    join equipos e_local on e_local.id = p.equipo_local_id
    where p.id = _partido_id
      and e_local.club_id = mi_club_de(p.org_id)
  ) or es_organizador((select org_id from partidos where id = _partido_id))
$$;

create or replace function public.es_miembro_del_partido(_partido_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from partidos p
    join equipos e_local on e_local.id = p.equipo_local_id
    join equipos e_visita on e_visita.id = p.equipo_visitante_id
    where p.id = _partido_id
      and (e_local.club_id = mi_club_de(p.org_id) or e_visita.club_id = mi_club_de(p.org_id))
  ) or es_organizador((select org_id from partidos where id = _partido_id))
$$;

-- ¿El delegado es del club local y la planilla sigue en borrador? (puede editar stats)
create or replace function public.es_delegado_local_borrador(_planilla_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from planillas pl
    join partidos p on p.id = pl.partido_id
    join equipos e on e.id = p.equipo_local_id
    where pl.id = _planilla_id
      and pl.estado = 'borrador'
      and e.club_id = mi_club_de(pl.org_id)
  ) or es_organizador((select org_id from planillas where id = _planilla_id))
$$;

-- ¿El delegado es del club VISITANTE y la planilla sigue en borrador? (puede disputar)
create or replace function public.es_visitante_borrador(_planilla_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from planillas pl
    join partidos p on p.id = pl.partido_id
    join equipos e on e.id = p.equipo_visitante_id
    where pl.id = _planilla_id
      and pl.estado = 'borrador'
      and e.club_id = mi_club_de(pl.org_id)
  )
$$;

-- ¿El delegado es dueño de ese equipo (su club)?
create or replace function public.es_delegado_de_equipo(_equipo_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from equipos e
    where e.id = _equipo_id and e.club_id = mi_club_de(e.org_id)
  )
$$;

-- Lo que ve el público: planilla verificada de un partido publicado de la org activa
create or replace function public.es_planilla_publica(_planilla_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from planillas pl
    join partidos p on p.id = pl.partido_id
    where pl.id = _planilla_id
      and pl.estado = 'verificada'
      and p.publicado = true
      and p.org_id = org_activa_id()
  )
$$;

-- ============================================================================
-- Triggers de negocio
-- ============================================================================

-- profile espejo al alta de usuario (Docs/02 §1)
create or replace function public.on_auth_user_created() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id) values (new.id) on conflict (id) do nothing;
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.on_auth_user_created();

-- El partido sale a la luz solo finalizado/walkover: al publicar, sella la hora
create or replace function public.partidos_guard_publicacion() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  -- solo liga_admin publica (Docs/03: el ayudante escribe, no publica)
  if new.publicado and not old.publicado and not es_liga_admin(new.org_id) then
    raise exception 'solo liga_admin puede publicar un partido';
  end if;
  if new.publicado and not old.publicado and new.publicado_at is null then
    new.publicado_at = now();
  end if;
  return new;
end $$;

create trigger partidos_guard_publicacion
  before update on partidos
  for each row execute function public.partidos_guard_publicacion();

-- Verificación de planilla ⇒ partido finalizado con marcador = suma de stats.
-- Publicar es un paso aparte (botón de la liga, guard liga_admin).
create or replace function public.planilla_verificada_cierre() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  v_local uuid;
  v_visita uuid;
  v_pts_local int;
  v_pts_visita int;
begin
  if new.estado = 'verificada' and old.estado is distinct from 'verificada' then
    select p.equipo_local_id, p.equipo_visitante_id
      into v_local, v_visita
      from partidos p
      where p.id = new.partido_id;

    select coalesce(sum(ps.puntos), 0) into v_pts_local
      from planilla_stats ps
      join fichas f on f.id = ps.ficha_id
      join equipos e on e.id = f.equipo_id
      where ps.planilla_id = new.id and e.id = v_local;

    select coalesce(sum(ps.puntos), 0) into v_pts_visita
      from planilla_stats ps
      join fichas f on f.id = ps.ficha_id
      join equipos e on e.id = f.equipo_id
      where ps.planilla_id = new.id and e.id = v_visita;

    update partidos
      set estado = 'finalizado',
          puntos_local = v_pts_local,
          puntos_visitante = v_pts_visita
      where id = new.partido_id
        and estado not in ('finalizado', 'walkover');

    new.verificada_at = coalesce(new.verificada_at, now());
  end if;
  return new;
end $$;

create trigger planilla_verificada_cierre
  before update on planillas
  for each row execute function public.planilla_verificada_cierre();

-- El plan/licencia/slug/dominio solo los toca el superadmin (Docs/03 §2)
create or replace function public.orgs_guard_plan() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if not es_superadmin() then
    if new.plan is distinct from old.plan
       or new.licencia_hasta is distinct from old.licencia_hasta
       or new.slug is distinct from old.slug
       or coalesce(new.dominio_custom, '-') is distinct from coalesce(old.dominio_custom, '-') then
      raise exception 'solo superadmin toca plan, licencia, slug o dominio';
    end if;
  end if;
  return new;
end $$;

create trigger orgs_guard_plan
  before update on orgs
  for each row execute function public.orgs_guard_plan();

-- ============================================================================
-- RLS: las policies son la única barrera (Docs/03). El helper es_* se evalúa
-- con derecho del dueño de la función (definer), así las policies no se muerden
-- la cola ellas mismas.
-- ============================================================================

alter table app_config            enable row level security;
alter table orgs                  enable row level security;
alter table profiles              enable row level security;
alter table org_members           enable row level security;
alter table categorias            enable row level security;
alter table torneos               enable row level security;
alter table clubes                enable row level security;
alter table equipos               enable row level security;
alter table jugadores             enable row level security;
alter table fichas                enable row level security;
alter table partidos              enable row level security;
alter table planillas             enable row level security;
alter table planilla_stats        enable row level security;
alter table sanciones             enable row level security;
alter table noticias              enable row level security;
alter table auspiciantes          enable row level security;
alter table paginas               enable row level security;

-- ---- app_config: la clave pública es la org activa; otras claves, solo superadmin
create policy app_config_leer on app_config
  for select using (clave = 'org_activa');
create policy app_config_admin on app_config
  for all to authenticated using (es_superadmin()) with check (es_superadmin());

-- ---- orgs: branding público; el plan solo lo toca el superadmin
create policy orgs_anon_leer on orgs
  for select to anon
  using (id = org_activa_id() and plan <> 'suspendido');
create policy orgs_miembros_leer on orgs
  for select to authenticated
  using (id = org_activa_id() or es_superadmin() or exists (
    select 1 from org_members om where om.org_id = id and om.user_id = auth.uid()
  ));
create policy orgs_crear on orgs
  for insert to authenticated with check (es_superadmin());
create policy orgs_editar on orgs
  for update to authenticated
  using (es_superadmin() or rol_en_org(id) = 'liga_admin')
  with check (es_superadmin() or rol_en_org(id) = 'liga_admin');
-- sin delete: una org no se borra desde la app (superadmin por SQL)

-- ---- profiles: uno mismo, superadmin, o un admin de org con la que esté
create policy profiles_leer on profiles
  for select to authenticated
  using (
    id = auth.uid()
    or es_superadmin()
    or exists (
      select 1
      from org_members mio
      join org_members otro on otro.org_id = mio.org_id
      where mio.user_id = auth.uid()
        and mio.rol in ('liga_admin', 'liga_ayudante')
        and otro.user_id = profiles.id
    )
  );
create policy profiles_editarme on profiles
  for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- ---- org_members: verlos los de tu org; escribir solo liga_admin
create policy org_members_leer on org_members
  for select to authenticated
  using (
    user_id = auth.uid()
    or es_superadmin()
    or coalesce(rol_en_org(org_id) in ('liga_admin', 'liga_ayudante'), false)
  );
create policy org_members_admin on org_members
  for all to authenticated
  using (es_superadmin() or rol_en_org(org_id) = 'liga_admin')
  with check (es_superadmin() or rol_en_org(org_id) = 'liga_admin');

-- ---- catálogos de la org: lectura con org activa, escritura del equipo de la liga
create policy categorias_leer on categorias for select
  using (
    org_id = org_activa_id()
    or es_organizador(org_id)
  );
create policy categorias_admin on categorias
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

create policy clubes_leer on clubes for select
  using (org_id = org_activa_id() or es_organizador(org_id));
create policy clubes_admin on clubes
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

create policy equipos_leer on equipos for select
  using (org_id = org_activa_id() or es_organizador(org_id));
create policy equipos_admin on equipos
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

create policy torneos_leer on torneos for select
  using (org_id = org_activa_id() or es_organizador(org_id));
create policy torneos_admin on torneos
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

create policy jugadores_leer on jugadores for select
  using (org_id = org_activa_id() or es_organizador(org_id));
create policy jugadores_admin on jugadores
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

-- ---- fichas: pública del roster; delegado propone en su club, la liga confirma
create policy fichas_leer on fichas for select
  using (org_id = org_activa_id() or es_organizador(org_id));
create policy fichas_delegado_solicitar on fichas
  for insert to authenticated
  with check (
    estado = 'solicitada'
    and org_id = org_activa_id()
    and es_delegado_de_equipo(equipo_id)
  );
create policy fichas_delegado_editar on fichas
  for update to authenticated
  using (estado = 'solicitada' and org_id = org_activa_id() and es_delegado_de_equipo(equipo_id))
  with check (estado in ('solicitada', 'baja'));  -- puede auto-bajar la suya; confirmar lo hace la liga
create policy fichas_liga on fichas
  for update to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

-- ---- partidos: fixture programado visible; resultados solo publicados
create policy partidos_anon_leer on partidos
  for select to anon
  using (
    org_id = org_activa_id()
    and (publicado or estado in ('programado', 'postergado', 'suspendido'))
  );
create policy partidos_auth_leer on partidos
  for select to authenticated
  using (org_id = org_activa_id());
create policy partidos_liga on partidos
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

-- ---- planillas: a anon ni una fila (Docs/03 §2)
create policy planillas_partido_leer on planillas
  for select to authenticated
  using (es_miembro_del_partido(partido_id));
create policy planillas_delegado_cargar on planillas
  for insert to authenticated
  with check (estado = 'borrador' and es_delegado_local(partido_id));
create policy planillas_delegado_borrador on planillas
  for update to authenticated
  using (estado = 'borrador' and es_delegado_local(partido_id))
  with check (estado = 'borrador' and es_delegado_local(partido_id));
create policy planillas_visita_disputar on planillas
  for update to authenticated
  using (estado = 'borrador' and es_visitante_borrador(id) and mi_club_de(org_id) is not null)
  with check (
    estado = 'disputada'
    and disputada_por_club = mi_club_de(org_id)
  );
create policy planillas_liga on planillas
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

-- ---- planilla_stats: líneas de planilla verificada y partido publicado para anon
create policy stats_anon_leer on planilla_stats
  for select to anon
  using (es_planilla_publica(planilla_id));
create policy stats_auth_leer on planilla_stats
  for select to authenticated
  using (org_id = org_activa_id());
create policy stats_delegado_cargar on planilla_stats
  for insert to authenticated
  with check (es_delegado_local_borrador(planilla_id));
create policy stats_delegado_borrador on planilla_stats
  for update to authenticated
  using (es_delegado_local_borrador(planilla_id))
  with check (es_delegado_local_borrador(planilla_id));
create policy stats_delegado_borrar on planilla_stats
  for delete to authenticated
  using (es_delegado_local_borrador(planilla_id));
create policy stats_liga on planilla_stats
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

-- ---- sanciones: publicadas al público; escribibles por la liga
create policy sanciones_anon_leer on sanciones
  for select to anon
  using (org_id = org_activa_id() and publicado);
create policy sanciones_auth_leer on sanciones
  for select to authenticated
  using (org_id = org_activa_id());
create policy sanciones_liga on sanciones
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

-- ---- noticias/páginas: publicadas al público; el equipo de la liga escribe
create policy noticias_anon_leer on noticias
  for select to anon
  using (org_id = org_activa_id() and publicado);
create policy noticias_auth_leer on noticias
  for select to authenticated
  using (org_id = org_activa_id());
create policy noticias_liga on noticias
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

create policy paginas_anon_leer on paginas
  for select to anon
  using (org_id = org_activa_id() and publicado);
create policy paginas_auth_leer on paginas
  for select to authenticated
  using (org_id = org_activa_id());
create policy paginas_liga on paginas
  for all to authenticated
  using (es_organizador(org_id)) with check (es_organizador(org_id));

-- ---- auspiciantes: escritura solo de liga_admin (ni ayudante, Docs/03 §2)
create policy ausp_anon_leer on auspiciantes
  for select to anon
  using (org_id = org_activa_id() and activo);
create policy ausp_auth_leer on auspiciantes
  for select to authenticated
  using (org_id = org_activa_id());
create policy ausp_liga_admin on auspiciantes
  for all to authenticated
  using (es_liga_admin(org_id)) with check (es_liga_admin(org_id));

-- ============================================================================
-- Permisos base: Supabase no garantiza todos los verbos por default-privileges;
-- los policies deciden qué filas pasan, el GRANT decide qué tablas se tocan.
-- ============================================================================

grant usage on schema public to anon, authenticated;
grant select on all tables in schema public to anon, authenticated;
grant select, insert, update, delete on all tables in schema public to authenticated;

-- ============================================================================
-- Views SQL (Docs/02 §4): la tabla de posiciones NUNCA se persiste
-- ============================================================================

create or replace view public.v_tabla as
with filas as (
  select
    t.id as torneo_id,
    t.org_id,
    t.reglas_json,
    e.id as equipo_id,
    p.id as partido_id,
    case
      when p.estado = 'finalizado' and p.equipo_local_id = e.id
        then case when p.puntos_local > p.puntos_visitante then 'V' else 'D' end
      when p.estado = 'finalizado'
        then case when p.puntos_visitante > p.puntos_local then 'V' else 'D' end
      when p.estado = 'walkover' and p.walkover_ganador_id = e.id then 'VW'
      when p.estado = 'walkover' then 'DW'
    end as resultado,
    case
      when p.estado = 'finalizado' and p.equipo_local_id = e.id then p.puntos_local
      when p.estado = 'finalizado' then p.puntos_visitante
      when p.estado = 'walkover' and p.walkover_ganador_id = e.id
        then (split_part(t.reglas_json ->> 'score_walkover', '-', 1))::int
      when p.estado = 'walkover'
        then (split_part(t.reglas_json ->> 'score_walkover', '-', 2))::int
    end as gf,
    case
      when p.estado = 'finalizado' and p.equipo_local_id = e.id then p.puntos_visitante
      when p.estado = 'finalizado' then p.puntos_local
      when p.estado = 'walkover' and p.walkover_ganador_id = e.id
        then (split_part(t.reglas_json ->> 'score_walkover', '-', 2))::int
      when p.estado = 'walkover'
        then (split_part(t.reglas_json ->> 'score_walkover', '-', 1))::int
    end as gc
  from partidos p
  join equipos e on e.id in (p.equipo_local_id, p.equipo_visitante_id)
  join torneos t on t.id = p.torneo_id
  where p.publicado and p.estado in ('finalizado', 'walkover')
)
select
  f.torneo_id,
  f.org_id,
  f.equipo_id,
  eq.nombre_mostrar as equipo,
  c.nombre          as club,
  count(f.partido_id)          as pj,
  count(f.partido_id) filter (where f.resultado = 'V')  as pg,
  count(f.partido_id) filter (where f.resultado = 'VW') as pw,
  count(f.partido_id) filter (where f.resultado = 'D')  as pp,
  count(f.partido_id) filter (where f.resultado = 'DW') as pdw,
  sum(f.gf)                    as gf,
  sum(f.gc)                    as gc,
  sum(f.gf) - sum(f.gc)        as dif,
  count(f.partido_id) filter (where f.resultado = 'V')
    * (f.reglas_json ->> 'puntos_victoria')::int
  + count(f.partido_id) filter (where f.resultado = 'VW')
    * (f.reglas_json ->> 'puntos_victoria_walkover')::int
  + count(f.partido_id) filter (where f.resultado = 'D')
    * (f.reglas_json ->> 'puntos_derrota')::int
  + count(f.partido_id) filter (where f.resultado = 'DW')
    * (f.reglas_json ->> 'puntos_derrota_walkover')::int as pts
from filas f
join equipos eq on eq.id = f.equipo_id
join clubes c on c.id = eq.club_id
group by f.torneo_id, f.org_id, f.equipo_id, eq.nombre_mostrar, c.nombre, f.reglas_json
order by pts desc, dif desc, gf desc;

create or replace view public.v_lideres as
select
  p.torneo_id,
  p.org_id,
  ficha.jugador_id,
  j.nombre_completo,
  eq.id as equipo_id,
  eq.nombre_mostrar as equipo,
  count(distinct pl.partido_id)                                   as pj,
  coalesce(sum(s.puntos), 0)                                      as puntos,
  coalesce(sum(s.rebotes), 0)                                     as rebotes,
  coalesce(sum(s.asistencias), 0)                                 as asistencias,
  coalesce(sum(s.tapas), 0)                                       as tapas,
  coalesce(sum(s.robos), 0)                                       as robos,
  coalesce(sum(s.faltas), 0)                                      as faltas
from planillas pl
join planilla_stats s on s.planilla_id = pl.id
join partidos p on p.id = pl.partido_id
join fichas ficha on ficha.id = s.ficha_id
join jugadores j on j.id = ficha.jugador_id
join equipos eq on eq.id = ficha.equipo_id
where pl.estado = 'verificada'
  and p.publicado
  and p.estado in ('finalizado', 'walkover')
group by p.torneo_id, p.org_id, ficha.jugador_id, j.nombre_completo, eq.id, eq.nombre_mostrar
order by p.torneo_id, puntos desc;

create or replace view public.v_sanciones_activas as
select
  s.id,
  s.org_id,
  s.tipo,
  coalesce(j.nombre_completo, s.nombre_libre, c.nombre) as persona,
  s.jugador_id,
  c.id as club_id,
  c.nombre as club,
  s.motivo,
  s.partidos_cumplir,
  s.fecha_alta,
  -- consume todo partido finalizado/walkover publicado del ámbito sancionado,
  -- a partir de la fecha del alta (postergados y suspendidos no descuentan, Docs/06 §4)
  s.partidos_cumplir - coalesce((
    select count(distinct p.id)
    from partidos p
    join equipos eq on eq.id in (p.equipo_local_id, p.equipo_visitante_id)
    where p.publicado
      and p.estado in ('finalizado', 'walkover')
      and p.fecha_hora::date >= s.fecha_alta
      and (
        (s.tipo = 'jugador' and exists (
          select 1 from fichas f
          where f.jugador_id = s.jugador_id
            and f.torneo_id = p.torneo_id
            and f.equipo_id = eq.id
        ))
        or (s.tipo in ('club', 'tecnico') and eq.club_id = s.club_id)
      )
  ), 0) as partidos_restantes
from sanciones s
left join jugadores j on j.id = s.jugador_id
left join clubes c on c.id = (case when s.tipo = 'club' then s.club_id else coalesce((
  -- club del jugador por su ficha vigente
  select eq.club_id from fichas f join equipos eq on eq.id = f.equipo_id
  where f.jugador_id = s.jugador_id order by f.created_at desc limit 1
)) end)
where s.estado = 'activa';

grant select on public.v_tabla, public.v_lideres, public.v_sanciones_activas to anon, authenticated;

-- ============================================================================
-- Storage (Docs/03 §3)
-- ============================================================================

insert into storage.buckets (id, name, public) values
  ('logos',        'logos',        true),
  ('noticias',     'noticias',     true),
  ('auspiciantes', 'auspiciantes', true),
  ('planillas',    'planillas',    false)
on conflict (id) do update set public = excluded.public;

-- lectura pública de los buckets públicos
create policy storage_publico_lee on storage.objects
  for select to anon
  using (bucket_id in ('logos', 'noticias', 'auspiciantes'));

-- escritura de la liga en buckets públicos (path 'bucket/{org}/…')
create policy storage_liga_escribe_logos on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'logos'
    and es_liga_admin(((storage.foldername(name))[2])::uuid)
  );
create policy storage_liga_escribe_noticias on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'noticias'
    and es_organizador(((storage.foldername(name))[2])::uuid)
  );
create policy storage_liga_escribe_auspiciantes on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'auspiciantes'
    and es_liga_admin(((storage.foldername(name))[2])::uuid)
  );
create policy storage_liga_actualiza_publicos on storage.objects
  for update to authenticated
  using (
    bucket_id in ('logos', 'noticias', 'auspiciantes')
    and es_organizador(((storage.foldername(name))[2])::uuid)
  )
  with check (
    bucket_id in ('logos', 'noticias', 'auspiciantes')
    and es_organizador(((storage.foldername(name))[2])::uuid)
  );
create policy storage_liga_borra_publicos on storage.objects
  for delete to authenticated
  using (
    bucket_id in ('logos', 'noticias', 'auspiciantes')
    and es_organizador(((storage.foldername(name))[2])::uuid)
  );

-- bucket privado planillas: path 'planillas/{org}/{partido}/…'
-- escribe: delegado del club local; leen: los dos clubes del partido y la liga
create policy storage_delegado_subita_planilla on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'planillas'
    and exists (
      select 1
      from partidos p
      join equipos e on e.id = p.equipo_local_id
      where p.id::text = (storage.foldername(name))[3]
        and p.org_id::text = (storage.foldername(name))[2]
        and e.club_id = mi_club_de(p.org_id)
    )
  );
create policy storage_leen_clubes_del_partido on storage.objects
  for select to authenticated
  using (
    bucket_id = 'planillas'
    and exists (
      select 1
      from partidos p
      where p.id::text = (storage.foldername(name))[3]
        and p.org_id::text = (storage.foldername(name))[2]
        and es_miembro_del_partido(p.id)
    )
  );
create policy storage_delegado_actualiza_foto on storage.objects
  for update to authenticated
  using (
    bucket_id = 'planillas'
    and exists (
      select 1
      from partidos p
      join equipos e on e.id = p.equipo_local_id
      where p.id::text = (storage.foldername(name))[3]
        and p.org_id::text = (storage.foldername(name))[2]
        and e.club_id = mi_club_de(p.org_id)
    )
  )
  with check (
    bucket_id = 'planillas'
  );
create policy storage_liga_borra_planilla on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'planillas'
    and es_organizador(((storage.foldername(name))[2])::uuid)
  );

