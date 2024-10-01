
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;

import 'exception.dart';
class ApiHelper{
  botApi({required String msg}) async {
    String url='https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyDNpgHcuxFxVarqajyKJWUvSTbgITXYfFY';
    try{
      var response=await http.post(Uri.parse(url),headers: {
      },
          body: jsonEncode({"contents":[{"parts":[{"text":msg}]}]})
      );
      return returnException(response);
    }catch(e){
      throw(HttpException(e.toString()));
    }

  }
  returnException(http.Response response){
    switch(response.statusCode){
      case 200 :{
        var mData=jsonDecode(response.body);
        return mData;
      }
      case 400:BadRequestError(errorMsg: response.toString());
      case 401:UnauthorisedError(errorMsg: response.toString());
      case 404:InvalidInputError(errorMsg: response.toString());
      default:NetworkError(errorMsg: 'Error - ${response.toString()}');
    }
  }
}