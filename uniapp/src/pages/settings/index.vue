<template>
  <Frame tab="settings" :title="tr('Settings', '设置')">
    <view class="stack narrow">
      <view class="panel">
        <text class="subhead">{{ tr('Language', '语言') }}</text>
        <picker
          :range="languages.map((x) => x[1])"
          :value="languageIndex"
          @change="lang(languages[$event.detail.value][0])"
        >
          <view class="picker">{{ languages[languageIndex][1] }}</view>
        </picker>
      </view>
      <view class="panel">
        <text class="subhead">{{ tr('My data', '我的资料') }}</text>
        <view class="actions">
          <button class="outline" @click="openPage('edit')">
            {{ tr('Birth details', '出生资料') }}
          </button>
          <button class="outline" @click="openPage('share', '?manage=1')">
            {{ tr('My shared links', '我的分享') }}
          </button>
          <button class="outline" @click="copy">
            {{ tr('Export this device', '导出本机资料') }}
          </button>
          <button class="quiet" @click="importing = !importing">
            {{ tr('Import a FatePair export', '导入已有资料') }}
          </button>
        </view>
        <view v-if="importing">
          <textarea
            class="input textarea"
            v-model="content"
            maxlength="-1"
            :placeholder="tr('Paste your device export', '粘贴原设备导出的资料')"
          />
          <button class="outline" @click="restore">
            {{ tr('Review and import', '确认导入') }}
          </button>
        </view>
        <textarea v-if="exported" class="input textarea" :value="exported" maxlength="-1" />
        <button class="quiet danger" @click="clear">
          {{ tr('Clear my data', '清除我的资料') }}
        </button>
      </view>
      <view class="panel">
        <text class="subhead">{{ tr('Privacy and safety', '隐私与安全') }}</text>
        <text class="body">
          {{
            tr(
              'Your birth profile stays on this device. Asking Agent sends the approved chart, birth inputs, current reading and full conversation to the chart service and DeepSeek.',
              '出生资料保存在本机。使用问答并同意后，排盘服务和 DeepSeek 会收到出生资料、命盘、当前解读及完整对话。'
            )
          }}
        </text>
        <text class="body">
          {{
            tr(
              'The public directory contains fictional adults. Invitations to these profiles, drafts, hidden profiles and reports stay on this device. Cultural chart scores measure alignment under the stated rules.',
              '公共人物库收录虚构成年人物。向示例人物的邀请、对话草稿、隐藏及举报记录保存在本机。命盘评分按页面列出的传统规则计算。'
            )
          }}
        </text>
        <text class="body">
          {{
            tr(
              'Friend invitations store the nickname, chosen reflections, day element and approved counts for seven days. Participants can withdraw. Clearing your device first withdraws its active links. Exported data excludes the private keys used to manage them.',
              '好友邀请将经同意分享的昵称、特点、日主及五行数量保存七天，参与者可撤回。清除本机数据时先撤回有效链接。导出资料不含管理分享所需的私人凭据。'
            )
          }}
        </text>
      </view>
      <view class="panel">
        <text class="subhead">{{ tr('Preview policies', '预览版服务说明') }}</text>
        <view v-for="n in notices" :key="n.id">
          <button class="quiet" @click="notice = notice === n.id ? '' : n.id">{{ n.title }}</button>
          <text v-if="notice === n.id" selectable class="body">{{ n.body }}</text>
        </view>
      </view>
      <view class="panel">
        <text class="subhead">{{ tr('Reading style', '解读风格') }}</text>
        <view class="segment">
          <button
            v-for="v in ['plain', 'professional']"
            :key="v"
            class="chip"
            :class="{ selected: data.style === v }"
            @click="style(v)"
          >
            {{ v === 'plain' ? tr('Everyday', '通俗') : tr('Professional', '专业') }}
          </button>
        </view>
      </view>
    </view>
  </Frame>
</template>
<script setup>
import { ref, computed } from 'vue'
import { languages } from '../../lib/translations.js'
import { notices } from '../../lib/notices.js'
import Frame from '../../components/Frame.vue'
import { data, update, tr, say, action, resetAll, exportLocal } from '../../lib/store.js'
import { clearConversation } from '../../lib/conversation.js'
import { openPage, navigate } from '../../lib/nav.js'
import { portableImport } from '../../lib/import.js'
const languageIndex = computed(() =>
  Math.max(
    0,
    languages.findIndex((x) => x[0] === (data.value.lang || 'en').replace('_', '-'))
  )
)
const notice = ref('')
const exported = ref(''),
  content = ref(''),
  importing = ref(false)
function style(value) {
  action(() =>
    update((s) => {
      s.style = value
    })
  )
}
function lang(value) {
  action(() =>
    update((s) => {
      s.lang = value
    })
  )
}
function copy() {
  exported.value = exportLocal()
  uni.setClipboardData({
    data: exported.value,
    fail: () => say(tr('Select the export to copy it.', '请选择并复制导出的文本。'))
  })
}
function restore() {
  try {
    const next = portableImport(content.value)
    uni.showModal({
      title: tr('Replace this device’s profile and progress?', '替换本机资料与进度？'),
      content: tr('Active sharing controls will stay on this device.', '现有分享仍可在本机管理。'),
      success: (r) => {
        if (r.confirm)
          action(() => {
            update((s) => {
              const links = s.links
              Object.assign(s, next, { links })
            })
            clearConversation()
            importing.value = false
            content.value = ''
            say(tr('Imported', '已导入'))
          })
      }
    })
  } catch (e) {
    say(e.message)
  }
}
function clear() {
  uni.showModal({
    title: tr('Clear this device?', '清除本机资料？'),
    content: tr(
      'Active links will be withdrawn before deletion completes.',
      '会先撤回有效分享，再完成删除。'
    ),
    success: async (r) => {
      if (r.confirm) {
        clearConversation()
        try {
          await resetAll()
          navigate('home', '?choose=1')
        } catch (e) {
          say(e.message)
        }
      }
    }
  })
}
</script>
<style scoped>
.narrow {
  max-width: 780px;
}
.body {
  margin: 8px 0;
}
</style>
