import { ref } from 'vue'
import { modelPacket, askModel } from './api.js'
export const turns = ref([]),
  busy = ref(false),
  failure = ref(''),
  failed = ref(null)
let currentTask,
  generation = 0,
  identity = ''
export function stop() {
  generation++
  currentTask?.abort()
  currentTask = null
  busy.value = false
}
export function clearConversation() {
  stop()
  turns.value = []
  failure.value = ''
  failed.value = null
}
export function bindSubject(subject) {
  const next = JSON.stringify(subject)
  if (identity !== next) {
    clearConversation()
    identity = next
  }
}
export function prepareQuestion(question, evidence, lang) {
  const packet = modelPacket(turns.value, question, evidence, lang)
  return {
    question,
    packet,
    context: JSON.parse(packet.messages[packet.messages.length - 1].content)
  }
}
export async function send(prepared, retry = false) {
  if (busy.value) return
  const ticket = ++generation
  if (!retry)
    turns.value.push({ role: 'user', content: prepared.question, packet: prepared.context })
  busy.value = true
  failure.value = ''
  failed.value = prepared
  try {
    currentTask = askModel(prepared.packet)
    const answer = await currentTask
    if (ticket !== generation) return
    const content = answer?.choices?.[0]?.message?.content
    if (!content) throw Error('No response received.')
    turns.value.push({ role: 'assistant', content })
    failed.value = null
  } catch (e) {
    if (ticket === generation) failure.value = e.message
  } finally {
    if (ticket === generation) {
      currentTask = null
      busy.value = false
    }
  }
}
