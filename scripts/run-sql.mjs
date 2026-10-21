// Runner de SQL multi-statement contra una DB remota.
// El `db query` de la CLI abre una prepared statement por llamada: los archivos
// con BEGIN/ROLLBACK o emulación de JWT (set_config + consulta en la misma
// sesión) necesitan un solo hilo de conexión. pg con protocolo simple lo resuelve.
//
// Uso:
//   export SUPA_DB_URL="postgresql://..."   # o DATABASE_URL
//   node scripts/run-sql.mjs supabase/tests/rls_negativas.sql
//
// Las credenciales viajan solo por entorno; el script nunca imprime la cadena.
import { readFileSync } from 'node:fs';
import { Client } from 'pg';

const file = process.argv[2];
if (!file) {
  console.error('uso: node scripts/run-sql.mjs <archivo.sql>');
  process.exit(1);
}
const url = process.env.SUPA_DB_URL || process.env.DATABASE_URL;
if (!url) {
  console.error('falta SUPA_DB_URL o DATABASE_URL en el entorno (no commitear la cadena)');
  process.exit(1);
}

const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
await client.connect();

const sql = readFileSync(file, 'utf8');
const results = await client.query(sql); // protocolo simple: BEGIN/secuencias completas

let n = 0;
for (const r of Array.isArray(results) ? results : [results]) {
  n += 1;
  if (r.rows && r.rows.length > 0) {
    console.log(`-- resultado ${n} (${r.command})`);
    for (const row of r.rows) console.log(JSON.stringify(row));
  } else if (r.command) {
    console.log(`-- resultado ${n}: ${r.command}${r.rowCount != null ? ` (${r.rowCount})` : ''}`);
  }
}
console.log(`\n${n} resultados de ${file}`);

await client.end();
