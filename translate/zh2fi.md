# 术语表:中文 → Suomi(zh2fi)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Suomi | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "BaZi-järjestelmä" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Suomi |
|---|---|
| 五行 | Viisi elementtiä |
| 木 | Puu |
| 火 | Tuli |
| 土 | Maa |
| 金 | Metalli |
| 水 | Vesi |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metalli,阳木 = Yang Puu(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Suomi |
|---|---|
| 甲 | Yang Puu |
| 乙 | Yin Puu |
| 丙 | Yang Tuli |
| 丁 | Yin Tuli |
| 戊 | Yang Maa |
| 己 | Yin Maa |
| 庚 | Yang Metalli |
| 辛 | Yin Metalli |
| 壬 | Yang Vesi |
| 癸 | Yin Vesi |

## 四、十二地支(生肖名显示)

| 中文 | Suomi |
|---|---|
| 子 | Rotta |
| 丑 | Härkä |
| 寅 | Tiikeri |
| 卯 | Kaniini |
| 辰 | Lohikäärme |
| 巳 | Käärme |
| 午 | Hevonen |
| 未 | Vuohi |
| 申 | Apina |
| 酉 | Kukko |
| 戌 | Koira |
| 亥 | Sika |

## 五、核心概念

| 中文 | Suomi | 说明 |
|---|---|---|
| 四柱 | Neljä pilaria | |
| 天干地支 | Taivaanrungot & maanhaarat | |
| 日主 | Päivän hallitsija | |
| 十神 | Kymmenen jumalaa | |
| 合 | Yhdistelmät | |
| 冲 | Törmäys | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Vahinko | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Kolmio | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Todellinen aurinkoaika | |
| 平太阳时 | Keskimääräinen aurinkoaika | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Onnenkausi | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Vuosionni | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Kiinalainen horoskooppi | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Elementtitasapaino | |
| 日主关系 | Päivän hallitsijan yhteys | |
| 日支共鸣 | Päivähaaran resonanssi | |
| 和谐分 | Sopusointupisteet | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Piirrä kartta | ARB 无对应 key;动词 |
| 命盘 | Syntymäkartta | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Aikavyöhyke | ARB 无对应 key |
| 夏令时 | Kesäaika | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Suomi |
|---|---|
| 取消 | Peruuta |
| 关闭 | Sulje |
| 重置 | Nollaa |
| 筛选 | Suodattimet |
| 发现 | Tutki |
| 连接 | Tallennetut(人脉/收藏的档案) |
| 我的能量 | Oma energia |
| 指南 | Opas |
| 工作室 | Studio |
| 服务条款 | Käyttöehdot |
| 隐私政策 | Tietosuojakäytäntö |
| 社区准则 | Yhteisön säännöt |
| 安全指南 | Deittailun turvaohjeet |
| 儿童安全(CSAE)政策 | Lasten turvallisuuskäytäntö (CSAE) |
| 账号与数据删除政策 | Tilin ja tietojen poistokäytäntö |
| 订阅条款 | Tilausehdot |
| 内容审核与举报政策 | Sisällön moderointi- ja ilmoituskäytäntö |
| 举报此资料 | Ilmianna tämä profiili(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Piilota tämä profiili(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Poista tili ja tiedot(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Vie tietoni (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 sinä(亲切、非正式,常省略代词只变动词词尾),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——saattaa / katsotaan / perinteisesti 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Sopusointu on kulttuurisen tutustumisen pistemäärä, ei ennuste suhteen onnistumisesta."
3. **文化词**:BaZi、Päivän hallitsija、Taivaanrungot 首次出现保持既有译名;不使用 ennustaminen 类贬义措辞,用 kulttuurinen näkökulma / perinteinen järjestelmä。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「–」;引号 "…";% 之前留空格(如 50 %)。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
