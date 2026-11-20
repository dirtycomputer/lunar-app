import { readFileSync, writeFileSync } from 'node:fs'
import { parseArgs } from 'node:util'
const { values } = parseArgs({
  options: { weixin: { type: 'string' }, dcloud: { type: 'string' } }
})
const file = new URL('../src/manifest.json', import.meta.url)
const config = JSON.parse(readFileSync(file))
if (!values.weixin && !values.dcloud)
  throw Error('Supply --weixin or --dcloud with the public app identifier.')
if (values.weixin && !/^wx[a-f\d]{16}$/i.test(values.weixin)) throw Error('Invalid WeChat AppID.')
if (values.dcloud && !/^__UNI__[A-Z0-9]+$/i.test(values.dcloud))
  throw Error('Invalid DCloud AppID.')
if (values.weixin) config['mp-weixin'].appid = values.weixin
if (values.dcloud) config.appid = values.dcloud
writeFileSync(file, JSON.stringify(config, null, 2) + '\n')
console.log('Public application identifiers saved. Rebuild the selected targets.')
