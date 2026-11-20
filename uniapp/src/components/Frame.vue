<template>
  <view class="frame">
    <view class="top" :style="safeTop">
      <button class="wordmark" @click="navigate('home', '?choose=1')">
        <image src="/static/art/flower.png" class="mark" />
        <text>FatePair</text>
      </button>
      <view class="tools">
        <button v-if="tab !== 'garden'" class="topbutton" @click="navigate('garden')">
          {{ tr('Garden', '花园') }}
        </button>
        <button v-if="tab !== 'settings'" class="topbutton" @click="navigate('settings')">
          {{ tr('Settings', '设置') }}
        </button>
      </view>
    </view>
    <view v-if="bootError" class="subpage">
      <text class="error">{{ bootError }}</text>
      <button @click="boot">{{ tr('Retry', '重试') }}</button>
    </view>
    <view v-else-if="data.resetPending" class="subpage stack">
      <text class="subhead">{{ tr('Finish clearing your data', '继续清除资料') }}</text>
      <button class="primary" @click="clear">
        {{ tr('Retry withdrawal and deletion', '重试撤回和删除') }}
      </button>
    </view>
    <view v-else>
      <view v-if="tab !== 'home'" class="nav">
        <button
          v-for="n in tabs"
          :key="n.key"
          class="nav-btn"
          :class="{ active: tab === n.key }"
          @click="navigate(n.key)"
        >
          {{ tr(n.en, n.zh) }}
        </button>
      </view>
      <view class="page">
        <text class="title">{{ title }}</text>
        <slot />
      </view>
    </view>
  </view>
</template>
<script setup>
import { ref } from 'vue'
import { boot, data, bootError, tr, say, resetAll } from '../lib/store.js'
import { navigate } from '../lib/nav.js'
defineProps({ tab: String, title: String })
boot()
const tabs = [
  { key: 'chart', en: 'My reading', zh: '看自己' },
  { key: 'match', en: 'Match', zh: '找匹配' },
  { key: 'agent', en: 'Ask Agent', zh: '问一问' }
]
const safeTop = ref({})
// #ifdef MP-WEIXIN
const capsule = uni.getMenuButtonBoundingClientRect()
safeTop.value = { paddingTop: capsule.top + capsule.height + 4 + 'px' }
// #endif
async function clear() {
  try {
    await resetAll()
    navigate('home')
  } catch (e) {
    say(e.message)
  }
}
</script>
<style scoped>
.top {
  max-width: 1200px;
  margin: auto;
  padding: calc(var(--status-bar-height, 0px) + 10px) 22px 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}
.wordmark {
  gap: 8px;
  padding: 4px 0;
  background: transparent;
  font-size: 22px;
  letter-spacing: -0.8px;
  color: #202d47;
}
.mark {
  width: 29px;
  height: 29px;
}
.tools {
  display: flex;
  gap: 4px;
}
.topbutton {
  background: transparent;
  font-size: 14px;
  padding: 8px;
  color: #4d5d74;
}
.nav {
  max-width: 1080px;
  margin: 0 auto;
  display: flex;
  gap: 6px;
  padding: 3px 24px;
}
.nav-btn {
  border-radius: 20px;
  background: transparent;
  color: #52627e;
}
.active {
  color: #1646a5;
  background: #e2edff;
}
@media (max-width: 750px) {
  .top {
    padding-left: 16px;
    padding-right: 12px;
  }
  .nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 5;
    justify-content: space-evenly;
    gap: 0;
    padding: 5px 4px calc(env(safe-area-inset-bottom) + 5px);
    background: #f5f7fc;
    border-top: 1px solid #dce3ee;
  }
  .nav-btn {
    font-size: 14px;
    flex: 1;
  }
  .wordmark {
    font-size: 20px;
  }
}
</style>
