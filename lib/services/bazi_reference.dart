String generalReference(String question) {
  final q = question.toLowerCase();
  if (RegExp(r'ten god|十神').hasMatch(q)) {
    return 'The Ten Gods (十神) name relationships between a chart’s day stem and other heavenly stems. The calculation uses the five-element generating/controlling cycles together with yin and yang.\n\nPeer, output, wealth, officer, and resource relationships each have two polarities, making ten categories. They describe traditional relationships, not ten literal deities.';
  }
  if (RegExp(r'day master|日主').hasMatch(q)) {
    return 'The day master (日主) is the heavenly stem of the day pillar. It is the reference point for calculating the Ten Gods.\n\nIts element and yin/yang polarity are calculated from the birth date and the selected day-boundary convention. Determining seasonal strength requires more analysis than counting visible elements.';
  }
  if (RegExp(r'solar|太阳时').hasMatch(q)) {
    return 'Local mean solar time uses UTC plus four minutes for each degree of longitude east of Greenwich; western longitudes subtract time. Apparent solar time adds an equation-of-time correction.\n\nFatePair’s default chart uses mean solar time for day/hour pillars. Year/month solar terms still follow the physical birth instant. You can change the convention in Tools.';
  }
  if (RegExp(r'bazi|eight character|four pillar|八字|四柱').hasMatch(q)) {
    return 'BaZi (八字) means Eight Characters. The year, month, day, and hour each form a pillar with a heavenly stem and an earthly branch.\n\nThe month follows solar terms rather than the first day of a lunar month. The day stem is the day master; other stems are interpreted in relation to it. Birth time can be omitted, leaving a partial three-pillar chart.';
  }
  if (RegExp(r'my|mine|自己|我的').hasMatch(q)) {
    return 'Add your birth details to ask about your own chart.';
  }
  return 'I can explain BaZi, the day master, Ten Gods, and solar-time conventions from the reference material. Connect a model for an open-ended BaZi question.';
}
