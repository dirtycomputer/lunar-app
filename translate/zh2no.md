# 术语表:中文 → Norsk(zh2no)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Norsk | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "BaZi-systemet" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Norsk |
|---|---|
| 五行 | De fem elementene |
| 木 | Tre |
| 火 | Ild |
| 土 | Jord |
| 金 | Metall |
| 水 | Vann |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metall,阳木 = Yang Tre(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Norsk |
|---|---|
| 甲 | Yang Tre |
| 乙 | Yin Tre |
| 丙 | Yang Ild |
| 丁 | Yin Ild |
| 戊 | Yang Jord |
| 己 | Yin Jord |
| 庚 | Yang Metall |
| 辛 | Yin Metall |
| 壬 | Yang Vann |
| 癸 | Yin Vann |

## 四、十二地支(生肖名显示)

| 中文 | Norsk |
|---|---|
| 子 | Rotte |
| 丑 | Okse |
| 寅 | Tiger |
| 卯 | Kanin |
| 辰 | Drake |
| 巳 | Slange |
| 午 | Hest |
| 未 | Geit |
| 申 | Ape |
| 酉 | Hane |
| 戌 | Hund |
| 亥 | Gris |

## 五、核心概念

| 中文 | Norsk | 说明 |
|---|---|---|
| 四柱 | Fire søyler | |
| 天干地支 | Himmelstammer & jordgrener | |
| 日主 | Dagsherre | |
| 十神 | Ti guder | |
| 合 | Kombinasjoner | |
| 冲 | Kollisjon | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Skade | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigon | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Ekte soltid | |
| 平太阳时 | Middelsoltid | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Lykkesyklus | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Årets lykke | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Kinesisk stjernetegn | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Elementbalanse | |
| 日主关系 | Dagsherre-kobling | |
| 日支共鸣 | Dagsgrenresonans | |
| 和谐分 | Harmonipoeng | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Lag diagram | ARB 无对应 key;动词 |
| 命盘 | Fødselskart | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Tidssone | ARB 无对应 key |
| 夏令时 | Sommertid | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Norsk |
|---|---|
| 取消 | Avbryt |
| 关闭 | Lukk |
| 重置 | Tilbakestill |
| 筛选 | Filtre |
| 发现 | Utforsk |
| 连接 | Lagrede(人脉/收藏的档案) |
| 我的能量 | Energien min |
| 指南 | Guide |
| 工作室 | Studio |
| 服务条款 | Bruksvilkår |
| 隐私政策 | Personvernerklæring |
| 社区准则 | Retningslinjer for fellesskapet |
| 安全指南 | Sikkerhetsråd for dating |
| 儿童安全(CSAE)政策 | Barnsikkerhetspolicy (CSAE) |
| 账号与数据删除政策 | Retningslinjer for sletting av konto og data |
| 订阅条款 | Abonnementsvilkår |
| 内容审核与举报政策 | Retningslinjer for innholdsmoderering og rapportering |
| 举报此资料 | Rapporter denne profilen(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Skjul denne profilen(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Slett konto & data(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Eksporter dataene mine (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 du(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——kan / regnes som / tradisjonelt 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Harmoni er en score for kulturell utforskning, ikke en spådom om et forholds suksess."
3. **文化词**:BaZi、Dagsherre、Himmelstammer 首次出现保持既有译名;不使用 spådom 类贬义措辞,用 kulturell innsikt / tradisjonelt system。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「–」;% 之前留空格(如 50 %)。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
