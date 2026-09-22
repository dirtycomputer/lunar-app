# 术语表:中文 → Türkçe(zh2tr)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Türkçe | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "BaZi sistemi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Türkçe |
|---|---|
| 五行 | Beş element |
| 木 | Ağaç |
| 火 | Ateş |
| 土 | Toprak |
| 金 | Metal |
| 水 | Su |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metal,阳木 = Yang Ağaç(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Türkçe |
|---|---|
| 甲 | Yang Ağaç |
| 乙 | Yin Ağaç |
| 丙 | Yang Ateş |
| 丁 | Yin Ateş |
| 戊 | Yang Toprak |
| 己 | Yin Toprak |
| 庚 | Yang Metal |
| 辛 | Yin Metal |
| 壬 | Yang Su |
| 癸 | Yin Su |

## 四、十二地支(生肖名显示)

| 中文 | Türkçe |
|---|---|
| 子 | Fare |
| 丑 | Öküz |
| 寅 | Kaplan |
| 卯 | Tavşan |
| 辰 | Ejderha |
| 巳 | Yılan |
| 午 | At |
| 未 | Keçi |
| 申 | Maymun |
| 酉 | Horoz |
| 戌 | Köpek |
| 亥 | Domuz |

## 五、核心概念

| 中文 | Türkçe | 说明 |
|---|---|---|
| 四柱 | Dört Sütun | |
| 天干地支 | Göksel gövdeler ve yer dalları | |
| 日主 | Gün efendisi | |
| 十神 | On Tanrı | |
| 合 | Birleşimler | |
| 冲 | Çatışma | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Zarar | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Üçgen | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Gerçek güneş zamanı | |
| 平太阳时 | Ortalama güneş zamanı | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Şans döngüsü | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Yıllık şans | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Çin burçları | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Element dengesi | |
| 日主关系 | Gün efendisi ilişkisi | |
| 日支共鸣 | Gün dalı rezonansı | |
| 和谐分 | Uyum puanı | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Harita oluştur | ARB 无对应 key;动词 |
| 命盘 | Doğum haritası | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Saat dilimi | ARB 无对应 key |
| 夏令时 | Yaz saati uygulaması | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Türkçe |
|---|---|
| 取消 | İptal |
| 关闭 | Kapat |
| 重置 | Sıfırla |
| 筛选 | Filtreler |
| 发现 | Keşfet |
| 连接 | Kaydedilenler(人脉/收藏的档案) |
| 我的能量 | Enerjim |
| 指南 | Rehber |
| 工作室 | Stüdyo |
| 服务条款 | Hizmet Şartları |
| 隐私政策 | Gizlilik Politikası |
| 社区准则 | Topluluk Kuralları |
| 安全指南 | Flört Güvenliği Rehberi |
| 儿童安全(CSAE)政策 | Çocuk Güvenliği (CSAE) Politikası |
| 账号与数据删除政策 | Hesap ve Veri Silme Politikası |
| 订阅条款 | Abonelik Koşulları |
| 内容审核与举报政策 | İçerik Denetimi ve Bildirim Politikası |
| 举报此资料 | Bu profili bildir(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Bu profili gizle(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Hesabı ve verileri sil(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Verilerimi dışa aktar (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 siz(敬体,亲切而礼貌),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——olabilir / kabul edilir / geleneksel olarak 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"Uyum kültürel bir keşif puanıdır, ilişkinin başarısına dair bir öngörü değildir."
3. **文化词**:BaZi、Gün efendisi、Göksel gövdeler 首次出现保持既有译名;不使用 falcılık 类贬义措辞,用 kültürel bakış / geleneksel sistem。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;百分号前置(如 %50);标点之后空格、之前不空格。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
