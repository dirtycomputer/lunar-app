<template>
  <view class="subpage stack" v-if="ready && !data.resetPending">
    <text class="title">{{ tr('Birth details', '出生资料') }}</text>
    <view>
      <text class="label">{{ tr('Name or nickname', '姓名或昵称') }}</text>
      <input v-model="name" class="input" maxlength="30" />
      <text class="label">{{ tr('Birth date', '出生日期') }}</text>
      <picker
        mode="date"
        start="1900-01-01"
        :end="today"
        :value="birth.date"
        @change="birth.date = $event.detail.value"
      >
        <view class="picker">{{ birth.date }}</view>
      </picker>
      <text class="label">{{ tr('Birth time', '出生时间') }}</text>
      <picker v-if="birth.timeKnown" mode="time" :value="time" @change="changeTime">
        <view class="picker">{{ time }}</view>
      </picker>
      <label class="flex">
        <checkbox :checked="!birth.timeKnown" @click="birth.timeKnown = !birth.timeKnown" />
        {{ tr('I don’t know the birth time', '出生时间未知') }}
      </label>
      <text class="label">{{ tr('Birthplace', '出生地点') }}</text>
      <picker :range="locations" :value="placeIndex" @change="setPlace">
        <view class="picker">
          {{ placeIndex === places.length ? tr('Other location', '其他地点') : birth.place }}
        </view>
      </picker>
      <view v-if="placeIndex === places.length">
        <text class="label">{{ tr('Place name', '地点名称') }}</text>
        <input v-model="birth.place" class="input" />
        <text class="label">{{ tr('IANA time zone', 'IANA 时区') }}</text>
        <input v-model="birth.zone" class="input" placeholder="Asia/Shanghai" />
        <text class="label">{{ tr('Longitude (east is positive)', '经度（东经为正）') }}</text>
        <input v-model="longitude" class="input" />
      </view>
      <text class="meta">{{ birth.zone }}</text>
    </view>
    <button class="outline" @click="advanced = !advanced">
      {{ tr('Chart conventions', '排盘口径') }}
    </button>
    <view v-if="advanced">
      <text class="label">{{ tr('Clock convention', '时间口径') }}</text>
      <picker
        :range="basisLabels"
        :value="bases.indexOf(basis)"
        @change="basis = bases[$event.detail.value]"
      >
        <view class="picker">{{ basisLabels[bases.indexOf(basis)] }}</view>
      </picker>
      <text class="label">{{ tr('Start of the chart day', '日界') }}</text>
      <view class="actions">
        <button
          v-for="n in [1, 2]"
          :key="n"
          class="chip"
          :class="{ selected: sect === n }"
          @click="sect = n"
        >
          {{ n === 1 ? '23:00' : '00:00' }}
        </button>
      </view>
      <text class="label">{{ tr('Traditional fortune direction rule', '传统大运顺逆设置') }}</text>
      <view class="actions">
        <button
          v-for="n in [1, 0]"
          :key="n"
          class="chip"
          :class="{ selected: sex === n }"
          @click="sex = n"
        >
          {{ n ? tr('Male rule', '男命规则') : tr('Female rule', '女命规则') }}
        </button>
      </view>
    </view>
    <label class="flex">
      <checkbox :checked="consent" @click="consent = !consent" />
      <text>
        {{
          editing === 'secondary'
            ? tr(
                'These are adult birth details and I have permission to use them here.',
                '此资料属于成年人，我已获准在这里使用。'
              )
            : tr(
                'I am 18 or older and agree to save these details on this device.',
                '我已年满 18 岁，同意将资料保存在本机。'
              )
        }}
      </text>
    </label>
    <text v-if="error" class="error">{{ error }}</text>
    <button class="primary" @click="save">{{ tr('Save birth details', '保存出生资料') }}</button>
  </view>
</template>
<script setup>
import { ref, reactive, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { boot, data, ready, currentSubject, tr, update } from '../../lib/store.js'
import { sample, places, chart, ageOn } from '../../lib/chart.js'
import { back } from '../../lib/nav.js'
import { bindSubject } from '../../lib/conversation.js'
boot()
const editing = ref('primary'),
  name = ref(''),
  birth = reactive({ ...sample.birth }),
  longitude = ref(''),
  placeIndex = ref(0),
  advanced = ref(false),
  consent = ref(false),
  error = ref('')
const bases = ['civil', 'meanSolar', 'apparentSolar'],
  basis = ref('meanSolar'),
  sect = ref(2),
  sex = ref(1)
const basisLabels = computed(() => [
  tr('Civil time', '当地钟表时间'),
  tr('Mean solar time', '平太阳时'),
  tr('Apparent solar time', '真太阳时')
])
const today = new Date().toISOString().slice(0, 10)
const locations = computed(() => [...places.map((p) => p.place), tr('Other location', '其他地点')])
const time = computed(() =>
  [birth.hour, birth.minute].map((v) => String(v).padStart(2, '0')).join(':')
)
onLoad((q) => {
  if (!ready.value || data.value.resetPending) return
  editing.value = q.target === 'secondary' ? 'secondary' : 'primary'
  const s =
    editing.value === 'secondary' ? data.value.studio?.secondary || sample : currentSubject()
  name.value = s === sample ? '' : s.name
  Object.assign(birth, s.birth, { date: s.birth.date.slice(0, 10) })
  longitude.value = String(birth.longitude)
  basis.value = s.basis || 'meanSolar'
  sect.value = s.sect || 2
  sex.value = s.sex ?? 1
  const ix = places.findIndex((p) => p.zone === birth.zone && p.longitude === birth.longitude)
  placeIndex.value = ix < 0 ? places.length : ix
})
function changeTime(e) {
  ;[birth.hour, birth.minute] = e.detail.value.split(':').map(Number)
}
function setPlace(e) {
  placeIndex.value = Number(e.detail.value)
  const p = places[placeIndex.value]
  if (p) {
    Object.assign(birth, p)
    longitude.value = String(p.longitude)
  }
}
function save() {
  try {
    const n = name.value.trim()
    if (!n || !birth.place.trim() || !longitude.value.trim())
      throw Error(tr('Enter a name and birthplace.', '请填写昵称和出生地。'))
    if (!consent.value || ageOn(birth.date) < 18)
      throw Error(
        tr('An adult profile and consent are required.', '请确认资料为成年人并同意保存。')
      )
    const b = {
      date: birth.date,
      timeKnown: birth.timeKnown,
      hour: birth.hour,
      minute: birth.minute,
      place: birth.place.trim(),
      zone: birth.zone.trim(),
      longitude: Number(longitude.value)
    }
    const s = { name: n, birth: b, sect: sect.value, sex: sex.value, basis: basis.value }
    chart(s)
    update((d) => {
      if (!d.studio)
        d.studio = { primary: d.profile ? { ...sample, ...d.profile } : sample, secondary: null }
      d.studio[editing.value] = s
      if (editing.value === 'primary') d.profile = { name: n, birth: b }
      d.consents.push('local-adult@1@' + new Date().toISOString())
    })
    if (editing.value === 'primary') bindSubject(s)
    back()
  } catch (e) {
    error.value = e.message
  }
}
</script>
