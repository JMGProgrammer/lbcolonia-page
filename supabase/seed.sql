-- ============================================================================
-- Seed para el checkpoint 2 (Docs/12 IT2) y la demo comercial (Docs/10 §2)
--
-- Contenido:
--   · Org LBC (organización real del piloto) con el brand de los afiches
--   · 4 clubes reales de Primera 2026 (nombres tal como salen en el afiche)
--   · Fixture completo de Primera: 6 fechas, doble jornada, anfitrión por fecha
--   · Torneos demo de formativas (Sub-15/Sub-13) y amateur
--   · Rosters [demo] con fichas confirmadas
--   · 3 planillas de ejemplo: verificada / disputada / borrador + 1 walkover
--   · Sanción demo, noticias, auspiciantes y páginas
--
-- Toda la data inventada va marcada [demo]; lo que la liga debe confirmar,
-- [a confirmar con la liga]. Las sedes de las fechas 5 y 6 quedan sin gimnasio
-- (así lo dice el afiche: "a confirmar").
-- Cuentas de panel: superadmin@ / liga@ / ayudante@ / delegado.<club>@demo.lbc.uy
-- clave de todas: demo-2026 (exclusiva del ambiente de prueba).
-- ============================================================================

do $$
declare
  -- IDs fijos: seed reproducible y claramente identifiable
  v_org        uuid := 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
  v_user_super uuid := '00000000-0000-0000-0000-0000000000a1';
  v_user_liga  uuid := '00000000-0000-0000-0000-0000000000a2';
  v_user_ayud  uuid := '00000000-0000-0000-0000-0000000000a3';
  v_user_d_pla uuid := '00000000-0000-0000-0000-0000000000b1';
  v_user_d_rol uuid := '00000000-0000-0000-0000-0000000000b2';
  v_user_d_est uuid := '00000000-0000-0000-0000-0000000000b3';
  v_user_d_juv uuid := '00000000-0000-0000-0000-0000000000b4';

  v_id_plaza uuid := '00000000-0000-0000-0000-0000000001c1';
  v_id_rowin uuid := '00000000-0000-0000-0000-0000000001c2';
  v_id_estud uuid := '00000000-0000-0000-0000-0000000001c3';
  v_id_juv   uuid := '00000000-0000-0000-0000-0000000001c4';

  v_cat_primer uuid;
  v_cat_sub15  uuid;
  v_cat_sub13  uuid;
  v_cat_amat   uuid;

  v_torneo_primer uuid;
  v_torneo_sub15  uuid;
  v_torneo_sub13  uuid;
  v_torneo_amat   uuid;

  v_eq_plaza uuid; v_eq_rowin uuid; v_eq_estud uuid; v_eq_juv uuid;       -- primera
  v_eq15_plaza uuid; v_eq15_rowin uuid; v_eq15_estud uuid; v_eq15_juv uuid; -- Sub-15

  v_p1 uuid;  -- fecha 1 · Plaza-Juventud (verificada y publicada)
  v_p2 uuid;  -- fecha 1 · Estudiantes-Rowing (en disputa)
  v_p3 uuid;  -- Sub-15 · Plaza-Juventud (planilla borrador)
  v_pw uuid;  -- Sub-15 · Rowing-Estudiantes (walkover demo)

  v_pl1 uuid; v_pl2 uuid; v_pl3 uuid;  -- planillas 1/2/3
