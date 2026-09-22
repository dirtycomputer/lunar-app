# 术语表:中文 → Français(zh2fr)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Français | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "le système BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Français |
|---|---|
| 五行 | les cinq éléments |
| 木 | Bois |
| 火 | Feu |
| 土 | Terre |
| 金 | Métal |
| 水 | Eau |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Métal,阳木 = Yang Bois(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Français |
|---|---|
| 甲 | Yang Bois |
| 乙 | Yin Bois |
| 丙 | Yang Feu |
| 丁 | Yin Feu |
| 戊 | Yang Terre |
| 己 | Yin Terre |
| 庚 | Yang Métal |
| 辛 | Yin Métal |
| 壬 | Yang Eau |
| 癸 | Yin Eau |

## 四、十二地支(生肖名显示)

| 中文 | Français |
|---|---|
| 子 | Rat |
| 丑 | Bœuf |
| 寅 | Tigre |
| 卯 | Lapin |
| 辰 | Dragon |
| 巳 | Serpent |
| 午 | Cheval |
| 未 | Chèvre |
| 申 | Singe |
| 酉 | Coq |
| 戌 | Chien |
| 亥 | Porc |

## 五、核心概念

| 中文 | Français | 说明 |
|---|---|---|
| 四柱 | Quatre piliers | |
| 天干地支 | Troncs célestes et branches terrestres | |
| 日主 | Maître du jour | |
| 十神 | Dix Dieux | |
| 合 | Combinaisons | |
| 冲 | Conflit | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Tort | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trigone | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Temps solaire vrai | |
| 平太阳时 | Temps solaire moyen | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Cycle de chance | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Chance annuelle | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Zodiaque chinois | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Équilibre des éléments | |
| 日主关系 | Connexion entre maîtres du jour | |
| 日支共鸣 | Résonance des branches du jour | |
| 和谐分 | Score d'harmonie | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Établir un thème | ARB 无对应 key;动词 |
| 命盘 | Thème de naissance | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Fuseau horaire | ARB 无对应 key |
| 夏令时 | Heure d'été | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Français |
|---|---|
| 取消 | Annuler |
| 关闭 | Fermer |
| 重置 | Réinitialiser |
| 筛选 | Filtres |
| 发现 | Découvrir |
| 连接 | Enregistrés(人脉/收藏的档案) |
| 我的能量 | Mon énergie |
| 指南 | Guide |
| 工作室 | Studio |
| 服务条款 | Conditions d'utilisation |
| 隐私政策 | Politique de confidentialité |
| 社区准则 | Règles de la communauté |
| 安全指南 | Conseils de sécurité pour les rencontres |
| 儿童安全(CSAE)政策 | Politique de sécurité des enfants (CSAE) |
| 账号与数据删除政策 | Politique de suppression de compte et de données |
| 订阅条款 | Conditions d'abonnement |
| 内容审核与举报政策 | Politique de modération et de signalement |
| 举报此资料 | Signaler ce profil(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Masquer ce profil(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Supprimer le compte et les données(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Exporter mes données (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 vous(亲切而礼貌),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——peut / il est dit que / traditionnellement 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):« L'harmonie est un score d'exploration culturelle, pas une prédiction du succès de la relation. »
3. **文化词**:BaZi、Maître du jour、Troncs célestes 首次出现保持既有译名;不使用 voyance 类贬义措辞,用 éclairage culturel / système traditionnel。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;引号 « … »(内含窄不换行空格);!、?、:、; 之前按法语惯例留空格。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
