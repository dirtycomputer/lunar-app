import { chart, ageOn } from './chart.js'
import { fresh } from './device.js'
// Only portable fields are accepted. Link secrets stay on the originating device.
export function portableImport(text) {
  const input = JSON.parse(text)
  if (input.app !== 'FatePair' || ![3, 4].includes(input.formatVersion) || input.deletionPending)
    throw Error('Choose a completed FatePair device export.')
  const s = fresh(typeof input.language === 'string' ? input.language : 'en')
  if (input.profile) {
    if (
      typeof input.profile.name !== 'string' ||
      !input.profile.name.trim() ||
      input.profile.name.length > 120
    )
      throw Error('Invalid profile.')
    if (ageOn(input.profile.birth.date) < 18) throw Error('Adult profiles only.')
    chart(input.profile)
    s.profile = { name: input.profile.name, birth: input.profile.birth }
  }
  const ids = (x) =>
    Array.isArray(x)
      ? [...new Set(x.filter((i) => typeof i === 'string' && /^[a-zA-Z0-9_-]{1,48}$/.test(i)))]
      : []
  s.saved = ids(input.saved)
  s.hidden = ids(input.hidden)
  if (['chart', 'match', 'agent'].includes(input.startIntent)) s.intent = input.startIntent
  const social = input.social || {}
  s.social.invitations = ids(social.invitations)
  for (const id of ids(Object.keys(social.threads || {})))
    s.social.threads[id] = (social.threads[id] || [])
      .filter((m) => m && typeof m.text === 'string')
      .map((m) => ({ text: m.text, id: String(m.id), createdAt: String(m.createdAt) }))
  const j = input.journey || {}
  s.garden.completed = ids(j.completed).filter((k) =>
    ['element', 'outlook', 'encounter'].includes(k)
  )
  const es = ['wood', 'fire', 'earth', 'metal', 'water']
  s.garden.seals = ids(j.seals).filter((k) => es.includes(k))
  if (
    j.cycle &&
    es.includes(j.cycle.seed) &&
    Number.isInteger(j.cycle.steps) &&
    j.cycle.steps >= 0 &&
    j.cycle.steps <= 5
  )
    s.garden.cycle = { seed: j.cycle.seed, steps: j.cycle.steps }
  const studio = input.studio?.['studio.charts']
  if (studio?.primary) {
    if (
      [studio.primary, studio.secondary].some((person) => person && ageOn(person.birth.date) < 18)
    )
      throw Error('Adult profiles only.')
    chart(studio.primary)
    if (studio.secondary) chart(studio.secondary)
    s.studio = { primary: studio.primary, secondary: studio.secondary || null }
  }
  s.style = input.studio?.['studio.style'] === 'professional' ? 'professional' : 'plain'
  const model = input.studio?.['studio.model']
  if (model && typeof model.baseUrl === 'string' && typeof model.model === 'string')
    s.model = { baseUrl: model.baseUrl, model: model.model }
  s.reports = Array.isArray(input.reports) ? input.reports : []
  s.consents = Array.isArray(input.consents) ? input.consents : []
  return s
}
