<template>
  <Frame tab="home" :title="tr('Choose your path', '选择你的入口')">
    <view class="paths">
      <button class="path reading" @click="navigate('chart')">
        <image src="/static/art/reading.png" mode="aspectFit" />
        <text>{{ tr('My reading', '看自己') }}</text>
      </button>
      <button class="path people" @click="navigate('match')">
        <image src="/static/art/match.png" mode="aspectFit" />
        <text>{{ tr('Find a match', '找匹配') }}</text>
      </button>
    </view>
    <button class="quiet ask" @click="navigate('agent')">{{ tr('Ask Agent', '问一问') }}</button>
  </Frame>
</template>
<script setup>
import { onLoad } from '@dcloudio/uni-app'
import Frame from '../../components/Frame.vue'
import { boot, data, tr } from '../../lib/store.js'
import { navigate, pages } from '../../lib/nav.js'
onLoad((q) => {
  boot()
  if (
    !q.choose &&
    !data.value.resetPending &&
    ['chart', 'match', 'agent'].includes(data.value.intent)
  )
    navigate(data.value.intent)
})
</script>
<style scoped>
.paths {
  display: flex;
  gap: 20px;
}
.path {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-width: 0;
  padding: 24px 28px;
  border-radius: 26px;
  text-align: left;
  align-items: flex-start;
  font-size: 28px;
  letter-spacing: -0.8px;
}
.path image {
  width: 100%;
  height: 210px;
}
.reading {
  background: #245acb;
  color: #fff;
}
.people {
  background: #e9f1ff;
  color: #223750;
}
.ask {
  margin-top: 14px;
}
@media (max-width: 650px) {
  .paths {
    flex-direction: column;
    gap: 14px;
  }
  .path {
    flex-direction: row-reverse;
    justify-content: space-between;
    align-items: center;
    padding: 18px 20px;
    font-size: 25px;
  }
  .path image {
    width: 45%;
    height: 110px;
  }
}
</style>
