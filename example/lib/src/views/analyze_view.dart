import 'package:camerax2/camerax2.dart';
import 'package:flutter/material.dart';

class AnalyzeView extends StatefulWidget {
  @override
  _AnalyzeViewState createState() => _AnalyzeViewState();
}

class _AnalyzeViewState extends State<AnalyzeView>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  late AnimationController _animController;
  late Animation<double> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController();

    _animController =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    _offsetAnimation = Tween(begin: 0.2, end: 0.8).animate(_animController);
    _opacityAnimation =
        CurvedAnimation(parent: _animController, curve: OpacityCurve());
    _animController.repeat();

    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CameraX2'),
      ),
      body: Stack(
        children: [
          CameraView(_cameraController),
          StreamBuilder<Face?>(
            stream: _cameraController.faces,
            builder: (
              BuildContext context,
              AsyncSnapshot<Face?> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _cameraIcon(false);
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return _cameraIcon(false);
                } else if (snapshot.hasData) {
                  return Stack(children: [
                    Padding(
                      padding: EdgeInsets.all(40),
                      child: CustomPaint(
                        size: MediaQuery.of(context).size,
                        painter: FacePainter(snapshot.data!.boundingBox),
                      ),
                    ),
                    _cameraIcon(true),
                  ]);
                } else {
                  return _cameraIcon(false);
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _cameraIcon(bool isFacePresent) {
    return Stack(
      children: [
        !isFacePresent
            ? AnimatedLine(
                offsetAnimation: _offsetAnimation,
                opacityAnimation: _opacityAnimation,
              )
            : Container(),
        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(bottom: 40.0),
          child: IconButton(
            icon: Icon(Icons.circle_outlined,
                color: isFacePresent ? Colors.white : Colors.grey),
            iconSize: 70.0,
            onPressed: () => isFacePresent? _cameraController.capturePhoto() : null,
          ),
        ),
      ],
    );
  }

  void capturePhoto() {
    _cameraController.capturePhoto();
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  void start() async {
    await _cameraController.startAsync();
    try {
      // final barcode = await cameraController.barcodes.first;
      // display(barcode);
      final face = await _cameraController.faces.first;
      print('abbas: $face');
    } catch (e) {
      print(e);
    }
  }

  void display(Barcode barcode) {
    Navigator.of(context).popAndPushNamed('display', arguments: barcode);
  }
}

class OpacityCurve extends Curve {
  @override
  double transform(double t) {
    if (t < 0.1) {
      return t * 10;
    } else if (t <= 0.9) {
      return 1.0;
    } else {
      return (1.0 - t) * 10;
    }
  }
}

class AnimatedLine extends AnimatedWidget {
  final Animation offsetAnimation;
  final Animation opacityAnimation;

  AnimatedLine(
      {Key? key, required this.offsetAnimation, required this.opacityAnimation})
      : super(key: key, listenable: offsetAnimation);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacityAnimation.value,
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: LinePainter(offsetAnimation.value),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double offset;

  LinePainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final radius = size.width * 0.45;
    final dx = size.width / 2.0;
    final center = Offset(dx, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        colors: [Colors.greenAccent, Colors.greenAccent.withOpacity(0.0)],
        radius: 0.5,
      ).createShader(rect);
    canvas.translate(0.0, size.height * offset);
    canvas.scale(1.0, 0.1);
    final top = Rect.fromLTRB(0, 0, size.width, radius);
    canvas.clipRect(top);
    canvas.drawCircle(center, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FacePainter extends CustomPainter {
  final Rect r;

  FacePainter(this.r);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.translate(0.0, size.height * 0.1);
    var rr = RRect.fromRectAndRadius(r, Radius.circular(10));
    canvas.drawRRect(rr, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
