import { update, data, tr, say } from './store.js'
export const pages = {
  chart: 'reading',
  match: 'matches',
  agent: 'agent',
  garden: 'garden',
  settings: 'settings',
  home: 'home'
}
export function navigate(section, options = '') {
  const path = pages[section] || section
  try {
    if (['chart', 'match', 'agent'].includes(section))
      update((s) => {
        s.intent = section
      })
    uni.reLaunch({
      url: '/pages/' + path + '/index' + options,
      fail: () => say(tr('Could not open this page.', '页面打开失败。'))
    })
  } catch (e) {
    say(e.message)
  }
}
export function openPage(page, query = '') {
  uni.navigateTo({ url: '/pages/' + page + '/index' + query })
}
export function back() {
  if (getCurrentPages().length > 1) uni.navigateBack()
  else navigate(data.value.intent || 'home')
}
