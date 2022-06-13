import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FlutterPainterExample extends StatefulWidget {
  final filePath;
  FlutterPainterExample({@required this.filePath});

  @override
  _FlutterPainterExampleState createState() => _FlutterPainterExampleState();
}

class _FlutterPainterExampleState extends State<FlutterPainterExample> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;

  static const Color red = Color(0xFFFF0000);
  FocusNode textFocusNode = FocusNode();
  late PainterController controller;
  ui.Image? backgroundImage;
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static List<String> imageLinks = [
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43891.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43884.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43885.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43886.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43887.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43889.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43888.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43890.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43895.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43896.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43897.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43899.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43904.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43906.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43907.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43908.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43910.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43911.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43912.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43913.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43919.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43917.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43914.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43915.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43960.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43959.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43958.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43957.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43942.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43944.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43939.png",
    "https://emojiguide.com/wp-content/uploads/platform/joypixels/43938.png",
  ];

  @override
  void initState() {
    // checkGps();
    super.initState();
    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, color: red, fontSize: 18),
            ),
            freeStyle: const FreeStyleSettings(
              color: red,
              strokeWidth: 5,
            ),
            shape: ShapeSettings(
              paint: shapePaint,
            ),
            scale: const ScaleSettings(
              enabled: true,
              minScale: 1,
              maxScale: 5,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  getLocation() async {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();

      setState(() {
        //refresh UI on update
      });
    });
  }

  void initBackground() async {
    final image = await FileImage(File(widget.filePath)).image;

    setState(() {
      backgroundImage = image;
      controller.background = image.backgroundDrawable;
    });
  }

  // Updates UI when the focus changes
  void onFocus() {
    setState(() {});
  }

  Widget buildDefault(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          // Listen to the controller and update the UI when it updates.
          child: ValueListenableBuilder<PainterControllerValue>(
              valueListenable: controller,
              child: const Text("Editor"),
              builder: (context, _, child) {
                return AppBar(
                  title: child,
                  actions: [
                    // Delete the selected drawable
                    IconButton(
                      icon: const Icon(
                        PhosphorIcons.trash,
                      ),
                      onPressed: controller.selectedObjectDrawable == null ? null : removeSelectedDrawable,
                    ),
                    // Delete the selected drawable
                    IconButton(
                      icon: const Icon(
                        Icons.flip,
                      ),
                      onPressed: controller.selectedObjectDrawable != null && controller.selectedObjectDrawable is ImageDrawable ? flipSelectedImageDrawable : null,
                    ),
                    // Redo action
                    IconButton(
                      icon: const Icon(
                        PhosphorIcons.arrowClockwise,
                      ),
                      onPressed: controller.canRedo ? redo : null,
                    ),
                    // Undo action
                    IconButton(
                      icon: const Icon(
                        PhosphorIcons.arrowCounterClockwise,
                      ),
                      onPressed: controller.canUndo ? undo : null,
                    ),
                  ],
                );
              }),
        ),
        // Generate image
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.save_sharp,
          ),
          // onPressed: renderAndDisplayImage,
          onPressed: renderAndSaveImage,
        ),
        body: Stack(
          children: [
            if (backgroundImage != null)
              // Enforces constraints
              Positioned.fill(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: backgroundImage!.width / backgroundImage!.height,
                    child: FlutterPainter(
                      controller: controller,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, _, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 400,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          color: Colors.white54,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (controller.freeStyleMode != FreeStyleMode.none) ...[
                              const Divider(),
                              const Text("Free Style Settings"),
                              // Control free style stroke width
                              Row(
                                children: [
                                  const Expanded(flex: 1, child: Text("Stroke Width")),
                                  Expanded(
                                    flex: 3,
                                    child: Slider.adaptive(min: 2, max: 25, value: controller.freeStyleStrokeWidth, onChanged: setFreeStyleStrokeWidth),
                                  ),
                                ],
                              ),
                              if (controller.freeStyleMode == FreeStyleMode.draw)
                                Row(
                                  children: [
                                    const Expanded(flex: 1, child: Text("Color")),
                                    // Control free style color hue
                                    Expanded(
                                      flex: 3,
                                      child: Slider.adaptive(
                                          min: 0,
                                          max: 359.99,
                                          value: HSVColor.fromColor(controller.freeStyleColor).hue,
                                          activeColor: controller.freeStyleColor,
                                          onChanged: setFreeStyleColor),
                                    ),
                                  ],
                                ),
                            ],
                            if (textFocusNode.hasFocus) ...[
                              const Divider(),
                              const Text("Text settings"),
                              // Control text font size
                              Row(
                                children: [
                                  const Expanded(flex: 1, child: Text("Font Size")),
                                  Expanded(
                                    flex: 3,
                                    child: Slider.adaptive(min: 8, max: 96, value: controller.textStyle.fontSize ?? 14, onChanged: setTextFontSize),
                                  ),
                                ],
                              ),

                              // Control text color hue
                              Row(
                                children: [
                                  const Expanded(flex: 1, child: Text("Color")),
                                  Expanded(
                                    flex: 3,
                                    child: Slider.adaptive(
                                        min: 0,
                                        max: 359.99,
                                        value: HSVColor.fromColor(controller.textStyle.color ?? red).hue,
                                        activeColor: controller.textStyle.color,
                                        onChanged: setTextColor),
                                  ),
                                ],
                              ),
                            ],
                            if (controller.shapeFactory != null) ...[
                              const Divider(),
                              const Text("Shape Settings"),

                              // Control text color hue
                              Row(
                                children: [
                                  const Expanded(flex: 1, child: Text("Stroke Width")),
                                  Expanded(
                                    flex: 3,
                                    child: Slider.adaptive(
                                        min: 2,
                                        max: 25,
                                        value: controller.shapePaint?.strokeWidth ?? shapePaint.strokeWidth,
                                        onChanged: (value) => setShapeFactoryPaint((controller.shapePaint ?? shapePaint).copyWith(
                                              strokeWidth: value,
                                            ))),
                                  ),
                                ],
                              ),

                              // Control shape color hue
                              Row(
                                children: [
                                  const Expanded(flex: 1, child: Text("Color")),
                                  Expanded(
                                    flex: 3,
                                    child: Slider.adaptive(
                                        min: 0,
                                        max: 359.99,
                                        value: HSVColor.fromColor((controller.shapePaint ?? shapePaint).color).hue,
                                        activeColor: (controller.shapePaint ?? shapePaint).color,
                                        onChanged: (hue) => setShapeFactoryPaint((controller.shapePaint ?? shapePaint).copyWith(
                                              color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                                            ))),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  const Expanded(flex: 1, child: Text("Fill shape")),
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Switch(
                                          value: (controller.shapePaint ?? shapePaint).style == PaintingStyle.fill,
                                          onChanged: (value) => setShapeFactoryPaint((controller.shapePaint ?? shapePaint).copyWith(
                                                style: value ? PaintingStyle.fill : PaintingStyle.stroke,
                                              ))),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, _, __) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Free-style eraser
              IconButton(
                icon: Icon(
                  PhosphorIcons.eraser,
                  color: controller.freeStyleMode == FreeStyleMode.erase ? Theme.of(context).accentColor : null,
                ),
                onPressed: toggleFreeStyleErase,
              ),
              // Free-style drawing
              IconButton(
                icon: Icon(
                  PhosphorIcons.scribbleLoop,
                  color: controller.freeStyleMode == FreeStyleMode.draw ? Theme.of(context).accentColor : null,
                ),
                onPressed: toggleFreeStyleDraw,
              ),
              // Add text
              IconButton(
                icon: Icon(
                  PhosphorIcons.textT,
                  color: textFocusNode.hasFocus ? Theme.of(context).accentColor : null,
                ),
                onPressed: addText,
              ),
              // Add sticker image
              IconButton(
                icon: const Icon(
                  PhosphorIcons.sticker,
                ),
                onPressed: addSticker,
              ),
              // Add shapes
              if (controller.shapeFactory == null)
                PopupMenuButton<ShapeFactory?>(
                  tooltip: "Add shape",
                  itemBuilder: (context) => <ShapeFactory, String>{
                    LineFactory(): "Line",
                    ArrowFactory(): "Arrow",
                    DoubleArrowFactory(): "Double Arrow",
                    RectangleFactory(): "Rectangle",
                    OvalFactory(): "Oval",
                  }
                      .entries
                      .map((e) => PopupMenuItem(
                          value: e.key,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                getShapeIcon(e.key),
                                color: Colors.black,
                              ),
                              Text(" ${e.value}")
                            ],
                          )))
                      .toList(),
                  onSelected: selectShape,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      getShapeIcon(controller.shapeFactory),
                      color: controller.shapeFactory != null ? Theme.of(context).accentColor : null,
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    getShapeIcon(controller.shapeFactory),
                    color: Theme.of(context).accentColor,
                  ),
                  onPressed: () => selectShape(null),
                ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return buildDefault(context);
  }

  static IconData getShapeIcon(ShapeFactory? shapeFactory) {
    if (shapeFactory is LineFactory) return PhosphorIcons.lineSegment;
    if (shapeFactory is ArrowFactory) return PhosphorIcons.arrowUpRight;
    if (shapeFactory is DoubleArrowFactory) {
      return PhosphorIcons.arrowsHorizontal;
    }
    if (shapeFactory is RectangleFactory) return PhosphorIcons.rectangle;
    if (shapeFactory is OvalFactory) return PhosphorIcons.circle;
    return PhosphorIcons.polygon;
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void toggleFreeStyleDraw() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw ? FreeStyleMode.draw : FreeStyleMode.none;
  }

  void toggleFreeStyleErase() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase ? FreeStyleMode.erase : FreeStyleMode.none;
  }

  void addText() {
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
  }

  void addSticker() async {
    // Text(servicestatus ? "GPS is Enabled" : "GPS is disabled.");
    // Text(haspermission ? "GPS is Enabled" : "GPS is disabled.");
    //
    // Text("Longitude: $long", style: TextStyle(fontSize: 20));
    // Text(
    //   "Latitude: $lat",
    //   style: TextStyle(fontSize: 20),
    // );
    final imageLink = await showDialog<String>(
        context: context,
        builder: (context) => SelectStickerImageDialog(
              imagesLinks: imageLinks,
            ));
    if (imageLink == null) return;
    controller.addImage(await NetworkImage(imageLink).image, const Size(100, 100));
  }

  void setFreeStyleStrokeWidth(double value) {
    controller.freeStyleStrokeWidth = value;
  }

  void setFreeStyleColor(double hue) {
    controller.freeStyleColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(textStyle: controller.textSettings.textStyle.copyWith(fontSize: size));
    });
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void setTextColor(double hue) {
    controller.textStyle = controller.textStyle.copyWith(color: HSVColor.fromAHSV(1, hue, 1, 1).toColor());
  }

  void selectShape(ShapeFactory? factory) {
    controller.shapeFactory = factory;
  }

  void renderAndSaveImage() async {
    print('renderAndSaveImage method called');
    if (backgroundImage == null) return;
    final backgroundImageSize = Size(backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
    print('backgroundImageSize $backgroundImageSize');

    final image = await controller.renderImage(backgroundImageSize);
    final byteData = await image.pngBytes;
    print('byteData $byteData');

    final extdir = await getExternalStorageDirectories();
    print('getExternalStorageDirectories ${extdir![0].path}');

    final file = File('${extdir[0].path}/img.jpg');
    await file.writeAsBytes(byteData!.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    Fluttertoast.showToast(
      msg: 'Image saved successfully',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
  }

  void flipSelectedImageDrawable() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    controller.replaceDrawable(imageDrawable, imageDrawable.copyWith(flipped: !imageDrawable.flipped));
  }
}

class RenderedImageDialog extends StatelessWidget {
  final Future<Uint8List?> imageFuture;

  const RenderedImageDialog({Key? key, required this.imageFuture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rendered Image"),
      content: FutureBuilder<Uint8List?>(
        future: imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox();
          }
          return InteractiveViewer(maxScale: 10, child: Image.memory(snapshot.data!));
        },
      ),
    );
  }
}

class SelectStickerImageDialog extends StatelessWidget {
  final List<String> imagesLinks;

  const SelectStickerImageDialog({Key? key, this.imagesLinks = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select sticker"),
      content: imagesLinks.isEmpty
          ? const Text("No images")
          : FractionallySizedBox(
              heightFactor: 0.5,
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    for (final imageLink in imagesLinks)
                      InkWell(
                        onTap: () => Navigator.pop(context, imageLink),
                        child: FractionallySizedBox(
                          widthFactor: 1 / 4,
                          child: Image.network(imageLink),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
