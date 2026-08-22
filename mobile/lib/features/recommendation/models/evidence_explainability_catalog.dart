import 'evidence_kind.dart';
import 'metric_explainability.dart';

class EvidenceExplainabilityCatalog {
  const EvidenceExplainabilityCatalog._();

  static const Map<EvidenceKind, MetricExplainability> definitions = {
    EvidenceKind.candleTrend: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs: 'Measures the overall direction of the recent candle sequence.',
      calculation:
          'Compares the first and last closing prices in the analyzed sequence. Reliability also considers sample size and how efficiently price travelled in the resulting direction.',
      whyItMatters:
          'A sustained directional move can indicate persistent buying or selling pressure.',
      supportiveInterpretation:
          'A sustained upward sequence can support bullish evidence, while a sustained downward sequence can support bearish evidence.',
      opposingInterpretation:
          'When the candle trend points against the candidate setup, it opposes that direction. Mostly sideways movement is treated as neutral rather than forced into a directional signal.',
      neutralInterpretation:
          'A small or inconsistent net move provides little directional confirmation.',
      recommendationImpact:
          'Candle Trend can influence direction and evidence-derived confidence inside the Trend evidence family. It is aggregated with related trend evidence rather than counted as a fully independent vote.',
      limitations:
          'The result depends on the selected analysis window and can be distorted by short-lived moves, gaps or volatile reversals. Recent direction does not guarantee continuation.',
    ),

