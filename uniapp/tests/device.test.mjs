import test from 'node:test'
import assert from 'node:assert/strict'
import { openDevice, fresh, exportDevice, stepGarden } from '../src/lib/device.js'
import { portableImport } from '../src/lib/import.js'
import { sample } from '../src/lib/chart.js'
import { catalog, modelPacket } from '../src/lib/api.js'
import {
  bindSubject,
  send,
  turns,
  failed,
  failure,
  prepareQuestion,
  clearConversation
} from '../src/lib/conversation.js'
import { data, boot, saveShare, retryEntry, resetAll, ready, update } from '../src/lib/store.js'

const owner = {
  id: 'o'.repeat(32),
  secret: 's'.repeat(32),
  kind: 'pair',
  role: 'owner',
  portrait: { name: 'Alex', element: 2, traits: [1] },
  expiresAt: '2099-03-01T00:00:00Z'
}
test('Flutter migration commits before cleanup and retries an interrupted cleanup', () => {
  let value,
    attempt = 0
  const storage = {
      get: () => value,
      set: (v) => {
        value = v
      }
    },
    legacy = {
      read: (k) =>
        ({
          'start.intent': 'match',
          profile: JSON.stringify(sample),
          'sharing.v1': JSON.stringify([owner]),
          saved: ['p1']
        })[k],
      clear: () => {
        if (!attempt++) throw Error('busy')
      }
    }
  assert.throws(() => openDevice(storage, legacy), /busy/)
  const migrated = openDevice(storage, legacy)
  assert.equal(migrated.profile.name, sample.name)
  assert.equal(migrated.links[0].secret, owner.secret)
  const portable = JSON.stringify(exportDevice(migrated))
  assert.equal(portable.includes(owner.secret), false)
  const imported = portableImport(portable)
  assert.deepEqual(imported.saved, ['p1'])
  assert.equal(imported.intent, 'match')
  assert.deepEqual(imported.links, [])
  assert.throws(() =>
    portableImport(JSON.stringify({ app: 'FatePair', formatVersion: 3, deletionPending: true }))
  )
  let cleared = false
  assert.throws(
    () =>
      openDevice(
        {
          get: () => null,
          set: () => {
            throw Error('full')
          }
        },
        {
          read: () => null,
          clear: () => {
            cleared = true
          }
        }
      ),
    /full/
  )
  assert.equal(cleared, false)
})
test('garden mistakes, resumption and replay keep one of each reward', () => {
  const g = fresh().garden
  assert.equal(stepGarden(g, 'wood', 4), false)
  for (const pick of [1, 2, 3, 4, 0]) assert.equal(stepGarden(g, 'wood', pick), true)
  assert.deepEqual(g.completed, ['element'])
  assert.equal(g.seals.length, 5)
  g.cycle = { seed: 'water', steps: 0 }
  for (const pick of [0, 1, 2, 3, 4]) stepGarden(g, 'water', pick)
  assert.equal(g.seals.length, 5)
  assert.deepEqual(g.completed, ['element'])
})
test('the directory follows all cursors and rejects partial or duplicate pages', async () => {
  const make = (id) => ({ id, synthetic: true, chart: { pillars: [] } })
  const page = { revision: 'r', synthetic: true, storage: 'cloudflare-d1', total: 2 }
  const pages = [
    { ...page, people: [make('a')], nextCursor: 'abc' },
    { ...page, people: [make('b')], nextCursor: null }
  ]
  const urls = []
  const people = await catalog((url) => {
    urls.push(url)
    return pages.shift()
  })
  assert.deepEqual(
    people.map((x) => x.id),
    ['a', 'b']
  )
  assert.match(urls[1], /after=abc/)
  await assert.rejects(
    catalog(() => ({ ...page, people: [make('a')] })),
    /incomplete/
  )
  await assert.rejects(
    catalog(() => ({ ...page, people: [make('a')], nextCursor: 'abc' })),
    /incomplete/
  )
})
test('AI retains original context on retry and discards a response after the profile changes', async () => {
  const requests = []
  globalThis.uni = {
    request: (q) => {
      requests.push(q)
      return { abort() {} }
    }
  }
  clearConversation()
  bindSubject('original')
  const a = prepareQuestion('first', { period: 'year' }, 'en')
  const first = send(a)
  requests.at(-1).fail()
  await first
  assert.match(failure.value, /reach/)
  assert.equal(turns.value.length, 1)
  const again = send(failed.value, true)
  assert.deepEqual(requests[0].data, requests[1].data)
  requests[1].success({ statusCode: 200, data: { choices: [{ message: { content: 'reply' } }] } })
  await again
  const second = prepareQuestion('next', { period: 'day' }, 'en')
  assert.deepEqual(second.packet, modelPacket(turns.value, 'next', { period: 'day' }, 'en'))
  assert.equal(JSON.parse(second.packet.messages[0].content).computedEvidence.period, 'year')
  const late = send(second)
  bindSubject('replacement')
  requests.at(-1).success({ statusCode: 200, data: { choices: [{ message: { content: 'old' } }] } })
  await late
  assert.deepEqual(turns.value, [])
})
test('ambiguous link creation is retried with the saved credentials and can be withdrawn', async () => {
  ready.value = false
  let saved,
    failOnce = true,
    failDelete = true
  const calls = []
  globalThis.uni = {
    getStorageSync: () => saved,
    setStorageSync: (_, v) => {
      saved = v
    },
    getSystemInfoSync: () => ({ language: 'en' }),
    request: (q) => {
      calls.push(q)
      queueMicrotask(() => {
        if (q.url.endsWith('share-tokens'))
          return q.success({ statusCode: 200, data: { id: owner.id, secret: owner.secret } })
        if (q.method === 'DELETE' && failDelete) {
          failDelete = false
          return q.fail()
        }
        if (failOnce) {
          failOnce = false
          return q.fail()
        }
        q.success({ statusCode: 200, data: { expiresAt: Math.ceil(Date.now() / 1000) + 86400 } })
      })
      return { abort() {} }
    }
  }
  boot()
  await assert.rejects(
    saveShare({ kind: 'pair', portrait: owner.portrait }),
    (e) => e.pendingId === owner.id
  )
  assert.equal(data.value.links.length, 1)
  assert.equal(data.value.links[0].pending, true)
  await retryEntry(data.value.links[0])
  assert.equal(data.value.links[0].pending, false)
  assert.deepEqual(calls[1].data, calls[2].data)
  assert.deepEqual(calls[1].header, calls[2].header)
  await assert.rejects(resetAll())
  assert.equal(data.value.resetPending, true)
  assert.throws(() => update((s) => s.saved.push('p')), /clearing/)
  await resetAll()
  assert.deepEqual(JSON.parse(saved).links, [])
  assert.equal(data.value.resetPending, false)
})
