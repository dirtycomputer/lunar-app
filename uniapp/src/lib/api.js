export const origin = 'https://yuan-bazi-connections.dirtycomputer.chatgpt.site'
export const modelOrigin = 'https://fatepair-api-buaa42wxys-projects.vercel.app/api/model'
export function request(url, options = {}) {
  let task
  const result = new Promise((resolve, reject) => {
    task = uni.request({
      url,
      method: options.method || 'GET',
      data: options.body,
      header: options.headers || {},
      timeout: options.timeout || 30000,
      success(res) {
        const body = res.data
        if (res.statusCode >= 200 && res.statusCode < 300) return resolve(body)
        const message =
          body?.error?.message ||
          body?.error?.code ||
          body?.code ||
          (typeof body?.error === 'string' ? body.error : 'Service unavailable')
        reject(
          Object.assign(Error(message), {
            status: res.statusCode,
            code: body?.code || body?.error?.code
          })
        )
      },
      fail: () => reject(Error('Could not reach the service. Check your connection and retry.'))
    })
  })
  result.abort = () => task?.abort()
  return result
}
export async function catalog(read = request) {
  const people = [],
    ids = new Set(),
    cursors = new Set()
  let after = '',
    revision,
    total
  do {
    const page = await read(
      origin + '/api/people?limit=200' + (after ? '&after=' + encodeURIComponent(after) : '')
    )
    if (
      !page ||
      page.synthetic !== true ||
      page.storage !== 'cloudflare-d1' ||
      !Array.isArray(page.people) ||
      !Number.isInteger(page.total) ||
      page.total < 0 ||
      (revision && (page.revision !== revision || page.total !== total))
    )
      throw Error('The directory changed. Reload the list.')
    revision = page.revision
    total = page.total
    for (const person of page.people) {
      if (person.synthetic !== true || ids.has(person.id) || !Array.isArray(person.chart?.pillars))
        throw Error('The directory is incomplete. Please retry.')
      ids.add(person.id)
      people.push(person)
    }
    after = page.nextCursor
    if (after && (!page.people.length || cursors.has(after) || people.length >= total))
      throw Error('Invalid directory page.')
    cursors.add(after)
  } while (after)
  if (people.length !== total) throw Error('The directory is incomplete. Please retry.')
  return people
}
export function modelPacket(turns, question, evidence, language) {
  return {
    messages: [
      ...turns.map((t) => ({
        role: t.role,
        content: t.role === 'user' ? JSON.stringify(t.packet) : t.content
      })),
      { role: 'user', content: JSON.stringify({ question, computedEvidence: evidence, language }) }
    ]
  }
}
export function askModel(packet) {
  return request(modelOrigin + '/chat/completions', {
    method: 'POST',
    body: packet,
    headers: { 'X-Lunar-Client': 'studio', 'Content-Type': 'application/json' },
    timeout: 285000
  })
}
export function shareRequest(path, method = 'GET', body, secret) {
  return request(origin + '/api/shares' + path, {
    method,
    body,
    headers: {
      ...(body ? { 'Content-Type': 'application/json' } : {}),
      ...(secret ? { Authorization: 'Bearer ' + secret } : {})
    }
  })
}
export function tokens() {
  // The App service runtime and older mini-program engines may lack Web Crypto.
  // This no-store endpoint only issues fresh entropy and creates no share record.
  return request(origin + '/api/share-tokens', { method: 'POST' })
}
