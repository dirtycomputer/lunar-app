# 术语表:中文 → Magyar(zh2hu)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Magyar | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "BaZi rendszer" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Magyar |
|---|---|
| 五行 | Öt elem |
| 木 | Fa |
| 火 | Tűz |
| 土 | Föld |
| 金 | Fém |
| 水 | Víz |
| 阴 | Jin |
| 阳 | Jang |

复合词大写:阴金 = Jin Fém,阳木 = Jang Fa(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Magyar |
|---|---|
| 甲 | Jang Fa |
| 乙 | Jin Fa |
| 丙 | Jang Tűz |
| 丁 | Jin Tűz |
| 戊 | Jang Föld |
| 己 | Jin Föld |
| 庚 | Jang Fém |
| 辛 | Jin Fém |
| 壬 | Jang Víz |
| 癸 | Jin Víz |

## 四、十二地支(生肖名显示)

| 中文 | Magyar |
|---|---|
| 子 | Patkány |
| 丑 | Bivaly |
| 寅 | Tigris |
| 卯 | Nyúl |
| 辰 | Sárkány |
| 巳 | Kígyó |
| 午 | Ló |
| 未 | Kecske |
| 申 | Majom |
| 酉 | Kakas |
| 戌 | Kutya |
| 亥 | Disznó |

## 五、核心概念

| 中文 | Magyar | 说明 |
|---|---|---|
| 四柱 | Négy oszlop | |
| 天干地支 | Égi szárak és földi ágak | |
| 日主 | Napmester | |
| 十神 | Tíz isten | |
| 合 | Kombinációk | |
| 冲 | Ütközés | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Kár | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigon | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Valódi napidő | |
| 平太阳时 | Átlagos napidő | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Szerencseciklus | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Éves szerencse | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Kínai állatöv | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Elemegyensúly | |
| 日主关系 | Napmester-kapcsolat | |
| 日支共鸣 | Napág-rezonancia | |
| 和谐分 | Harmóniapontszám | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Képlet készítése | ARB 无对应 key;动词 |
| 命盘 | Születési képlet | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Időzóna | ARB 无对应 key |
| 夏令时 | Nyári időszámítás | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Magyar |
|---|---|
| 取消 | Mégse |
| 关闭 | Bezárás |
| 重置 | Visszaállítás |
| 筛选 | Szűrők |
| 发现 | Felfedezés |
| 连接 | Mentve(人脉/收藏的档案) |
| 我的能量 | Az energiám |
| 指南 | Útmutató |
| 工作室 | Stúdió |
| 服务条款 | Általános Szerződési Feltételek |
| 隐私政策 | Adatvédelmi Szabályzat |
| 社区准则 | Közösségi Irányelvek |
| 安全指南 | Randevúbiztonsági Útmutató |
| 儿童安全(CSAE)政策 | Gyermekbiztonsági Szabályzat (CSAE) |
| 账号与数据删除政策 | Fiók- és Adattörlési Szabályzat |
| 订阅条款 | Előfizetési Feltételek |
| 内容审核与举报政策 | Tartalommoderációs és Bejelentési Szabályzat |
| 举报此资料 | Profil bejelentése(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Profil elrejtése(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Fiók és adatok törlése(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Adataim exportálása (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 te(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——lehet / szerint / hagyományosan 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):„A harmónia kulturális felfedezési pontszám, nem jóslat a kapcsolat sikerére."
3. **文化词**:BaZi、Napmester、Égi szárak 首次出现保持既有译名;不使用 jóslás 类贬义措辞,用 kulturális betekintés / hagyományos rendszer。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「–」;引号 „…"。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
