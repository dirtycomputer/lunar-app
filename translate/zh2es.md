# 术语表:中文 → Español(zh2es)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Español | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译 |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "el sistema BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Español |
|---|---|
| 五行 | Los cinco elementos |
| 木 | Madera |
| 火 | Fuego |
| 土 | Tierra |
| 金 | Metal |
| 水 | Agua |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metal,阳木 = Yang Madera(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Español |
|---|---|
| 甲 | Yang Madera |
| 乙 | Yin Madera |
| 丙 | Yang Fuego |
| 丁 | Yin Fuego |
| 戊 | Yang Tierra |
| 己 | Yin Tierra |
| 庚 | Yang Metal |
| 辛 | Yin Metal |
| 壬 | Yang Agua |
| 癸 | Yin Agua |

## 四、十二地支(生肖名显示)

| 中文 | Español |
|---|---|
| 子 | Rata |
| 丑 | Buey |
| 寅 | Tigre |
| 卯 | Conejo |
| 辰 | Dragón |
| 巳 | Serpiente |
| 午 | Caballo |
| 未 | Cabra |
| 申 | Mono |
| 酉 | Gallo |
| 戌 | Perro |
| 亥 | Cerdo |

## 五、核心概念

| 中文 | Español | 说明 |
|---|---|---|
| 四柱 | Cuatro pilares | |
| 天干地支 | Talos celestes y ramas terrestres | |
| 日主 | Maestro del día | |
| 十神 | Diez Dioses | |
| 合 | Combinaciones | |
| 冲 | Choque | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Daño | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trígono | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Hora solar verdadera | |
| 平太阳时 | Hora solar media | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Ciclo de fortuna | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Suerte anual | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Zodiaco chino | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Equilibrio de elementos | |
| 日主关系 | Conexión entre maestros del día | |
| 日支共鸣 | Resonancia de ramas del día | |
| 和谐分 | Puntuación de armonía | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Elaborar la carta | ARB 无对应 key;动词 |
| 命盘 | Carta natal | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Zona horaria | ARB 无对应 key |
| 夏令时 | Horario de verano | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Español |
|---|---|
| 取消 | Cancelar |
| 关闭 | Cerrar |
| 重置 | Restablecer |
| 筛选 | Filtros |
| 发现 | Descubrir |
| 连接 | Guardados(人脉/收藏的档案) |
| 我的能量 | Mi energía |
| 指南 | Guía |
| 工作室 | Estudio |
| 服务条款 | Términos del Servicio |
| 隐私政策 | Política de Privacidad |
| 社区准则 | Normas de la Comunidad |
| 安全指南 | Guías de Seguridad para Citas |
| 儿童安全(CSAE)政策 | Política de Seguridad Infantil (CSAE) |
| 账号与数据删除政策 | Política de Eliminación de Cuenta y Datos |
| 订阅条款 | Términos de Suscripción |
| 内容审核与举报政策 | Política de Moderación de Contenido y Denuncias |
| 举报此资料 | Denunciar este perfil(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Ocultar este perfil(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Eliminar cuenta y datos(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Exportar mis datos (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 tú(亲切、非正式),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——puede / se considera / tradicionalmente 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"La armonía es una puntuación de exploración cultural, no una predicción del éxito de la relación."
3. **文化词**:BaZi、Maestro del día、Talos celestes 首次出现保持既有译名;不使用 adivinación 类贬义措辞,用 enfoque cultural / sistema tradicional。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;疑问句用倒置符号 ¿…?,感叹句用 ¡…!。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
