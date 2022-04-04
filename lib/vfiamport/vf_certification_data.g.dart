// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vf_certification_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

vfCertificationData _$vfCertificationDataFromJson(Map<String, dynamic> json) =>
    vfCertificationData(
        merchantUid: json['merchant_uid'] as String?,
        company: json['company'] as String?,
        carrier: json['carrier'] as String?,
        name: json['name'] as String?,
        phone: json['phone'] as String?,
        minAge: json['min_age'] as int?,
        mRedirectUrl: json['m_redirect_url'] as String?,
        redirectPage: json['redirect_page'] as String?
    );

Map<String, dynamic> _$vfCertificationDataToJson(vfCertificationData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('merchant_uid', instance.merchantUid);
  writeNotNull('company', instance.company);
  writeNotNull('carrier', instance.carrier);
  writeNotNull('name', instance.name);
  writeNotNull('phone', instance.phone);
  writeNotNull('min_age', instance.minAge);
  writeNotNull('m_redirect_url', instance.mRedirectUrl);
  return val;
}
