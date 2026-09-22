# 术语表:中文 → Polski(zh2pl)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Polski | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "system BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Polski |
|---|---|
| 五行 | Pięć żywiołów |
| 木 | Drewno |
| 火 | Ogień |
| 土 | Ziemia |
| 金 | Metal |
| 水 | Woda |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metal,阳木 = Yang Drewno(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Polski |
|---|---|
| 甲 | Yang Drewno |
| 乙 | Yin Drewno |
| 丙 | Yang Ogień |
| 丁 | Yin Ogień |
| 戊 | Yang Ziemia |
| 己 | Yin Ziemia |
| 庚 | Yang Metal |
| 辛 | Yin Metal |
| 壬 | Yang Woda |
| 癸 | Yin Woda |

## 四、十二地支(生肖名显示)

| 中文 | Polski |
|---|---|
| 子 | Szczur |
| 丑 | Byk |
| 寅 | Tygrys |
| 卯 | Królik |
| 辰 | Smok |
| 巳 | Wąż |
| 午 | Koń |
| 未 | Koza |
| 申 | Małpa |
| 酉 | Kogut |
| 戌 | Pies |
| 亥 | Świnia |

## 五、核心概念

| 中文 | Polski | 说明 |
|---|---|---|
| 四柱 | Cztery Filary | |
| 天干地支 | Niebiańskie łodygi i ziemskie gałęzie | |
| 日主 | Władca dnia | |
| 十神 | Dziesięć Bogów | |
| 合 | Kombinacje | |
| 冲 | Kolizja | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Szkoda | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trygon | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Prawdziwy czas słoneczny | |
| 平太阳时 | Średni czas słoneczny | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Cykl szczęścia | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Roczne szczęście | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Chiński zodiak | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Równowaga żywiołów | |
| 日主关系 | Powiązanie władców dnia | |
| 日支共鸣 | Rezonans gałęzi dnia | |
| 和谐分 | Wynik harmonii | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Sporządź kosmogram | ARB 无对应 key;动词 |
| 命盘 | Kosmogram urodzeniowy | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Strefa czasowa | ARB 无对应 key |
| 夏令时 | Czas letni | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Polski |
|---|---|
| 取消 | Anuluj |
| 关闭 | Zamknij |
| 重置 | Resetuj |
| 筛选 | Filtry |
| 发现 | Odkrywaj |
| 连接 | Zapisane(人脉/收藏的档案) |
| 我的能量 | Moja energia |
| 指南 | Przewodnik |
| 工作室 | Studio |
| 服务条款 | Regulamin usługi |
| 隐私政策 | Polityka prywatności |
| 社区准则 | Zasady społeczności |
| 安全指南 | Wytyczne bezpieczeństwa randkowania |
| 儿童安全(CSAE)政策 | Zasady bezpieczeństwa dzieci (CSAE) |
| 账号与数据删除政策 | Zasady usuwania konta i danych |
| 订阅条款 | Warunki subskrypcji |
| 内容审核与举报政策 | Zasady moderacji treści i zgłoszeń |
| 举报此资料 | Zgłoś ten profil(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Ukryj ten profil(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Usuń konto i dane(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Eksportuj moje dane (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 Ty(T 大写,亲切),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——może / uważa się / tradycyjnie 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Harmonia to wynik kulturowej eksploracji, a nie prognoza powodzenia związku."
3. **文化词**:BaZi、Władca dnia、Niebiańskie łodygi 首次出现保持既有译名;不使用 wróżenie 类贬义措辞,用 kulturowe spojrzenie / tradycyjny system。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;引号 „…";% 之前留空格(如 50 %)。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
