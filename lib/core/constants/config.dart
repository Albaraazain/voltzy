class Config {
  // Financial Constants
  static const double serviceFeePercentage = 0.10; // 10% service fee
  static const double platformFeePercentage = 0.05; // 5% platform fee
  static const double taxRate = 0.13; // 13% tax rate

  // Payment Limits
  static const double minPaymentAmount =
      10.0; // Minimum payment amount in dollars
  static const double maxPaymentAmount =
      10000.0; // Maximum payment amount in dollars

  // Timeouts
  static const int paymentTimeoutSeconds = 300; // 5 minutes
  static const int refundTimeoutSeconds = 432000; // 5 days

  // Retry Configuration
  static const int maxPaymentRetries = 3;
  static const int retryDelaySeconds = 60;

  // Payment Method Limits
  static const int maxPaymentMethods = 5;
  static const int maxSavedCards = 3;

  // Payment Link Configuration
  static const int paymentLinkExpiryHours = 24;
  static const int paymentSessionTimeoutMinutes = 30;
}
