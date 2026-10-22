
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  
  "public": {
          Tables: {
            "app_config": {
                  Row: {
                    "clave": string,"updated_at": string,"valor": string
                  }
                  ComputedFields: never
                  Insert: {
                    "clave": string,"updated_at"?: string,"valor": string
                  }
                  Update: {
                    "clave"?: string,"updated_at"?: string,"valor"?: string
                  }
                  Relationships: [
                    
                  ]
                },"audit_log": {
                  Row: {
                    "accion": string,"antes": Json | null,"created_at": string,"despues": Json | null,"fila_id": string,"id": string,"org_id": string,"tabla": string,"user_id": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "accion": string,"antes"?: Json | null,"created_at"?: string,"despues"?: Json | null,"fila_id": string,"id"?: string,"org_id": string,"tabla": string,"user_id"?: string | null
                  }
                  Update: {
                    "accion"?: string,"antes"?: Json | null,"created_at"?: string,"despues"?: Json | null,"fila_id"?: string,"id"?: string,"org_id"?: string,"tabla"?: string,"user_id"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "audit_log_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"auspiciantes": {
                  Row: {
                    "activo": boolean,"created_at": string,"id": string,"link": string | null,"logo_url": string | null,"nivel": Database["public"]['Enums']["nivel_auspicio"],"nombre": string,"orden": number,"org_id": string,"vigencia_hasta": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "activo"?: boolean,"created_at"?: string,"id"?: string,"link"?: string | null,"logo_url"?: string | null,"nivel"?: Database["public"]['Enums']["nivel_auspicio"],"nombre": string,"orden"?: number,"org_id": string,"vigencia_hasta"?: string | null
                  }
                  Update: {
                    "activo"?: boolean,"created_at"?: string,"id"?: string,"link"?: string | null,"logo_url"?: string | null,"nivel"?: Database["public"]['Enums']["nivel_auspicio"],"nombre"?: string,"orden"?: number,"org_id"?: string,"vigencia_hasta"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "auspiciantes_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"categorias": {
                  Row: {
                    "acronimo": string | null,"activa": boolean,"created_at": string,"es_formativa": boolean,"id": string,"nombre": string,"orden": number,"org_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "acronimo"?: string | null,"activa"?: boolean,"created_at"?: string,"es_formativa"?: boolean,"id"?: string,"nombre": string,"orden"?: number,"org_id": string
                  }
                  Update: {
                    "acronimo"?: string | null,"activa"?: boolean,"created_at"?: string,"es_formativa"?: boolean,"id"?: string,"nombre"?: string,"orden"?: number,"org_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "categorias_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"clubes": {
                  Row: {
                    "activo": boolean,"color1": string | null,"color2": string | null,"created_at": string,"escudo_url": string | null,"gimnasio": string | null,"id": string,"nombre": string,"org_id": string,"redes_json": NonNullable<Json>,"slug": string
                  }
                  ComputedFields: never
                  Insert: {
                    "activo"?: boolean,"color1"?: string | null,"color2"?: string | null,"created_at"?: string,"escudo_url"?: string | null,"gimnasio"?: string | null,"id"?: string,"nombre": string,"org_id": string,"redes_json"?: NonNullable<Json>,"slug": string
                  }
                  Update: {
                    "activo"?: boolean,"color1"?: string | null,"color2"?: string | null,"created_at"?: string,"escudo_url"?: string | null,"gimnasio"?: string | null,"id"?: string,"nombre"?: string,"org_id"?: string,"redes_json"?: NonNullable<Json>,"slug"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "clubes_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"equipos": {
                  Row: {
                    "activo": boolean,"categoria_id": string,"club_id": string,"created_at": string,"id": string,"nombre_mostrar": string | null,"org_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "activo"?: boolean,"categoria_id": string,"club_id": string,"created_at"?: string,"id"?: string,"nombre_mostrar"?: string | null,"org_id": string
                  }
                  Update: {
                    "activo"?: boolean,"categoria_id"?: string,"club_id"?: string,"created_at"?: string,"id"?: string,"nombre_mostrar"?: string | null,"org_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "equipos_categoria_id_fkey"
      columns: ["categoria_id"]
isOneToOne: false
      referencedRelation: "categorias"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "clubes"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_sanciones_activas"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "equipos_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"fichas": {
                  Row: {
                    "created_at": string,"desde": string,"dorsal": number | null,"equipo_id": string,"estado": Database["public"]['Enums']["estado_ficha"],"hasta": string | null,"id": string,"jugador_id": string,"org_id": string,"torneo_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"desde": string,"dorsal"?: number | null,"equipo_id": string,"estado"?: Database["public"]['Enums']["estado_ficha"],"hasta"?: string | null,"id"?: string,"jugador_id": string,"org_id": string,"torneo_id": string
                  }
                  Update: {
                    "created_at"?: string,"desde"?: string,"dorsal"?: number | null,"equipo_id"?: string,"estado"?: Database["public"]['Enums']["estado_ficha"],"hasta"?: string | null,"id"?: string,"jugador_id"?: string,"org_id"?: string,"torneo_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "equipos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_lideres"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "jugadores"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_partidos_log"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "fichas_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "torneos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "fichas_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["torneo_id"]
    }
                  ]
                },"jugadores": {
                  Row: {
                    "altura_cm": number | null,"ciudad_origen": string | null,"created_at": string,"fecha_nacimiento": string | null,"foto_url": string | null,"id": string,"mano_habil": string | null,"nombre_completo": string,"notas": string | null,"org_id": string,"posicion": string | null,"slug": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "altura_cm"?: number | null,"ciudad_origen"?: string | null,"created_at"?: string,"fecha_nacimiento"?: string | null,"foto_url"?: string | null,"id"?: string,"mano_habil"?: string | null,"nombre_completo": string,"notas"?: string | null,"org_id": string,"posicion"?: string | null,"slug"?: string | null
                  }
                  Update: {
                    "altura_cm"?: number | null,"ciudad_origen"?: string | null,"created_at"?: string,"fecha_nacimiento"?: string | null,"foto_url"?: string | null,"id"?: string,"mano_habil"?: string | null,"nombre_completo"?: string,"notas"?: string | null,"org_id"?: string,"posicion"?: string | null,"slug"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "jugadores_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"noticias": {
                  Row: {
                    "bajada": string | null,"created_at": string,"cuerpo_md": string | null,"destacado": boolean,"etiquetas": (string)[],"id": string,"org_id": string,"portada_url": string | null,"publicado": boolean,"publicado_at": string | null,"slug": string,"titulo": string
                  }
                  ComputedFields: never
                  Insert: {
                    "bajada"?: string | null,"created_at"?: string,"cuerpo_md"?: string | null,"destacado"?: boolean,"etiquetas"?: (string)[],"id"?: string,"org_id": string,"portada_url"?: string | null,"publicado"?: boolean,"publicado_at"?: string | null,"slug": string,"titulo": string
                  }
                  Update: {
                    "bajada"?: string | null,"created_at"?: string,"cuerpo_md"?: string | null,"destacado"?: boolean,"etiquetas"?: (string)[],"id"?: string,"org_id"?: string,"portada_url"?: string | null,"publicado"?: boolean,"publicado_at"?: string | null,"slug"?: string,"titulo"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "noticias_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"org_members": {
                  Row: {
                    "club_id": string | null,"org_id": string,"rol": Database["public"]['Enums']["rol_org"],"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "club_id"?: string | null,"org_id": string,"rol": Database["public"]['Enums']["rol_org"],"user_id": string
                  }
                  Update: {
                    "club_id"?: string | null,"org_id"?: string,"rol"?: Database["public"]['Enums']["rol_org"],"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "org_members_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "clubes"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "org_members_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "org_members_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "org_members_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_sanciones_activas"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "org_members_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "org_members_user_id_fkey"
      columns: ["user_id"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"orgs": {
                  Row: {
                    "color_primario": string | null,"color_secundario": string | null,"config_json": NonNullable<Json>,"created_at": string,"dominio_custom": string | null,"id": string,"licencia_hasta": string | null,"logo_url": string | null,"nombre": string,"plan": Database["public"]['Enums']["plan_org"],"slug": string,"updated_at": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "color_primario"?: string | null,"color_secundario"?: string | null,"config_json"?: NonNullable<Json>,"created_at"?: string,"dominio_custom"?: string | null,"id"?: string,"licencia_hasta"?: string | null,"logo_url"?: string | null,"nombre": string,"plan"?: Database["public"]['Enums']["plan_org"],"slug": string,"updated_at"?: string | null
                  }
                  Update: {
                    "color_primario"?: string | null,"color_secundario"?: string | null,"config_json"?: NonNullable<Json>,"created_at"?: string,"dominio_custom"?: string | null,"id"?: string,"licencia_hasta"?: string | null,"logo_url"?: string | null,"nombre"?: string,"plan"?: Database["public"]['Enums']["plan_org"],"slug"?: string,"updated_at"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"paginas": {
                  Row: {
                    "created_at": string,"cuerpo_md": string | null,"id": string,"org_id": string,"publicado": boolean,"slug": string,"titulo": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"cuerpo_md"?: string | null,"id"?: string,"org_id": string,"publicado"?: boolean,"slug": string,"titulo": string
                  }
                  Update: {
                    "created_at"?: string,"cuerpo_md"?: string | null,"id"?: string,"org_id"?: string,"publicado"?: boolean,"slug"?: string,"titulo"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "paginas_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"partidos": {
                  Row: {
                    "created_at": string,"cuartos_local": (number)[] | null,"cuartos_visitante": (number)[] | null,"equipo_local_id": string,"equipo_visitante_id": string,"estado": Database["public"]['Enums']["estado_partido"],"fecha_hora": string,"id": string,"nota_publica": string | null,"org_id": string,"publicado": boolean,"publicado_at": string | null,"puntos_local": number | null,"puntos_visitante": number | null,"ronda": string,"sede": string | null,"torneo_id": string,"walkover_ganador_id": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"cuartos_local"?: (number)[] | null,"cuartos_visitante"?: (number)[] | null,"equipo_local_id": string,"equipo_visitante_id": string,"estado"?: Database["public"]['Enums']["estado_partido"],"fecha_hora": string,"id"?: string,"nota_publica"?: string | null,"org_id": string,"publicado"?: boolean,"publicado_at"?: string | null,"puntos_local"?: number | null,"puntos_visitante"?: number | null,"ronda": string,"sede"?: string | null,"torneo_id": string,"walkover_ganador_id"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"cuartos_local"?: (number)[] | null,"cuartos_visitante"?: (number)[] | null,"equipo_local_id"?: string,"equipo_visitante_id"?: string,"estado"?: Database["public"]['Enums']["estado_partido"],"fecha_hora"?: string,"id"?: string,"nota_publica"?: string | null,"org_id"?: string,"publicado"?: boolean,"publicado_at"?: string | null,"puntos_local"?: number | null,"puntos_visitante"?: number | null,"ronda"?: string,"sede"?: string | null,"torneo_id"?: string,"walkover_ganador_id"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "partidos_equipo_local_id_fkey"
      columns: ["equipo_local_id"]
isOneToOne: false
      referencedRelation: "equipos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_equipo_local_id_fkey"
      columns: ["equipo_local_id"]
isOneToOne: false
      referencedRelation: "v_lideres"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "partidos_equipo_local_id_fkey"
      columns: ["equipo_local_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "partidos_equipo_visitante_id_fkey"
      columns: ["equipo_visitante_id"]
isOneToOne: false
      referencedRelation: "equipos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_equipo_visitante_id_fkey"
      columns: ["equipo_visitante_id"]
isOneToOne: false
      referencedRelation: "v_lideres"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "partidos_equipo_visitante_id_fkey"
      columns: ["equipo_visitante_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "partidos_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "torneos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "partidos_walkover_ganador_id_fkey"
      columns: ["walkover_ganador_id"]
isOneToOne: false
      referencedRelation: "equipos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_walkover_ganador_id_fkey"
      columns: ["walkover_ganador_id"]
isOneToOne: false
      referencedRelation: "v_lideres"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "partidos_walkover_ganador_id_fkey"
      columns: ["walkover_ganador_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["equipo_id"]
    }
                  ]
                },"planilla_stats": {
                  Row: {
                    "asistencias": number | null,"created_at": string,"dorsal": number | null,"faltas": number,"ficha_id": string,"id": string,"minutos": number | null,"org_id": string,"planilla_id": string,"puntos": number,"rebotes": number | null,"robos": number | null,"t3_convertidos": number | null,"t3_intentados": number | null,"tapas": number | null,"tc_convertidos": number | null,"tc_intentados": number | null,"tl_convertidos": number | null,"tl_intentados": number | null
                  }
                  ComputedFields: never
                  Insert: {
                    "asistencias"?: number | null,"created_at"?: string,"dorsal"?: number | null,"faltas"?: number,"ficha_id": string,"id"?: string,"minutos"?: number | null,"org_id": string,"planilla_id": string,"puntos"?: number,"rebotes"?: number | null,"robos"?: number | null,"t3_convertidos"?: number | null,"t3_intentados"?: number | null,"tapas"?: number | null,"tc_convertidos"?: number | null,"tc_intentados"?: number | null,"tl_convertidos"?: number | null,"tl_intentados"?: number | null
                  }
                  Update: {
                    "asistencias"?: number | null,"created_at"?: string,"dorsal"?: number | null,"faltas"?: number,"ficha_id"?: string,"id"?: string,"minutos"?: number | null,"org_id"?: string,"planilla_id"?: string,"puntos"?: number,"rebotes"?: number | null,"robos"?: number | null,"t3_convertidos"?: number | null,"t3_intentados"?: number | null,"tapas"?: number | null,"tc_convertidos"?: number | null,"tc_intentados"?: number | null,"tl_convertidos"?: number | null,"tl_intentados"?: number | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "planilla_stats_ficha_id_fkey"
      columns: ["ficha_id"]
isOneToOne: false
      referencedRelation: "fichas"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "planilla_stats_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "planilla_stats_planilla_id_fkey"
      columns: ["planilla_id"]
isOneToOne: false
      referencedRelation: "planillas"
      referencedColumns: ["id"]
    }
                  ]
                },"planillas": {
                  Row: {
                    "cargada_por": string | null,"created_at": string,"disputada_por_club": string | null,"estado": Database["public"]['Enums']["estado_planilla"],"foto_url": string | null,"id": string,"motivo_disputa": string | null,"org_id": string,"partido_id": string,"updated_at": string | null,"verificada_at": string | null,"verificada_por": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "cargada_por"?: string | null,"created_at"?: string,"disputada_por_club"?: string | null,"estado"?: Database["public"]['Enums']["estado_planilla"],"foto_url"?: string | null,"id"?: string,"motivo_disputa"?: string | null,"org_id": string,"partido_id": string,"updated_at"?: string | null,"verificada_at"?: string | null,"verificada_por"?: string | null
                  }
                  Update: {
                    "cargada_por"?: string | null,"created_at"?: string,"disputada_por_club"?: string | null,"estado"?: Database["public"]['Enums']["estado_planilla"],"foto_url"?: string | null,"id"?: string,"motivo_disputa"?: string | null,"org_id"?: string,"partido_id"?: string,"updated_at"?: string | null,"verificada_at"?: string | null,"verificada_por"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "planillas_cargada_por_fkey"
      columns: ["cargada_por"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "planillas_disputada_por_club_fkey"
      columns: ["disputada_por_club"]
isOneToOne: false
      referencedRelation: "clubes"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "planillas_disputada_por_club_fkey"
      columns: ["disputada_por_club"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "planillas_disputada_por_club_fkey"
      columns: ["disputada_por_club"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "planillas_disputada_por_club_fkey"
      columns: ["disputada_por_club"]
isOneToOne: false
      referencedRelation: "v_sanciones_activas"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "planillas_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "planillas_partido_id_fkey"
      columns: ["partido_id"]
isOneToOne: true
      referencedRelation: "partidos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "planillas_partido_id_fkey"
      columns: ["partido_id"]
isOneToOne: true
      referencedRelation: "v_detalle_publico"
      referencedColumns: ["partido_id"]
    },{
      foreignKeyName: "planillas_partido_id_fkey"
      columns: ["partido_id"]
isOneToOne: true
      referencedRelation: "v_jugador_partidos_log"
      referencedColumns: ["partido_id"]
    },{
      foreignKeyName: "planillas_verificada_por_fkey"
      columns: ["verificada_por"]
isOneToOne: false
      referencedRelation: "profiles"
      referencedColumns: ["id"]
    }
                  ]
                },"profiles": {
                  Row: {
                    "created_at": string,"foto_url": string | null,"id": string,"is_superadmin": boolean,"nombre": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"foto_url"?: string | null,"id": string,"is_superadmin"?: boolean,"nombre"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"foto_url"?: string | null,"id"?: string,"is_superadmin"?: boolean,"nombre"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"sanciones": {
                  Row: {
                    "club_id": string | null,"created_at": string,"estado": Database["public"]['Enums']["estado_sancion"],"fecha_alta": string,"id": string,"jugador_id": string | null,"motivo": string,"nombre_libre": string | null,"nota_baja": string | null,"org_id": string,"partidos_cumplir": number,"publicado": boolean,"tipo": Database["public"]['Enums']["persona_sancion"]
                  }
                  ComputedFields: never
                  Insert: {
                    "club_id"?: string | null,"created_at"?: string,"estado"?: Database["public"]['Enums']["estado_sancion"],"fecha_alta"?: string,"id"?: string,"jugador_id"?: string | null,"motivo": string,"nombre_libre"?: string | null,"nota_baja"?: string | null,"org_id": string,"partidos_cumplir"?: number,"publicado"?: boolean,"tipo": Database["public"]['Enums']["persona_sancion"]
                  }
                  Update: {
                    "club_id"?: string | null,"created_at"?: string,"estado"?: Database["public"]['Enums']["estado_sancion"],"fecha_alta"?: string,"id"?: string,"jugador_id"?: string | null,"motivo"?: string,"nombre_libre"?: string | null,"nota_baja"?: string | null,"org_id"?: string,"partidos_cumplir"?: number,"publicado"?: boolean,"tipo"?: Database["public"]['Enums']["persona_sancion"]
                  }
                  Relationships: [
                    {
      foreignKeyName: "sanciones_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "clubes"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "sanciones_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "sanciones_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "sanciones_club_id_fkey"
      columns: ["club_id"]
isOneToOne: false
      referencedRelation: "v_sanciones_activas"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "jugadores"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_partidos_log"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "sanciones_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"torneos": {
                  Row: {
                    "categoria_id": string,"created_at": string,"estadisticas_detalladas": boolean,"estado": Database["public"]['Enums']["estado_torneo"],"formato": Database["public"]['Enums']["formato_torneo"],"id": string,"nombre": string,"org_id": string,"reglas_json": NonNullable<Json>,"temporada": number
                  }
                  ComputedFields: never
                  Insert: {
                    "categoria_id": string,"created_at"?: string,"estadisticas_detalladas"?: boolean,"estado"?: Database["public"]['Enums']["estado_torneo"],"formato"?: Database["public"]['Enums']["formato_torneo"],"id"?: string,"nombre": string,"org_id": string,"reglas_json"?: NonNullable<Json>,"temporada": number
                  }
                  Update: {
                    "categoria_id"?: string,"created_at"?: string,"estadisticas_detalladas"?: boolean,"estado"?: Database["public"]['Enums']["estado_torneo"],"formato"?: Database["public"]['Enums']["formato_torneo"],"id"?: string,"nombre"?: string,"org_id"?: string,"reglas_json"?: NonNullable<Json>,"temporada"?: number
                  }
                  Relationships: [
                    {
      foreignKeyName: "torneos_categoria_id_fkey"
      columns: ["categoria_id"]
isOneToOne: false
      referencedRelation: "categorias"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "torneos_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            "v_detalle_publico": {
                  Row: {
                    "asistencias": number | null,"dorsal": number | null,"equipo_id": string | null,"faltas": number | null,"ficha_id": string | null,"jugador_id": string | null,"minutos": number | null,"nombre_completo": string | null,"org_id": string | null,"partido_id": string | null,"puntos": number | null,"rebotes": number | null,"robos": number | null,"stat_id": string | null,"tapas": number | null,"torneo_id": string | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "equipos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_lideres"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "jugadores"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_partidos_log"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "partidos_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "torneos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "planilla_stats_ficha_id_fkey"
      columns: ["ficha_id"]
isOneToOne: false
      referencedRelation: "fichas"
      referencedColumns: ["id"]
    }
                  ]
                },"v_jugador_partidos_log": {
                  Row: {
                    "asistencias": number | null,"dorsal": number | null,"equipo_id": string | null,"es_local": boolean | null,"faltas": number | null,"fecha_hora": string | null,"jugador_id": string | null,"jugador_slug": string | null,"mi_club_id": string | null,"mi_club_nombre": string | null,"mi_club_slug": string | null,"minutos": number | null,"nombre_completo": string | null,"org_id": string | null,"partido_estado": Database["public"]['Enums']["estado_partido"] | null,"partido_id": string | null,"puntos": number | null,"puntos_local": number | null,"puntos_visitante": number | null,"rebotes": number | null,"resultado": string | null,"rival_equipo_id": string | null,"rival_nombre": string | null,"rival_slug": string | null,"robos": number | null,"ronda": string | null,"sede": string | null,"t3_convertidos": number | null,"t3_intentados": number | null,"tapas": number | null,"tc_convertidos": number | null,"tc_intentados": number | null,"tl_convertidos": number | null,"tl_intentados": number | null,"torneo_id": string | null,"torneo_nombre": string | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["mi_club_id"]
isOneToOne: false
      referencedRelation: "clubes"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["mi_club_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["mi_club_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "equipos_club_id_fkey"
      columns: ["mi_club_id"]
isOneToOne: false
      referencedRelation: "v_sanciones_activas"
      referencedColumns: ["club_id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "equipos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_lideres"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "partidos_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "torneos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["torneo_id"]
    }
                  ]
                },"v_jugador_totales_temporada": {
                  Row: {
                    "apg": number | null,"asistencias_totales": number | null,"bpg": number | null,"club_id": string | null,"club_nombre": string | null,"club_slug": string | null,"faltas_totales": number | null,"fpg": number | null,"jugador_id": string | null,"max_asistencias": number | null,"max_puntos": number | null,"max_rebotes": number | null,"org_id": string | null,"pj": number | null,"ppg": number | null,"puntos_totales": number | null,"rebotes_totales": number | null,"robos_totales": number | null,"rpg": number | null,"spg": number | null,"tapas_totales": number | null,"torneo_id": string | null,"torneo_nombre": string | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "jugadores_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"v_jugadores_publico": {
                  Row: {
                    "altura_cm": number | null,"categoria_nombre": string | null,"ciudad_origen": string | null,"club_id": string | null,"club_nombre": string | null,"club_slug": string | null,"dorsal": number | null,"equipo_id": string | null,"fecha_nacimiento": string | null,"foto_url": string | null,"jugador_id": string | null,"mano_habil": string | null,"nombre_completo": string | null,"org_id": string | null,"posicion": string | null,"slug": string | null,"torneo_id": string | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "equipos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_lideres"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "fichas_equipo_id_fkey"
      columns: ["equipo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["equipo_id"]
    },{
      foreignKeyName: "fichas_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "torneos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "fichas_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "jugadores_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"v_lideres": {
                  Row: {
                    "asistencias": number | null,"equipo": string | null,"equipo_id": string | null,"faltas": number | null,"jugador_id": string | null,"nombre_completo": string | null,"org_id": string | null,"pj": number | null,"puntos": number | null,"rebotes": number | null,"robos": number | null,"tapas": number | null,"torneo_id": string | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "jugadores"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_partidos_log"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "fichas_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "partidos_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "torneos"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["torneo_id"]
    },{
      foreignKeyName: "partidos_torneo_id_fkey"
      columns: ["torneo_id"]
isOneToOne: false
      referencedRelation: "v_tabla"
      referencedColumns: ["torneo_id"]
    }
                  ]
                },"v_sanciones_activas": {
                  Row: {
                    "club": string | null,"club_id": string | null,"fecha_alta": string | null,"id": string | null,"jugador_id": string | null,"motivo": string | null,"org_id": string | null,"partidos_cumplir": number | null,"partidos_restantes": number | null,"persona": string | null,"tipo": Database["public"]['Enums']["persona_sancion"] | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "jugadores"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_partidos_log"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugador_totales_temporada"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "sanciones_jugador_id_fkey"
      columns: ["jugador_id"]
isOneToOne: false
      referencedRelation: "v_jugadores_publico"
      referencedColumns: ["jugador_id"]
    },{
      foreignKeyName: "sanciones_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                },"v_tabla": {
                  Row: {
                    "club": string | null,"dif": number | null,"equipo": string | null,"equipo_id": string | null,"gc": number | null,"gf": number | null,"org_id": string | null,"pdw": number | null,"pg": number | null,"pj": number | null,"pp": number | null,"pts": number | null,"pw": number | null,"torneo_id": string | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "torneos_org_id_fkey"
      columns: ["org_id"]
isOneToOne: false
      referencedRelation: "orgs"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Functions: {
            "es_delegado_de_equipo":
{ Args: { "_equipo_id": string }; Returns: boolean
                           },
"es_delegado_local":
{ Args: { "_partido_id": string }; Returns: boolean
                           },
"es_delegado_local_borrador":
{ Args: { "_planilla_id": string }; Returns: boolean
                           },
"es_liga_admin":
{ Args: { "_org_id": string }; Returns: boolean
                           },
"es_miembro_del_partido":
{ Args: { "_partido_id": string }; Returns: boolean
                           },
"es_organizador":
{ Args: { "_org_id": string }; Returns: boolean
                           },
"es_planilla_publica":
{ Args: { "_planilla_id": string }; Returns: boolean
                           },
"es_superadmin":
{ Args: Record<PropertyKey, never>; Returns: boolean
                           },
"es_visitante_borrador":
{ Args: { "_planilla_id": string }; Returns: boolean
                           },
"mi_club_de":
{ Args: { "_org_id": string }; Returns: string
                           },
"org_activa_id":
{ Args: Record<PropertyKey, never>; Returns: string
                           },
"rol_en_org":
{ Args: { "_org_id": string }; Returns: Database["public"]['Enums']["rol_org"]
                           }
          }
          Enums: {
            "estado_ficha": "solicitada"|"confirmada"|"baja","estado_partido": "programado"|"en_juego"|"finalizado"|"postergado"|"suspendido"|"walkover","estado_planilla": "borrador"|"disputada"|"verificada"|"anulada","estado_sancion": "activa"|"cumplida"|"levantada","estado_torneo": "proximo"|"en_curso"|"finalizado","formato_torneo": "liga"|"liga_playoffs"|"torneo","nivel_auspicio": "oro"|"plata"|"bronce"|"colaborador","persona_sancion": "jugador"|"tecnico"|"club","plan_org": "piloto"|"licencia"|"suspendido","rol_org": "liga_admin"|"liga_ayudante"|"delegado"
          }
          CompositeTypes: {
            [_ in never]: never
          }
        }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R
    }
    ? R
    : never
  : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I
    }
    ? I
    : never
  : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U
    }
    ? U
    : never
  : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  "public": {
          Enums: {
            "estado_ficha": ["solicitada", "confirmada", "baja"],"estado_partido": ["programado", "en_juego", "finalizado", "postergado", "suspendido", "walkover"],"estado_planilla": ["borrador", "disputada", "verificada", "anulada"],"estado_sancion": ["activa", "cumplida", "levantada"],"estado_torneo": ["proximo", "en_curso", "finalizado"],"formato_torneo": ["liga", "liga_playoffs", "torneo"],"nivel_auspicio": ["oro", "plata", "bronce", "colaborador"],"persona_sancion": ["jugador", "tecnico", "club"],"plan_org": ["piloto", "licencia", "suspendido"],"rol_org": ["liga_admin", "liga_ayudante", "delegado"]
          }
        }
} as const
