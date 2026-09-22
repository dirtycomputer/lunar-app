# 术语表:中文 → Dansk(zh2da)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Dansk | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "BaZi-systemet" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Dansk |
|---|---|
| 五行 | De fem elementer |
| 木 | Træ |
| 火 | Ild |
| 土 | Jord |
| 金 | Metal |
| 水 | Vand |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metal,阳木 = Yang Træ(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Dansk |
|---|---|
| 甲 | Yang Træ |
| 乙 | Yin Træ |
| 丙 | Yang Ild |
| 丁 | Yin Ild |
| 戊 | Yang Jord |
| 己 | Yin Jord |
| 庚 | Yang Metal |
| 辛 | Yin Metal |
| 壬 | Yang Vand |
| 癸 | Yin Vand |

## 四、十二地支(生肖名显示)

| 中文 | Dansk |
|---|---|
| 子 | Rotte |
| 丑 | Okse |
| 寅 | Tiger |
| 卯 | Kanin |
| 辰 | Drage |
| 巳 | Slange |
| 午 | Hest |
| 未 | Ged |
| 申 | Abe |
| 酉 | Hane |
| 戌 | Hund |
| 亥 | Svin |

## 五、核心概念

| 中文 | Dansk | 说明 |
|---|---|---|
| 四柱 | Fire søjler | |
| 天干地支 | Himmelstammer & jordgrene | |
| 日主 | Dagsherre | |
| 十神 | Ti guder | |
| 合 | Kombinationer | |
| 冲 | Kollision | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Skade | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trine | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Sand soltid | |
| 平太阳时 | Middel soltid | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Lykkecyklus | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Årlig lykke | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Kinesisk stjernetegn | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Elementbalance | |
| 日主关系 | Dagsherre-forbindelse | |
| 日支共鸣 | Dagsgrenresonans | |
| 和谐分 | Harmoniscore | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Opret diagram | ARB 无对应 key;动词 |
| 命盘 | Fødselsdiagram | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Tidszone | ARB 无对应 key |
| 夏令时 | Sommertid | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Dansk |
|---|---|
| 取消 | Annuller |
| 关闭 | Luk |
| 重置 | Nulstil |
| 筛选 | Filtre |
| 发现 | Opdag |
| 连接 | Gemte(人脉/收藏的档案) |
| 我的能量 | Min energi |
| 指南 | Guide |
| 工作室 | Studio |
| 服务条款 | Servicevilkår |
| 隐私政策 | Privatlivspolitik |
| 社区准则 | Fællesskabsretningslinjer |
| 安全指南 | Sikkerhedsvejledning til dating |
| 儿童安全(CSAE)政策 | Barnsikkerhedspolitik (CSAE) |
| 账号与数据删除政策 | Politik for sletning af konto og data |
| 订阅条款 | Abonnementsvilkår |
| 内容审核与举报政策 | Politik for indholdsmoderering og anmeldelser |
| 举报此资料 | Anmeld denne profil(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Skjul denne profil(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Slet konto & data(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Eksportér mine data (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 du(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——kan / anses for / traditionelt 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Harmoni er en score til kulturel udforskning, ikke en forudsigelse af et forholds succes."
3. **文化词**:BaZi、Dagsherre、Himmelstammer 首次出现保持既有译名;不使用 spådom 类贬义措辞,用 kulturel indsigt / traditionelt system。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「–」;小数用逗号,千位用点号。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
