# 术语表:中文 → Português(zh2pt)

Lunar 应用的翻译基准表。每个 `zh2<目标语言>.md` 与本文件结构一致。
**规则:每次为新语言翻译或修订 ARB 前,必须先读对应 zh2XX 文件,术语逐条对照,不得临场发挥。**

## 一、不变译名(所有语言一致)

| 中文 | Português | 说明 |
|---|---|---|
| Lunar | Lunar | 产品名,不译;葡语惯用定冠词时写作 "o Lunar" |
| BaZi(八字) | BaZi | 体系名,保留拼音;正文中可补 "o sistema BaZi" |
| Chart Studio | Chart Studio | 功能名,不译 |
| lunar(logo 文字) | lunar | 小写,不译 |

## 二、五行与阴阳

| 中文 | Português |
|---|---|
| 五行 | Os cinco elementos |
| 木 | Madeira |
| 火 | Fogo |
| 土 | Terra |
| 金 | Metal |
| 水 | Água |
| 阴 | Yin |
| 阳 | Yang |

复合词大写:阴金 = Yin Metal,阳木 = Yang Madeira(应用 identityLabel 固定拼接 "{polarity} {element}",极性在前)。

## 三、十天干(显示形式:"阴阳+元素")

| 中文 | Português |
|---|---|
| 甲 | Yang Madeira |
| 乙 | Yin Madeira |
| 丙 | Yang Fogo |
| 丁 | Yin Fogo |
| 戊 | Yang Terra |
| 己 | Yin Terra |
| 庚 | Yang Metal |
| 辛 | Yin Metal |
| 壬 | Yang Água |
| 癸 | Yin Água |

## 四、十二地支(生肖名显示)

| 中文 | Português |
|---|---|
| 子 | Rato |
| 丑 | Boi |
| 寅 | Tigre |
| 卯 | Coelho |
| 辰 | Dragão |
| 巳 | Serpente |
| 午 | Cavalo |
| 未 | Cabra |
| 申 | Macaco |
| 酉 | Galo |
| 戌 | Cão |
| 亥 | Porco |

## 五、核心概念

| 中文 | Português | 说明 |
|---|---|---|
| 四柱 | Quatro pilares | |
| 天干地支 | Troncos celestes e ramos terrestres | |
| 日主 | Mestre do dia | |
| 十神 | Dez Deuses | |
| 合 | Combinações | |
| 冲 | Choque | ARB 无对应 key,为 Studio 本地化预留 |
| 刑 | Dano | ARB 无对应 key,为 Studio 本地化预留 |
| 三合 | Trígono | ARB 无对应 key;与「合」区分,指三支成局 |
| 真太阳时 | Hora solar verdadeira | |
| 平太阳时 | Hora solar média | ARB 无对应 key;与真太阳时区分(不做均时差修正) |
| 大运 | Ciclo de sorte | ARB 无对应 key,为 Studio 本地化预留 |
| 流年 | Sorte anual | ARB 无对应 key,为 Studio 本地化预留 |
| 生肖 | Zodíaco chinês | ARB 无对应 key;即十二地支对应的动物 |
| 五行平衡 | Equilíbrio de elementos | |
| 日主关系 | Conexão entre mestres do dia | |
| 日支共鸣 | Ressonância dos ramos do dia | |
| 和谐分 | Pontuação de harmonia | ARB 无对应 key,为 Studio 本地化预留 |
| 排盘 | Elaborar o mapa | ARB 无对应 key;动词 |
| 命盘 | Mapa natal | ARB 无对应 key,为 Studio 本地化预留 |
| 时区 | Fuso horário | ARB 无对应 key |
| 夏令时 | Horário de verão | ARB 无对应 key |

## 六、UI 动词与界面词(与 ARB 既有词条保持一致)

| 中文 | Português |
|---|---|
| 取消 | Cancelar |
| 关闭 | Fechar |
| 重置 | Redefinir |
| 筛选 | Filtros |
| 发现 | Descobrir |
| 连接 | Salvos(人脉/收藏的档案) |
| 我的能量 | Minha energia |
| 指南 | Guia |
| 工作室 | Estúdio |
| 服务条款 | Termos de Serviço |
| 隐私政策 | Política de Privacidade |
| 社区准则 | Diretrizes da Comunidade |
| 安全指南 | Diretrizes de Segurança para Namoro |
| 儿童安全(CSAE)政策 | Política de Segurança Infantil (CSAE) |
| 账号与数据删除政策 | Política de Exclusão de Conta e Dados |
| 订阅条款 | Termos de Assinatura |
| 内容审核与举报政策 | Política de Moderação de Conteúdo e Denúncias |
| 举报此资料 | Denunciar este perfil(含宾语,裸动词截取动词部分) |
| 隐藏此资料 | Ocultar este perfil(含宾语,裸动词截取动词部分) |
| 删除账号与数据 | Excluir conta e dados(含宾语,裸动词截取动词部分) |
| 导出我的数据(JSON) | Exportar meus dados (JSON)(含宾语,裸动词截取动词部分) |

## 七、语气与风格规则

1. **第二人称**:用 você(亲切、通用),与 ARB 既有翻译保持一致。
2. **谦逊表述**:命理结论一律软化——pode / considera-se / tradicionalmente 类推定词,避免断言。已有固定句式(harmonyNote,示意;以 ARB 现有译文为准):"A harmonia é uma pontuação de exploração cultural, não uma previsão do sucesso da relação."
3. **文化词**:BaZi、Mestre do dia、Troncos celestes 首次出现保持既有译名;不使用 adivinhação 类贬义措辞,用 leitura cultural / sistema tradicional。
4. **法律文本**:正文当前为占位草稿(英文),法务定稿前不翻译正文;标题必须本地化(见 docTerms…docModeration 8 个 key)。
5. **省略号与破折号**:省略号用「…」,破折号用「—」;% 紧贴数字(如 50%)。
6. **占位符**:ARB 里 `{name}`、`{count}`、`{a}` 等占位符必须原样保留,不得翻译、不得移动到语法错误的位置。
