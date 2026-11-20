<template>
  <view class="subpage stack">
    <button v-if="returnHome" class="quiet" @click="navigate('home', '?choose=1')">
      {{ tr('FatePair home', '首页') }}
    </button>
    <text class="title">{{ title }}</text>
    <text v-if="error" class="error">{{ error }}</text>
    <view v-if="!ready || data.resetPending">
      <button class="outline" @click="navigate('settings')">
        {{ tr('Open settings', '打开设置') }}
      </button>
    </view>
    <view v-else-if="mode === 'manage'" class="stack">
      <text v-if="!data.links.length" class="meta">
        {{ tr('No shared links on this device.', '本机还没有分享。') }}
      </text>
      <view v-for="e in data.links" :key="e.id" class="panel">
        <text>
          {{ e.portrait.name }} ·
          {{
            e.kind === 'pair' ? tr('Friend comparison', '好友合盘') : tr('Element card', '五行卡')
          }}
        </text>
        <text class="meta">{{ dateLabel(e.expiresAt) }}</text>
        <view class="actions">
          <button class="outline" :disabled="busy" @click="openSaved(e)">
            {{ e.pending ? tr('Retry', '重试') : tr('Open', '查看') }}
          </button>
          <button class="quiet danger" :disabled="busy" @click="remove(e)">
            {{ tr('Withdraw', '撤回') }}
          </button>
        </view>
      </view>
    </view>
    <view v-else-if="mode === 'compose' || review" class="stack">
      <view v-if="!data.profile">
        <button class="primary" @click="openPage('edit')">
          {{ tr('Add my birth details', '填写出生资料') }}
        </button>
      </view>
      <view v-else class="stack">
        <Portrait :p="candidate" />
        <text class="label">{{ tr('Nickname on the card', '卡片昵称') }}</text>
        <input v-model="nickname" :disabled="busy" class="input" maxlength="30" />
        <text class="label">{{ tr('Choose up to two reflections', '最多选两条特点') }}</text>
        <view class="segment">
          <button
            v-for="n in [0, 1, 2]"
            :key="n"
            class="chip"
            :class="{ selected: selected.includes(n) }"
            :disabled="busy || (!selected.includes(n) && selected.length >= 2)"
            @click="toggle(n)"
          >
            {{ traitText(candidate.element, n, zh) }}
          </button>
        </view>
        <text class="body">
          {{
            review
              ? tr(
                  'Your friend will see the card above in your shared result.',
                  '朋友将在共同结果里看到上面的卡片。'
                )
              : tr(
                  'Anyone with the link can see this card. A comparison accepts one friend. Links expire after seven days.',
                  '获得链接的人可见这张卡片。每条合盘邀请只接受一位朋友，链接七天后到期。'
                )
          }}
        </text>
        <text class="meta">
          {{
            tr(
              'Birth details and conversations stay off the card. You can withdraw your link and result in My shared links. Images already shared remain with their recipients.',
              '卡片不含具体出生资料和对话。可在「我的分享」撤回链接和结果，已分享的图片仍由收件人保留。'
            )
          }}
        </text>
        <label class="flex">
          <checkbox :checked="agreed" :disabled="busy" @click="!busy && (agreed = !agreed)" />
          {{ tr('I agree to share this card', '我同意分享这张卡片') }}
        </label>
        <button class="primary" :disabled="busy || !agreed || !nickname.trim()" @click="submit">
          {{ review ? tr('See our result', '查看共同结果') : tr('Create link', '创建链接') }}
        </button>
        <button v-if="review" class="quiet" @click="openPage('edit')">
          {{ tr('Edit my birth details', '修改出生资料') }}
        </button>
        <button v-if="error" class="outline" @click="manage">
          {{ tr('My shared links / retry', '管理分享或重试') }}
        </button>
      </view>
    </view>
    <view v-else-if="link" class="stack">
      <view v-if="link.result" class="stack">
        <view class="pair">
          <image :src="art(link.result.host.element)" />
          <image :src="art(link.result.guest.element)" />
        </view>
        <text class="subhead">{{ link.result.host.name }} &amp; {{ link.result.guest.name }}</text>
        <view v-for="block in resultBlocks" :key="block[0]">
          <text class="subhead">{{ block[0] }}</text>
          <text class="body" selectable>{{ block[1] }}</text>
        </view>
        <text v-if="link.result.unknownTime" class="meta">
          {{ tr('At least one birth hour is unknown.', '至少有一位参与者的出生时辰未知。') }}
        </text>
        <button class="primary" @click="navigate('chart')">
          {{ tr('My full reading', '看我的解读') }}
        </button>
        <button class="outline" @click="onward">
          {{ tr('Compare with another friend', '邀请另一位朋友') }}
        </button>
      </view>
      <view v-else class="stack">
        <Portrait :p="link.portrait" />
        <view v-if="owner" class="stack">
          <text v-if="link.kind === 'pair'">
            {{ tr('Waiting for your friend', '等待朋友加入') }}
          </text>
          <!-- #ifdef MP-WEIXIN -->
          <button class="primary" open-type="share">
            {{ tr('Send to a friend', '发给微信好友') }}
          </button>
          <!-- #endif -->
          <!-- #ifndef MP-WEIXIN -->
          <button class="primary" @click="shareSystem">{{ tr('Share link', '分享链接') }}</button>
          <!-- #endif -->
          <button class="outline" @click="copyLink">{{ tr('Copy link', '复制链接') }}</button>
          <button class="quiet" @click="imageCard">
            {{ tr('Save or share card image', '保存或分享卡片图片') }}
          </button>
          <text selectable class="meta">{{ linkUrl(id) }}</text>
          <button v-if="link.kind === 'pair'" class="quiet" @click="load">
            {{ tr('Check for reply', '查看回复') }}
          </button>
        </view>
        <view v-else-if="link.kind === 'pair' && link.status === 'open'" class="stack">
          <button class="primary" @click="join">
            {{
              data.profile
                ? tr('Preview my card', '预览我的卡片')
                : tr('Add my birth details', '填写出生资料')
            }}
          </button>
          <text class="meta">
            {{ tr('Preview your card before sharing.', '分享前可先预览自己的卡片。') }}
          </text>
        </view>
        <text v-else-if="link.kind === 'pair'">
          {{ tr('This invitation has already been joined.', '此邀请已有朋友参与。') }}
        </text>
        <button v-else class="primary" @click="goReading">
          {{ tr('Discover my element', '探索我的五行') }}
        </button>
      </view>
      <text class="meta">
        {{ tr('Available until ', '有效至 ') }}{{ dateLabel(link.expiresAt * 1000) }}
      </text>
      <button v-if="entry" class="quiet danger" @click="remove(entry)">
        {{ tr('Withdraw link and result', '撤回链接与结果') }}
      </button>
    </view>
    <button v-else-if="error && id" class="outline" @click="load">{{ tr('Retry', '重试') }}</button>
    <text v-else-if="loading" class="meta">{{ tr('Opening invitation…', '正在打开邀请…') }}</text>
    <canvas v-if="owner" canvas-id="portraitExport" id="portraitExport" class="exportcanvas" />
  </view>
