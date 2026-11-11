import '../l10n/generated/app_localizations.dart';
import '../services/bazi.dart' as bazi;

String cycleFact(AppLocalizations l, bazi.Element from) => switch (from) {
      bazi.Element.wood => l.gardenWoodFact,
      bazi.Element.fire => l.gardenFireFact,
      bazi.Element.earth => l.gardenEarthFact,
      bazi.Element.metal => l.gardenMetalFact,
      bazi.Element.water => l.gardenWaterFact,
    };
String elementMeaning(AppLocalizations l, bazi.Element element) =>
    switch (element) {
      bazi.Element.wood => l.gardenWoodMeaning,
      bazi.Element.fire => l.gardenFireMeaning,
      bazi.Element.earth => l.gardenEarthMeaning,
      bazi.Element.metal => l.gardenMetalMeaning,
      bazi.Element.water => l.gardenWaterMeaning,
    };
