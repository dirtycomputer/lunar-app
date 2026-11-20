<template>
  <Frame tab="match" :title="tr('Match', '找匹配')">
    <view class="segment">
      <button
        v-for="(v, i) in tabs"
        :key="v"
        class="chip"
        :class="{ selected: tab === i }"
        @click="tab = i"
      >
        {{ v }}
      </button>
    </view>
    <view class="actions search">
      <input
        v-model="query"
        class="input grow"
        :placeholder="tr('Search people, places or interests', '搜索人物、地点或兴趣')"
        @input="limit = 20"
      />
      <button v-if="!tab" class="primary" :disabled="!filtered.length" @click="random">
        {{ tr('Random match', '随机匹配') }}
      </button>
      <button class="outline" @click="filters = !filters">
        {{ tr('Filters', '筛选') }}
      </button>
    </view>
    <view v-if="filters" class="panel">
      <text class="label">{{ tr('Country', '国家或地区') }}</text>
      <picker
        :range="countries"
        :value="countries.indexOf(country)"
        @change="country = countries[$event.detail.value]"
      >
        <view class="picker">{{ country || tr('Worldwide', '全球') }}</view>
      </picker>
      <text class="label">{{ tr('Gender', '性别') }}</text>
      <view class="segment">
        <button
          v-for="g in genders"
          :key="g"
          class="chip"
          :class="{ selected: gender === g }"
          @click="gender = g"
        >
          {{ g }}
        </button>
      </view>
      <view class="flex">
        <view class="grow">
          <text class="label">{{ tr('Minimum age', '最低年龄') }}</text>
          <input v-model="minAge" class="input" type="number" />
        </view>
        <view class="grow">
          <text class="label">{{ tr('Maximum age', '最高年龄') }}</text>
          <input v-model="maxAge" class="input" type="number" />
        </view>
      </view>
      <text class="label">{{ tr('Minimum chart score', '最低匹配分') }} {{ minimum }}/100</text>
      <slider
        :value="minimum"
        :max="100"
        activeColor="#245acb"
        @change="minimum = $event.detail.value"
      />
      <button class="quiet" @click="reset">{{ tr('Reset filters', '重置筛选') }}</button>
    </view>
    <view class="actions">
      <text class="meta">
        {{ tr('Fictional profiles', '虚构示例人物') }} · {{ filtered.length }}
      </text>
      <button v-if="!data.profile" class="quiet" @click="openPage('edit')">
        {{ tr('Using sample chart · Personalize', '当前使用示例命盘 · 换成我的') }}
      </button>
    </view>
    <view v-if="directoryError" class="error">
      {{ directoryError }}
      <button @click="loadPeople(true)">{{ tr('Retry', '重试') }}</button>
    </view>
    <text v-if="loading && !people.length" class="meta">
      {{ tr('Loading people…', '正在载入人物…') }}
    </text>
    <text v-if="!loading && !directoryError && !filtered.length" class="meta">
      {{ tr('No profiles match this view.', '当前筛选范围内没有人物。') }}
    </text>
    <view class="list">
      <view v-for="m in visible" :key="m.person.id" class="listitem record">
        <button class="identity" @click="open(m)">
          <view class="initials" :style="{ background: palette[m.other.element] }">
            {{ initials(m.person.name) }}
          </view>
          <view class="grow">
            <text class="name">{{ m.person.name }}, {{ ageOn(m.person.birth.date) }}</text>
            <text class="meta">{{ m.person.location }}</text>
          </view>
        </button>
        <button class="why" @click="open(m)">{{ reason(mine, m, zh) }}</button>
        <text class="score">{{ tr('Chart score', '命盘匹配分') }} {{ m.score }}/100</text>
        <button
          class="heart"
          :aria-label="tr('Save or unsave', '收藏或取消收藏') + ' ' + m.person.name"
          @click="save(m.person.id)"
        >
          {{ data.saved.includes(m.person.id) ? '♥' : '♡' }}
        </button>
      </view>
    </view>
    <view v-if="filtered.length > limit" class="actions">
      <button class="outline" @click="limit += 20">
        {{ tr('Show more people', '查看更多') }}
      </button>
    </view>
  </Frame>
