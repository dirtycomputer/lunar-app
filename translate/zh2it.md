# 术语表:中文 → Italiano(zh2it)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Italiano | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "il sistema BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Italiano |
|---|---|
| 五行 | I cinque elementi |
| 木 | Legno |
| 火 | Fuoco |
| 土 | Terra |
| 金 | Metallo |
| 水 | Acqua |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metallo,阳木 = Yang Legno(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Italiano |
|---|---|
| 甲 | Yang Legno |
| 乙 | Yin Legno |
| 丙 | Yang Fuoco |
| 丁 | Yin Fuoco |
| 戊 | Yang Terra |
| 己 | Yin Terra |
| 庚 | Yang Metallo |
| 辛 | Yin Metallo |
| 壬 | Yang Acqua |
| 癸 | Yin Acqua |

## 四、十二地支(生肖名显示)

| 中文 | Italiano |
|---|---|
| 子 | Ratto |
| 丑 | Bue |
| 寅 | Tigre |
| 卯 | Coniglio |
| 辰 | Drago |
| 巳 | Serpente |
| 午 | Cavallo |
| 未 | Capra |
| 申 | Scimmia |
| 酉 | Gallo |
| 戌 | Cane |
| 亥 | Maiale |

## 五、核心概念

| 中文 | Italiano | 说明 |
|---|---|---|
| 四柱 | Quattro pilastri | |
| 天干地支 | Steli celesti e rami terrestri | |
| 日主 | Maestro del giorno | |
| 十神 | Dieci Dei | |
| 合 | Combinazioni | |
| 冲 | Conflitto | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Danno | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigono | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Tempo solare vero | |
| 平太阳时 | Tempo solare medio | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Ciclo di fortuna | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Fortuna annuale | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Zodiaco cinese | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Equilibrio degli elementi | |
| 日主关系 | Connessione tra maestri del giorno | |
| 日支共鸣 | Risonanza dei rami del giorno | |
| 和谐分 | Punteggio di armonia | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Calcolare il tema | ARB 无对应 key;动词 |
| 命盘 | Tema natale | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Fuso orario | ARB 无对应 key |
| 夏令时 | Ora legale | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Italiano |
|---|---|
| 取消 | Annulla |
| 关闭 | Chiudi |
| 重置 | Reimposta |
| 筛选 | Filtri |
| 发现 | Scopri |
| 连接 | Salvati(人脉/收藏的档案) |
| 我的能量 | La mia energia |
| 指南 | Guida |
| 工作室 | Studio |
| 服务条款 | Termini di Servizio |
| 隐私政策 | Informativa sulla Privacy |
| 社区准则 | Linee guida della community |
| 安全指南 | Linee guida di sicurezza per gli appuntamenti |
| 儿童安全(CSAE)政策 | Politica di sicurezza dei minori (CSAE) |
| 账号与数据删除政策 | Politica di eliminazione di account e dati |
| 订阅条款 | Termini di abbonamento |
| 内容审核与举报政策 | Politica di moderazione dei contenuti e segnalazioni |
| 举报此资料 | Segnala questo profilo(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Nascondi questo profilo(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Elimina account e dati(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Esporta i miei dati (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 tu(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——può / si ritiene / tradizionalmente 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"L'armonia è un punteggio di esplorazione culturale, non una previsione del successo della relazione."
3. **文化词**:BaZi、Maestro del giorno、Steli celesti 首次出现保持既有译名;不使用 divinazione 类贬义措辞,用 lettura culturale / sistema tradizionale。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;正式文本引号 «…»,界面可用 "…"。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
