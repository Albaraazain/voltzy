class Config {
  // Payment fee percentages
  static const double SERVICE_FEE_PERCENTAGE = 0.10; // 10% service fee
  static const double PLATFORM_FEE_PERCENTAGE = 0.05; // 5% platform fee
  static const double TAX_RATE = 0.13; // 13% tax rate

  // Payment thresholds
  static const double MIN_PAYMENT_AMOUNT = 0.0;
  static const double MAX_PAYMENT_AMOUNT = 10000.0;

  // Payment processing timeouts
  static const int PAYMENT_TIMEOUT_SECONDS = 30;
  static const int REFUND_TIMEOUT_SECONDS = 30;

  // Payment retry settings
  static const int MAX_PAYMENT_RETRIES = 3;
  static const int RETRY_DELAY_SECONDS = 5;

  // Payment method limits
  static const int MAX_PAYMENT_METHODS = 5;
  static const int MAX_SAVED_CARDS = 3;

  // Payment expiry settings
  static const int PAYMENT_LINK_EXPIRY_HOURS = 24;
  static const int PAYMENT_SESSION_TIMEOUT_MINUTES = 30;
}
