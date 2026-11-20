import assert from 'node:assert/strict'
import { readFileSync, readdirSync, statSync, existsSync } from 'node:fs'
import { join } from 'node:path'
const root = 'dist/build'
const read = (p) => readFileSync(p, 'utf8')
const json = (p) => JSON.parse(read(p))
const size = (p) =>
  statSync(p).isFile()
    ? statSync(p).size
    : readdirSync(p).reduce((s, child) => s + size(join(p, child)), 0)
const h5 = join(root, 'h5'),
  wx = join(root, 'mp-weixin'),
  app = join(root, 'app')
const source = json('src/manifest.json'),
  pages = json('src/pages.json').pages.map((p) => p.path)
const index = read(join(h5, 'index.html'))
assert.match(index, /#\/pages\/share\/index\?id=/)
assert.match(index, /id="app"/)
for (const [, url] of index.matchAll(/(?:src|href)="(\/[^"]+)"/g))
  assert.ok(existsSync(join(h5, url)), url)
assert.ok(existsSync(join(h5, 'static/h5/manrope.ttf')))
assert.deepEqual(json(join(wx, 'app.json')).pages, pages)
for (const page of pages)
  for (const ext of ['js', 'wxml', 'json'])
    assert.ok(existsSync(join(wx, page + '.' + ext)), page + ext)
assert.match(read(join(wx, 'pages/share/index.wxml')), /open-type="share"/)
assert.equal(
  json(join(wx, 'project.config.json')).appid,
  source['mp-weixin'].appid || 'touristappid'
)
assert.ok(size(wx) < 2 * 1024 * 1024, 'WeChat main package exceeds 2 MiB')
const icons = source['app-plus'].distribute.icons
for (const path of [
  ...Object.values(icons.android),
  icons.ios.appstore,
  ...Object.values(icons.ios.iphone),
  ...Object.values(icons.ios.ipad)
])
  assert.ok(existsSync(join('src', path)), path)
const native = json(join(app, 'manifest.json'))
assert.deepEqual(native['@platforms'], ['android', 'iPhone', 'iPad'])
assert.equal(native.id, source.appid)
for (const file of ['app-service.js', 'app-config-service.js', '__uniappview.html'])
  assert.ok(statSync(join(app, file)).size > 0)
for (const target of [h5, wx, app]) assert.ok(existsSync(join(target, 'static/art/garden.png')))
console.log(
  JSON.stringify({
    pages: pages.length,
    webBytes: size(h5),
    weixinBytes: size(wx),
    nativeResourceBytes: size(app),
    weixinAppIdConfigured: !!source['mp-weixin'].appid,
    dcloudAppIdConfigured: !!source.appid
  })
)
