class PriceData {
  final String buyPrice;
  final String sellPrice;
  final String currentPrice;
  final String changeAmount;
  final String changePercentage;
  final bool isIncreasing;
  final bool isDecreasing;

  PriceData({
    this.buyPrice = '',
    this.sellPrice = '',
    this.currentPrice = '',
    this.changeAmount = '',
    this.changePercentage = '',
    this.isIncreasing = false,
    this.isDecreasing = false,
  });
} 