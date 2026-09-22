# 术语表:中文 → Română(zh2ro)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Română | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "sistemul BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Română |
|---|---|
| 五行 | Cele cinci elemente |
| 木 | Lemn |
| 火 | Foc |
| 土 | Pământ |
| 金 | Metal |
| 水 | Apă |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metal,阳木 = Yang Lemn(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Română |
|---|---|
| 甲 | Yang Lemn |
| 乙 | Yin Lemn |
| 丙 | Yang Foc |
| 丁 | Yin Foc |
| 戊 | Yang Pământ |
| 己 | Yin Pământ |
| 庚 | Yang Metal |
| 辛 | Yin Metal |
| 壬 | Yang Apă |
| 癸 | Yin Apă |

## 四、十二地支(生肖名显示)

| 中文 | Română |
|---|---|
| 子 | Șobolan |
| 丑 | Bivol |
| 寅 | Tigru |
| 卯 | Iepure |
| 辰 | Dragon |
| 巳 | Șarpe |
| 午 | Cal |
| 未 | Capră |
| 申 | Maimuță |
| 酉 | Cocoș |
| 戌 | Câine |
| 亥 | Porc |

## 五、核心概念

| 中文 | Română | 说明 |
|---|---|---|
| 四柱 | Patru stâlpi | |
| 天干地支 | Tulpini cerești și ramuri pământești | |
| 日主 | Maestrul zilei | |
| 十神 | Zece Zei | |
| 合 | Combinații | |
| 冲 | Ciocnire | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Vătămare | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigon | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Ora solară adevărată | |
| 平太阳时 | Ora solară medie | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Ciclul norocului | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Norocul anului | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Zodiacul chinezesc | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Echilibrul elementelor | |
| 日主关系 | Conexiunea dintre maeștrii zilei | |
| 日支共鸣 | Rezonanța ramurilor zilei | |
| 和谐分 | Scorul de armonie | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Elaborează harta | ARB 无对应 key;动词 |
| 命盘 | Harta natală | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Fus orar | ARB 无对应 key |
| 夏令时 | Ora de vară | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Română |
|---|---|
| 取消 | Anulare |
| 关闭 | Închide |
| 重置 | Resetează |
| 筛选 | Filtre |
| 发现 | Descoperă |
| 连接 | Salvate(人脉/收藏的档案) |
| 我的能量 | Energia mea |
| 指南 | Ghid |
| 工作室 | Studio |
| 服务条款 | Termeni și Condiții |
| 隐私政策 | Politica de Confidențialitate |
| 社区准则 | Reguli ale Comunității |
| 安全指南 | Ghid de Siguranță pentru Întâlniri |
| 儿童安全(CSAE)政策 | Politica de Siguranță a Copiilor (CSAE) |
| 账号与数据删除政策 | Politica de Ștergere a Contului și Datelor |
| 订阅条款 | Termenii Abonamentului |
| 内容审核与举报政策 | Politica de Moderare a Conținutului și Raportare |
| 举报此资料 | Raportează acest profil(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Ascunde acest profil(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Șterge contul și datele(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Exportă datele mele (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 tu(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——poate / se consideră / în mod tradițional 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Armonia este un scor de explorare culturală, nu o predicție a succesului relației."
3. **文化词**:BaZi、Maestrul zilei、Tulpini cerești 首次出现保持既有译名;不使用 ghicire 类贬义措辞,用 perspectivă culturală / sistem tradițional。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;引号 „…"。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
