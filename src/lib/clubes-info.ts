export interface ClubCultura {
  nombreOficial: string;
  apodo: string;
  fundacion: string;
  ciudad: string;
  colores: string;
  resena: string;
  gimnasioNombre: string;
  hito: string;
}

export const CULTURA_CLUBES: Record<string, ClubCultura> = {
  'plaza-colonia': {
    nombreOficial: 'Club Plaza Colonia de Deportes',
    apodo: 'El Patablanca',
    fundacion: '1917',
    ciudad: 'Colonia del Sacramento',
    colores: 'Blanco y Verde',
    gimnasioNombre: 'Gimnasio de Plaza Colonia (Av. General Flores)',
    hito: 'Decano polideportivo de la capital departamental y cantera histórica de formativas.',
    resena:
      'Fundado en 1917, Plaza Colonia es una de las instituciones más tradicionales y arraigadas del suroeste uruguayo. Su rama de básquetbol es pilar fundamental de su vida social, albergando generaciones de deportistas colonienses desde las categorías formativas U10 hasta la Primera División. Con su clásico verde y blanco, su gimnasio céntrico vibra en cada jornada de la LBC con un básquetbol dinámico, escuela de valores y fuerte identidad barrial.',
  },
  'colonia-rowing': {
    nombreOficial: 'Colonia Rowing Club',
    apodo: 'El Costero',
    fundacion: '1924',
    ciudad: 'Colonia del Sacramento',
    colores: 'Azul Marino y Blanco',
    gimnasioNombre: 'Gimnasio Costero de Colonia Rowing',
    hito: 'Tradición náutica y deportiva frente a la bahía con clásicos memorables de básquetbol.',
    resena:
      'Nacido a orillas del Río de la Plata en 1924, Colonia Rowing combina su estirpe de club social y náutico con una pasión inquebrantable por el básquetbol. Su gimnasio frente a la bahía de Colonia es un reducto donde el juego físico, la defensa intensa y la lealtad de su parcialidad han forjado capítulos memorables en la historia de la liga departamental.',
  },
  'estudiantes-el-colla': {
    nombreOficial: 'Club Estudiantes El Colla',
    apodo: 'El Fusión / El Colla',
    fundacion: '1938',
    ciudad: 'Rosario (del Colla)',
    colores: 'Rojo, Verde y Amarillo',
    gimnasioNombre: 'Gimnasio de Estudiantes El Colla (Rosario)',
    hito: 'Orgullo pichonero y anfitrión de las grandes jornadas inaugurales de la LBC.',
    resena:
      'Emblema de la pujante ciudad de Rosario del Colla, Estudiantes El Colla representa el corazón del básquetbol del este y centro departamental. Con una mística inconfundible y los colores rojo, verde y amarillo, el club destaca por su calidez comunitaria, una tribuna que colma cada localía y planteles aguerridos que disputan cada pelota como si fuera la última.',
  },
  'juventud-caj': {
    nombreOficial: 'Club Atlético Juventud',
    apodo: 'El Rojo de Colonia',
    fundacion: '1934',
    ciudad: 'Colonia del Sacramento',
    colores: 'Rojo y Azul',
    gimnasioNombre: 'Gimnasio de Juventud',
    hito: 'Potencia formativa con protagonismo continuo en todas las categorías.',
    resena:
      'Fundado en 1934, el Club Atlético Juventud es sinónimo de básquetbol de alta competencia y trabajo formativo metódico en Colonia del Sacramento. Sus planteles se caracterizan por una estructura sólida, formación técnica desde la infancia y una rica trayectoria en finales departamentales, respaldada por una masa societaria vibrante.',
  },
  'cac-valdense': {
    nombreOficial: 'Club Atlético Colonia Valdense',
    apodo: 'El Albiceleste',
    fundacion: '1923',
    ciudad: 'Colonia Valdense',
    colores: 'Celeste y Blanco',
    gimnasioNombre: 'Gimnasio de CAC Valdense',
    hito: 'Bastión del básquetbol formativo en la zona este con gran arraigo comunitario.',
    resena:
      'Referente indiscutido del deporte de Colonia Valdense y la región de inmigración piamontesa, el CAC Valdense se distingue por su impecable conducta formativa, respeto deportivo y desarrollo continuo de categorías infantiles y juveniles. Sus divisiones de base son un semillero inagotable de básquetbol para el departamento.',
  },
};

export function obtenerCulturaClub(slug: string, nombre: string): ClubCultura {
  const slugNorm = slug.toLowerCase().trim();
  if (CULTURA_CLUBES[slugNorm]) return CULTURA_CLUBES[slugNorm];

  const nomNorm = nombre.toLowerCase();
  if (nomNorm.includes('plaza')) return CULTURA_CLUBES['plaza-colonia'];
  if (nomNorm.includes('rowing')) return CULTURA_CLUBES['colonia-rowing'];
  if (nomNorm.includes('estudiantes') || nomNorm.includes('colla')) return CULTURA_CLUBES['estudiantes-el-colla'];
  if (nomNorm.includes('juventud')) return CULTURA_CLUBES['juventud-caj'];
  if (nomNorm.includes('valdense')) return CULTURA_CLUBES['cac-valdense'];

  return {
    nombreOficial: nombre,
    apodo: 'Club Afiliado LBC',
    fundacion: 'Afiliado Oficial',
    ciudad: 'Departamento de Colonia',
    colores: 'Institucionales',
    gimnasioNombre: 'Gimnasio del Club',
    hito: 'Institución integrante de la Liga de Básquetbol de Colonia.',
    resena: `${nombre} es una institución afiliada a la Liga de Básquetbol de Colonia, compitiendo en el circuito oficial federado del departamento de Colonia.`,
  };
}
