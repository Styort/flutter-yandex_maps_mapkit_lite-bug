import 'package:flutter/material.dart';
import 'package:yandex_maps_kit_bugs/second_page.dart';
import 'package:yandex_maps_mapkit_lite/mapkit.dart';
import 'package:yandex_maps_mapkit_lite/mapkit_factory.dart';
import 'package:yandex_maps_mapkit_lite/yandex_map.dart';
import 'package:yandex_maps_mapkit_lite/src/mapkit/animation.dart' as yandex_animation;
import 'package:yandex_maps_mapkit_lite/init.dart' as init;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init.initMapkit(apiKey: 'API_KEY');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yandex Maps Bugs Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        MyHomePage.route: (context) => const MyHomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        SecondPage.route: (context) => const SecondPage(),
      },
      initialRoute: MyHomePage.route,
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const String route = '/';
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _defaultAnimation = yandex_animation.Animation(AnimationType.Smooth, duration: 0.6);
  late final AppLifecycleListener _lifecycleListener;
  bool _isMapkitActive = false;
  MapWindow? _mapWindow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Demo Home Page'),
        ),
        body: Stack(children: [
          YandexMap(
            onMapCreated: _onMapCreated,
            platformViewType: PlatformViewType.Hybrid,
          ),

          // Кнопки зума
          Positioned.fill(
              child: Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 80),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: const BorderRadius.all(Radius.circular(12))),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          IconButton.filled(onPressed: () => _zoomIn(), icon: const Icon(Icons.zoom_in)),
                          const SizedBox(
                            width: 40,
                            child: Divider(
                              height: 5,
                              thickness: 1,
                            ),
                          ),
                          IconButton.filled(onPressed: () => _zoomOut(), icon: const Icon(Icons.zoom_out)),
                        ]),
                      )))),

          // Кнопка перехода на другую страницу
          Positioned.fill(
              child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16, bottom: 10),
                  child: Align(alignment: Alignment.bottomCenter, child: ElevatedButton(onPressed: () => Navigator.of(context).pushNamed(SecondPage.route), child: const Text('Second page')))))
        ]));
  }

  void _onMapCreated(MapWindow mapWindow) {
    _mapWindow = mapWindow;

    mapWindow.map.logo.setAlignment(const LogoAlignment(LogoHorizontalAlignment.Left, LogoVerticalAlignment.Bottom));
    mapWindow.map.tiltGesturesEnabled = false;
  }

  /// Приблизить карту
  _zoomIn() {
    if (_mapWindow == null) return;

    var nextZoom = _mapWindow!.map.cameraPosition.zoom + 1;
    if (nextZoom < 0) nextZoom = 0;

    _mapWindow?.map
        .moveWithAnimation(CameraPosition(_mapWindow!.map.cameraPosition.target, zoom: nextZoom, azimuth: 0, tilt: 0), _defaultAnimation, cameraCallback: MapCameraCallback(onMoveFinished: (_) {}));
  }

  /// Отдалить карту
  _zoomOut() {
    if (_mapWindow == null) return;

    var nextZoom = _mapWindow!.map.cameraPosition.zoom - 1;
    if (nextZoom < 0) nextZoom = 0;

    _mapWindow?.map
        .moveWithAnimation(CameraPosition(_mapWindow!.map.cameraPosition.target, zoom: nextZoom, azimuth: 0, tilt: 0), _defaultAnimation, cameraCallback: MapCameraCallback(onMoveFinished: (_) {}));
  }

  @override
  void initState() {
    super.initState();
    _startMapkit();

    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _startMapkit();
      },
      onInactive: () {
        _stopMapkit();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _startMapkit() {
    if (!_isMapkitActive) {
      _isMapkitActive = true;
      mapkit.onStart();
    }
  }

  void _stopMapkit() {
    if (_isMapkitActive) {
      _isMapkitActive = false;
      mapkit.onStop();
    }
  }
}
