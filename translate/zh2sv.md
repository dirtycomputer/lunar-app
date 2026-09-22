# 术语表:中文 → Svenska(zh2sv)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Svenska | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "BaZi-systemet" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Svenska |
|---|---|
| 五行 | De fem elementen |
| 木 | Träd |
| 火 | Eld |
| 土 | Jord |
| 金 | Metall |
| 水 | Vatten |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metall,阳木 = Yang Träd(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Svenska |
|---|---|
| 甲 | Yang Träd |
| 乙 | Yin Träd |
| 丙 | Yang Eld |
| 丁 | Yin Eld |
| 戊 | Yang Jord |
| 己 | Yin Jord |
| 庚 | Yang Metall |
| 辛 | Yin Metall |
| 壬 | Yang Vatten |
| 癸 | Yin Vatten |

## 四、十二地支(生肖名显示)

| 中文 | Svenska |
|---|---|
| 子 | Råtta |
| 丑 | Oxe |
| 寅 | Tiger |
| 卯 | Kanin |
| 辰 | Drake |
| 巳 | Orm |
| 午 | Häst |
| 未 | Get |
| 申 | Apa |
| 酉 | Tupp |
| 戌 | Hund |
| 亥 | Gris |

## 五、核心概念

| 中文 | Svenska | 说明 |
|---|---|---|
| 四柱 | Fyra pelare | |
| 天干地支 | Himmelstammar & jordgrenar | |
| 日主 | Dagsherre | |
| 十神 | Tio gudar | |
| 合 | Kombinationer | |
| 冲 | Kollision | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Skada | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigon | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Sann soltid | |
| 平太阳时 | Medelsoltid | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Lyckocykel | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Årets lycka | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Kinesisk zodiak | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Elementbalans | |
| 日主关系 | Dagsherre-koppling | |
| 日支共鸣 | Dagsgrensresonans | |
| 和谐分 | Harmonipoäng | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Skapa diagram | ARB 无对应 key;动词 |
| 命盘 | Födelsediagram | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Tidszon | ARB 无对应 key |
| 夏令时 | Sommartid | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Svenska |
|---|---|
| 取消 | Avbryt |
| 关闭 | Stäng |
| 重置 | Återställ |
| 筛选 | Filter |
| 发现 | Upptäck |
| 连接 | Sparade(人脉/收藏的档案) |
| 我的能量 | Min energi |
| 指南 | Guide |
| 工作室 | Studio |
| 服务条款 | Användarvillkor |
| 隐私政策 | Integritetspolicy |
| 社区准则 | Community-riktlinjer |
| 安全指南 | Säkerhetsråd för dejtande |
| 儿童安全(CSAE)政策 | Barnsäkerhetspolicy (CSAE) |
| 账号与数据删除政策 | Policy för radering av konto och data |
| 订阅条款 | Prenumerationsvillkor |
| 内容审核与举报政策 | Policy för innehållsmoderering och anmälningar |
| 举报此资料 | Anmäl den här profilen(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Dölj den här profilen(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Radera konto & data(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Exportera mina data (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 du(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——kan / anses / traditionellt 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Harmoni är en poäng för kulturell utforskning, inte en förutsägelse av en relations framgång."
3. **文化词**:BaZi、Dagsherre、Himmelstammar 首次出现保持既有译名;不使用 spåkonst 类贬义措辞,用 kulturell inblick / traditionellt system。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「–」;% 之前留空格(如 50 %)。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
