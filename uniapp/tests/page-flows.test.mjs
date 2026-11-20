import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs'
import { resolve, join } from 'node:path'
import { pathToFileURL } from 'node:url'
import { createRenderer, nextTick } from 'vue'
import { parse, compileScript } from '@vue/compiler-sfc'
import { build } from 'esbuild'

// Mount the actual source pages with uni lifecycle, storage and network adapters.
// The renderer exercises the controls without relying on a browser or a simulator.
const root = process.cwd()
const pages = ['home', 'reading', 'agent', 'matches', 'person']
const custom = new Set([
  'view',
  'text',
  'image',
  'picker',
  'slider',
  'checkbox',
  'canvas',
  'textarea',
  'input'
])
function h5(source) {
  return source.replace(/\/\/ #ifdef (MP-WEIXIN|APP-PLUS)[\s\S]*?\/\/ #endif/g, '')
}
async function loadPages() {
  const bundle = await build({
    stdin: {
      contents: pages
        .map((name) => 'export {default as ' + name + "} from './src/pages/" + name + "/index.vue'")
        .join('\n'),
      resolveDir: root
    },
    bundle: true,
    platform: 'node',
    format: 'esm',
    packages: 'external',
    write: false,
    plugins: [
      {
        name: 'vue-pages',
        setup(b) {
          b.onResolve({ filter: /^@dcloudio\/uni-app$/ }, () => ({
            path: 'hooks',
            namespace: 'uni-test'
          }))
          b.onLoad({ filter: /.*/, namespace: 'uni-test' }, () => ({
            contents: ['onLoad', 'onShow', 'onHide', 'onUnload', 'onShareAppMessage']
              .map(
                (name) => 'export const ' + name + '=f=>globalThis.pageHooks.' + name + '.push(f)'
              )
              .join('\n')
          }))
          b.onLoad({ filter: /\.vue$/ }, (args) => {
            const { descriptor } = parse(h5(readFileSync(args.path, 'utf8')), {
              filename: args.path
            })
            descriptor.template.ast = undefined
            const script = compileScript(descriptor, {
              id: 'test-page',
              inlineTemplate: true,
              templateOptions: { compilerOptions: { isCustomElement: (t) => custom.has(t) } }
            })
            return { contents: script.content, resolveDir: resolve(args.path, '..') }
          })
        }
      }
    ]
  })
  const directory = mkdtempSync(join(root, 'node_modules/.fatepair-flow-'))
  try {
    const path = join(directory, 'pages.mjs')
    writeFileSync(path, bundle.outputFiles[0].contents)
    return await import(pathToFileURL(path).href)
  } finally {
    rmSync(directory, { recursive: true, force: true })
  }
}
function tree(tag, text = '') {
  return {
    tag,
    tagName: tag.toUpperCase(),
    text,
    props: {},
    children: [],
    parent: null,
    value: '',
    listeners: {},
    addEventListener(k, fn) {
      this.listeners[k] = fn
    },
    removeEventListener(k) {
      delete this.listeners[k]
    }
  }
}
function detach(n) {
  if (n.parent) {
    const k = n.parent.children.indexOf(n)
    if (k >= 0) n.parent.children.splice(k, 1)
    n.parent = null
  }
}
const renderer = createRenderer({
  createElement: (tag) => tree(tag),
  createText: (s) => tree('#text', s),
  createComment: (s) => tree('#comment', s),
  setElementText: (n, s) => {
    n.text = s
    n.children = []
  },
  setText: (n, s) => {
    n.text = s
  },
  patchProp: (n, k, _, v) => {
    n.props[k] = v
  },
  insert: (n, p, a) => {
    detach(n)
    const at = p.children.indexOf(a)
    p.children.splice(at < 0 ? p.children.length : at, 0, n)
    n.parent = p
  },
  remove: detach,
  parentNode: (n) => n.parent,
  nextSibling: (n) => n.parent?.children[n.parent.children.indexOf(n) + 1] || null,
  setScopeId() {},
  insertStaticContent: (html, p, a) => {
    const n = tree('#static', html)
    p.children.push(n)
    n.parent = p
    return [n, n]
  }
})
const textOf = (n) => (n.tag === '#comment' ? '' : n.text + n.children.map(textOf).join(''))
const nodes = (n) => [n, ...n.children.flatMap(nodes)]
function find(container, tag, label) {
  const el = nodes(container).find(
    (n) => n.tag === tag && (label === undefined || textOf(n).trim() === label)
  )
  assert.ok(el, tag + ' ' + label)
  return el
}
const flush = async () => {
  await new Promise((done) => setImmediate(done))
  await nextTick()
}
test('chooser, in-place outlook, consented AI and a ranked person are reachable via their page controls', async () => {
  globalThis.document = { activeElement: null }
  const components = await loadPages(),
    catalog = JSON.parse(readFileSync('../catalog/seed.json')).people.map((x) => x.profile)
  let storage, route, app, packet
  globalThis.uni = {
    getStorageSync: () => storage,
    setStorageSync: (_, v) => {
      storage = v
    },
    getSystemInfoSync: () => ({ language: 'en' }),
    reLaunch: (q) => {
      route = q.url
    },
    navigateTo: (q) => {
      route = q.url
    },
    showToast() {},
    request: (q) => {
      const url = new URL(q.url)
      if (url.pathname === '/api/people') {
        const start = Number(url.searchParams.get('after')) || 0
        queueMicrotask(() =>
          q.success({
            statusCode: 200,
            data: {
              people: catalog.slice(start, start + 200),
              revision: 'fixture',
              total: 1000,
              synthetic: true,
              storage: 'cloudflare-d1',
              nextCursor: start + 200 < 1000 ? String(start + 200) : null
            }
          })
        )
      } else {
        packet = q.data
        queueMicrotask(() =>
          q.success({
            statusCode: 200,
            data: { choices: [{ message: { content: 'A test chart response.' } }] }
          })
        )
      }
      return { abort() {} }
    }
  }
  globalThis.getCurrentPages = () => [{}, {}]
  async function mount(name, query = {}) {
    if (app) {
      for (const f of pageHooks.onUnload) f()
      app.unmount()
    }
    globalThis.pageHooks = {
      onLoad: [],
      onShow: [],
      onHide: [],
      onUnload: [],
      onShareAppMessage: []
    }
    const container = tree('root')
    app = renderer.createApp(components[name])
    app.mount(container)
    for (const f of pageHooks.onLoad) f(query)
    for (const f of pageHooks.onShow) f()
    await flush()
    return container
  }
  async function click(p, label) {
    const b = find(p, 'button', label)
    assert.ok(!b.props.disabled, label)
    b.props.onClick()
    await flush()
  }
  let p = await mount('home')
  await click(p, 'My reading')
  assert.equal(route, '/pages/reading/index')
  p = await mount('reading')
  assert.match(textOf(p), /Sample chart/)
  await click(p, 'Recent outlook')
  await click(p, 'Ask about this period')
  assert.match(route, /source=outlook&period=1/)
  p = await mount('agent', { source: 'outlook', period: '1' })
  assert.ok(find(p, 'button', 'Ask').props.disabled)
  find(p, 'checkbox').props.onClick()
  await flush()
  await click(p, 'Ask')
  const evidence = JSON.parse(packet.messages.at(-1).content).computedEvidence
  assert.equal(evidence.natal.pillars.length, 4)
  assert.equal(evidence.userContext.sampleChart, true)
  assert.match(textOf(p), /AI · DeepSeek/)
  assert.match(textOf(p), /A test chart response/)
  p = await mount('home', { choose: 1 })
  await click(p, 'Find a match')
  assert.equal(route, '/pages/matches/index')
  p = await mount('matches')
  assert.match(textOf(p), /Fictional profiles.*1000/)
  await click(p, 'Random match')
  const id = new URL(route, 'https://test.invalid').searchParams.get('id')
  p = await mount('person', { id })
  assert.ok(catalog.some((row) => row.id === id && textOf(p).includes(row.name)))
  await click(p, 'Save profile')
  assert.ok(JSON.parse(storage).saved.includes(id))
  app.unmount()
})
