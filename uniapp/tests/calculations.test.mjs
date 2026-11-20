import test from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
import { createHash } from 'node:crypto'
import { chart, resolveClock, rank, sample } from '../src/lib/chart.js'
import { phaseYear, almanac } from '../src/lib/almanac.js'

const read = (file) => JSON.parse(readFileSync(new URL(file, import.meta.url)))
const fixtures = read('../../server/tests/fixtures/charts.json')
const people = read('../../catalog/seed.json').people.map((row) => row.profile)
const at = new Date('2026-11-20T06:30:00Z')
test('every independent server fixture agrees on the instant and detailed pillars', () => {
  for (const row of fixtures) {
    const result = chart(row.subject, at)
    assert.equal(result.clock.utc, Date.parse(row.expectedUtc), row.subject.name)
    assert.deepEqual(result.pillars, row.expectedPillars, row.subject.name)
  }
})
test('all saved database birth instants, solar clocks and pillars survive migration', () => {
  assert.equal(people.length, 1000)
  for (const person of people) {
    const result = chart(
      { birth: person.birth, basis: person.chart.basis, sect: person.chart.sect },
      at
    )
    assert.deepEqual(result.values, person.chart.pillars, person.id)
    assert.equal(result.clock.utc, Date.parse(person.chart.clock.utc), person.id)
    assert.equal(
      new Date(result.clock.meanSolar).toISOString().slice(0, 19),
      person.chart.solarTime,
      person.id
    )
  }
})
test('21,000 ranked entries retain the original Dart scores, three factors and tie order', () => {
  const rankings = [sample, ...fixtures.map((f) => f.subject)].map((subject) =>
    rank(chart(subject, at), people).map((m) => [
      m.person.id,
      m.score,
      m.balance,
      m.connection,
      m.resonance
    ])
  )
  const digest = createHash('sha256').update(JSON.stringify(rankings)).digest('hex')
  assert.equal(digest, '3d5276fa6b9e3ed6c1356c6fbecd34a5c50207460b905a2c3eec724b019b6199')
})
test('clock-change gaps reject the input and repeated clocks select the earlier instant', () => {
  const b = {
    ...sample.birth,
    zone: 'America/New_York',
    longitude: -74,
    hour: 2,
    minute: 30,
    date: '2024-03-10'
  }
  assert.throws(() => resolveClock(b), /did not exist/)
  const repeated = resolveClock({ ...b, hour: 1, date: '2024-11-03' })
  assert.equal(repeated.repeatedTime, true)
  assert.equal(new Date(repeated.utc).toISOString(), '2024-11-03T05:30:00.000Z')
})
test('calendar tools retain leap months, the separate late Rat hour and six consecutive Qi periods', () => {
  const day = almanac('2023-03-25')
  assert.match(day.lunar, /闰二月|閏二月/)
  assert.equal(day.hours.length, 13)
  assert.equal(day.hours.at(-1).from, 23)
  const y = phaseYear(2024)
  assert.equal(y.pillar, '甲辰')
  assert.equal(y.element, 2)
  assert.equal(y.periods.length, 6)
  for (let i = 1; i < 6; i++) assert.equal(y.periods[i - 1].end, y.periods[i].start)
  assert.match(y.periods[5].end, /^2025-01/)
})
