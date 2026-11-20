import { elements, cnElements, stems } from './chart.js'
const themes = {
  正官: ['commitments and responsibility', '承诺与责任'],
  七杀: ['initiative under pressure', '压力下的行动'],
  偏官: ['initiative under pressure', '压力下的行动'],
  正印: ['study and support', '学习与支持'],
  偏印: ['independent learning', '独立探索'],
  正财: ['steady resources and practical choices', '稳定的资源与务实选择'],
  偏财: ['opportunities and the exchange of resources', '机会与资源流动'],
  比肩: ['independence and peers', '独立与同伴'],
  劫财: ['shared effort and competing needs', '协作与不同需求'],
  食神: ['creative expression and everyday enjoyment', '创作与日常乐趣'],
  伤官: ['expression and questioning conventions', '表达与思考惯例']
}
export function theme(god, zh) {
  return (themes[god] || ['the day master and its surroundings', '日主与环境的关系'])[zh ? 1 : 0]
}
export function reading(r, zh = false) {
  const god = r.pillars[1].tenGod
  return zh
    ? '这份命盘的月干与日主构成' + god + '。按传统十神解读，可以关注' + theme(god, true) + '。'
    : 'Your month pillar points to ' + theme(god, false) + ' in the traditional Ten Gods reading.'
}
export function readingDetail(r, zh = false) {
  const e = (zh ? cnElements : elements)[r.element],
    m = r.pillars[2].ganZhi[0],
    top = Math.max(...r.counts)
  const common = (zh ? cnElements : elements)
    .filter((_, i) => r.counts[i] === top)
    .join(zh ? '、' : ' and ')
  return zh
    ? '日主为' +
        m +
        '，属' +
        e +
        '。可见干支里，' +
        common +
        '出现最多（' +
        top +
        '次）。季节也会影响五行强弱。'
    : 'Your day master is ' +
        m +
        ' (' +
        e +
        '). ' +
        common +
        ' appears most often among the visible stems and branches (' +
        top +
        ' occurrences). Its seasonal strength also depends on the time of year.'
}
export function outlook(p, zh = false) {
  return zh
    ? '这段时间的干支为' +
        p.ganZhi +
        '，与日主的关系是' +
        p.tenGod +
        '。可以留意' +
        theme(p.tenGod, true) +
        '。'
    : 'The ' +
        p.ganZhi +
        ' period brings the traditional theme of ' +
        theme(p.tenGod, false) +
        '. Its stem relates to your day master as ' +
        p.tenGod +
        '.'
}
