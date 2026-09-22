# 术语表:中文 → Čeština(zh2cs)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Čeština | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "systém BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Čeština |
|---|---|
| 五行 | Pět prvků |
| 木 | Dřevo |
| 火 | Oheň |
| 土 | Země |
| 金 | Kov |
| 水 | Voda |
| 阴 | Jin |
| 阳 | Jang |

复合词大写:阴金 = Jin Kov,阳木 = Jang Dřevo(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Čeština |
|---|---|
| 甲 | Jang Dřevo |
| 乙 | Jin Dřevo |
| 丙 | Jang Oheň |
| 丁 | Jin Oheň |
| 戊 | Jang Země |
| 己 | Jin Země |
| 庚 | Jang Kov |
| 辛 | Jin Kov |
| 壬 | Jang Voda |
| 癸 | Jin Voda |

## 四、十二地支(生肖名显示)

| 中文 | Čeština |
|---|---|
| 子 | Krysa |
| 丑 | Buvol |
| 寅 | Tygr |
| 卯 | Králík |
| 辰 | Drak |
| 巳 | Had |
| 午 | Kůň |
| 未 | Koza |
| 申 | Opice |
| 酉 | Kohout |
| 戌 | Pes |
| 亥 | Prase |

## 五、核心概念

| 中文 | Čeština | 说明 |
|---|---|---|
| 四柱 | Čtyři pilíře | |
| 天干地支 | Nebeské kmeny a zemské větve | |
| 日主 | Pán dne | |
| 十神 | Deset bohů | |
| 合 | Kombinace | |
| 冲 | Střet | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Újma | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trojice | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Pravý sluneční čas | |
| 平太阳时 | Místní střední sluneční čas | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Cyklus štěstí | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Roční štěstí | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Čínský zvěrokruh | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Rovnováha prvků | |
| 日主关系 | Spojení pánů dne | |
| 日支共鸣 | Rezonance denní větve | |
| 和谐分 | Skóre harmonie | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Sestavit rozbor | ARB 无对应 key;动词 |
| 命盘 | Narozeninový rozbor | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Časové pásmo | ARB 无对应 key |
| 夏令时 | Letní čas | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Čeština |
|---|---|
| 取消 | Zrušit |
| 关闭 | Zavřít |
| 重置 | Resetovat |
| 筛选 | Filtry |
| 发现 | Objevovat |
| 连接 | Uložené(人脉/收藏的档案) |
| 我的能量 | Moje energie |
| 指南 | Průvodce |
| 工作室 | Studio |
| 服务条款 | Podmínky užívání |
| 隐私政策 | Zásady ochrany osobních údajů |
| 社区准则 | Pravidla komunity |
| 安全指南 | Zásady bezpečného randění |
| 儿童安全(CSAE)政策 | Zásady bezpečnosti dětí (CSAE) |
| 账号与数据删除政策 | Zásady mazání účtu a dat |
| 订阅条款 | Podmínky předplatného |
| 内容审核与举报政策 | Zásady moderace obsahu a hlášení |
| 举报此资料 | Nahlásit tento profil(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Skrýt tento profil(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Smazat účet a data(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Exportovat moje data (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 vy(小写,亲切但保持礼貌),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——可能/传统上认为 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):„Harmonie je skóre kulturního objevování, nikoli předpověď úspěchu vztahu."
3. **文化词**:BaZi、Pán dne、Nebeské kmeny 首次出现保持既有译名;不使用 věštba 类贬义措辞,用 kulturní vhled / tradiční systém。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「–」;捷克排版惯例:%、?、!、: 之前留空格;引号 „…"。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
