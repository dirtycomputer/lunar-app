<template>
  <view class="portrait" :style="{ background: colors[p.element] }">
    <view class="flex">
      <image src="/static/art/flower.png" class="flower" />
      <text>FatePair</text>
    </view>
    <view class="flex">
      <view class="grow">
        <text class="body">{{ p.name }}</text>
        <text class="bigword" :style="{ color: elementColors[p.element] }">
          {{ names[p.element] }}
        </text>
      </view>
      <image class="spirit" :src="'/static/art/' + elements[p.element].toLowerCase() + '.png'" />
    </view>
    <text v-for="n in p.traits" :key="n" class="body">{{ traitText(p.element, n, zh) }}</text>
    <view v-if="p.counts">
      <view class="bar">
        <view
          v-for="(n, i) in p.counts"
          :key="i"
          :style="{ flex: n, background: elementColors[i] }"
        />
      </view>
      <view class="counts">
        <text v-for="(n, i) in p.counts" :key="i">{{ names[i] }} {{ n }}</text>
      </view>
      <text v-if="p.counts.reduce((a, b) => a + b, 0) === 6" class="meta">
        {{ tr('Birth hour unknown · three pillars', '出生时辰未知，按三柱') }}
      </text>
    </view>
  </view>
</template>
<script setup>
import { computed } from 'vue'
import { elements, cnElements, elementColors } from '../lib/chart.js'
import { traitText } from '../lib/portrait.js'
import { data, tr } from '../lib/store.js'
defineProps({ p: { type: Object, required: true } })
const colors = ['#e8f3ec', '#faede8', '#faf3df', '#efedf8', '#e9f1ff'],
  zh = computed(() => /^zh/i.test(data.value.lang)),
  names = computed(() => (zh.value ? cnElements : elements))
</script>
<style scoped>
.portrait {
  border-radius: 22px;
  padding: 22px;
  display: flex;
  flex-direction: column;
  gap: 9px;
}
.flower {
  width: 21px;
  height: 21px;
}
.spirit {
  width: 84px;
  height: 84px;
}
.bar {
  display: flex;
  height: 7px;
  border-radius: 6px;
  overflow: hidden;
  margin: 10px 0;
}
.counts {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  font-size: 14px;
}
</style>
