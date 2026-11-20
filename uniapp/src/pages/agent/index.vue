<template>
  <Frame tab="agent" :title="tr('Ask Agent', '问一问')">
    <view class="conversation stack">
      <text v-if="subject && !data.profile" class="meta">{{ tr('Sample chart', '示例命盘') }}</text>
      <button v-if="source" class="quiet" @click="back">{{ tr('Back', '返回') }}</button>
      <view v-for="(t, i) in turns" :key="i" class="message" :class="{ mine: t.role === 'user' }">
        <text class="meta">{{ t.role === 'user' ? tr('You', '你') : 'AI · DeepSeek' }}</text>
        <text selectable class="body">{{ t.content }}</text>
      </view>
      <view v-if="failure" class="panel">
        <text class="error">{{ failure }}</text>
        <text class="meta">{{ tr('On-device reference', '本地参考') }}</text>
        <text class="body">{{ reference }}</text>
      </view>
      <view v-if="!turns.length" class="actions">
        <button v-for="q in suggestions" :key="q" class="outline" @click="question = q">
          {{ q }}
        </button>
      </view>
      <textarea
        v-model="question"
        maxlength="-1"
        class="input textarea"
        :placeholder="tr('Ask about your chart', '询问你的命盘')"
      />
      <label class="flex">
        <checkbox :checked="ok" @click="ok = !ok" />
        <text class="meta">
          {{
            tr(
              'I agree to send my question, birth profile, active charts and conversation to the chart service and DeepSeek.',
              '我同意将问题、出生资料、当前涉及的命盘和本次对话发送给排盘服务与 DeepSeek。'
            )
          }}
        </text>
      </label>
      <view class="actions">
        <button class="primary" :disabled="busy || !ok || !question.trim()" @click="submit">
          {{ tr('Ask', '提问') }}
        </button>
        <button v-if="busy" @click="stop">{{ tr('Stop', '停止') }}</button>
        <button v-if="failed && !busy" :disabled="!ok" @click="send(failed, true)">
          {{ tr('Retry question', '重试问题') }}
        </button>
        <button v-if="turns.length" class="quiet" @click="clearConversation">
          {{ tr('New conversation', '新对话') }}
        </button>
      </view>
      <text v-if="busy" class="meta">
        {{ tr('Verifying the chart and preparing your reading…', '正在校核排盘并撰写解读…') }}
      </text>
    </view>
  </Frame>
</template>
<script setup>
import { computed, ref } from 'vue'
import { onLoad, onShow, onUnload } from '@dcloudio/uni-app'
import Frame from '../../components/Frame.vue'
import { data, boot, currentSubject, ready, tr, say } from '../../lib/store.js'
import { snapshot, chart } from '../../lib/chart.js'
import { reading, outlook } from '../../lib/reading.js'
import { back } from '../../lib/nav.js'
import {
  turns,
  busy,
  failed,
  failure,
  clearConversation,
  stop,
  send,
  bindSubject,
  prepareQuestion
} from '../../lib/conversation.js'
boot()
const source = ref(''),
  period = ref(1),
  question = ref(''),
  ok = ref(false)
const subject = computed(() =>
  data.value.profile || ['reading', 'outlook', 'compare'].includes(source.value)
    ? currentSubject()
    : null
)
const zh = computed(() => /^zh/i.test(data.value.lang))
const suggestions = computed(() => [
  tr('What stands out in my chart?', '我的命盘有什么特点？'),
  tr('What should I reflect on this month?', '本月可以关注什么？')
])
const reference = computed(() =>
  subject.value
    ? reading(chart(subject.value), zh.value)
    : tr('A personal reading starts with your birth details.', '填写出生资料后可生成个人解读。')
)
onLoad((q) => {
  source.value = q.source || ''
  period.value = [0, 1, 2].includes(Number(q.period)) ? Number(q.period) : 1
  if (source.value)
    question.value = source.value === 'outlook' ? suggestions.value[1] : suggestions.value[0]
})
onShow(() => bindSubject(subject.value))
onUnload(() => {
  if (busy.value) stop()
})
function submit() {
  if (!ready.value || busy.value || !ok.value || !question.value.trim()) return
  try {
    const lang = zh.value ? 'zh' : 'en',
      evidence = snapshot(subject.value, source.value || 'agent', data.value.garden, lang)
    if (subject.value) {
      const r = chart(subject.value)
      evidence.visibleReading =
        source.value === 'outlook'
          ? outlook(r.periods[period.value], zh.value)
          : reading(r, zh.value)
      evidence.userContext.period = ['year', 'month', 'today'][period.value]
      evidence.userContext.style = data.value.style
      evidence.userContext.sampleChart = !data.value.profile
    }
    if (source.value === 'compare' && data.value.studio?.secondary) {
      const b = data.value.studio.secondary
      const secondary = chart(b)
      evidence.comparison = { calculationInput: b, pillars: secondary.pillars }
      evidence.userContext.comparisonReading = reading(secondary, zh.value)
    }
    const p = prepareQuestion(question.value.trim(), evidence, lang)
    question.value = ''
    send(p)
  } catch (e) {
    say(e.message)
  }
}
</script>
<style scoped>
.conversation {
  max-width: 760px;
}
.message {
  background: white;
  border-radius: 18px;
  padding: 14px 18px;
}
.message.mine {
  background: #e9f1ff;
}
.message .body {
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
</style>
