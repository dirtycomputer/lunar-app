import calendar from 'lunar-javascript'
import moment from 'moment-timezone/moment-timezone.js'
import zoneData from './zones-data.js'
import backzone from './backzone.js'
moment.tz.load(zoneData)

const { Solar, LunarUtil } = calendar
export const elements = ['Wood', 'Fire', 'Earth', 'Metal', 'Water']
export const cnElements = ['木', '火', '土', '金', '水']
export const elementColors = ['#357258', '#af4c40', '#886517', '#626a91', '#326ba5']
export const signs = [
  'Rat',
  'Ox',
  'Tiger',
  'Rabbit',
  'Dragon',
  'Snake',
  'Horse',
  'Goat',
  'Monkey',
  'Rooster',
  'Dog',
  'Pig'
]
export const cnSigns = Array.from('鼠牛虎兔龙蛇马羊猴鸡狗猪')
export const stems = '甲乙丙丁戊己庚辛壬癸'
export const branches = '子丑寅卯辰巳午未申酉戌亥'
const branchElements = [4, 2, 0, 0, 2, 1, 1, 2, 3, 3, 2, 4]
const pillars = ['Year', 'Month', 'Day', 'Hour']
export const sampleBirth = {
  date: '1997-06-18',
  hour: 9,
  minute: 30,
  timeKnown: true,
  place: 'San Francisco, USA',
  zone: 'America/Los_Angeles',
  longitude: -122.4194
}
export const sample = {
  name: 'Sample chart',
  birth: sampleBirth,
  basis: 'meanSolar',
  sect: 2,
  sex: 1
}
export const places = [
  {
    place: 'San Francisco, USA',
    zone: 'America/Los_Angeles',
    longitude: -122.4194
  },
  {
    place: 'New York, USA',
    zone: 'America/New_York',
    longitude: -74.006
  },
  {
    place: 'London, UK',
    zone: 'Europe/London',
    longitude: -0.1276
  },
  {
    place: 'Paris, France',
    zone: 'Europe/Paris',
    longitude: 2.3522
  },
  {
    place: 'Berlin, Germany',
    zone: 'Europe/Berlin',
    longitude: 13.405
  },
  {
    place: 'Singapore',
    zone: 'Asia/Singapore',
    longitude: 103.8198
  },
  {
    place: 'Tokyo, Japan',
    zone: 'Asia/Tokyo',
    longitude: 139.6917
  },
  {
    place: 'Seoul, South Korea',
    zone: 'Asia/Seoul',
    longitude: 126.978
  },
  {
    place: 'Shanghai, China',
    zone: 'Asia/Shanghai',
    longitude: 121.4737
  },
  {
    place: 'Hong Kong',
    zone: 'Asia/Hong_Kong',
    longitude: 114.1694
  },
  {
    place: 'Mumbai, India',
    zone: 'Asia/Kolkata',
    longitude: 72.8777
  },
  {
    place: 'Dubai, UAE',
    zone: 'Asia/Dubai',
    longitude: 55.2708
  },
  {
    place: 'Sydney, Australia',
    zone: 'Australia/Sydney',
    longitude: 151.2093
  },
  {
    place: 'São Paulo, Brazil',
    zone: 'America/Sao_Paulo',
    longitude: -46.6333
  },
  {
    place: 'Cape Town, South Africa',
    zone: 'Africa/Johannesburg',
    longitude: 18.4241
  },
  {
    place: 'Toronto, Canada',
    zone: 'America/Toronto',
    longitude: -79.3832
  }
]
export const meaning = [
  ['Making room for ideas and steady growth', '重视新想法与长期成长'],
  ['Bringing warmth and energy to a conversation', '擅长表达热情和建立联系'],
  ['Building trust through consistency', '通过持续的行动积累信任'],
  ['Finding clarity and a workable structure', '重视清晰的判断与秩序'],
  ['Taking time to listen and adapt', '愿意倾听，也善于调整方向']
]
export const traits = [
  ['Make room for new ideas', 'Grow through small steps', 'Leave space to change direction'],
  ['Bring warmth to a conversation', 'Celebrate the little things', 'Make room for a quieter pace'],
  [
    'Build trust through consistency',
    'Create a place to feel at home',
    'Let others support you too'
  ],
  [
    'Find clarity in what matters',
    'Notice the thoughtful details',
    'Leave room for the unexpected'
  ],
  ['Stay curious about other people', 'Take time to reflect', 'Share what is on your mind']
]
const plusOrMinusRound = (x) => Math.sign(x) * Math.round(Math.abs(x))
export function ageOn(birthDate, today = new Date()) {
  const date = birthDate.slice(0, 10)
  const monthDay =
    String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0')
  return today.getFullYear() - Number(date.slice(0, 4)) - (monthDay < date.slice(5) ? 1 : 0)
}
export function resolveClock(b) {
  if (
    !b ||
    typeof b.date !== 'string' ||
    !/^\d{4}-\d\d-\d\d(?:T.*)?$/.test(b.date) ||
    typeof b.timeKnown !== 'boolean'
  )
    throw Error('Check the birth date.')
  const [y, m, d] = b.date.slice(0, 10).split('-').map(Number)
  const h = b.timeKnown ? b.hour : 12,
    min = b.timeKnown ? b.minute : 0
  const wall = Date.UTC(y, m - 1, d, h, min)
  if (
    y < 1900 ||
    y > 2100 ||
    !Number.isInteger(h) ||
    h < 0 ||
    h > 23 ||
    !Number.isInteger(min) ||
    min < 0 ||
    min > 59 ||
    new Date(wall).toISOString().slice(0, 10) !== b.date.slice(0, 10)
  )
    throw Error('Check the birth date and time.')
  const zone = typeof b.zone === 'string' && moment.tz.zone(b.zone)
  if (!zone || !Number.isFinite(b.longitude) || Math.abs(b.longitude) > 180)
    throw Error('Choose a valid time zone and longitude.')
  let candidates
  const historical = wall < 0 ? backzone[1][backzone[0][b.zone]] : null
  if (historical) {
    const offsets = historical.filter((_, i) => i % 2 === 0)
    candidates = [...new Set(offsets)]
      .map((off) => wall - off * 1000)
      .filter((t) => {
        let offset = historical[0]
        for (let i = 1; i < historical.length && t >= historical[i] * 1000; i += 2)
          offset = historical[i + 1]
        return t + offset * 1000 === wall
      })
  } else {
    candidates = [...new Set(zone.offsets)]
      .map((off) => wall + Math.round(off * 60000))
      .filter((t) => t - Math.round(zone.utcOffset(t) * 60000) === wall)
  }
  candidates.sort((a, c) => a - c)
  if (!candidates.length) throw Error('This local time did not exist because the clocks changed.')
  const utc = candidates[0],
    yr = new Date(utc).getUTCFullYear(),
    start = Date.UTC(yr, 0, 1),
    end = Date.UTC(yr + 1, 0, 1)
  const angle = (2 * Math.PI * (utc - start - 43200000)) / (end - start)
  const eot =
    229.18 *
    (0.000075 +
      0.001868 * Math.cos(angle) -
      0.032077 * Math.sin(angle) -
      0.014615 * Math.cos(2 * angle) -
      0.040849 * Math.sin(2 * angle))
  const mean = utc + plusOrMinusRound(b.longitude * 240) * 1000
  return {
    utc,
    civil: wall,
    meanSolar: mean,
    apparentSolar: mean + plusOrMinusRound(eot * 60) * 1000,
    calendar: utc + 8 * 3600000,
    repeatedTime: candidates.length > 1
  }
}
function eightAt(time, sect) {
  const d = new Date(time)
  const eight = Solar.fromYmdHms(
    d.getUTCFullYear(),
    d.getUTCMonth() + 1,
    d.getUTCDate(),
    d.getUTCHours(),
    d.getUTCMinutes(),
    d.getUTCSeconds()
  )
    .getLunar()
    .getEightChar()
  eight.setSect(sect)
  return eight
}
function detail(label, ganZhi, master) {
  const [stem, branch] = ganZhi
  const hiddenStems = LunarUtil.ZHI_HIDE_GAN[branch]
  const stage =
    (LunarUtil.CHANG_SHENG_OFFSET[master] +
      (stems.indexOf(master) % 2 === 0 ? 1 : -1) * branches.indexOf(branch) +
      12) %
    12
  return {
    pillar: label,
    ganZhi,
    tenGod: label === 'Day' ? '日主' : LunarUtil.SHI_SHEN[master + stem],
    hiddenStems,
    hiddenTenGods: hiddenStems.map((s) => LunarUtil.SHI_SHEN[master + s]),
    growthStage: LunarUtil.CHANG_SHENG[stage],
    naYin: LunarUtil.NAYIN[ganZhi],
    voidBranches: LunarUtil.getXunKong(ganZhi)
  }
}
export function pattern(values) {
  if (!Array.isArray(values) || ![3, 4].includes(values.length))
    throw Error('Invalid chart pillars.')
  const counts = [0, 0, 0, 0, 0]
  for (const value of values) {
    if (
      typeof value !== 'string' ||
      value.length !== 2 ||
      !stems.includes(value[0]) ||
      !branches.includes(value[1])
    )
      throw Error('Invalid chart pillar.')
    counts[Math.floor(stems.indexOf(value[0]) / 2)]++
    counts[branchElements[branches.indexOf(value[1])]]++
  }
  return {
    values,
    counts,
    element: Math.floor(stems.indexOf(values[2][0]) / 2),
    branch: branches.indexOf(values[2][1])
  }
}
export function chart(subject, instant = new Date()) {
  const { birth, basis = 'meanSolar', sect = 2, sex = 1 } = subject
  if (
    !['civil', 'meanSolar', 'apparentSolar'].includes(basis) ||
    ![1, 2].includes(sect) ||
    ![0, 1].includes(sex)
  )
    throw Error('Check the chart convention.')
  const clock = resolveClock(birth)
  const seasonal = eightAt(clock.calendar, sect),
    daily = eightAt(clock[basis], sect)
  const values = [
    seasonal.getYear(),
    seasonal.getMonth(),
    daily.getDay(),
    ...(birth.timeKnown ? [daily.getTime()] : [])
  ]
  const master = daily.getDayGan(),
    visible = pattern(values)
  const stamped = moment(instant).tz(birth.zone)
  const transit = resolveClock({
    ...birth,
    date: stamped.format('YYYY-MM-DD'),
    hour: stamped.hour(),
    minute: stamped.minute(),
    timeKnown: true
  })
  const tc = eightAt(transit.calendar, sect),
    td = eightAt(transit[basis], sect)
  const periods = [tc.getYear(), tc.getMonth(), td.getDay()].map((x, i) =>
    detail(['year', 'month', 'today'][i], x, master)
  )
  const reading = meaning[visible.element]
  return {
    ...visible,
    subject,
    pillars: values.map((v, i) => detail(pillars[i], v, master)),
    clock,
    date: stamped.format('YYYY-MM-DD'),
    periods,
    reading,
    cycles: birth.timeKnown
      ? seasonal
          .getYun(sex, 2)
          .getDaYun(11)
          .filter((d) => d.getGanZhi())
          .map((d) => ({ ganZhi: d.getGanZhi(), start: d.getStartYear(), end: d.getEndYear() }))
      : []
  }
}
export function match(mine, p) {
  const other = pattern(p.chart.pillars)
  const totalA = mine.values.length * 2,
    totalB = other.values.length * 2
  const combined = mine.counts.map((n, i) => (n / totalA + other.counts[i] / totalB) / 2)
  const balance = Math.round(
    (-combined.reduce((s, n) => s + (n ? n * Math.log(n) : 0), 0) / Math.log(5)) * 100
  )
  const distance = Math.abs(mine.element - other.element)
  const connection = distance === 0 ? 82 : distance === 1 || distance === 4 ? 96 : 60
  const a = mine.branch,
    b = other.branch
  const union = [
    [0, 1],
    [2, 11],
    [3, 10],
    [4, 9],
    [5, 8],
    [6, 7]
  ].some(([x, y]) => (a === x && b === y) || (a === y && b === x))
  const resonance = union ? 98 : Math.abs(a - b) === 6 ? 50 : a % 4 === b % 4 ? 88 : 72
  return {
    person: p,
    other,
    balance,
    connection,
    resonance,
    score: Math.round(0.45 * balance + 0.35 * connection + 0.2 * resonance)
  }
}
export function rank(mine, people) {
  return people
    .map((p) => match(mine, p))
    .sort(
      (a, b) =>
        b.score - a.score || (a.person.id < b.person.id ? -1 : a.person.id > b.person.id ? 1 : 0)
    )
}
export function reason(mine, m, zh = false) {
  const es = zh ? cnElements : elements,
    bs = zh ? cnSigns : signs,
    o = m.other
  if (m.resonance >= 88 && m.resonance >= m.balance && m.resonance >= m.connection) {
    if (mine.branch === o.branch)
      return zh
        ? '两份命盘的日支同属' + bs[o.branch] + '。'
        : 'Both day pillars share the ' + bs[o.branch] + ' sign.'
    return zh
      ? bs[mine.branch] + '和' + bs[o.branch] + '的日支传统相合。'
      : bs[mine.branch] + ' and ' + bs[o.branch] + ' form a traditional day-sign pairing.'
  }
  if (m.connection >= 90) {
    const source = (mine.element + 1) % 5 === o.element ? mine.element : o.element
    return zh
      ? es[source] + '生' + es[(source + 1) % 5] + '，日主五行相生。'
      : es[source] + ' supports ' + es[(source + 1) % 5] + ' in these charts.'
  }
  if (m.balance >= 80)
    return zh
      ? '两份命盘相加，五行较为均衡。'
      : 'Together these charts have a balanced mix of visible elements.'
  if (m.connection >= 80)
    return zh
      ? '日主同属' + es[o.element] + '。'
      : 'Both charts share ' + es[o.element] + ' as their core element.'
  return zh
    ? es[mine.element] + '和' + es[o.element] + '构成相克关系。'
    : es[mine.element] + ' and ' + es[o.element] + ' form a contrasting pair.'
}
export function snapshot(subject, page, progress, lang, instant) {
  if (!subject) return { personalChartAvailable: false, userContext: { page, lang, progress } }
  const r = chart(subject, instant)
  return {
    natal: { calculationInput: subject, pillars: r.pillars },
    currentDate: r.date,
    currentPeriods: r.periods,
    visibleReading: r.reading[lang === 'zh' ? 1 : 0],
    userContext: { page, lang, progress }
  }
}
