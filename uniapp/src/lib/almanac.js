import calendar from 'lunar-javascript'
import { branches, stems } from './chart.js'
const { Solar } = calendar
const boundaries = ['大寒', '春分', '小满', '大暑', '秋分', '小雪', '大寒']
export const qiNames = [
  ['Jueyin · Wind wood', '厥阴风木'],
  ['Shaoyin · Sovereign fire', '少阴君火'],
  ['Taiyin · Damp earth', '太阴湿土'],
  ['Shaoyang · Minister fire', '少阳相火'],
  ['Yangming · Dry metal', '阳明燥金'],
  ['Taiyang · Cold water', '太阳寒水']
]
function term(year, name) {
  for (const month of [6, 1]) {
    const date = Solar.fromYmd(year, month, 1).getLunar().getJieQiTable()[name]
    if (date && date.getYear() === year) return date.toYmdHms()
  }
  throw Error('Solar term unavailable.')
}
export function phaseYear(year) {
  const pillar = Solar.fromYmd(year, 7, 1).getLunar().getYearInGanZhiExact()
  const stem = stems.indexOf(pillar[0]),
    heaven = (branches.indexOf(pillar[1]) + 1) % 6
  const periods = boundaries.slice(0, -1).map((key, i) => ({
    host: [0, 1, 3, 2, 4, 5][i],
    guest: (heaven + i + 4) % 6,
    start: term(year, key),
    end: term(i === 5 ? year + 1 : year, boundaries[i + 1])
  }))
  return {
    pillar,
    element: [2, 3, 4, 0, 1][stem % 5],
    excess: stem % 2 === 0,
    heaven,
    earth: (heaven + 3) % 6,
    periods
  }
}
export function almanac(date) {
  const [year, month, day] = date.split('-').map(Number)
  const lunar = Solar.fromYmd(year, month, day).getLunar()
  const hours = [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 23].map((hour) => {
    const l = Solar.fromYmdHms(year, month, day, hour, 0, 0).getLunar()
    return {
      hour,
      from: hour === 23 ? 23 : Math.max(0, hour - 1),
      pillar: l.getTimeInGanZhi(),
      yi: l.getTimeYi(),
      ji: l.getTimeJi()
    }
  })
  return {
    lunar:
      lunar.getYearInChinese() + '年 ' + lunar.getMonthInChinese() + '月' + lunar.getDayInChinese(),
    term: lunar.getJieQi(),
    pillar: lunar.getDayInGanZhi(),
    yi: lunar.getDayYi(),
    ji: lunar.getDayJi(),
    hours
  }
}
