<template>
  <view class="subpage stack" v-if="ready && !data.resetPending">
    <view v-if="m" class="stack">
      <text class="meta">{{ tr('Fictional profile', '虚构示例人物') }}</text>
      <text class="title">{{ m.person.name }}, {{ ageOn(m.person.birth.date) }}</text>
      <text>{{ m.person.location }} · {{ m.person.occupation }}</text>
      <text class="body">{{ m.person.bio }}</text>
      <text class="meta">
        {{ m.person.interests.join(' · ') }} · {{ m.person.languages.join(', ') }}
      </text>
      <view class="panel">
        <text class="subhead">{{ tr('Chart score', '命盘匹配分') }} {{ m.score }}/100</text>
        <text class="body">{{ reason(mine, m, zh) }}</text>
        <view v-for="f in factors" :key="f[0]" class="factor">
          <text>{{ f[0] }} · {{ f[1] }}%</text>
          <text class="score">{{ f[2] }}/100</text>
        </view>
        <text v-if="!m.person.birth.timeKnown || !mine.subject.birth.timeKnown" class="meta">
          {{ tr('Birth hour unknown · approximate score', '出生时间未知，评分为近似值') }}
        </text>
      </view>
      <view class="actions">
        <button class="outline" @click="toggle">
          {{ data.saved.includes(id) ? tr('Unsave', '取消收藏') : tr('Save profile', '收藏人物') }}
        </button>
        <button class="outline" @click="invite">
          {{
            data.social.invitations.includes(id)
              ? tr('Remove sample invitation', '取消示例邀请')
              : tr('Save sample invitation', '保存示例邀请')
          }}
        </button>
      </view>
      <text class="subhead">{{ tr('Local conversation drafts', '本地对话草稿') }}</text>
      <text v-for="msg in data.social.threads[id] || []" :key="msg.id">{{ msg.text }}</text>
      <textarea
        v-model="draft"
        class="input textarea"
        maxlength="1500"
        :placeholder="tr('Write a local draft', '写一条本地草稿')"
      />
      <button class="outline" :disabled="!draft.trim()" @click="saveDraft">
        {{ tr('Save draft on this device', '保存到本机') }}
      </button>
      <view class="actions">
        <button class="quiet" @click="hide">{{ tr('Hide profile', '隐藏人物') }}</button>
        <button class="quiet" @click="report">
          {{ tr('Record a local report', '记录本地举报') }}
        </button>
      </view>
    </view>
    <text v-else class="meta">{{ directoryError || tr('Loading profile…', '正在载入资料…') }}</text>
    <button v-if="directoryError" @click="loadPeople(true)">
      {{ tr('Retry', '重试') }}
    </button>
  </view>
</template>
<script setup>
import { ref, computed } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { boot, ready, data, update, tr, say, action } from '../../lib/store.js'
import { matches, mine, loadPeople, directoryError } from '../../lib/directory.js'
import { ageOn, reason } from '../../lib/chart.js'
import { back } from '../../lib/nav.js'
boot()
const id = ref(''),
  draft = ref('')
onLoad((q) => {
  id.value = q.id
  loadPeople()
})
const zh = computed(() => /^zh/i.test(data.value.lang)),
  m = computed(() => matches.value.find((x) => x.person.id === id.value))
const factors = computed(() =>
  m.value
    ? [
        [tr('Element balance', '五行平衡'), 45, m.value.balance],
        [tr('Day master connection', '日主关系'), 35, m.value.connection],
        [tr('Day branch resonance', '日支关系'), 20, m.value.resonance]
      ]
    : []
)
function toggle() {
  action(() =>
    update((s) => {
      s.saved = s.saved.includes(id.value)
        ? s.saved.filter((x) => x !== id.value)
        : [...s.saved, id.value]
    })
  )
}
function invite() {
  action(() =>
    update((s) => {
      const a = s.social.invitations
      s.social.invitations = a.includes(id.value)
        ? a.filter((x) => x !== id.value)
        : [...a, id.value]
    })
  )
}
function saveDraft() {
  action(() => {
    update((s) => {
      ;(s.social.threads[id.value] ||= []).push({
        id: String(Date.now()),
        text: draft.value.trim(),
        createdAt: new Date().toISOString()
      })
    })
    draft.value = ''
  })
}
function hide() {
  action(() => {
    update((s) => {
      s.hidden.push(id.value)
    })
    back()
  })
}
function report() {
  uni.showActionSheet({
    itemList: [tr('Harassment', '骚扰'), tr('Underage', '未成年'), tr('Other', '其他')],
    success: (r) =>
      action(() => {
        update((s) => {
          s.reports.push({
            userId: id.value,
            reasonIndex: [0, 3, 7][r.tapIndex],
            at: new Date().toISOString()
          })
          if (!s.hidden.includes(id.value)) s.hidden.push(id.value)
        })
        back()
        say(tr('Saved on this device', '已保存到本机'))
      })
  })
}
</script>
<style scoped>
.factor {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 10px 0;
}
</style>