    EvidenceKind.rsi: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs: 'Measures recent price momentum on a scale from 0 to 100.',
      calculation:
          'Uses average gains and average losses over the selected RSI lookback period to calculate the Relative Strength Index.',
      whyItMatters:
          'Extreme momentum can identify stretched conditions where continuation may become less reliable and reversal risk may increase.',
      supportiveInterpretation:
          'Oversold RSI conditions can contribute bullish reversal evidence when downward momentum appears unusually stretched.',
      opposingInterpretation:
          'Overbought RSI conditions can contribute bearish pullback evidence when upward momentum appears unusually stretched.',
      neutralInterpretation:
          'Mid-range RSI values do not provide strong reversal evidence in either direction.',
      recommendationImpact:
          'RSI contributes directional and confidence information inside the Momentum family and is aggregated with related momentum evidence.',
      limitations:
          'Overbought does not automatically mean price will fall and oversold does not automatically mean price will rise. Strong trends can keep RSI extreme for extended periods.',
    ),

    EvidenceKind.relativeVolume: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Compares current trading activity with the stock\'s recent volume baseline.',
      calculation:
          'Divides the current candle volume by average volume from prior candles in the configured lookback.',
      whyItMatters:
          'A price move accompanied by unusually strong participation can carry more conviction than the same move on ordinary or weak volume.',
      supportiveInterpretation:
          'Above-average volume strengthens the significance of the latest price move. It can therefore confirm either bullish or bearish price action.',
      opposingInterpretation:
          'Weak participation does not automatically create evidence in the opposite direction. Instead it reduces conviction in the price move and is normally treated as neutral directional evidence.',
      neutralInterpretation:
          'Volume close to its recent baseline provides little unusual confirmation.',
      recommendationImpact:
          'Relative Volume affects the Participation family. Strong participation can reinforce the direction of price action, while weak participation reduces confirmation without inventing an opposite signal.',
      limitations:
          'Intraday volume naturally varies by time of day. The current development calculation uses a recent-candle baseline and will require stronger time-of-day normalization with authoritative live data.',
    ),

    EvidenceKind.emaStructure: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Checks the ordering of current price and fast and slow exponential moving averages.',
      calculation:
          'Compares price with the fast EMA and slow EMA and measures the normalized distance between them.',
      whyItMatters:
          'A clean moving-average structure can indicate that short-term price action agrees with the underlying trend.',
      supportiveInterpretation:
          'Price above the fast EMA with the fast EMA above the slow EMA supports bullish trend evidence.',
      opposingInterpretation:
          'Price below the fast EMA with the fast EMA below the slow EMA supports bearish trend evidence.',
      neutralInterpretation:
          'Mixed moving-average ordering is treated as neutral rather than forced into a trend direction.',
      recommendationImpact:
          'EMA Structure contributes inside the Trend family and is de-duplicated with other related trend signals before final direction and confidence are calculated.',
      limitations:
          'Moving averages are lagging indicators and can react slowly to abrupt reversals. Choppy markets can produce repeated false transitions.',
    ),

    EvidenceKind.macdMomentum: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures momentum using the relationship between fast and slow exponential moving averages and a MACD signal line.',
      calculation:
          'Calculates MACD from the fast EMA minus the slow EMA, compares it with the signal line, and normalizes histogram magnitude by stock price.',
      whyItMatters:
          'MACD can show whether momentum is strengthening, weakening or transitioning.',
      supportiveInterpretation:
          'MACD above its signal line with a positive histogram can contribute bullish momentum evidence.',
      opposingInterpretation:
          'MACD below its signal line with a negative histogram can contribute bearish momentum evidence.',
      neutralInterpretation:
          'Mixed or very small MACD relationships provide weak or neutral directional information.',
      recommendationImpact:
          'MACD contributes inside the Momentum family. Its influence is combined with other momentum evidence rather than treated as an independent duplicate confirmation.',
      limitations:
          'MACD is derived from moving averages and therefore lags price. Rapidly changing or sideways markets can create false momentum transitions.',
    ),

    EvidenceKind.vwapPosition: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Shows whether current price is trading above or below the volume-weighted average price of the active analysis window.',
      calculation:
          'Calculates a volume-weighted average of candle typical prices and measures the latest price\'s percentage distance from that VWAP.',
      whyItMatters:
          'VWAP provides an intraday reference for whether current price is trading above or below the average price paid during the analyzed window.',
      supportiveInterpretation:
          'Price meaningfully above VWAP can support bullish price-structure evidence.',
      opposingInterpretation:
          'Price meaningfully below VWAP can support bearish price-structure evidence.',
      neutralInterpretation:
          'Price close to VWAP provides little directional structure evidence.',
      recommendationImpact:
          'VWAP contributes inside the Price Structure family and is aggregated with support/resistance evidence so correlated structure signals cannot multiply confidence independently.',
      limitations:
          'The result depends on the chosen analysis window and available volume data. VWAP is a reference level, not a guaranteed support or resistance boundary.',
    ),

    EvidenceKind.supportResistance: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Evaluates current price relative to recent local support and resistance levels.',
      calculation:
          'Uses prior candle highs and lows to identify local levels and uses ATR to normalize breakout and proximity thresholds.',
      whyItMatters:
          'Price can react near established levels, while a sufficiently strong break through a level can strengthen directional evidence.',
      supportiveInterpretation:
          'Holding near support or breaking above resistance can contribute bullish price-structure evidence.',
      opposingInterpretation:
          'Holding near resistance or breaking below support can contribute bearish price-structure evidence.',
      neutralInterpretation:
          'Price between meaningful levels without a breakout or immediate level test is treated as neutral.',
      recommendationImpact:
          'Support and Resistance contributes inside the Price Structure family and is aggregated with related structure evidence such as VWAP.',
      limitations:
          'Detected levels are local to the analysis window and are not guaranteed barriers. Volatility, gaps and changing market conditions can invalidate them quickly.',
    ),

    EvidenceKind.volumeConfirmation: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Checks whether recent changes in trading participation confirm or challenge recent price direction.',
      calculation:
          'Compares average volume in the recent part of the analysis window with the preceding part and evaluates that change together with price direction.',
      whyItMatters:
          'Directional price movement with expanding participation is generally more convincing than movement occurring while participation fades.',
      supportiveInterpretation:
          'Expanding volume in the same direction as a meaningful price move reinforces that direction.',
      opposingInterpretation:
          'A directional price move accompanied by materially fading volume can create divergence evidence against the move.',
      neutralInterpretation:
          'When neither price nor participation changes enough to be meaningful, the result remains neutral.',
      recommendationImpact:
          'Volume Confirmation contributes inside the Participation family and is combined with Relative Volume rather than counted as a separate independent participation vote.',
      limitations:
          'Volume relationships depend on the selected window and can be distorted by unusual sessions, opening or closing activity, news events and incomplete market data.',
    ),

    EvidenceKind.priceExtension: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures how far price is stretched from a short-term equilibrium after adjusting for the stock\'s own volatility.',
      calculation:
          'Measures price distance from EMA 21 and divides that distance by ATR to express extension in volatility-normalized ATR units.',
      whyItMatters:
          'A trend can remain directionally valid while price becomes a poor entry because it has moved too far too quickly.',
      supportiveInterpretation:
          'Material extension below short-term equilibrium can contribute bullish mean-reversion evidence by reducing conviction in chasing further downside.',
      opposingInterpretation:
          'Material extension above short-term equilibrium can contribute bearish mean-reversion evidence by increasing the risk of chasing further upside.',
      neutralInterpretation:
          'Price within a normal ATR-adjusted distance from equilibrium does not create meaningful extension evidence.',
      recommendationImpact:
          'Price Extension contributes through the Volatility family. It can challenge an otherwise strong directional setup without claiming that the underlying trend has already reversed.',
      limitations:
          'Strong trends can remain extended for long periods. Extension indicates entry and reversal risk, not a guaranteed turning point.',
    ),

    EvidenceKind.multiTimeframeTrend: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Compares the active Trader trend with confirmation and broader-regime timeframes.',
      calculation:
          'Evaluates normalized price direction across the primary, confirmation and regime timeframe roles and combines them using strategy-specific weights.',
      whyItMatters:
          'A short-term setup is generally more credible when higher timeframes agree and less credible when broader trends oppose it.',
      supportiveInterpretation:
          'Alignment of primary and higher-timeframe trends strengthens evidence in their shared direction.',
      opposingInterpretation:
          'Higher timeframes pointing against the active setup create directional conflict and weaken that setup.',
      neutralInterpretation:
          'Mixed timeframe direction provides partial or limited confirmation.',
      recommendationImpact:
          'Multi-Timeframe Trend contributes inside the Trend family. It does not receive an additional independent vote simply because multiple timeframes were inspected.',
      limitations:
          'Different timeframes can legitimately disagree during transitions. Alignment improves context but does not guarantee continuation.',
    ),

    EvidenceKind.marketContext: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Evaluates the stock relative to its broad-market and sector backdrop.',
      calculation:
          'Combines stock-versus-market and stock-versus-sector relative performance with smaller contributions from sector leadership and broad-market direction.',
      whyItMatters:
          'Stocks do not trade in isolation. Relative performance can separate genuine stock leadership or weakness from movement caused mainly by the broader market.',
      supportiveInterpretation:
          'Outperformance combined with a supportive market or sector backdrop can strengthen bullish context.',
      opposingInterpretation:
          'Underperformance combined with a challenging market or sector backdrop can strengthen bearish context.',
      neutralInterpretation:
          'Mixed benchmark relationships or a neutral backdrop provide limited directional context.',
      recommendationImpact:
          'Market and Sector Context contributes through the Market Context family. Related breadth evidence is aggregated within the same family rather than counted independently.',
      limitations:
          'Benchmark choice matters, sector mappings can be imperfect, and temporary stock-specific events can overwhelm broader market relationships.',
    ),

    EvidenceKind.marketBreadth: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Measures how broadly a market move is supported across underlying stocks and sectors.',
      calculation:
          'Combines advancing-stock participation, stocks above a medium-term trend reference, sector participation and a volatility-regime adjustment.',
      whyItMatters:
          'A headline index can move strongly while participation underneath it is narrow. Broader participation generally makes market direction more robust.',
      supportiveInterpretation:
          'Broad and healthy participation can contribute bullish market-context evidence.',
      opposingInterpretation:
          'Weak or stressed participation can contribute bearish market-context evidence.',
      neutralInterpretation:
          'Mixed breadth provides limited directional confirmation.',
      recommendationImpact:
          'Market Breadth contributes inside the existing Market Context family and therefore cannot double-count broader market evidence as an independent family.',
      limitations:
          'Breadth depends on the quality and completeness of the underlying universe. The current development source is synthetic and must not be presented as authoritative live market intelligence.',
    ),

    EvidenceKind.newsSentiment: MetricExplainability(
      semanticRole: MetricSemanticRole.directionalEvaluative,
      whatItIs:
          'Summarizes the directional tone of recent company-specific news.',
      calculation:
          'Uses a signed sentiment score and adjusts reliability using article count, independent source count, freshness and estimated materiality.',
      whyItMatters:
          'Material company news can reinforce, contradict or invalidate a technical setup.',
      supportiveInterpretation:
          'Sufficiently reliable positive sentiment can contribute bullish sentiment evidence.',
      opposingInterpretation:
          'Sufficiently reliable negative sentiment can contribute bearish sentiment evidence.',
      neutralInterpretation:
          'Mixed, weak or insufficiently diverse news coverage should not be forced into a directional conclusion.',
      recommendationImpact:
          'News Sentiment contributes through its own capped Sentiment family. Its influence remains subject to reliability, materiality and family-level controls.',
      limitations:
          'Sentiment classification can misinterpret nuance, repeated stories can exaggerate apparent coverage, and the current development data is synthetic rather than authoritative live news intelligence.',
    ),
  };

  static MetricExplainability? forKind(EvidenceKind kind) {
    return definitions[kind];
  }

  static bool get coversAllProductionKinds {
    final productionKinds = EvidenceKind.values.where(
      (kind) => kind != EvidenceKind.generic,
    );

    return productionKinds.every(definitions.containsKey) &&
        definitions.keys.every((kind) => kind != EvidenceKind.generic);
  }
}
