
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:myvef_app/Config/Constant.dart';
import 'package:myvef_app/Data/global_data.dart';

import 'CustomException.dart';

/*
class Response<T> {
  Status status;
  T data;
  String message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}
*/

enum Status { LOADING, COMPLETED, ERROR }

class ApiProvider {
  final String _baseUrl = kReleaseMode == false ? "http://61.101.55.40:" : "http://ec2-54-180-41-20.ap-northeast-2.compute.amazonaws.com:"; //서버 붙는 위치
  final String _imageUrl = kReleaseMode == false ? "http://myvfdevbucket.s3.ap-northeast-2.amazonaws.com" : "http://myvef-bowl-production-bucket.s3.ap-northeast-2.amazonaws.com";
  final String port = kReleaseMode == false ? "50007" : "20000";                       //기본 포트
  String get getUrl => _baseUrl + port;
  String get getImgUrl => _imageUrl;
  //get
  Future<dynamic> get(String url) async {
    var responseJson;

    var uri = Uri.parse(_baseUrl + port + url);

    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    IOClient ioClient = new IOClient(httpClient);

    try {
      final response = await ioClient.get(uri,
      headers: {
        'Content-Type' : 'application/json',
        'user' : GlobalData.loggedInUser.value.userID == nullInt ? 'myvfToken' : GlobalData.loggedInUser.value.userID.toString() ,
        'accessToken' : GlobalData.accessToken
      },);

      if(response.body == "" || response.body == null) return null;

      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('인터넷 접속이 원활하지 않습니다.');
    }
    return responseJson;
  }

  //post
  Future<dynamic> post(String url, dynamic data, {bool isChat = false}) async{
    var responseJson;

    var uri = Uri.parse(_baseUrl + port + url);

    HttpClient httpClient = new HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    IOClient ioClient = new IOClient(httpClient);

    try {
      final response = await ioClient.post(uri,
          headers: {
            'Content-Type' : 'application/json',
            'user' : GlobalData.loggedInUser.value.userID == nullInt ? 'myvfToken' : GlobalData.loggedInUser.value.userID.toString() ,
            'accessToken' : GlobalData.accessToken
          },
          body: data,
          encoding: Encoding.getByName('utf-8'));

      if(response.body == "" || response.body == null) return null;

      responseJson = _response(response);
    } on SocketException {
      if(!GlobalData.isResisterBowl){//보울 등록중 토스트를 던지지 않음.
        throw FetchDataException('인터넷 접속이 원활하지 않습니다');
      }
    }

    return responseJson;
  }

  dynamic _response(http.Response response) {
      switch (response.statusCode) {
        case 200:
          var responseJson = json.decode(response.body.toString());
          debugPrint(responseJson.toString());
          return responseJson;
        case 400:
          //throw BadRequestException(response.body.toString());
          BadRequestException(response.body.toString());
          return null;
        case 401: //토큰 정보 실패
          BadRequestException(response.body.toString());
          return null;
        case 403:
          //throw UnauthorisedException(response.body.toString());
          BadRequestException(response.body.toString());
          return null;
        case 404: //토큰 정보 실패
          BadRequestException(response.body.toString());
          return null;
        case 500:
          return null;
        default:
        //throw FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
          FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
          return null;
    }
  }
}