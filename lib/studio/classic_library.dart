class ClassicPassage {
  final String id, book, section, original, plain, professional, url;
  const ClassicPassage(this.id, this.book, this.section, this.original,
      this.plain, this.professional, this.url);
}

// Short public-domain excerpts. English explanations are original editorial
// summaries, not quoted translations or claims of a full classical corpus.
const classicPassages = [
  ClassicPassage(
      'dt-01',
      'Di Tian Sui · 滴天髓',
      'Heavenly stems',
      '五阳皆阳丙为最，五阴皆阴癸为至。',
      'The text uses Bing fire and Gui water as vivid examples of yang and yin. These are symbolic qualities, not a diagnosis of a person.',
      'The stem discussion distinguishes polarity within the Ten Stems. Read this in the context of season, roots and the whole structure; a day stem alone is insufficient.',
      'https://ctext.org/wiki.pl?chapter=126492&if=gb&remap=gb'),
  ClassicPassage(
      'sm-01',
      'San Ming Tong Hui · 三命通会',
      'Heavenly noble',
      '甲戊庚牛羊，乙己鼠猴乡。',
      'A mnemonic connects certain heavenly stems to the Ox, Goat, Rat and Monkey branches. Lunar shows exactly which rule produced a symbolic star.',
      'For the convention used here, Jia/Wu/Geng map to Chou/Wei, while Yi/Ji map to Zi/Shen. Different schools may choose year or day stems; this implementation uses the day stem.',
      'https://ctext.org/wiki.pl?chapter=117077&if=en'),
  ClassicPassage(
      'sw-01',
      'Su Wen · 素问',
      'Tian Yuan Ji Da Lun · 天元纪大论',
      '甲己之岁，土运统之。',
      'The Five Movements tradition associates Jia and Ji years with earth. The diagram is a cultural calendar, not a weather forecast or a health assessment.',
      'Annual movement is assigned from paired year stems: Jia/Ji Earth, Yi/Geng Metal, Bing/Xin Water, Ding/Ren Wood, Wu/Gui Fire. Yang years are classed as excess and yin years as insufficiency.',
      'https://ctext.org/wiki.pl?chapter=69728&if=en&remap=gb'),
];
