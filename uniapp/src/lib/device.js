export const deviceKey = 'fatepair.uni.v1'
export const legacyKeys = [
  'start.intent',
  'locale',
  'profile',
  'saved',
  'hidden',
  'sharing.v1',
  'social.v1',
  'journey.v1',
  'reports',
  'consents',
  'studio.charts',
  'studio.style',
  'studio.model',
  'privacy.reset.pending'
]
export function fresh(lang = 'en') {
  return {
    version: 1,
    lang,
    intent: '',
    profile: null,
    saved: [],
    hidden: [],
    links: [],
    reports: [],
    consents: [],
    social: { version: 1, invitations: [], threads: {} },
    garden: { version: 2, completed: [], seals: [], cycle: null },
    studio: null,
    style: 'plain',
    model: null,
    resetPending: false
  }
}
export const isToken = (value) => typeof value === 'string' && /^[A-Za-z0-9_-]{32}$/.test(value)
function twice(value) {
  return typeof value === 'string' ? JSON.parse(value) : value
}
export function legacySnapshot(read, lang) {
  const result = fresh(read('locale') || lang)
  const links = twice(read('sharing.v1')) || []
  result.links = links.filter(
    (e) =>
      isToken(e.id) &&
      isToken(e.secret) &&
      ['owner', 'guest'].includes(e.role) &&
      ['pair', 'portrait'].includes(e.kind)
  )
  if (read('privacy.reset.pending')) return { ...result, resetPending: true }
  result.intent = read('start.intent') || ''
  result.profile = twice(read('profile')) || null
  for (const key of ['saved', 'hidden', 'consents']) result[key] = read(key) || []
  result.reports = (read('reports') || []).map(twice)
  result.social = twice(read('social.v1')) || result.social
  const garden = twice(read('journey.v1'))
  if (garden) result.garden = { ...result.garden, ...garden, version: 2 }
  result.studio = twice(read('studio.charts')) || null
  result.style = read('studio.style') || 'plain'
  const model = twice(read('studio.model'))
  if (model) result.model = { baseUrl: model.baseUrl, model: model.model }
  return result
}
export function openDevice(storage, legacy, lang = 'en') {
  const previous = storage.get()
  const current = previous ? JSON.parse(previous) : legacySnapshot(legacy.read, lang)
  if (current.version !== 1 || !Array.isArray(current.links))
    throw Error('Cannot read saved FatePair data. Try again.')
  if (!previous) storage.set(JSON.stringify(current))
  // A failed cleanup is retried on next launch. The new copy is authoritative.
  legacy.clear()
  return current
}
export function progress(garden, task) {
  if (!garden.completed.includes(task)) garden.completed.push(task)
}
export function stepGarden(garden, day, pick) {
  const cycle = garden.cycle || { seed: day, steps: 0 }
  const expected =
    (['wood', 'fire', 'earth', 'metal', 'water'].indexOf(cycle.seed) + cycle.steps + 1) % 5
  if (cycle.steps >= 5 || expected !== pick) return false
  cycle.steps++
  garden.cycle = cycle
  const seal = ['wood', 'fire', 'earth', 'metal', 'water'][pick]
  if (!garden.seals.includes(seal)) garden.seals.push(seal)
  if (cycle.steps === 5) progress(garden, 'element')
  return true
}
export function exportDevice(data) {
  return {
    app: 'FatePair',
    formatVersion: 4,
    scope: 'This device only',
    exportedAt: new Date().toISOString(),
    profile: data.profile,
    saved: data.saved,
    hidden: data.hidden,
    social: data.social,
    journey: data.garden,
    language: data.lang,
    startIntent: data.intent,
    reports: data.reports,
    consents: data.consents,
    studio: {
      'studio.charts': data.studio,
      'studio.style': data.style,
      'studio.model': data.model ? { baseUrl: data.model.baseUrl, model: data.model.model } : null
    },
    deletionPending: data.resetPending,
    sharing: data.links.map(({ id, kind, role, portrait, expiresAt, pending }) => ({
      id,
      kind,
      role,
      portrait,
      expiresAt,
      pending
    }))
  }
}
