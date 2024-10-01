class AppException implements Exception{
  String title;
  String error;
  AppException({required this. title,required this. error});
  String toError(){
    return '$title : $error';
  }
}
class NetworkError extends AppException{
  NetworkError({required String errorMsg}):super(title: "NetWork" ,error: errorMsg);
}
class BadRequestError  extends AppException{
  BadRequestError({required String errorMsg}):super(title: "Invalid Request" ,error: errorMsg);
}
class UnauthorisedError extends AppException{
  UnauthorisedError({required String errorMsg}):super(title: "Unauthorised" ,error: errorMsg);
}
class InvalidInputError extends AppException{
  InvalidInputError({required String errorMsg}):super(title: "InvalidInput" ,error: errorMsg);
}