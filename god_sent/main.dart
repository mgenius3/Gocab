import 'dart:ffi';

void main() {
  int a = 2;
  double b = 1.2;
  String c = "i am a boy";
  bool d = true;

//Find the area of a rectange with
//formular area = length * breadth, given that length is 2cm and breadth 3cm, find the area

  double area;
  double length = 2;
  double breadth = 3;

  area = length * breadth;
  print("our area is $area"); //6.0

  //Find the length of a rectangle, if the breadth is 3cm and the area is 9cm
  //area = length * breadth;

  double ar = 9;
  double le;
  double br = 3;

  le = ar / br;
  print("the length is $le");

  //Find the breadth of a rectangle, if the length is 2cm and the area is 4cm
  //area = length * breadth;
  double aa = 4;
  double ll = 2;
  double bb;

  bb = aa / ll;
  print("the breadth is $bb");
}
