import './i_sentiment_analysis.dart';

class DemoNaiiveSentimentAnalyzer implements ISentimentAnalyzer {
  static const Set<String> goodWordSet = {"happy", "good"};
  static const Set<String> badWordSet = {"sad", "bad"};
  @override
  double analyzeText(String contents) {
    // counts the good words, bad words, and total words
    // and calculates a naiive sentiment analysis.
    double wordCount = 0;
    double goodWords = 0;
    double badWords = 0;
    for (String word in contents.toLowerCase().split(" ")) {
      wordCount += 1;
      if (goodWordSet.contains(word)) {
        goodWords += 1;
      } else if (badWordSet.contains(word)) {
        badWords += 1;
      }
    }
    if (wordCount > 0) { // avoid divide by 0
      // range from 1 (good) to -1 (bad)
      var simpleScale = ((goodWords - badWords) / wordCount);
      // remap to 1 .. 0
      return (simpleScale + 1.0) / 2.0;
    } else {
      return 0.5;
    }
  }
}