</template>
<script setup>
import { ref, computed, watch, getCurrentInstance } from 'vue'
import { onLoad, onShow, onHide, onUnload, onShareAppMessage } from '@dcloudio/uni-app'
import Portrait from '../../components/Portrait.vue'
import {
  data,
  ready,
  boot,
  tr,
  say,
  currentSubject,
  saveShare,
  portraitFrom,
  linkUrl,
  withdraw,
  retryEntry
} from '../../lib/store.js'
import { elements, chart, elementColors } from '../../lib/chart.js'
import { isToken } from '../../lib/device.js'
import { shareRequest } from '../../lib/api.js'
import { openPage, navigate } from '../../lib/nav.js'
import { traitText } from '../../lib/portrait.js'
boot()
const vm = getCurrentInstance()?.proxy,
  mode = ref('open'),
  id = ref(''),
  kind = ref('pair'),
  parentId = ref(''),
  link = ref(null),
  selected = ref([0, 1]),
  nickname = ref('')
const agreed = ref(false),
  review = ref(false),
  busy = ref(false),
  loading = ref(false),
  error = ref(''),
  returnHome = ref(false)
const zh = computed(() => /^zh/i.test(data.value.lang)),
  entry = computed(() => data.value.links.find((e) => e.id === id.value)),
  owner = computed(() => entry.value?.role === 'owner')
