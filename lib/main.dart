
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("绘制"),
        elevation: 0.0,
       ),
        body: MyHomePage(),
    ));
  }
}

class DrawDemo extends StatefulWidget {
  @override
  _DrawDemoState createState() => _DrawDemoState();
}

class _DrawDemoState extends State<DrawDemo> {

  Uint8List imageMemory = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 30,),
          imageMemory == null ? Container():SingleChildScrollView(child: Image.memory(imageMemory,width: 300,fit: BoxFit.fitWidth,),),
          imageMemory == null ?
          InkWell(
            child: Container(width: 160,height: 80,color: Colors.redAccent,),
            onTap: ()async {
              var pictureRecorder = ui.PictureRecorder(); // 图片记录仪
              var canvas =  Canvas(pictureRecorder); //canvas接受一个图片记录仪
              var images = await getImage('assets/rt.JPG'); // 使用方法获取Unit8List格式的图片
              // 绘制图片
              canvas.drawImage(images, Offset(0, 0), Paint());

              // 绘制文字
              ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                fontSize: 50.0));
              pb.pushStyle(ui.TextStyle(color: Colors.black));
              pb.addText("贤合庄真的是太辣了🌶🌶🌶🌶🌶");
              ParagraphConstraints pc = ui.ParagraphConstraints(width: images.width.toDouble());
              ui.Paragraph paragraph = pb.build()..layout(pc);
              canvas.drawParagraph(paragraph, Offset(0, 200));

              //生成图片
              var picture = await pictureRecorder.endRecording().toImage(750, 1334);//设置生成图片的宽和高
              var pngImageBytes = await picture.toByteData(format: ui.ImageByteFormat.png);
              // var imgBytes = Uint8List.view(pngImageBytes.buffer);
              Uint8List pngBytes = pngImageBytes.buffer.asUint8List();
              setState(() {
                imageMemory = pngBytes;
              });
            },
          ):Container()
        ],
      ),
    );
  }

  // 本地图片转换成Uint8List的方法
  Future<ui.Image> getImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      children: <Widget>[
        CustomPaint(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
          foregroundPainter: RadarDemo(6),
        )
      ],
    ));
  }
}

Paint _paint = Paint()
  ..color = Colors.redAccent
  ..strokeCap = StrokeCap.round
  ..isAntiAlias = true
  ..strokeWidth = 5.0
  ..style = PaintingStyle.stroke;

