<template>
  <view class="subpage stack" v-if="ready && !data.resetPending">
    <text class="title">{{ tr('Chart tools', '命盘工具') }}</text>
    <view class="segment">
      <button
        v-for="(label, i) in labels"
        :key="label"
        class="chip"
        :class="{ selected: tab === i }"
        @click="tab = i"
      >
        {{ label }}
      </button>
    </view>
    <view v-if="tab === 0" class="stack">
      <picker
        mode="date"
        :value="date"
        start="1900-01-01"
        end="2099-12-31"
        @change="date = $event.detail.value"
      >
        <view class="picker">{{ date }}</view>
      </picker>
      <view class="panel stack">
        <text class="subhead">{{ day.lunar }}</text>
        <text>{{ day.pillar }} {{ day.term }}</text>
        <text class="label">{{ tr('Traditional activities', '传统宜项') }}</text>
        <text>{{ activity(day.yi) }}</text>
        <text class="label">{{ tr('Traditionally avoided', '传统忌项') }}</text>
        <text>{{ activity(day.ji) }}</text>
        <picker :range="hours" :value="hour" @change="hour = Number($event.detail.value)">
          <view class="picker">{{ hours[hour] }}</view>
        </picker>
        <text>{{ activity(day.hours[hour].yi) }}</text>
      </view>
    </view>
    <view v-if="tab === 1" class="stack">
      <picker
        mode="date"
        fields="year"
        start="1900"
        end="2099"
        :value="String(year)"
        @change="year = Number($event.detail.value.slice(0, 4))"
      >
        <view class="picker">{{ year }}</view>
      </picker>
      <view class="panel stack">
        <text class="subhead">{{ phases.pillar }} · {{ names[phases.element] }}</text>
        <text>
          {{ phases.excess ? tr('Excess', '太过') : tr('Insufficiency', '不及') }} ·
          {{ qi(phases.heaven) }} / {{ qi(phases.earth) }}
        </text>
        <view v-for="q in phases.periods" :key="q.start">
          <text>{{ qi(q.host) }} / {{ qi(q.guest) }}</text>
          <text class="meta">{{ q.start }} – {{ q.end }} (UTC+8)</text>
        </view>
      </view>
    </view>
    <view v-if="tab === 2" class="stack">
      <button class="outline" @click="openPage('edit', '?target=secondary')">
        {{ tr('Edit comparison chart', '编辑对照命盘') }}
      </button>
      <view v-if="second" class="panel stack">
        <view v-for="x in [first, second]" :key="x.subject.name + x.clock.utc">
          <text class="subhead">{{ x.subject.name }}</text>
          <text>{{ x.values.join(' · ') }}</text>
          <text class="meta">{{ reading(x, zh) }}</text>
        </view>
        <text>{{ reason(first, pair, zh) }} · {{ pair.score }}/100</text>
        <button class="outline" @click="openPage('agent', '?source=compare')">
          {{ tr('Ask about both charts', '追问两份命盘') }}
        </button>
      </view>
    </view>
    <view v-if="tab === 3" class="stack">
      <view class="segment">
        <button class="chip" :class="{ selected: !classic }" @click="classic = false">
          {{ tr('Glossary', '术语') }}
        </button>
        <button class="chip" :class="{ selected: classic }" @click="classic = true">
          {{ tr('Classic sources', '典籍') }}
        </button>
      </view>
      <input v-model="query" class="input" :placeholder="tr('Search the library', '搜索资料库')" />
      <view v-for="x in library" :key="x[0]" class="panel">
        <button class="quiet" @click="selected = selected === x[0] ? '' : x[0]">
          {{ x[1] }} · {{ x[2] }}
        </button>
        <view v-if="selected === x[0]" class="stack">
          <text selectable class="body">{{ x[classic ? 3 : 4] }}</text>
          <text selectable class="body">
            {{ x[classic ? (data.style === 'professional' ? 5 : 4) : 5] }}
          </text>
          <text selectable class="meta">{{ x[6] }}</text>
        </view>
      </view>
    </view>
  </view>
</template>
<script setup>
import { ref, computed } from 'vue'
import { boot, ready, data, tr, currentSubject } from '../../lib/store.js'
import { chart, match, reason, elements, cnElements } from '../../lib/chart.js'
import { reading } from '../../lib/reading.js'
import { almanac, phaseYear, qiNames } from '../../lib/almanac.js'
import { terms, passages, activities } from '../../lib/learning.js'
import { openPage } from '../../lib/nav.js'
boot()
const now = new Date()
const date = ref(
  [
    now.getFullYear(),
    String(now.getMonth() + 1).padStart(2, '0'),
    String(now.getDate()).padStart(2, '0')
  ].join('-')
)
const year = ref(now.getFullYear()),
  tab = ref(0),
  hour = ref(0),
  classic = ref(false),
  query = ref(''),
  selected = ref('')
const labels = computed(() => [
  tr('Almanac', '历书'),
  tr('Five movements', '五运六气'),
  tr('Compare', '对照'),
  tr('Library', '资料库')
])
const zh = computed(() => /^zh/i.test(data.value.lang)),
  names = computed(() => (zh.value ? cnElements : elements))
const first = computed(() => chart(currentSubject()))
const second = computed(() =>
  data.value.studio?.secondary ? chart(data.value.studio.secondary) : null
)
const pair = computed(() =>
  second.value ? match(first.value, { chart: { pillars: second.value.values } }) : null
)
const day = computed(() => almanac(date.value)),
  phases = computed(() => phaseYear(year.value))
const clock = (n) => String(n).padStart(2, '0')
const hours = computed(() =>
  day.value.hours.map((h) => clock(h.from) + ':00–' + clock(h.hour) + ':59 · ' + h.pillar)
)
const qi = (i) => qiNames[i][zh.value ? 1 : 0]
const activity = (values) => values.map((x) => (zh.value ? x : activities[x] || x)).join(' · ')
const library = computed(() =>
  (classic.value ? passages : terms).filter((x) =>
    x.slice(1, 6).join(' ').toLowerCase().includes(query.value.trim().toLowerCase())
  )
)
</script>