begin
  -- ---------------------------------------------------------------- org -----
  insert into orgs (id, slug, nombre, color_primario, color_secundario, plan)
  values (v_org, 'lbc', 'Liga de Básquetbol de Colonia', '#f39c2d', '#e8222f', 'piloto');

  insert into app_config (clave, valor) values ('org_activa', v_org::text);

  -- ------------------------------------------------ cuentas demo del panel --
  insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
  values
    ('00000000-0000-0000-0000-000000000000', v_user_super, 'authenticated', 'authenticated', 'superadmin@demo.lbc.uy',          crypt('demo-2026', gen_salt('bf')), now(), now(), now()),
    ('00000000-0000-0000-0000-000000000000', v_user_liga,  'authenticated', 'authenticated', 'liga@demo.lbc.uy',                crypt('demo-2026', gen_salt('bf')), now(), now(), now()),
    ('00000000-0000-0000-0000-000000000000', v_user_ayud,  'authenticated', 'authenticated', 'ayudante@demo.lbc.uy',            crypt('demo-2026', gen_salt('bf')), now(), now(), now()),
    ('00000000-0000-0000-0000-000000000000', v_user_d_pla, 'authenticated', 'authenticated', 'delegado.plaza@demo.lbc.uy',      crypt('demo-2026', gen_salt('bf')), now(), now(), now()),
    ('00000000-0000-0000-0000-000000000000', v_user_d_rol, 'authenticated', 'authenticated', 'delegado.rowing@demo.lbc.uy',     crypt('demo-2026', gen_salt('bf')), now(), now(), now()),
    ('00000000-0000-0000-0000-000000000000', v_user_d_est, 'authenticated', 'authenticated', 'delegado.estudiantes@demo.lbc.uy',crypt('demo-2026', gen_salt('bf')), now(), now(), now()),
    ('00000000-0000-0000-0000-000000000000', v_user_d_juv, 'authenticated', 'authenticated', 'delegado.juventud@demo.lbc.uy',   crypt('demo-2026', gen_salt('bf')), now(), now(), now());

  -- el trigger on_auth_user_created ya creó los profiles: nombres visibles
  update profiles set nombre = 'Juan (superadmin) [demo]'              where id = v_user_super;
  update profiles set nombre = 'Secretaría LBC [demo]'                 where id = v_user_liga;
  update profiles set nombre = 'Ayudante de secretaría [demo]'         where id = v_user_ayud;
  update profiles set nombre = 'Delegado de Plaza Colonia [demo]'      where id = v_user_d_pla;
  update profiles set nombre = 'Delegado de Colonia Rowing [demo]'     where id = v_user_d_rol;
  update profiles set nombre = 'Delegado de Estudiantes El Colla [demo]' where id = v_user_d_est;
  update profiles set nombre = 'Delegado de Juventud [demo]'           where id = v_user_d_juv;

  insert into org_members (org_id, user_id, rol, club_id) values
    (v_org, v_user_super, 'liga_admin',    null),
    (v_org, v_user_liga,  'liga_admin',    null),
    (v_org, v_user_ayud,  'liga_ayudante', null);

  -- ------------------------------------------------ clubes reales del afiche --
  insert into clubes (id, org_id, nombre, slug, gimnasio) values
    (v_id_plaza, v_org, 'Plaza Colonia',        'plaza-colonia',        'Gimnasio de Plaza Colonia [gimnasios/sedes reales a confirmar con la liga]'),
    (v_id_rowin, v_org, 'Colonia Rowing',       'colonia-rowing',       'Gimnasio de Colonia Rowing [gimnasios/sedes reales a confirmar con la liga]'),
    (v_id_estud, v_org, 'Estudiantes El Colla', 'estudiantes-el-colla', 'Gimnasio de Estudiantes El Colla, Rosario [a confirmar con la liga]'),
    (v_id_juv,   v_org, 'Juventud',             'juventud-caj',         'Gimnasio de Juventud [a confirmar con la liga]');

  insert into org_members (org_id, user_id, rol, club_id) values
    (v_org, v_user_d_pla, 'delegado', v_id_plaza),
    (v_org, v_user_d_rol, 'delegado', v_id_rowin),
    (v_org, v_user_d_est, 'delegado', v_id_estud),
    (v_org, v_user_d_juv, 'delegado', v_id_juv);

  -- --------------------------------- categorías [nombres reales a confirmar] --
  insert into categorias (org_id, nombre, acronimo, orden, es_formativa) values (v_org, 'Primera', '1RA',   1, false) returning id into v_cat_primer;
  insert into categorias (org_id, nombre, acronimo, orden, es_formativa) values (v_org, 'Sub-15',  'SUB15', 2, true)  returning id into v_cat_sub15;
  insert into categorias (org_id, nombre, acronimo, orden, es_formativa) values (v_org, 'Sub-13',  'SUB13', 3, true)  returning id into v_cat_sub13;
  insert into categorias (org_id, nombre, acronimo, orden, es_formativa) values (v_org, 'Amateur', 'AMA',   4, false) returning id into v_cat_amat;

  -- equipos: uno por club y categoría
  insert into equipos (org_id, club_id, categoria_id, nombre_mostrar)
  select v_org, c.id, ct.id, c.nombre || ' - ' || ct.acronimo
  from clubes c cross join categorias ct
  where c.org_id = v_org;

  -- referencias a los equipos que usa el fixture
  select eq.id into v_eq_plaza from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'plaza-colonia' and ct.nombre = 'Primera';
  select eq.id into v_eq_rowin from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'colonia-rowing' and ct.nombre = 'Primera';
  select eq.id into v_eq_estud from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'estudiantes-el-colla' and ct.nombre = 'Primera';
  select eq.id into v_eq_juv from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'juventud-caj' and ct.nombre = 'Primera';
  select eq.id into v_eq15_plaza from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'plaza-colonia' and ct.nombre = 'Sub-15';
  select eq.id into v_eq15_rowin from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'colonia-rowing' and ct.nombre = 'Sub-15';
  select eq.id into v_eq15_estud from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'estudiantes-el-colla' and ct.nombre = 'Sub-15';
  select eq.id into v_eq15_juv from equipos eq join clubes c on c.id = eq.club_id
    join categorias ct on ct.id = eq.categoria_id
    where eq.org_id = v_org and c.slug = 'juventud-caj' and ct.nombre = 'Sub-15';

  -- ------------------------------------------------------------- torneos --
  insert into torneos (org_id, categoria_id, temporada, nombre, formato, estado, estadisticas_detalladas)
  values (v_org, v_cat_primer, 2026, 'Primera División 2026', 'liga', 'en_curso', true)  -- playoffs [a confirmar con la liga]
  returning id into v_torneo_primer;

  insert into torneos (org_id, categoria_id, temporada, nombre, formato, estado, estadisticas_detalladas)
  values (v_org, v_cat_sub15, 2026, 'Copa Sub-15 2026', 'torneo', 'en_curso', false)
  returning id into v_torneo_sub15;

  insert into torneos (org_id, categoria_id, temporada, nombre, formato, estado, estadisticas_detalladas)
  values (v_org, v_cat_sub13, 2026, 'Copa Sub-13 2026', 'torneo', 'proximo', false)
  returning id into v_torneo_sub13;

  insert into torneos (org_id, categoria_id, temporada, nombre, formato, estado, estadisticas_detalladas)
  values (v_org, v_cat_amat, 2026, 'Campeonato Amateur 2026', 'torneo', 'proximo', false)
  returning id into v_torneo_amat;

  -- ------------------------------ fixture real de Primera (afiche oficial) --
  -- Fecha 1 · 17/10 · anfitrión Estudiantes El Colla (Rosario)
  -- El partido de las 19 ya se resolvió y publicó (ÚNICO con datos reales: demo);
  -- el de las 21 quedó en disputa para probar el flujo del panel.
  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, equipo_local_id, equipo_visitante_id,
                        estado, puntos_local, puntos_visitante, publicado, publicado_at, cuartos_local, cuartos_visitante)
  values (v_org, v_torneo_primer, '1', make_timestamptz(2026, 10, 17, 19, 0, 0, 'America/Montevideo'),
          'Gimnasio de Estudiantes El Colla, Rosario',
          v_eq_plaza, v_eq_juv,
          'finalizado', 78, 70, true, now(), '{22,19,21,16}', '{17,20,17,16}')
  returning id into v_p1;

  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, equipo_local_id, equipo_visitante_id)
  values (v_org, v_torneo_primer, '1', make_timestamptz(2026, 10, 17, 21, 0, 0, 'America/Montevideo'),
          'Gimnasio de Estudiantes El Colla, Rosario',
          v_eq_estud, v_eq_rowin)
  returning id into v_p2;

  -- Fecha 2 · 24/10 · anfitrión Juventud (Colonia)
  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, equipo_local_id, equipo_visitante_id) values
  (v_org, v_torneo_primer, '2', make_timestamptz(2026, 10, 24, 19, 0, 0, 'America/Montevideo'), 'Gimnasio de Juventud, Colonia', v_eq_plaza, v_eq_rowin),
  (v_org, v_torneo_primer, '2', make_timestamptz(2026, 10, 24, 21, 0, 0, 'America/Montevideo'), 'Gimnasio de Juventud, Colonia', v_eq_juv,   v_eq_estud);

  -- Fecha 3 · 31/10 · anfitrión Colonia Rowing (Colonia)
  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, equipo_local_id, equipo_visitante_id) values
  (v_org, v_torneo_primer, '3', make_timestamptz(2026, 10, 31, 19, 0, 0, 'America/Montevideo'), 'Gimnasio de Colonia Rowing, Colonia', v_eq_plaza, v_eq_estud),
  (v_org, v_torneo_primer, '3', make_timestamptz(2026, 10, 31, 21, 0, 0, 'America/Montevideo'), 'Gimnasio de Colonia Rowing, Colonia', v_eq_juv,   v_eq_rowin);

  -- Fecha 4 · 07/11 · anfitrión Plaza Colonia (Colonia)
  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, equipo_local_id, equipo_visitante_id) values
  (v_org, v_torneo_primer, '4', make_timestamptz(2026, 11, 7, 19, 0, 0, 'America/Montevideo'), 'Gimnasio de Plaza Colonia, Colonia', v_eq_juv,   v_eq_rowin),
  (v_org, v_torneo_primer, '4', make_timestamptz(2026, 11, 7, 21, 0, 0, 'America/Montevideo'), 'Gimnasio de Plaza Colonia, Colonia', v_eq_plaza, v_eq_estud);

  -- Fechas 5 y 6 · 14/11 y 21/11 · anfitrión [a confirmar con la liga] (afiche)
  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, nota_publica, equipo_local_id, equipo_visitante_id) values
  (v_org, v_torneo_primer, '5', make_timestamptz(2026, 11, 14, 19, 0, 0, 'America/Montevideo'), null, 'Sede y anfitrión a confirmar por la liga', v_eq_estud, v_eq_juv),
  (v_org, v_torneo_primer, '5', make_timestamptz(2026, 11, 14, 21, 0, 0, 'America/Montevideo'), null, 'Sede y anfitrión a confirmar por la liga', v_eq_rowin, v_eq_plaza),
  (v_org, v_torneo_primer, '6', make_timestamptz(2026, 11, 21, 19, 0, 0, 'America/Montevideo'), null, 'Sede y anfitrión a confirmar por la liga', v_eq_estud, v_eq_rowin),
  (v_org, v_torneo_primer, '6', make_timestamptz(2026, 11, 21, 21, 0, 0, 'America/Montevideo'), null, 'Sede y anfitrión a confirmar por la liga', v_eq_juv,   v_eq_plaza);

  -- ---------------------------- fixture demo de formativas (Sub-15, 17/10) --
  -- Marcadores del partido 19:00 [demo]; el walkover pruebe la view de tabla.
  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, equipo_local_id, equipo_visitante_id)
  values (v_org, v_torneo_sub15, '1', make_timestamptz(2026, 10, 17, 17, 0, 0, 'America/Montevideo'),
          'Gimnasio de Estudiantes El Colla, Rosario', v_eq15_plaza, v_eq15_juv)
  returning id into v_p3;

  insert into partidos (org_id, torneo_id, ronda, fecha_hora, sede, equipo_local_id, equipo_visitante_id,
                        estado, walkover_ganador_id, publicado, publicado_at, nota_publica)
  values (v_org, v_torneo_sub15, '1', make_timestamptz(2026, 10, 17, 18, 30, 0, 'America/Montevideo'),
          'Gimnasio de Estudiantes El Colla, Rosario',
          v_eq15_rowin, v_eq15_estud,
          'walkover', v_eq15_estud, true, now(), 'No presentación del club visitante [demo]')
  returning id into v_pw;

  -- -------------------------------------------------- rosters [demo] + fichas --
  create temp table _jugadores (clubid uuid, categoria text, nombre text, dorsal int, nace date);
  insert into _jugadores (clubid, categoria, nombre, dorsal, nace) values
    (v_id_plaza, 'Primera', 'Lucas Pereira [demo]',        4,  date '1999-03-14'),
    (v_id_plaza, 'Primera', 'Diego Martínez [demo]',       5,  date '2001-07-22'),
    (v_id_plaza, 'Primera', 'Facundo Acosta [demo]',       7,  date '2000-01-30'),
    (v_id_plaza, 'Primera', 'Matías Olivera [demo]',       8,  date '2002-09-05'),
    (v_id_plaza, 'Primera', 'Sebastián Techera [demo]',    10, date '1998-11-12'),
    (v_id_plaza, 'Primera', 'Andrés Ríos [demo]',         11, date '2003-04-18'),
    (v_id_juv,   'Primera', 'Gonzalo Ramírez [demo]',      4,  date '2000-06-09'),
    (v_id_juv,   'Primera', 'Joaquín Falero [demo]',       5,  date '2002-02-27'),
    (v_id_juv,   'Primera', 'Cristian Viera [demo]',       8,  date '1999-10-16'),
    (v_id_juv,   'Primera', 'Nicolás Méndez [demo]',       10, date '2001-12-03'),
    (v_id_juv,   'Primera', 'Pablo González [demo]',       11, date '2003-08-21'),
    (v_id_juv,   'Primera', 'Emiliano Cardozo [demo]',     12, date '2000-05-11'),
    (v_id_estud, 'Primera', 'Martín Sosa [demo]',          4,  date '2001-03-08'),
    (v_id_estud, 'Primera', 'Rodrigo Umpiérrez [demo]',    5,  date '1999-07-19'),
    (v_id_estud, 'Primera', 'Carlos Bertolino [demo]',     7,  date '2002-01-25'),
    (v_id_estud, 'Primera', 'Lucas Ferreira [demo]',       8,  date '2003-10-02'),
    (v_id_estud, 'Primera', 'Diego Gutiérrez [demo]',      10, date '2000-04-14'),
    (v_id_estud, 'Primera', 'Tomás Cabrera [demo]',        12, date '2001-06-30'),
    (v_id_rowin, 'Primera', 'Bruno Silvera [demo]',        4,  date '2002-05-17'),
    (v_id_rowin, 'Primera', 'Matías Alciaturi [demo]',     5,  date '2000-09-28'),
    (v_id_rowin, 'Primera', 'Federico Lago [demo]',        6,  date '2001-02-05'),
    (v_id_rowin, 'Primera', 'Ignacio Pintos [demo]',       7,  date '2003-11-23'),
    (v_id_rowin, 'Primera', 'Valentín Cuello [demo]',      9,  date '1999-12-08'),
    (v_id_rowin, 'Primera', 'Juan Barros [demo]',          11, date '2002-03-19'),
    (v_id_plaza, 'Sub-15', 'Rafael Pereira [demo]',        4,  date '2011-03-14'),
    (v_id_plaza, 'Sub-15', 'Tomas Ferreira [demo]',        5,  date '2011-07-22'),
    (v_id_plaza, 'Sub-15', 'Luciano Couce [demo]',         7,  date '2010-01-30'),
    (v_id_plaza, 'Sub-15', 'Mateo Bentancor [demo]',       8,  date '2012-09-05'),
    (v_id_juv,   'Sub-15', 'Simón González [demo]',        4,  date '2011-06-09'),
    (v_id_juv,   'Sub-15', 'Julián Latorre [demo]',        5,  date '2011-02-27'),
    (v_id_juv,   'Sub-15', 'Maximiliano Barreto [demo]',   7,  date '2010-10-16'),
    (v_id_juv,   'Sub-15', 'Facundo Silvera [demo]',       8,  date '2012-08-21');

  insert into jugadores (org_id, nombre_completo, fecha_nacimiento, notas)
  select v_org, j.nombre, j.nace, 'Roster [demo] para el piloto'
  from _jugadores j;

  insert into fichas (org_id, jugador_id, equipo_id, torneo_id, dorsal, estado, desde)
  select
    v_org,
    pl.id,
    eq.id,
    case eq.categoria_id when v_cat_primer then v_torneo_primer else v_torneo_sub15 end,
    j.dorsal,
    'confirmada',
    date '2026-10-01'
  from _jugadores j
  join jugadores pl on pl.nombre_completo = j.nombre and pl.org_id = v_org
  join equipos eq on eq.org_id = v_org
   join clubes c on c.id = eq.club_id
   join categorias ct on ct.id = eq.categoria_id
  where eq.club_id = j.clubid and ct.nombre = j.categoria;

  -- ------------------------------------------------------------ planillas --
  -- Planilla 1 · verificada: fecha 1 (Plaza-Juventud), ya publicada
  insert into planillas (org_id, partido_id, estado, foto_url, cargada_por, verificada_por, verificada_at)
  values (v_org, v_p1, 'verificada', 'planillas/' || v_org || '/' || v_p1 || '/foto-demo.jpg',
          v_user_d_pla, v_user_liga, now())
  returning id into v_pl1;

  -- Planilla 2 · disputada: fecha 1 (Estudiantes-Rowing) el visitante no está de acuerdo
  insert into planillas (org_id, partido_id, estado, foto_url, cargada_por, disputada_por_club, motivo_disputa)
  values (v_org, v_p2, 'disputada', 'planillas/' || v_org || '/' || v_p2 || '/foto-demo.jpg',
          v_user_d_est, v_id_rowin, 'La suma del tercer cuarto no da el marcador del papel [demo]')
  returning id into v_pl2;

  -- Planilla 3 · borrador: Sub-15 fecha 1 cargada esta noche, sin verificar
  insert into planillas (org_id, partido_id, estado, foto_url, cargada_por)
  values (v_org, v_p3, 'borrador', 'planillas/' || v_org || '/' || v_p3 || '/foto-demo.jpg',
          v_user_d_pla)
  returning id into v_pl3;

  -- estadísticas de la planilla 1 (marcador 78-70 sale de esta suma)
  insert into planilla_stats (org_id, planilla_id, ficha_id, dorsal, minutos, puntos, faltas, rebotes, asistencias, tapas)
  select v_org, v_pl1, f.id, s.dorsal, s.minutos, s.pts, s.fl, s.reb, s.asist, s.tp
  from (values
    (4::int, 34::int, 18::int, 2::int, 5::int, 4::int, 1::int),
    (5::int, 30::int, 15::int, 4::int, 4::int, 2::int, 0::int),
    (7::int, 28::int, 14::int, 3::int, 3::int, 5::int, 1::int),
    (8::int, 24::int, 12::int, 1::int, 6::int, 1::int, 0::int),
    (10::int, 22::int, 11::int, 5::int, 2::int, 0::int, 2::int),
    (11::int, 18::int, 8::int, 2::int, 1::int, 3::int, 0::int)
  ) as s(dorsal, minutos, pts, fl, reb, asist, tp)
  join fichas f on f.equipo_id = v_eq_plaza and f.dorsal = s.dorsal and f.torneo_id = v_torneo_primer;

  insert into planilla_stats (org_id, planilla_id, ficha_id, dorsal, minutos, puntos, faltas, rebotes, asistencias, tapas)
  select v_org, v_pl1, f.id, s.dorsal, s.minutos, s.pts, s.fl, s.reb, s.asist, s.tp
  from (values
    (4::int, 34::int, 17::int, 1::int, 4::int, 3::int, 0::int),
    (5::int, 30::int, 14::int, 3::int, 2::int, 1::int, 0::int),
    (8::int, 28::int, 13::int, 4::int, 5::int, 2::int, 1::int),
    (10::int, 24::int, 12::int, 2::int, 3::int, 2::int, 0::int),
    (11::int, 20::int, 8::int, 2::int, 1::int, 1::int, 0::int),
    (12::int, 16::int, 6::int, 5::int, 2::int, 0::int, 0::int)
  ) as s(dorsal, minutos, pts, fl, reb, asist, tp)
  join fichas f on f.equipo_id = v_eq_juv and f.dorsal = s.dorsal and f.torneo_id = v_torneo_primer;

  -- estadísticas de la planilla 2 (82-75 según los datos cargados por el local)
  insert into planilla_stats (org_id, planilla_id, ficha_id, dorsal, minutos, puntos, faltas, rebotes, asistencias, tapas)
  select v_org, v_pl2, f.id, s.dorsal, s.minutos, s.pts, s.fl, s.reb, s.asist, s.tp
  from (values
    (4::int, 32::int, 20::int, 2::int, 4::int, 6::int, 2::int),
    (5::int, 30::int, 17::int, 2::int, 3::int, 2::int, 1::int),
    (7::int, 28::int, 15::int, 3::int, 2::int, 3::int, 0::int),
    (8::int, 26::int, 12::int, 1::int, 5::int, 1::int, 2::int),
    (10::int, 22::int, 10::int, 4::int, 1::int, 2::int, 0::int),
    (12::int, 18::int, 8::int, 1::int, 2::int, 0::int, 0::int)
  ) as s(dorsal, minutos, pts, fl, reb, asist, tp)
  join fichas f on f.equipo_id = v_eq_estud and f.dorsal = s.dorsal and f.torneo_id = v_torneo_primer;

  insert into planilla_stats (org_id, planilla_id, ficha_id, dorsal, minutos, puntos, faltas, rebotes, asistencias, tapas)
  select v_org, v_pl2, f.id, s.dorsal, s.minutos, s.pts, s.fl, s.reb, s.asist, s.tp
  from (values
    (4::int, 32::int, 16::int, 3::int, 3::int, 1::int, 1::int),
    (5::int, 30::int, 15::int, 1::int, 4::int, 3::int, 0::int),
    (6::int, 28::int, 14::int, 2::int, 2::int, 2::int, 0::int),
    (7::int, 26::int, 13::int, 4::int, 3::int, 1::int, 0::int),
    (9::int, 20::int, 9::int, 2::int, 1::int, 0::int, 1::int),
    (11::int, 18::int, 8::int, 3::int, 2::int, 2::int, 0::int)
  ) as s(dorsal, minutos, pts, fl, reb, asist, tp)
  join fichas f on f.equipo_id = v_eq_rowin and f.dorsal = s.dorsal and f.torneo_id = v_torneo_primer;

  -- estadísticas de la planilla 3 (borrador de Sub-15)
  insert into planilla_stats (org_id, planilla_id, ficha_id, dorsal, minutos, puntos, faltas, rebotes)
  select v_org, v_pl3, f.id, s.dorsal, s.minutos, s.pts, s.fl, s.reb
  from (values
    (4::int, 28::int, 18::int, 1::int, 4::int),
    (5::int, 26::int, 16::int, 2::int, 3::int),
    (7::int, 24::int, 15::int, 1::int, 2::int),
    (8::int, 22::int, 16::int, 2::int, 2::int)
  ) as s(dorsal, minutos, pts, fl, reb)
  join fichas f on f.equipo_id = v_eq15_plaza and f.dorsal = s.dorsal and f.torneo_id = v_torneo_sub15;

  insert into planilla_stats (org_id, planilla_id, ficha_id, dorsal, minutos, puntos, faltas, rebotes)
  select v_org, v_pl3, f.id, s.dorsal, s.minutos, s.pts, s.fl, s.reb
  from (values
    (4::int, 26::int, 15::int, 1::int, 3::int),
    (5::int, 24::int, 14::int, 2::int, 1::int),
    (7::int, 22::int, 14::int, 3::int, 2::int),
    (8::int, 20::int, 15::int, 2::int, 1::int)
  ) as s(dorsal, minutos, pts, fl, reb)
  join fichas f on f.equipo_id = v_eq15_juv and f.dorsal = s.dorsal and f.torneo_id = v_torneo_sub15;

  -- ------------------------------------------------------------ sanciones --
  -- 1 sanción demo: 3 partidos a cumplir desde la fecha 1
  insert into sanciones (org_id, tipo, jugador_id, club_id, motivo, partidos_cumplir, fecha_alta, publicado, nota_baja)
  values (v_org, 'jugador',
          (select jugador_id from fichas where equipo_id = v_eq_juv and dorsal = 4 and torneo_id = v_torneo_primer),
          v_id_juv,
          'Expulsión por doble actitud antideportiva en la fecha 1 [demo]',
          3, date '2026-10-18', false, null);

  -- ------------------------------------------------ contenido editorial demo --
  insert into noticias (org_id, slug, titulo, bajada, cuerpo_md, destacado, publicado, publicado_at, etiquetas) values
  (v_org, 'arranco-la-primera-2026',
   'Arrancó la Primera División 2026',
   'La fecha 1 se jugó este sábado 17/10 en Rosario.',
   '# Arrancó la Primera División 2026

La Liga de Básquetbol de Colonia abrió la temporada con la fecha 1 en el gimnasio de Estudiantes El Colla, Rosario.

Contenido [demo]: la liga cargará sus noticias reales desde el panel.',
   true, true, now(), array['temporada', 'LBC2026']),
  (v_org, 'fixture-primera-2026',
   'Ya está el fixture completo de la Primera',
   'Seis fechas, ida y vuelta, sábados con doble jornada.',
   '# Fixture completo

Ida y vuelta, 6 fechas, todos los sábados a las 19:00 y 21:00 con un club anfitrión por fecha.

Contenido [demo] al día de la carga del seed.',
   false, true, now() - interval '3 days', array['fixture', 'LBC2026']);

  insert into auspiciantes (org_id, nombre, nivel, activo, orden) values
  (v_org, 'Auspiciante Oro 1 [demo]',   'oro',   true,  1),
  (v_org, 'Auspiciante Oro 2 [demo]',   'oro',   false, 2),
  (v_org, 'Auspiciante Plata 1 [demo]', 'plata', false, 3),
  (v_org, 'Auspiciante Plata 2 [demo]', 'plata', false, 4);

  insert into paginas (org_id, slug, titulo, cuerpo_md, publicado) values
  (v_org, 'reglamento', 'Reglamento',
   '# Reglamento de competencias

Contenido [demo]: el texto oficial se carga una vez firmado con la secretaría.',
   true),
  (v_org, 'contacto', 'Contacto',
   '# Contacto de la liga

Secretaría de la Liga de Básquetbol de Colonia.

Oficina, teléfono y redes: [a completar por la liga].',
   true);

  -- ---------------------------------------------------------- sanity check --
  -- v_tabla debe arrancar con Plaza 1º (2 pts, +8) y Juventud 4º (1 pt, -8)
  raise notice 'seed LBC listo · org %: % equipos · % partidos',
    v_org::text,
    (select count(*) from equipos where org_id = v_org),
    (select count(*) from partidos where org_id = v_org);
end $$;
