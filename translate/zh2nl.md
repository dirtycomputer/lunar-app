# 术语表:中文 → Nederlands(zh2nl)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Nederlands | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "het BaZi-systeem" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Nederlands |
|---|---|
| 五行 | De vijf elementen |
| 木 | Hout |
| 火 | Vuur |
| 土 | Aarde |
| 金 | Metaal |
| 水 | Water |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metaal,阳木 = Yang Hout(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Nederlands |
|---|---|
| 甲 | Yang Hout |
| 乙 | Yin Hout |
| 丙 | Yang Vuur |
| 丁 | Yin Vuur |
| 戊 | Yang Aarde |
| 己 | Yin Aarde |
| 庚 | Yang Metaal |
| 辛 | Yin Metaal |
| 壬 | Yang Water |
| 癸 | Yin Water |

## 四、十二地支(生肖名显示)

| 中文 | Nederlands |
|---|---|
| 子 | Rat |
| 丑 | Os |
| 寅 | Tijger |
| 卯 | Konijn |
| 辰 | Draak |
| 巳 | Slang |
| 午 | Paard |
| 未 | Geit |
| 申 | Aap |
| 酉 | Haan |
| 戌 | Hond |
| 亥 | Varken |

## 五、核心概念

| 中文 | Nederlands | 说明 |
|---|---|---|
| 四柱 | Vier pilaren | |
| 天干地支 | Hemelstammen & aardtakken | |
| 日主 | Dagheerser | |
| 十神 | Tien Goden | |
| 合 | Combinaties | |
| 冲 | Botsing | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Schade | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigon | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Ware zonnetijd | |
| 平太阳时 | Middelbare zonnetijd | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Gelukscyclus | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Jaargeluk | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Chinese dierenriem | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Elementbalans | |
| 日主关系 | Dagheerser-connectie | |
| 日支共鸣 | Dagtak-resonantie | |
| 和谐分 | Harmoniescore | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Schema opstellen | ARB 无对应 key;动词 |
| 命盘 | Geboorteschema | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Tijdzone | ARB 无对应 key |
| 夏令时 | Zomertijd | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Nederlands |
|---|---|
| 取消 | Annuleren |
| 关闭 | Sluiten |
| 重置 | Resetten |
| 筛选 | Filters |
| 发现 | Ontdekken |
| 连接 | Opgeslagen(人脉/收藏的档案) |
| 我的能量 | Mijn energie |
| 指南 | Gids |
| 工作室 | Studio |
| 服务条款 | Servicevoorwaarden |
| 隐私政策 | Privacybeleid |
| 社区准则 | Communityrichtlijnen |
| 安全指南 | Veiligheidsrichtlijnen voor daten |
| 儿童安全(CSAE)政策 | Kinderveiligheidsbeleid (CSAE) |
| 账号与数据删除政策 | Beleid voor account- en gegevensverwijdering |
| 订阅条款 | Abonnementsvoorwaarden |
| 内容审核与举报政策 | Contentmoderatie- en meldingsbeleid |
| 举报此资料 | Dit profiel melden(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Dit profiel verbergen(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Account & gegevens verwijderen(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Mijn gegevens exporteren (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 jij(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——kan / geldt als / traditioneel 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Harmonie is een score voor culturele verkenning, geen voorspelling van het slagen van een relatie."
3. **文化词**:BaZi、Dagheerser、Hemelstammen 首次出现保持既有译名;不使用 waarzeggerij 类贬义措辞,用 cultureel inzicht / traditioneel systeem。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「–」;% 紧贴数字(如 50%)。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
