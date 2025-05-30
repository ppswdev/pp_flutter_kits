# pp_asa_attribution

Apple search ads attribution plugin

## Built on

- Flutter 3.24.5+
- iOS 14.3+
- Swift 5.0+
  
## Requirements

- Add iOS Framework: iAd、AdServices、AdSupport、AppTrackingTransparency
  
## Apple Documents

### Docs API

<https://developer.apple.com/documentation/adservices/aaattribution>

<https://developer.apple.com/documentation/adservices/changelog>

### Roles

The token that the framework returns is a Base64 encoded string and has a 24-hour TTL. You can provide the token to a Mobile Measurement Provider ( MMP), or app developers can use it to make a POST API call to fetch attribution records within the 24-hour TTL window. Use a single token in the request body and use a content-type of text/plain in the header, as the following example shows:

```
POST https://api-adservices.apple.com/api/v1/
--header 'Content-Type: text/plain' \
--data-raw


G9i5hC8lQJeGOfmS+MFycll/025oJEjtpZ+rs4AUkDEJh52fT8RrjwIR/ h+2JOpXz4MRdmtcemL8WTTHfNN52tjqjbWupke40AAAAVADAAAAvQAAAIAg QF1+XF4Tl2IZ7Bw/M6ufUHt+UcIhuBeJT8YenB2v36bnZKEjvq/ IH8rqXkRELTHdyiqOYtpy837+UjF/NjE6t1/ l7sIn71b0t3FEXJd8QOtl3Bi6iQyJgGeN8w8X0MK1PDqz9nLJtRD/ wl+p112qR2YrMDyyKnwNrbfRhnGB9AAAAB7wAXlwNHelWf5RT2bzSJcGflq ELMCGoDEHIl7jF6kAAACfAb9ylY8ffdbTlyJODQYQ/ 6V9qbaBAAAAhgUBW39MQI1A0SZgNmZFz4KPaF94BxBzd4rDkjr/ eSeuaXWCmEW3ZhBzE/MOM17hAPBVlDhTPcZ/2ybr3WYIkfb+AAg/ 7jxGpDXgTtco3fzTytnZpEaI5SenXHALIexQAUTBsfBW2HCMQuTRo+7anoW kf69656ZAWcSc3DEQ1CAkUSKO9X7iAAABBEQQBQA=
```

### Important
>
> Important ！！！
>
> A 404 response can occur if you make an API call too quickly after receiving a valid token. A best practice is to initiate retries > at intervals of 5 seconds, with a maximum of three attempts.

## Getting Started

```dart
Future<void> fetchASAData1() async {
    Map<String, dynamic>? attributionJson =
        await PPAsaAttribution().requestAttributionDetails();
    int retryCount = 0;
    while (attributionJson == null && retryCount < 3) {
      print('uploadASAData attributionJson is null, retry count: $retryCount');
      // 延迟5秒后重试
      await Future.delayed(const Duration(seconds: 5));
      attributionJson = await PPAsaAttribution().requestAttributionDetails();
      retryCount++;
    }
    if (attributionJson == null) {
      print('uploadASAData json null after 3 retries');
      return;
    }
    print('uploadASAData attributionJson: $attributionJson');
  }

  Future<void> fetchASAData2() async {
    String? token = await PPAsaAttribution().attributionToken();
    if (token == null) {
      print('uploadASAData token is null');
      return;
    }
    print('uploadASAData token: $token');
    // 延迟500毫秒后再请求
    await Future.delayed(const Duration(milliseconds: 500));
    Map<String, dynamic>? attributionJson =
        await PPAsaAttribution().requestAttributionWithToken(token);
    int retryCount = 0;
    while (attributionJson == null && retryCount < 3) {
      print('uploadASAData attributionJson is null, retry count: $retryCount');
      // 延迟5秒后重试
      await Future.delayed(const Duration(seconds: 5));
      attributionJson =
          await PPAsaAttribution().requestAttributionWithToken(token);
      retryCount++;
    }
    if (attributionJson == null) {
      print('uploadASAData json null after 3 retries');
      return;
    }
    print('uploadASAData attributionJson: $attributionJson');
  }
```

## Results

```json
{
    clickDate: 2025-03-15T12:04Z, 
    countryOrRegion: US, 
    campaignId: 1234567890, 
    conversionType: Download, 
    keywordId: 12323222, 
    adGroupId: 1234567890, 
    attribution: true, 
    claimType: Click, 
    orgId: 1234567890, 
    adId: 1234567890
}
```
