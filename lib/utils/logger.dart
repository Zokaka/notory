import 'package:logger/logger.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    //定义了打印的调用堆栈的层数。设置为0表示不打印调用堆栈。
    methodCount: 0,
    //置日期时间的格式，这里使用的是日期和时间
    dateTimeFormat: DateTimeFormat.dateAndTime,
    //设置是否显示表情符号
    printEmojis: true,
    //设置是否为各个组件使用不同的颜色
    colors: true,
    //设置输出行的最大长度
    lineLength: 80,
    //设置默认不使用方框来包裹日志输出内容
    noBoxingByDefault: true,
  ),
);
