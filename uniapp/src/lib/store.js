import { shallowRef, ref } from 'vue'
import { deviceKey, legacyKeys, fresh, openDevice, exportDevice, isToken } from './device.js'
import { origin, shareRequest, tokens } from './api.js'
import { sample } from './chart.js'
import { clearConversation } from './conversation.js'
import { languages, labels } from './translations.js'

export const data = shallowRef(fresh()),
  bootError = ref(''),
  ready = ref(false)
const disk = {
  get: () => uni.getStorageSync(deviceKey),
  set: (v) => uni.setStorageSync(deviceKey, v)
}
const legacy = {
  read() {
    return null
  },
  clear() {}
}
// #ifdef H5
if (typeof window !== 'undefined') {
  legacy.read = (k) => JSON.parse(window.localStorage.getItem('flutter.' + k) || 'null')
  legacy.clear = () => legacyKeys.forEach((k) => window.localStorage.removeItem('flutter.' + k))
}
// #endif
export function boot() {
  if (ready.value) return
  try {
    const locale = uni.getSystemInfoSync().language || 'en'
    const code = locale.replace('_', '-')
    const supported =
      languages.find(([x]) => x.toLowerCase() === code.toLowerCase()) ||
      languages.find(([x]) => x === code.split('-')[0])
    data.value = openDevice(disk, legacy, supported?.[0] || 'en')
    ready.value = true
    bootError.value = ''
  } catch (e) {
    bootError.value = e.message || 'Could not read saved data.'
  }
}
export function tr(en, zh) {
  const code = (data.value.lang || 'en').replace('_', '-')
  return labels[code]?.[en] || (/^zh/i.test(code) ? zh : en)
}
export function update(f, allowReset = false) {
  if (!ready.value || (data.value.resetPending && !allowReset))
    throw Error('Finish clearing your data first.')
  const next = JSON.parse(JSON.stringify(data.value))
  f(next)
  disk.set(JSON.stringify(next))
  data.value = next
}
export function say(message) {
  uni.showToast({ title: String(message), icon: 'none', duration: 2700 })
}
export function action(f) {
  try {
    return f()
  } catch (e) {
    say(e.message)
  }
}
export function currentSubject() {
  if (data.value.studio?.primary) return data.value.studio.primary
  return data.value.profile ? { ...sample, ...data.value.profile } : sample
}
export const linkUrl = (id) => origin + '/s/' + id
export function portraitFrom(r, name, kind, traits = [0, 1]) {
  return {
    name: name.trim(),
    element: r.element,
    traits: [...traits].sort(),
    ...(kind === 'pair' ? { counts: [...r.counts] } : {})
  }
}
function remember(entry) {
  update((s) => {
    s.links = [entry, ...s.links.filter((e) => e.id !== entry.id)]
  })
}
let mutation = false
export async function saveShare({ kind, portrait, id, parentId, expiresAt }) {
  if (mutation) throw Error('A share operation is already in progress.')
  if (id && data.value.links.some((link) => link.id === id && link.pending))
    throw Object.assign(Error('Retry the saved card in My shared links.'), { pendingId: id })
  mutation = true
  try {
    const random = await tokens()
    if (!isToken(random.id) || !isToken(random.secret))
      throw Error('Could not prepare a private link.')
    const e = {
      id: id || random.id,
      secret: random.secret,
      role: id ? 'guest' : 'owner',
      kind,
      portrait,
      parentId: parentId || null,
      pending: true,
      expiresAt: expiresAt || new Date(Date.now() + 7 * 86400000).toISOString()
    }
    remember(e)
    try {
      return await sendEntry(e)
    } catch (error) {
      if (data.value.links.some((link) => link.id === e.id && link.pending)) error.pendingId = e.id
      throw error
    }
  } finally {
    mutation = false
  }
}
async function sendEntry(e) {
  const owner = e.role === 'owner'
  const payload = owner
    ? {
        id: e.id,
        kind: e.kind,
        portrait: e.portrait,
        consent: true,
        ...(e.parentId ? { parentId: e.parentId } : {})
      }
    : { portrait: e.portrait, consent: true }
  let res
  try {
    res = await shareRequest(owner ? '' : '/' + e.id + '/join', 'POST', payload, e.secret)
  } catch (error) {
    if (error.status === 409 && !owner)
      update((s) => {
        s.links = s.links.filter((x) => x.id !== e.id)
      })
    else error.pendingId = e.id
    throw error
  }
  const saved = { ...e, pending: false, expiresAt: new Date(res.expiresAt * 1000).toISOString() }
  remember(saved)
  return saved
}
export async function retryEntry(e) {
  if (mutation) throw Error('A share operation is already in progress.')
  mutation = true
  try {
    return await sendEntry(e)
  } finally {
    mutation = false
  }
}
async function revokeEntry(e) {
  try {
    await shareRequest('/' + e.id, 'DELETE', undefined, e.secret)
  } catch (error) {
    if (error.status !== 410 && !(e.pending && e.role === 'guest' && error.status === 401))
      throw error
  }
}
export async function withdraw(e) {
  if (mutation) throw Error('A share operation is already in progress.')
  mutation = true
  try {
    await revokeEntry(e)
    update((s) => {
      s.links = s.links.filter((x) => x.id !== e.id)
    })
  } finally {
    mutation = false
  }
}
export async function resetAll() {
  if (mutation) throw Error('Finish the current share operation first.')
  mutation = true
  try {
    update((s) => {
      const pending = s.links
      Object.assign(s, fresh(s.lang), { links: pending, resetPending: true })
    }, true)
    clearConversation()
    legacy.clear()
    for (const e of [...data.value.links]) {
      if (new Date(e.expiresAt) > new Date()) await revokeEntry(e)
      update((s) => {
        s.links = s.links.filter((x) => x.id !== e.id)
      }, true)
    }
    update((s) => {
      s.resetPending = false
    }, true)
  } finally {
    mutation = false
  }
}
export function exportLocal() {
  return JSON.stringify(exportDevice(data.value), null, 2)
}