const candidate = computed(() =>
  portraitFrom(
    chart(currentSubject()),
    nickname.value.trim() || tr('You', '你'),
    review.value ? 'pair' : kind.value,
    selected.value
  )
)
const resultBlocks = computed(() => {
  const r = link.value?.result
  return r
    ? [
        [r.commonTitle, r.commonText],
        [r.differenceTitle, r.differenceText],
        [tr('Ask each other', '一起聊聊'), r.prompt]
      ]
    : []
})
const title = computed(() =>
  mode.value === 'manage'
    ? tr('My shared links', '我的分享')
    : review.value
      ? tr('Your shared details', '预览分享内容')
      : mode.value === 'compose'
        ? kind.value === 'pair'
          ? tr('Invite a friend', '邀请朋友')
          : tr('Share my element', '分享我的元素')
        : link.value?.result
          ? tr('Your elements together', '两人的五行')
          : link.value?.portrait
            ? (link.value.kind === 'pair' ? tr('Compare with ', '和这位朋友合盘 · ') : '') +
              link.value.portrait.name
            : tr('Friend invitation', '好友邀请')
)
const art = (i) => '/static/art/' + elements[i].toLowerCase() + '.png'
const dateLabel = (t) => new Date(t).toLocaleDateString()
let expiry,
  version = 0,
  registered = false,
  opened = false,
  afterEdit = ''
