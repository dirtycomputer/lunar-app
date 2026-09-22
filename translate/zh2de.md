# 术语表:中文 → Deutsch(zh2de)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Deutsch | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "das BaZi-System" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Deutsch |
|---|---|
| 五行 | Die fünf Elemente |
| 木 | Holz |
| 火 | Feuer |
| 土 | Erde |
| 金 | Metall |
| 水 | Wasser |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metall,阳木 = Yang Holz(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Deutsch |
|---|---|
| 甲 | Yang Holz |
| 乙 | Yin Holz |
| 丙 | Yang Feuer |
| 丁 | Yin Feuer |
| 戊 | Yang Erde |
| 己 | Yin Erde |
| 庚 | Yang Metall |
| 辛 | Yin Metall |
| 壬 | Yang Wasser |
| 癸 | Yin Wasser |

## 四、十二地支(生肖名显示)

| 中文 | Deutsch |
|---|---|
| 子 | Ratte |
| 丑 | Ochse |
| 寅 | Tiger |
| 卯 | Hase |
| 辰 | Drache |
| 巳 | Schlange |
| 午 | Pferd |
| 未 | Ziege |
| 申 | Affe |
| 酉 | Hahn |
| 戌 | Hund |
| 亥 | Schwein |

## 五、核心概念

| 中文 | Deutsch | 说明 |
|---|---|---|
| 四柱 | Vier Säulen | |
| 天干地支 | Himmelsstämme & Erdzweige | |
| 日主 | Tagesherrscher | |
| 十神 | Zehn Götter | |
| 合 | Kombinationen | |
| 冲 | Konflikt | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Schädigung | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigon | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Wahre Sonnenzeit | |
| 平太阳时 | Mittlere Sonnenzeit | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Glückszyklus | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Jahresglück | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Chinesischer Tierkreis | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Elementbalance | |
| 日主关系 | Tagesherrscher-Verbindung | |
| 日支共鸣 | Tageszweig-Resonanz | |
| 和谐分 | Harmoniewert | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Diagramm erstellen | ARB 无对应 key;动词 |
| 命盘 | Geburtsdiagramm | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Zeitzone | ARB 无对应 key |
| 夏令时 | Sommerzeit | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Deutsch |
|---|---|
| 取消 | Abbrechen |
| 关闭 | Schließen |
| 重置 | Zurücksetzen |
| 筛选 | Filter |
| 发现 | Entdecken |
| 连接 | Gespeichert(人脉/收藏的档案) |
| 我的能量 | Meine Energie |
| 指南 | Guide |
| 工作室 | Studio |
| 服务条款 | Nutzungsbedingungen |
| 隐私政策 | Datenschutzerklärung |
| 社区准则 | Community-Richtlinien |
| 安全指南 | Sicherheitshinweise für Dating |
| 儿童安全(CSAE)政策 | Kinderschutzrichtlinie (CSAE) |
| 账号与数据删除政策 | Richtlinie zur Konto- und Datenlöschung |
| 订阅条款 | Abo-Bedingungen |
| 内容审核与举报政策 | Inhaltsmoderation & Meldungsrichtlinie |
| 举报此资料 | Dieses Profil melden(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Dieses Profil ausblenden(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Konto & Daten löschen(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Meine Daten exportieren (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 du(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——kann / gilt als / traditionell 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):„Harmonie ist ein Score zur kulturellen Erkundung, keine Vorhersage des Beziehungserfolgs."
3. **文化词**:BaZi、Tagesherrscher、Himmelsstämme 首次出现保持既有译名(注意复合词按 Solarterminen 系连写风格,如 Tageszweig-Resonanz);不使用 Wahrsagerei 类贬义措辞,用 kulturelle Einordnung / traditionelles System。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用半字线「–」;引号 „…";保留 ß。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
