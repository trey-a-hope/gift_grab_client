extension NullableBoolExtensions on bool? {
  bool falseIfNull() => this == true ? true : false;
}
