<template>
  <Frame tab="garden" :title="tr('Element garden', '五行花园')">
    <view class="stack">
      <view class="map">
        <image class="land" src="/static/art/garden.png" mode="scaleToFill" />
        <button
          v-for="(name, i) in elements"
          :key="name"
          class="habitat"
          :style="{ left: coords[i][0] + '%', top: coords[i][1] + '%' }"
          :aria-label="names[i]"
          @click="selected = i"
        >
          <image :src="art(i)" mode="aspectFit" />
          <text>{{ names[i] }}{{ seals.includes(name.toLowerCase()) ? ' ✓' : '' }}</text>
        </button>
      </view>
      <view class="panel">
        <view class="flex">
          <image class="smallArt" :src="art(selected)" />
          <view>
            <text class="subhead">{{ names[selected] }}</text>
            <text>{{ meaning[selected][zh ? 1 : 0] }}</text>
          </view>
        </view>
        <text class="meta">
          {{ names[(selected + 4) % 5] }} → {{ names[selected] }} → {{ names[(selected + 1) % 5] }}
        </text>
      </view>
      <view class="panel">
        <text class="subhead">{{ tr('Light the generating cycle', '点亮相生循环') }}</text>
        <text class="body">
          {{
            steps === 5
              ? tr('All five elements are connected.', '五行相生循环已点亮。')
              : tr('Which element does ', '哪个五行受到') +
                names[current] +
                tr(' support?', '的滋养？')
          }}
        </text>
        <text class="meta">
          {{ steps }}/5 · {{ data.garden.completed.length * 20 }} {{ tr('sparks', '火花') }}
        </text>
        <view v-if="steps < 5" class="segment">
          <button v-for="(n, i) in names" :key="n" class="chip" @click="choose(i)">
            {{ n }}
          </button>
        </view>
        <button v-else class="quiet" @click="restart">
          {{ tr('Practice again', '重新练习') }}
        </button>
        <text v-if="feedback" class="body" aria-live="polite">{{ feedback }}</text>
        <text v-if="cycle && cycle.seed !== seed" class="meta">
          {{ tr('Continuing your earlier cycle', '正在继续上次的循环') }}
        </text>
      </view>
      <view class="actions">
        <button class="outline" @click="navigate('chart')">{{ tr('My reading', '看自己') }}</button>
        <button class="outline" @click="navigate('match')">
          {{ tr('Explore a match', '探索匹配') }}
        </button>
      </view>
    </view>
  </Frame>
</template>
<script setup>
import { computed, ref } from 'vue'
import Frame from '../../components/Frame.vue'
import { boot, data, tr, currentSubject, update, action } from '../../lib/store.js'
import { elements, cnElements, meaning, chart } from '../../lib/chart.js'
import { stepGarden } from '../../lib/device.js'
import { navigate } from '../../lib/nav.js'
boot()
const selected = ref(0),
  feedback = ref(''),
  coords = [
    [22, 32],
    [63, 22],
    [80, 57],
    [56, 80],
    [20, 72]
  ]
const zh = computed(() => /^zh/i.test(data.value.lang)),
  names = computed(() => (zh.value ? cnElements : elements)),
  seals = computed(() => data.value.garden.seals)
const seed = computed(() => elements[chart(currentSubject()).element].toLowerCase())
const cycle = computed(() => data.value.garden.cycle),
  steps = computed(() => cycle.value?.steps || 0)
const current = computed(
  () =>
    (elements.map((e) => e.toLowerCase()).indexOf(cycle.value?.seed || seed.value) + steps.value) %
    5
)
const art = (i) => '/static/art/' + elements[i].toLowerCase() + '.png'
function choose(i) {
  action(() => {
    const from = current.value
    let ok
    update((s) => {
      ok = stepGarden(s.garden, seed.value, i)
    })
    feedback.value = ok
      ? names.value[from] + tr(' supports ', '生') + names.value[i]
      : tr('Try the next link in the cycle.', '再试试循环中的下一步。')
    if (ok) selected.value = i
  })
}
function restart() {
  action(() =>
    update((s) => {
      s.garden.cycle = { seed: seed.value, steps: 0 }
    })
  )
  feedback.value = ''
}
</script>
<style scoped>
.map {
  position: relative;
  aspect-ratio: 16/9;
  background: #e7f2e8;
  border-radius: 23px;
  overflow: hidden;
  min-height: 195px;
}
.land {
  width: 100%;
  height: 100%;
  position: absolute;
}
.habitat {
  position: absolute;
  transform: translate(-50%, -50%);
  display: flex;
  flex-direction: column;
  background: transparent;
  padding: 0;
  min-width: 44px;
}
.habitat image {
  width: clamp(35px, 6vw, 80px);
  height: clamp(35px, 6vw, 80px);
}
.habitat text {
  background: #fff;
  border-radius: 12px;
  padding: 1px 8px;
  font-size: 14px;
}
</style>
