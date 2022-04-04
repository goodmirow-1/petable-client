import 'package:iamport_flutter/model/url_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vf_certification_data.g.dart';

@JsonSerializable()
class vfCertificationData {
  @JsonKey(name: 'merchant_uid')
  String? merchantUid;

  String? company;
  String? carrier;
  String? name;
  String? phone;

  @JsonKey(name: 'min_age')
  int? minAge;

  @JsonKey(name: 'm_redirect_url')
  String? mRedirectUrl;

  String? redirectPage;

  vfCertificationData({
    this.merchantUid,
    this.company,
    this.carrier,
    this.name,
    this.phone,
    this.minAge,
    this.mRedirectUrl,
    this.redirectPage
  });

  factory vfCertificationData.fromJson(Map<String, dynamic> json) =>
      _$vfCertificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$vfCertificationDataToJson(this);
}
