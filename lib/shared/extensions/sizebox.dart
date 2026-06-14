import 'package:timer/common_libs.dart';

extension Sizes on SizedBox {
  SizedBox operator *(num factor) {
    final width = this.width ?? 0;
    final height = this.height ?? 0;

    return SizedBox(
      height: width > height ? height : height * factor,
      width: height > width ? width : width * factor,
    );
  }
}
