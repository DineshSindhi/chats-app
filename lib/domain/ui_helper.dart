import 'package:flutter/material.dart';

mySizedBoxW2(){
  return SizedBox(width: 2,);
}
mySizedBoxW7(){
  return SizedBox(width: 7,);
}
mySizedBoxW5(){
  return SizedBox(width: 5,);
}
mText22(String text){
  return Text(text,style: TextStyle(fontSize: 22),);
}
mText22align(String text){
  return Text(text,style: TextStyle(fontSize: 22,overflow: TextOverflow.ellipsis),maxLines: 1,);
}
mText25(String text){
  return Text(text,style: TextStyle(fontSize: 25),);
}
mText18(String text){
  return Text(text,style: TextStyle(fontSize: 18),);
}
mText18W(String text){
  return Text(text,style: TextStyle(fontSize: 18,color: Colors.white),);
}
mText15(String text){
  return Text(text,style: TextStyle(fontSize: 17),);
}
mText20P(String text){
  return Padding(
    padding: const EdgeInsets.only(left: 10.0,top: 5),
    child: Text(text,style: TextStyle(fontSize: 20),),
  );
}
mText20(String text){
  return Text(text,style: TextStyle(fontSize: 20),);
}

mListTile({required Widget widget, required VoidCallback onTap, required String tittle, required String subTittle}) {
  return ListTile(
    onTap: onTap,
    leading: widget,
    title: Text(tittle),
    subtitle: Text(subTittle),
  );
}
mListTileP({required Widget widget, required VoidCallback onTap, required String tittle, required String subTittle,required Widget widgetT,}) {
  return ListTile(
    onTap: onTap,
    leading: widget,
    title: Text(tittle),
    trailing: widgetT,
    subtitle: Text(subTittle,style: TextStyle(fontSize: 22),
    ),
  );
}
