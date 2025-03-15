# pp_asa_attribution

Apple search ads attribution plugin

## Built on

- Flutter 3.24.5+
- iOS 14.3+
- Swift 5.0+
  
## Requirements

- Add iOS Framework: iAd、AdServices、AdSupport、AppTrackingTransparency
  
## Getting Started

```dart
import 'package:pp_asa_attribution/pp_asa_attribution.dart';

Map<String, dynamic>? attributionJson = await PPAsaAttribution().requestAttributionDetails();
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
