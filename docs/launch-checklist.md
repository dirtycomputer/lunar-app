# FatePair 上线清单

现行客户端使用 uni-app。Web、微信小程序、iOS 与 Android 的共享资源分别构建。微信正式 AppID、类目与域名、真机核验、DCloud AppID、原生签名与商店身份仍需完成。大陆上线前，需结合 2026 年「AI 算命」整治逐项核定实际服务与收费项目。以下旧版 Flutter 的构建记录仅适用于对应的历史客户端。[迁移与打包](uni-app.md) · [国内市场核查](china-market-review.md)


核对日期为 2026 年 11 月 18 日。网页版已作为英文预览公开，可排盘、问答和与自己邀请的朋友合盘。共享数据库里有 1,000 份虚构的成年人物资料。点这些人物发出的邀请、消息草稿和举报目前保存在自己的设备上。版本的六项发布阻碍记录在仓库中。[当前发布状态](../release/launch.json)

## 负责人先准备什么

| 需要确定 | 完成的标志 |
| --- | --- |
| 运营主体、首批国家或地区、对外支持邮箱、隐私及儿童安全联系人 | 商店、网站、协议都能找到同一主体。实测能收到用户请求，有人负责回复和升级处理。 |
| 首批测试范围 | 先邀请一小批成年人，从自己的解读开始，用两台设备走完邀请、同意、看到结果和撤回。招募、截图和商店素材如实标明示例人物。 |
| AI 预算与凭据 | 设定每日费用上限、告警接收人和暂停服务的权限。核实曾在对话中分享的 DeepSeek 密钥已轮换并已撤销旧值。分别更新 GitHub Secret 和生产后端的同名环境变量，再部署并验证新值。 |
| 商店身份与签名 | 开通并验证 Apple Developer 和 Google Play Console 账号，确认最终包名、Bundle ID、应用名称和发行国家。签名资料放入受控的凭据存储。 |

## 开放真人匹配前

| 交付 | 如何验收 |
| --- | --- |
| 账号与公开资料 | 成年人注册并主动选择加入发现。换设备能恢复自己的资料。只向其他人显示同意公开的字段，匹配在服务端进行。两个测试账号互相核对可见范围。 |
| 双向同意和安全 | 两个人都同意后才能聊天。拉黑立即阻止发现和后续联系。举报能到达审核队列，有负责人、时限、处置、申诉和未成年人事件处理流程。实测从举报提交到处置和反馈的全过程。 |
| 数据权利与 AI 同意 | 发布可公开访问的英文隐私政策、条款、社区与儿童安全标准。写清出生资料、完整问答历史、分享内容分别交给谁、用途、保存时间和删除方式。发送给第三方 AI 前取得明确同意，并覆盖所有能发起问答的入口。测试应用内删号和网页删除申请，包括已分享内容、后台数据及备份的处理时限。 |
| 问答成本与服务运行 | 把解读额度持久保存在服务端，为账户和全站设上限。并发或服务重启后仍能限额，超额后能暂停付费调用。监控错误和费用，排除出生资料、对话和凭据出现在日志中，演练数据库恢复与发布回滚。 |

Google Play 要求以匹配或约会为核心的应用使用 Play Console 提供的未成年人屏蔽功能。社交及约会应用还需公布儿童安全标准，提供应用内反馈途径并指定儿童安全联系人。苹果对用户生成内容要求具备过滤、举报、拉黑和有效联系方式。收集和向第三方 AI 发送个人资料需要相应告知与同意。请根据首批发行地区核对数据、跨境处理与年龄要求。[Google 年龄限制](https://support.google.com/googleplay/android-developer/answer/16302250?hl=en) · [Google 儿童安全](https://support.google.com/googleplay/android-developer/answer/14747720?hl=en) · [Google 删号要求](https://support.google.com/googleplay/android-developer/answer/13327111?hl=en) · [Apple 审核指南](https://developer.apple.com/app-store/review/guidelines/)

## 三个平台分别验收

| 平台 | 下一次交付 |
| --- | --- |
| Web | 在桌面 Chrome、iPhone Safari 和 Android Chrome 从公开地址首次进入。用两个独立浏览器实测邀请链接、提交同意、查看结果、撤回、刷新以及拒绝剪贴板或系统分享后的回退。再验证手机键盘、200% 字号和断网重试。保存设备、浏览器版本和结果。 |
| iOS | 仓库当前构建未签名的模拟器应用。使用 Xcode 26 或更高版本和 iOS 26 或更高版本 SDK 归档、签名和上传，通过 TestFlight 在真机验证。填写 App Privacy、年龄分级、支持与隐私网址，准备英文截图、审核账号和审核说明。 |
| Android | 当前 Flutter 3.27.1 默认目标为 API 35，CI 构建 Debug APK。升级并验证编译工具链，使新手机应用以 Android 16（API 36）或更高版本为目标。构建签名 Release AAB，配置 Play App Signing，在 Play 测试轨验证安装、更新、系统分享、断网和删除。填写 Data safety、目标年龄和内容分级。 |

Apple 把约会和算命均列入竞争充分的类别。审核材料应直接演示排盘如何得出推荐理由、未知出生时辰如何处理，以及两位朋友怎样各自同意并获得共同结果。Google Play 的新个人开发者账号若在 2023 年 11 月 13 日以后创建，申请生产访问前需至少 12 名测试者连续加入封闭测试满 14 天。依账号类型和提交日再次核对商店公告。[Apple SDK 要求](https://developer.apple.com/news/upcoming-requirements/) · [Apple 审核指南第 4.3(b) 节](https://developer.apple.com/app-store/review/guidelines/#spam) · [Google 目标 API](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en) · [Google 封闭测试](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en) · [Google Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)

先用已开放的排盘与好友合盘收集第一批真实体验反馈。真人账号、安全运营、隐私处理和服务额度验收后，再小范围开放真人推荐。各端的签名、真机和审核证据齐全后，分别决定上架和扩大发行的时间。