function manage() {
  clearTimeout(expiry)
  version++
  mode.value = 'manage'
  link.value = null
  error.value = ''
  review.value = false
  loading.value = false
}
watch(
  candidate,
  () => {
    agreed.value = false
  },
  { flush: 'sync' }
)
function scheduleExpiry(result) {
  clearTimeout(expiry)
  const remaining = result.expiresAt * 1000 - Date.now()
  function expired() {
    version++
    link.value = null
    review.value = false
    agreed.value = false
    loading.value = false
    error.value = tr('This link has expired.', '链接已到期。')
  }
  if (remaining <= 0) {
    expired()
    return false
  }
  expiry = setTimeout(expired, remaining)
  return true
}
onLoad((q) => {
  returnHome.value = getCurrentPages().length <= 1
  if (q.manage) {
    manage()
    return
  }
  if (q.compose) {
    mode.value = 'compose'
    kind.value = q.compose === 'portrait' ? 'portrait' : 'pair'
    parentId.value = isToken(q.parent) ? q.parent : ''
  } else if (isToken(q.id)) {
    id.value = q.id
  } else error.value = tr('Invalid invitation link.', '邀请链接无效。')
  registered = true
})
onShow(() => {
  if (!ready.value || data.value.resetPending) return
  if (!nickname.value) nickname.value = data.value.profile?.name || ''
  const resume = afterEdit
  afterEdit = ''
  if (resume && data.value.profile) {
    if (resume === 'join') {
      review.value = true
      agreed.value = false
    } else {
      navigate('chart')
      return
    }
  }
  if (review.value && link.value && !scheduleExpiry(link.value)) return
  if (registered && mode.value === 'open' && id.value && !review.value) load()
})
onHide(() => clearTimeout(expiry))
onUnload(() => {
  clearTimeout(expiry)
  version++
})
onShareAppMessage(() =>
  id.value && owner.value && link.value && !link.value.result
    ? { title: 'FatePair · ' + link.value.portrait.name, path: '/pages/share/index?id=' + id.value }
    : { title: 'FatePair', path: '/pages/home/index' }
)
async function load() {
  const ticket = ++version
  clearTimeout(expiry)
  link.value = null
  loading.value = true
  error.value = ''
  try {
    let result
    try {
      result = await shareRequest('/' + id.value, 'GET', undefined, entry.value?.secret)
    } catch (e) {
      if (entry.value?.pending && entry.value.role === 'guest' && e.status === 401)
        result = await shareRequest('/' + id.value)
      else throw e
    }
    if (ticket !== version) return
    if (!scheduleExpiry(result)) return
    link.value = result
    if (!entry.value && !opened) {
      opened = true
      shareRequest('/' + id.value + '/open', 'POST').catch(() => {})
    }
  } catch (e) {
    if (ticket === version) {
      link.value = null
      review.value = false
      error.value =
        e.status === 410
          ? tr('This link expired or was withdrawn.', '链接已到期或被撤回。')
          : e.message
    }
  } finally {
    if (ticket === version) loading.value = false
  }
}
function toggle(n) {
  if (selected.value.includes(n)) selected.value = selected.value.filter((x) => x !== n)
  else if (selected.value.length < 2) selected.value = [...selected.value, n]
  agreed.value = false
}
function join() {
  agreed.value = false
  if (data.value.profile) review.value = true
  else {
    afterEdit = 'join'
    openPage('edit')
  }
}
function goReading() {
  if (data.value.profile) navigate('chart')
  else {
    afterEdit = 'reading'
    openPage('edit')
  }
}
function onward() {
  openPage('share', '?compose=pair&parent=' + id.value)
}
async function submit() {
  if (!agreed.value || busy.value) return
  busy.value = true
  error.value = ''
  try {
    const e = await saveShare({
      kind: review.value ? 'pair' : kind.value,
      portrait: candidate.value,
      id: review.value ? id.value : undefined,
      parentId: parentId.value,
      expiresAt: review.value ? new Date(link.value.expiresAt * 1000).toISOString() : undefined
    })
    id.value = e.id
    mode.value = 'open'
    review.value = false
    await load()
  } catch (e) {
    if (e.pendingId) manage()
    error.value = e.message
  } finally {
    busy.value = false
  }
}
async function openSaved(e) {
  if (busy.value) return
  error.value = ''
  busy.value = true
  try {
    if (e.pending) await retryEntry(e)
    openPage('share', '?id=' + e.id)
  } catch (e) {
    error.value = e.message
  } finally {
    busy.value = false
  }
}
function remove(e) {
  uni.showModal({
    title: tr('Withdraw this link?', '撤回这个链接？'),
    content: tr('Both people will lose access to the result.', '双方都将无法再访问共同结果。'),
    success: async (r) => {
      if (!r.confirm || busy.value) return
      busy.value = true
      try {
        await withdraw(e)
        manage()
      } catch (err) {
        error.value = err.message
      } finally {
        busy.value = false
      }
    }
  })
}
function copyLink() {
  uni.setClipboardData({
    data: linkUrl(id.value),
    fail: () => say(tr('Select the link to copy it.', '请选中并复制链接。'))
  })
}
async function shareSystem() {
  // #ifdef H5
  if (typeof navigator.share === 'function') {
    try {
      await navigator.share({ title: 'FatePair', url: linkUrl(id.value) })
      return
    } catch (e) {
      if (e.name === 'AbortError') return
    }
  }
  // #endif
  // #ifdef APP-PLUS
  uni.shareWithSystem({ type: 'text', summary: 'FatePair ' + linkUrl(id.value), fail: copyLink })
  return
  // #endif
  copyLink()
}
async function imageCard() {
  try {
    const p = link.value.portrait,
      ctx = uni.createCanvasContext('portraitExport', vm)
    ctx.setFillStyle('#f5f7fc')
    ctx.fillRect(0, 0, 340, 300)
    ctx.setFillStyle('#202d47')
    ctx.setFontSize(16)
    ctx.fillText('FatePair', 22, 32)
    ctx.setFontSize(20)
    ctx.fillText(p.name, 22, 76, 290)
    ctx.setFillStyle(elementColors[p.element])
    ctx.setFontSize(36)
    ctx.fillText(elements[p.element], 22, 122)
    ctx.setFillStyle('#202d47')
    ctx.setFontSize(15)
    p.traits.forEach((t, i) =>
      ctx.fillText(traitText(p.element, t, zh.value), 22, 162 + i * 25, 300)
    )
    if (p.counts) {
      ctx.setFontSize(13)
      ctx.fillText(elements.map((e, i) => e + ' ' + p.counts[i]).join('  '), 22, 238, 300)
      if (p.counts.reduce((a, b) => a + b, 0) === 6)
        ctx.fillText('Birth hour unknown · three pillars', 22, 269)
    }
    ctx.draw(false, () =>
      uni.canvasToTempFilePath(
        {
          canvasId: 'portraitExport',
          width: 340,
          height: 300,
          destWidth: 680,
          destHeight: 600,
          success: (r) => uni.previewImage({ urls: [r.tempFilePath] }),
          fail: () => say(tr('Use Copy link on this device.', '可在本机复制链接。'))
        },
        vm
      )
    )
  } catch (e) {
    say(e.message)
  }
}
</script>
<style scoped>
.pair {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e9f1ff;
  padding: 25px;
  border-radius: 22px;
}
.pair image {
  width: 96px;
  height: 96px;
}
.exportcanvas {
  position: fixed;
  left: -1000px;
  top: 0;
  width: 340px;
  height: 300px;
  pointer-events: none;
}
</style>
