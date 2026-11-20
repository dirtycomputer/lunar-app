import { shallowRef, ref, computed } from 'vue'
import { catalog } from './api.js'
import { currentSubject } from './store.js'
import { chart, rank } from './chart.js'
export const people = shallowRef([]),
  loading = ref(false),
  directoryError = ref('')
export const mine = computed(() => chart(currentSubject()))
export const matches = computed(() => rank(mine.value, people.value))
let active
export async function loadPeople(refresh = false) {
  if (active) return active
  if (!refresh && people.value.length) return
  loading.value = true
  directoryError.value = ''
  active = catalog()
    .then((rows) => {
      people.value = rows
    })
    .catch((e) => {
      directoryError.value = e.message
    })
    .finally(() => {
      loading.value = false
      active = null
    })
  return active
}