</template>
<script setup>
import { computed, ref, watch } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import Frame from '../../components/Frame.vue'
import { data, update, tr, action } from '../../lib/store.js'
import { matches, mine, people, loadPeople, loading, directoryError } from '../../lib/directory.js'
import { ageOn, reason } from '../../lib/chart.js'
import { openPage } from '../../lib/nav.js'
import { progress } from '../../lib/device.js'
onLoad(() => loadPeople())
const tab = ref(0),
  limit = ref(20),
  filters = ref(false),
  query = ref(''),
  minAge = ref('18'),
  maxAge = ref(''),
  minimum = ref(0),
  gender = ref('Everyone'),
  country = ref('Worldwide')
const genders = ['Everyone', 'Women', 'Men', 'Non-binary'],
  palette = ['#e7f2eb', '#faece7', '#faf2db', '#f0eafd', '#e8f0ff']
const tabs = computed(() => [
  tr('People', '人物'),
  tr('Saved', '收藏'),
  tr('Invitations', '邀请'),
  tr('Drafts', '草稿')
])
watch([tab, query, minAge, maxAge, minimum, gender, country], () => {
  limit.value = 20
})
const countries = computed(() => [
  'Worldwide',
  ...new Set(people.value.map((p) => p.country).sort())
])
const zh = computed(() => /^zh/i.test(data.value.lang))
const filtered = computed(() =>
  matches.value.filter((m) => {
    const p = m.person,
      a = ageOn(p.birth.date),
      s = data.value
    return (
      !s.hidden.includes(p.id) &&
      (!tab.value ||
        [s.saved, s.social.invitations, Object.keys(s.social.threads)][tab.value - 1].includes(
          p.id
        )) &&
      (gender.value === 'Everyone' || p.gender === gender.value) &&
      (country.value === 'Worldwide' || p.country === country.value) &&
      a >= Number(minAge.value || 18) &&
      a <= Number(maxAge.value || 150) &&
      m.score >= minimum.value &&
      [p.name, p.location, p.occupation, ...p.interests]
        .join(' ')
        .toLowerCase()
        .includes(query.value.trim().toLowerCase())
    )
  })
)
const visible = computed(() => filtered.value.slice(0, limit.value))
function reset() {
  query.value = ''
  gender.value = 'Everyone'
  country.value = 'Worldwide'
  minimum.value = 0
  minAge.value = '18'
  maxAge.value = ''
  limit.value = 20
}
function initials(n) {
  return n
    .split(/\s+/)
    .slice(0, 2)
    .map((x) => x[0])
    .join('')
}
function save(id) {
  action(() =>
    update((s) => {
      s.saved = s.saved.includes(id) ? s.saved.filter((x) => x !== id) : [...s.saved, id]
    })
  )
}
function open(m) {
  action(() => {
    update((s) => progress(s.garden, 'encounter'))
    openPage('person', '?id=' + encodeURIComponent(m.person.id))
  })
}
let last
function random() {
  let pool = filtered.value
  if (pool.length > 1) pool = pool.filter((x) => x.person.id !== last)
  if (pool.length) {
    const m = pool[Math.floor(Math.random() * pool.length)]
    last = m.person.id
    open(m)
  }
}
</script>
<style scoped>
.record {
  display: grid;
  grid-template-columns: 1.05fr 1.15fr auto 44px;
  align-items: center;
  gap: 14px;
}
.identity,
.why {
  background: transparent;
  text-align: left;
  justify-content: flex-start;
  padding: 0;
  gap: 12px;
}
.why {
  font-size: 15px;
  font-weight: 400;
}
.initials {
  border-radius: 50%;
  width: 46px;
  height: 46px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.name {
  display: block;
  font-size: 17px;
  font-weight: 650;
}
.heart {
  font-size: 24px;
  background: transparent;
  color: #456287;
}
.search .input {
  min-width: 180px;
}
@media (max-width: 750px) {
  .record {
    grid-template-columns: 1fr 44px;
    gap: 4px 6px;
  }
  .identity {
    grid-row: 1;
    grid-column: 1;
  }
  .why {
    grid-row: 2;
    grid-column: 1 / -1;
    min-height: 0;
  }
  .score {
    grid-row: 3;
    grid-column: 1 / -1;
  }
  .heart {
    grid-row: 1;
    grid-column: 2;
  }
  .search .input {
    flex-basis: 100%;
  }
}
</style>
