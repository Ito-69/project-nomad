#!/usr/bin/env node
/**
 * Re-apply public app URLs after NOMAD seed/migrations.
 * Runs on every admin container start so updates cannot leave stale port-only links.
 *
 * Requires env vars (see .env.example). Skips quietly when unset.
 */
import { createRequire } from 'module'
const require = createRequire('/app/package.json')
const mysql = require('mysql2/promise')

const mappings = [
  ['NOMAD_APP_KIWIX_URL', 'nomad_kiwix_server'],
  ['NOMAD_APP_CYBERCHEF_URL', 'nomad_cyberchef'],
  ['NOMAD_APP_FLATNOTES_URL', 'nomad_flatnotes'],
  ['NOMAD_APP_KOLIBRI_URL', 'nomad_kolibri'],
]

const pending = mappings.filter(([envKey]) => process.env[envKey])
if (pending.length === 0) {
  console.log('configure-app-urls: no NOMAD_APP_*_URL set, skipping')
  process.exit(0)
}

const {
  DB_HOST = 'mysql',
  DB_PORT = '3306',
  DB_DATABASE = 'nomad',
  DB_USER,
  DB_PASSWORD,
} = process.env

if (!DB_USER || !DB_PASSWORD) {
  console.error('configure-app-urls: DB_USER/DB_PASSWORD missing')
  process.exit(1)
}

const conn = await mysql.createConnection({
  host: DB_HOST,
  port: Number(DB_PORT),
  database: DB_DATABASE,
  user: DB_USER,
  password: DB_PASSWORD,
})

for (const [envKey, serviceName] of pending) {
  const url = process.env[envKey]
  const [result] = await conn.execute(
    'UPDATE services SET ui_location = ? WHERE service_name = ? AND installed = 1',
    [url, serviceName]
  )
  console.log(
    `configure-app-urls: ${serviceName} -> ${url} (${result.affectedRows} row(s))`
  )
}

await conn.end()