// 1、绘制直线-------------------
class PaintDemo1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(50.0, 50.0), Offset(150.0, 50.0), _paint);
    canvas.drawLine(Offset(50.0, 100.0), Offset(250.0, 100.0), _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 2、绘制点---------------
class PaintDemo2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(

        ///PointMode的枚举类型有三个，points（点），lines（线，隔点连接），polygon（线，相邻连接）
        PointMode.polygon,
        [
          Offset(200.0, 50.0),
          Offset(300.0, 120.0),
          Offset(300.0, 250.0),
          Offset(200.0, 320.0),
          Offset(100.0, 250.0),
          Offset(100.0, 120.0),
          Offset(200.0, 50.0),
        ],
        _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 3、绘制圆rawCircle---------------
// void drawCircle(Offset c, double radius, Paint paint)
// 圆形是否填充或描边(或两者)由Paint.style控制，fill填充。
class PaintDemo3 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    //绘制圆 参数(圆心，半径，画笔)
    canvas.drawCircle(
        Offset(200.0, 120.0),
        100.0,
        _paint
          ..color = Colors.redAccent
          ..style = PaintingStyle.stroke //绘画风格改为stroke
        );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 4、绘制椭圆----------------
// void drawOval(Rect rect, Paint paint)
class PaintDemo4 extends CustomPainter {
  // 使用左上角点和右下角点坐标来确定矩形的大小和位置,椭圆是在这个矩形之中内切的，正方形中就是个圆了
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect1 = Rect.fromPoints(Offset(100.0, 100.0), Offset(300.0, 200.0));
    canvas.drawOval(rect1, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 5、绘制圆弧----------------
// void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint)

class PaintDemo5 extends CustomPainter {
  @override
  // Rect来确认圆弧的位置，还需要开始的弧度、结束的弧度、是否使用中心点绘制（圆弧两段是否连接圆心）、以及paint弧度
  void paint(Canvas canvas, Size size) {
    Rect rect2 = Rect.fromCircle(center: Offset(200.0, 50.0), radius: 80.0);
    canvas.drawArc(rect2, 0.0, pi, true, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 6、绘制矩形、圆角矩形----------------
class PaintDemo6 extends CustomPainter {
  @override
  // Rect来确认圆弧的位置，还需要开始的弧度、结束的弧度、是否使用中心点绘制、以及paint弧度
  void paint(Canvas canvas, Size size) {
    // 1、用Rect构建一个边长50,中心点坐标为100,100的矩形
    Rect rect = Rect.fromCircle(center: Offset(60.0, 100.0), radius: 50.0);
    canvas.drawRect(rect, _paint);

    // 2、圆角矩形
    Rect rect0 = Rect.fromCircle(center: Offset(180.0, 100.0), radius: 50.0);
    RRect rrect = RRect.fromRectAndRadius(rect0, Radius.circular(10.0));
    canvas.drawRRect(rrect, _paint);

    // 3、分别绘制外部圆角矩形和内部的圆角矩形
    Rect rect1 = Rect.fromCircle(center: Offset(320.0, 100.0), radius: 60.0);
    Rect rect2 = Rect.fromCircle(center: Offset(320.0, 100.0), radius: 40.0);

    RRect outer = RRect.fromRectAndRadius(rect1, Radius.circular(10.0));
    RRect inner = RRect.fromRectAndRadius(rect2, Radius.circular(10.0));
    canvas.drawDRRect(outer, inner, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 7、绘制路径drawPath----------------
// void drawPath(Path path, Paint paint)
class PaintDemo7 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    /* Path的常用方法：
    *  moveTo ：将路径起始点移动到指定的位置
    *  relativeMoveTo ： 相对于当前位置移动到
    *  lineTo ：从当前位置连接指定点
    *  relativeLineTo ： 相对当前位置连接到
    *  arcTo ： 曲线
    *  conicTo ：  贝塞尔曲线
    *  add** ： 添加其他图形，如addArc，在路径是添加圆弧
    *  contains ： 路径上是否包括某点
    *  transfor ： 给路径做matrix4变换
    *  combine ： 结合两个路径
    *  close ： 关闭路径，连接路径的起始点
    *  reset ： 重置路径，恢复到默认状态
    */
    Path path = Path();
    path.moveTo(50.0, 50.0);
    path.lineTo(100, 100.0);
    path.lineTo(50.0, 150.0);
    path.lineTo(100.0, 200.0);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// canvas.drawShadow(path, color, elevation, transparentOccluder)
//  路径、阴影的颜色、阴影扩散的范围、
class PaintDemo8 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
        Path()
          ..moveTo(50.0, 50.0)
          ..lineTo(150.0, 50.0)
          ..lineTo(150.0, 150.0)
          ..lineTo(50.0, 150.0)
          ..close(),
        Colors.red,
        3,
        false);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 9、使用二阶贝塞尔曲线绘制弧线:----------------
// void arcTo(Rect rect, double startAngle, double sweepAngle, bool forceMoveTo)
/*
* rect我们都知道了,是一个矩形,startAngle是开始的弧度,sweepAngle是结束的弧度
* 如果“forceMoveTo”参数为false，则添加一条直线段和一条弧段。
* 如果“forceMoveTo”参数为true，则启动一个新的子路径，其中包含一个弧段。
*/
class PaintDemo9 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path()..moveTo(100.0, 100.0);
    Rect rect = Rect.fromCircle(center: Offset(100.0, 100.0), radius: 60.0);
    //path.arcTo(rect, pi*0.2, pi*1.5, true); // 字母C
    path.arcTo(rect, pi * 0.0, pi * 1.6, false); // 字母G
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 10、使用二阶贝塞尔曲线直接画一个圆:----------------
class PaintDemo10 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = new Path()..moveTo(100.0, 100.0);
    Rect rect = Rect.fromCircle(center: Offset(200.0, 200.0), radius: 60.0);
    path.arcTo(rect, 0.0, 3.14 * 2, true);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
// 11、使用三阶贝塞尔曲线绘制❤:----------------
// void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3)

class PaintDemo11 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paint..style = PaintingStyle.stroke;
    Path path = Path();
    // A点
    path.moveTo(0, 50);
    // B点
    path.cubicTo(0, 25, 40, 0, 80, 0);
    // C点
    path.cubicTo(120, 0, 160, 25, 160, 50);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PaintDemo12 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double width = 200;
    double height = 300;
    _paint
      ..style = PaintingStyle.fill
      ..color = Colors.redAccent;

    // 右边一半
    Path path = Path();
    path.moveTo(width / 2, height / 4);
    path.cubicTo((width * 6) / 7, height / 9, width, (height * 2) / 5,
        width / 2, (height * 7) / 12);

    // 左边一半
    path.moveTo(width / 2, height / 4);
    path.cubicTo(width / 7, height / 9, width / 21, (height * 2) / 5, width / 2,
        (height * 7) / 12);

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// 13、绘制颜色drawColor----------------
// void drawColor(Color color, BlendMode blendMode)
class PaintDemo13 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(100.0, 100.0), 50.0, _paint);
    canvas.drawColor(Colors.greenAccent, BlendMode.colorDodge);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PaintDemo14 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    ParagraphBuilder pb = ParagraphBuilder(ParagraphStyle(
        textAlign: TextAlign.center,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal, // 正常 or 斜体
        maxLines: 1));
    pb.pushStyle(ui.TextStyle(color: Colors.redAccent));
    pb.addText("RC LOVE TMH");
    // 绘制的宽度
    ParagraphConstraints pc = ParagraphConstraints(width: 350.0);
    Paragraph paragraph = pb.build()..layout(pc);
    canvas.drawParagraph(paragraph, Offset(30, 300));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PaintDemo15 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    getImage("assets/spring_box_article.png").then((value) {
      if (value != null) {
        canvas.drawImage(value, Offset(0, 500), Paint());
      }
    });
  }

  Future<ui.Image> getImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

// 雷达图
class RadarDemo extends CustomPainter {

  int sideNumber = 6; // 多边形边数
  int layerNumber = 4; // 维度分几层
  double c_X;// view 的中心点
  double c_Y;
  double maxRadius; // 半径，最大的半径
  Paint linePaint; // 划线的画笔
  Path path; // 路径
  Paint maskPaint; // 遮罩的画笔

  RadarDemo(int sideNumber) {
    this.sideNumber = sideNumber;
    linePaint = Paint()
    ..color = randomRGB()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
    path = Path();

    maskPaint = Paint()
    ..color = randomARGB()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    c_X = size.width / 2;
    c_Y = size.height / 2;
    if (c_X > c_Y) {
      maxRadius = c_Y;
    } else {
      maxRadius = c_X;
    }
    canvas.save();
    drawPolygon(canvas);
    drawMaskLayer(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate != this;
  }

  double eachRadius;
  double eachAngle;

  // 绘制多边形边框
  void drawPolygon(Canvas canvas) {
    ///每个角的度数
    eachAngle = 360 / sideNumber;

    ///找好所有的顶点，连接起来即可
    for (int i = 0; i < layerNumber; i++) {
      path.reset();
      eachRadius = maxRadius / layerNumber * (i + 1);

      for (int j = 0; j < sideNumber + 1; j++) {
        if (j == 0) {
          path.moveTo(c_X + eachRadius, c_Y);
        } else {
          double x = c_X + eachRadius * cos(degToRad(eachAngle * j));
          double y = c_Y + eachRadius * sin(degToRad(eachAngle * j));
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, linePaint);
    }
    drawLineLinkPoint(canvas, eachAngle, eachRadius);
  }

  // 连接多边形顶点和中心点
  void drawLineLinkPoint(Canvas canvas, double eachAngle, double eachRadius) {
    path.reset();
    for (int i = 0; i < sideNumber; i++) {
      path.moveTo(c_X, c_Y);
      double x = c_X + eachRadius * cos(degToRad(eachAngle * i));
      double y = c_Y + eachRadius * sin(degToRad(eachAngle * i));
      path.lineTo(x, y);
      path.close();
      canvas.drawPath(path, linePaint);
    }
  }

  // 绘制遮罩
  void drawMaskLayer(Canvas canvas) {
    path.reset();
    for (int i = 0; i < sideNumber; i++) {
      double mRandomInt = randomInt();
      double x =
          c_X + maxRadius * cos(degToRad(eachAngle * i)) * mRandomInt;
      double y =
          c_Y + maxRadius * sin(degToRad(eachAngle * i)) * mRandomInt;
      if (i == 0) {
        path.moveTo(x, c_Y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, maskPaint);
  }

  num degToRad(num deg) => deg * (pi / 180.0);

  num radToDeg(num rad) => rad * (180.0 / pi);

  Color randomRGB() {
    Random random = new Random();
    return Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }
  Color randomARGB() {
    Random random = Random();
    return Color.fromARGB(random.nextInt(90), random.nextInt(255),
        random.nextInt(255), random.nextInt(255));
  }
  double randomInt() {
    Random random = new Random();
    return (random.nextInt(10) + 1) / 10;
  }
}

class SpiderNetView extends CustomPainter {
  ///多边形几个边
  int sideNum = 6;

  ///默认几层多边形
  int layerNum = 6;

  ///view 的中心点
  double viewCenterX;
  double viewCenterY;

  ///半径，最大的半径
  double maxRadius;
  Paint mPaint;
  Path mPath;
  final double CIRCLE_ANGLE = 360;
  Paint mLayerPaint;

  SpiderNetView(int sideNum) {
    this.sideNum = sideNum;
    mPaint = new Paint();
    mPaint.color = randomRGB();
    mPaint.isAntiAlias = true;
    mPaint.style = PaintingStyle.stroke;
    mPath = new Path();

    mLayerPaint = new Paint();
    mLayerPaint.color = randomARGB();
    mLayerPaint.isAntiAlias = true;
    mLayerPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    viewCenterX = size.width / 2;
    viewCenterY = size.height / 2;
    if (viewCenterX > viewCenterY) {
      maxRadius = viewCenterY;
    } else {
      maxRadius = viewCenterX;
    }
    canvas.save();
    drawPolygon(canvas);
    drawMaskLayer(canvas);
    drawText(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return oldDelegate != this;
  }

  double eachRadius;
  double eachAngle;

  void drawPolygon(Canvas canvas) {
    ///每个角的度数
    eachAngle = CIRCLE_ANGLE / sideNum;

    ///找好所有的顶点，连接起来即可
    for (int i = 0; i < layerNum; i++) {
      mPath.reset();
      eachRadius = maxRadius / layerNum * (i + 1);

      for (int j = 0; j < sideNum + 1; j++) {
        if (j == 0) {
          mPath.moveTo(viewCenterX + eachRadius, viewCenterY);
        } else {
          double x = viewCenterX + eachRadius * cos(degToRad(eachAngle * j));
          double y = viewCenterY + eachRadius * sin(degToRad(eachAngle * j));
          mPath.lineTo(x, y);
        }
      }
      mPath.close();
      canvas.drawPath(mPath, mPaint);
    }
    drawLineLinkPoint(canvas, eachAngle, eachRadius);
  }

  void drawLineLinkPoint(Canvas canvas, double eachAngle, double eachRadius) {
    mPath.reset();
    for (int i = 0; i < sideNum; i++) {
      mPath.moveTo(viewCenterX, viewCenterY);
      double x = viewCenterX + eachRadius * cos(degToRad(eachAngle * i));
      double y = viewCenterY + eachRadius * sin(degToRad(eachAngle * i));
      mPath.lineTo(x, y);
      mPath.close();
      canvas.drawPath(mPath, mPaint);
    }
  }

  void drawMaskLayer(Canvas canvas) {
    mPath.reset();
    for (int i = 0; i < sideNum; i++) {
      double mRandomInt = randomInt();
      double x =
          viewCenterX + maxRadius * cos(degToRad(eachAngle * i)) * mRandomInt;
      double y =
          viewCenterY + maxRadius * sin(degToRad(eachAngle * i)) * mRandomInt;
      if (i == 0) {
        mPath.moveTo(x, viewCenterY);
      } else {
        mPath.lineTo(x, y);
      }
    }
    mPath.close();
    canvas.drawPath(mPath, mLayerPaint);
  }

  void drawText(Canvas canvas) {
    for (int i = 0; i < sideNum; i++) {
      double x = viewCenterX + maxRadius * cos(degToRad(eachAngle * i));
      double y = viewCenterY + maxRadius * sin(degToRad(eachAngle * i));
    }
  }

  num degToRad(num deg) => deg * (pi / 180.0);

  num radToDeg(num rad) => rad * (180.0 / pi);

  Color randomRGB() {
    Random random = new Random();
    return Color.fromARGB(
        255, random.nextInt(255), random.nextInt(255), random.nextInt(255));
  }

  Color randomARGB() {
    Random random = Random();
    return Color.fromARGB(random.nextInt(180), random.nextInt(255),
        random.nextInt(255), random.nextInt(255));
  }

  double randomInt() {
    Random random = new Random();
    return (random.nextInt(10) + 1) / 10;
  }
}