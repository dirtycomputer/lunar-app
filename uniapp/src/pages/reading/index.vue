<template>
  <Frame tab="chart" :title="tr('My reading', '我的命盘')">
    <view class="stack" v-if="r">
      <view>
        <text class="subhead">
          {{ data.profile ? r.subject.name : tr('Sample chart', '示例命盘') }}
        </text>
        <text class="meta">
          {{ r.subject.birth.date.slice(0, 10) }} · {{ r.subject.birth.place }}
        </text>
        <view class="actions">
          <button class="outline" @click="openPage('edit')">
            {{ tr('Edit birth details', '编辑出生资料') }}
          </button>
          <button class="quiet" @click="tools = !tools">
            {{ tr('Chart tools', '命盘工具') }}
          </button>
        </view>
        <view class="segment">
          <button class="chip" :class="{ selected: !forecast }" @click="forecast = false">
            {{ tr('Birth chart', '本命盘') }}
          </button>
          <button class="chip" :class="{ selected: forecast }" @click="showOutlook">
            {{ tr('Recent outlook', '近期运势') }}
          </button>
        </view>
      </view>
      <view v-if="!forecast" class="split">
        <view class="panel" :style="{ backgroundColor: colors[r.element] }">
          <view class="flex">
            <text class="subhead grow">{{ tr('Reading', '个人解读') }}</text>
            <image class="smallArt" :src="art" mode="aspectFit" />
          </view>
          <text class="lead">{{ reading(r, zh) }}</text>
          <button class="quiet" @click="expanded = !expanded">
            {{ tr('Read the details', '展开解读') }}
          </button>
          <text v-if="expanded" class="body">{{ readingDetail(r, zh) }}</text>
          <view>
            <button class="outline" @click="ask">
              {{ tr('Ask about this', '就此追问') }}
            </button>
          </view>
        </view>
        <view>
          <view class="pillars">
            <view
              v-for="(v, i) in labels"
              :key="v"
              class="pillar"
              :style="{ backgroundColor: i === 2 ? colors[r.element] : 'white' }"
            >
              <text class="meta">{{ v }}</text>
              <text class="han">{{ r.values[i]?.[0] || '—' }}</text>
              <text class="han">{{ r.values[i]?.[1] || '—' }}</text>
              <text class="meta">
                {{ r.values[i] ? (zh ? cnSigns : signs)[branches.indexOf(r.values[i][1])] : '—' }}
              </text>
            </view>
          </view>
          <button class="quiet" @click="details = !details">
            {{ tr('Four pillar details', '四柱详情') }}
          </button>
          <view v-if="details" class="list">
            <view v-for="p in r.pillars" :key="p.pillar" class="listitem">
              <text>{{ p.ganZhi }} · {{ p.tenGod }} · {{ p.naYin }}</text>
              <text class="meta">
                {{ tr('Hidden stems', '藏干') }} {{ p.hiddenStems.join(' ') }} ·
                {{ p.growthStage }} · {{ tr('Void', '空亡') }} {{ p.voidBranches }}
              </text>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="panel">
        <view class="segment">
          <button
            v-for="(p, i) in r.periods"
            :key="p.pillar"
            class="chip"
            :class="{ selected: period === i }"
            @click="period = i"
          >
            {{ periodLabels[i] }}
          </button>
        </view>
        <text class="bigword">{{ r.periods[period].ganZhi }}</text>
        <text class="meta">{{ r.date }}</text>
        <text class="lead">{{ outlook(r.periods[period], zh) }}</text>
        <button class="quiet" @click="ask">
          {{ tr('Ask about this period', '追问这段运势') }}
        </button>
      </view>
      <text v-if="!r.subject.birth.timeKnown" class="meta">
        {{ tr('Birth hour unknown · three pillars', '出生时间未知，按三柱解读') }}
      </text>
      <view v-if="tools" class="panel stack">
        <text class="subhead">{{ tr('Chart tools', '命盘工具') }}</text>
        <text>{{ tr('Ten-year cycles', '十年大运') }}</text>
        <view v-for="c in r.cycles" :key="c.start">{{ c.start }}–{{ c.end }} · {{ c.ganZhi }}</view>
        <text v-if="!r.cycles.length" class="meta">
          {{ tr('A known birth time is needed for cycle dates.', '推算起运日期需要出生时间。') }}
        </text>
        <button class="outline" @click="openPage('edit', '?target=secondary')">
          {{ tr('Edit comparison chart', '编辑对照命盘') }}
        </button>
        <button class="outline" @click="openPage('tools')">
          {{ tr('Almanac, comparison and library', '历书、双盘与资料库') }}
        </button>
        <view v-if="comparison">
          <text>{{ comparison.subject.name }} · {{ comparison.values.join(' ') }}</text>
          <text class="meta">{{ reading(comparison, zh) }}</text>
        </view>
      </view>
      <view class="actions">
        <button class="outline" @click="compose('pair')">
          {{ tr('Compare with a friend', '和朋友合盘') }}
        </button>
        <button class="quiet" @click="compose('portrait')">
          {{ tr('Share my element', '分享我的元素') }}
        </button>
      </view>
    </view>
  </Frame>
</template>
<script setup>
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import Frame from '../../components/Frame.vue'
import { data, ready, tr, currentSubject, action, update } from '../../lib/store.js'
import { chart, elements, branches, signs, cnSigns } from '../../lib/chart.js'
import { reading, readingDetail, outlook } from '../../lib/reading.js'
import { openPage } from '../../lib/nav.js'
import { progress } from '../../lib/device.js'
const forecast = ref(false),
  expanded = ref(false),
  details = ref(false),
  tools = ref(false),
  period = ref(1),
  clock = ref(Date.now())
onShow(() => {
  clock.value = Date.now()
})
const r = computed(() =>
  ready.value && !data.value.resetPending ? chart(currentSubject(), new Date(clock.value)) : null
)
const comparison = computed(() =>
  data.value.studio?.secondary ? chart(data.value.studio.secondary) : null
)
const labels = computed(() => [
  tr('Year', '年'),
  tr('Month', '月'),
  tr('Day', '日'),
  tr('Hour', '时')
])
const periodLabels = computed(() => [
  tr('This year', '今年'),
  tr('This month', '本月'),
  tr('Today', '今天')
])
const zh = computed(() => /^zh/i.test(data.value.lang)),
  colors = ['#e8f3ec', '#faede8', '#faf3df', '#efedf8', '#e9f1ff']
const art = computed(() => '/static/art/' + elements[r.value.element].toLowerCase() + '.png')
function showOutlook() {
  forecast.value = true
  action(() => update((d) => progress(d.garden, 'outlook')))
}
function ask() {
  openPage(
    'agent',
    '?source=' + (forecast.value ? 'outlook' : 'reading') + '&period=' + period.value
  )
}
function compose(kind) {
  openPage('share', '?compose=' + kind)
}
</script>
<style scoped>
.lead {
  display: block;
  font-size: 18px;
  line-height: 1.55;
  margin: 12px 0;
  font-weight: 500;
}
</style>
