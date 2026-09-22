# 术语表:中文 → Bahasa Melayu(zh2ms)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Bahasa Melayu | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "sistem BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Bahasa Melayu |
|---|---|
| 五行 | Lima elemen |
| 木 | Kayu |
| 火 | Api |
| 土 | Tanah |
| 金 | Logam |
| 水 | Air |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Logam,阳木 = Yang Kayu(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Bahasa Melayu |
|---|---|
| 甲 | Yang Kayu |
| 乙 | Yin Kayu |
| 丙 | Yang Api |
| 丁 | Yin Api |
| 戊 | Yang Tanah |
| 己 | Yin Tanah |
| 庚 | Yang Logam |
| 辛 | Yin Logam |
| 壬 | Yang Air |
| 癸 | Yin Air |

## 四、十二地支(生肖名显示)

| 中文 | Bahasa Melayu |
|---|---|
| 子 | Tikus |
| 丑 | Lembu |
| 寅 | Harimau |
| 卯 | Arnab |
| 辰 | Naga |
| 巳 | Ular |
| 午 | Kuda |
| 未 | Kambing |
| 申 | Monyet |
| 酉 | Ayam |
| 戌 | Anjing |
| 亥 | Babi |

## 五、核心概念

| 中文 | Bahasa Melayu | 说明 |
|---|---|---|
| 四柱 | Empat pilar | |
| 天干地支 | Batang langit & cabang bumi | |
| 日主 | Penguasa Hari | |
| 十神 | Sepuluh Dewa | |
| 合 | Gabungan | |
| 冲 | Pertembungan | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Kecederaan | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trine | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Masa suria sebenar | |
| 平太阳时 | Masa suria purata | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Kitaran tuah | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Tuah tahunan | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Zodiak Cina | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Keseimbangan elemen | |
| 日主关系 | Kaitan Penguasa Hari | |
| 日支共鸣 | Resonans cabang hari | |
| 和谐分 | Skor keharmonian | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Bina carta | ARB 无对应 key;动词 |
| 命盘 | Carta kelahiran | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Zon masa | ARB 无对应 key |
| 夏令时 | Waktu musim panas | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Bahasa Melayu |
|---|---|
| 取消 | Batal |
| 关闭 | Tutup |
| 重置 | Set semula |
| 筛选 | Penapis |
| 发现 | Temui |
| 连接 | Disimpan(人脉/收藏的档案) |
| 我的能量 | Tenaga saya |
| 指南 | Panduan |
| 工作室 | Studio |
| 服务条款 | Terma Perkhidmatan |
| 隐私政策 | Dasar Privasi |
| 社区准则 | Garis Panduan Komuniti |
| 安全指南 | Panduan Keselamatan Perkenalan |
| 儿童安全(CSAE)政策 | Dasar Keselamatan Kanak-Kanak (CSAE) |
| 账号与数据删除政策 | Dasar Pemadaman Akaun & Data |
| 订阅条款 | Terma Langganan |
| 内容审核与举报政策 | Dasar Pemoderatan Kandungan & Pelaporan |
| 举报此资料 | Laporkan profil ini(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Sembunyikan profil ini(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Padam akaun & data(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Eksport data saya (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 anda(标准礼貌称呼),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——mungkin / dianggap / secara tradisional 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Keharmonian ialah skor penerokaan budaya, bukan ramalan kejayaan hubungan."
3. **文化词**:BaZi、Penguasa Hari、Batang langit 首次出现保持既有译名;不使用 ramalan 类贬义措辞,用 pandangan budaya / sistem tradisional。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;标准拉丁标点,标点后空格。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
