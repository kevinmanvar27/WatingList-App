class RazorpayKeys {
  bool success;
  RazorpayData data;
  String message;

  RazorpayKeys({
    required this.success,
    required this.data,
    required this.message,
  });

}

class RazorpayData {
  String keyId;
  String keySecret;

  RazorpayData({
    required this.keyId,
    required this.keySecret,
  });

}
