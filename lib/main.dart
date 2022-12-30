// hello
import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;
import 'dart:core';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'package:torch_control/torch_control.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_icons/weather_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
double gpsLongitude = 0;
double gpsLatitude = 0;
Map<dynamic, dynamic> jsonWeather = {};
var theme = ThemeData(
  primarySwatch: Colors.orange,
  fontFamily: 'Fredoka',
  brightness: Brightness.light,
  iconTheme: const IconThemeData(
    color: Colors.black
  ),
);
var darkTheme = ThemeData(
  primarySwatch: Colors.orange,
  brightness: Brightness.dark,
  iconTheme: const IconThemeData(
    color: Colors.white
  ),
);
/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
scrollPysics(context){
  if(Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.android){
    return const ScrollPhysics();
  }
  return const NeverScrollableScrollPhysics();
}
double maxWidth(double maxWidth, context){
  if(MediaQuery.of(context).size.width > maxWidth){
    return maxWidth;
  }
  return MediaQuery.of(context).size.width;
}
class ScrollVelocity extends ScrollController {
  ScrollVelocity([int extraScrollSpeed = 200]) {
    super.addListener(() {
      ScrollDirection scrollDirection = super.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = super.offset +
            (scrollDirection == ScrollDirection.reverse
                ? extraScrollSpeed
                : -extraScrollSpeed);
        scrollEnd = math.min(super.position.maxScrollExtent,
            math.max(super.position.minScrollExtent, scrollEnd));
        jumpTo(scrollEnd);
      }
    });
  }
}
class CreateCard extends StatefulWidget {
  const CreateCard(this.title, this.content, this.image, this.function, {this.colorTheme = const Color(0xffdadada), Key? key}) : super(key: key);
  final String title;
  final String content;
  final String image;
  final Color colorTheme;
  final function;
  @override
  State<CreateCard> createState() => _CreateCardState(title, content, image, function, colorTheme);
}
class _CreateCardState extends State<CreateCard> {
  _CreateCardState(this.title, this.content, this.image, this.function, this.colorTheme);
  final String title;
  final String content;
  final String image;
  final Color colorTheme;
  final function;
  double _height = 0;
  final double _finalHeight = 250;
  double opacityLevel = 0;
  void showCard() {
    setState(() {
      _height = _finalHeight;
      Timer(const Duration(milliseconds: 200), () {
        opacityLevel = 1;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 100), () {
      showCard();
    });
    return GestureDetector(
      onTap: (){
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.lightImpact();
        Navigator.of(context).push(routeShowPage(function));
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedOpacity(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          opacity: opacityLevel,
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 500),
            height: _height,
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 500),
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsetsDirectional.only(bottom: 20),
            decoration: BoxDecoration(
              color: colorTheme,
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                width: 2,
                color: hexToColor('#e2e2e2'),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
                const Separator(10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(content, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
class CustomScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
class Separator extends StatelessWidget {
  const Separator(this.height, {super.key});
  final double height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: MediaQuery.of(context).size.width,
    );
  }
}
class DrawerItem extends StatelessWidget {
  const DrawerItem(this.text, this.icon, this.context, this.toShow, {Key? key}) : super(key: key);
  final String text;
  final icon;
  final context;
  final toShow;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        trailing: Icon(icon, size: 30),
        title: Text(text, style: const TextStyle(fontSize: 17), textAlign: TextAlign.start, maxLines: 1, overflow: TextOverflow.ellipsis,),
        onTap: (){
          Navigator.of(context).push(toShow);
        },
      )
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ors Apps',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScroll(),
      home: const MyHomePage(title: 'Ors Apps'),
    );
  }
}
class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      height: MediaQuery.of(context).size.height - 60,
      alignment: Alignment.centerLeft,
      child: Drawer(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          iconSize: 40,
                          onPressed: () { Navigator.pop(context); },
                          icon: const Icon(Icons.close_rounded),
                          padding: const EdgeInsets.all(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DrawerItem('Inicio', Icons.home, context, routeShowPage(const MyHomePage(title: 'Ors Apps'))),
              DrawerItem('Brújula', Icons.compass_calibration_rounded, context, routeShowPage(const MyCompass())),
              DrawerItem('Linterna', Icons.lightbulb_rounded, context, routeShowPage(const MyLight())),
              DrawerItem('Clima', Icons.sunny, context, routeShowPage(const MyWeather())),
              //DrawerItem('Translate', Icons.translate, context, const Translate()),
              DrawerItem('Configuración', Icons.settings, context, routeShowPageVertical(const Settings())),
              DrawerItem('Acerca de', Icons.info_outline_rounded, context, routeShowPageVertical(const Creditos())),
            ],
          ),
        ),
      ),
    );
  }
}
class PageHome extends StatelessWidget {
  const PageHome({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: const <Widget>[
        Separator(10),
        Text('¡Hola! Bienvenido a Ors Apps. Una aplicación de utilidades que te facilitara el dia a dia.', style: TextStyle(fontSize: 25, fontFamily: 'Fredoka'), textAlign: TextAlign.justify),
        Separator(0),
        CreateCard('Ors Weather', 'Consulta la previsión del clima en un click', 'lib/assets/card-img/weather.jpg', MyWeather()),
        CreateCard('Ors Compass', '¿Tienes curiosidad por los puntos cardinales?\n¡Usa Ors Compass!\nLa brújula más completa del mercado', 'lib/assets/card-img/brujula.png', MyCompass()),
        CreateCard('Ors Light', '¿Estás en la oscuridad?\n¿No ves absolutamente nada?\nCreo que esta herramienta te puede ayudar...', 'lib/assets/card-img/bulb.jpg', MyLight()),
        ],
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  late ScrollController _scrollController;
  @override
  void initState() {
    // initialize scroll controllers
    _scrollController = ScrollController();
    locationPermision();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          title: const Text('Ors Apps', style: TextStyle(fontFamily: 'Dancing', fontSize: 35, height: 1.5)),
          leading: Builder(
            builder: (BuildContext context) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: IconButton(
                  icon: const Icon(Icons.menu, size: 40,),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip: 'Abrir menu de navegación',
                ),
              );
            },
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: WebSmoothScroll(
        controller: _scrollController,
        scrollOffset: 500,
        animationDuration: 400,
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          physics: scrollPysics(context),
          controller: _scrollController,
          child: const PageHome(),
        ),
      ),
    );
  }
}
class MyCompass extends StatefulWidget {
  const MyCompass({Key? key}) : super(key: key);
  @override
  State<MyCompass> createState() => _MyCompassState();
}
class _MyCompassState extends State<MyCompass> {
  double _gpsLongitude = gpsLongitude;
  double _gpsLatitude = gpsLatitude;
  String locationData = "";
  var locationService = serviceStatusLocation();
  void refreshPosition() async {
    await getLocationPosition(LocationAccuracy.best);
    setState(() {
      _gpsLatitude = gpsLatitude;
      _gpsLongitude = gpsLongitude;
    });
    List<Placemark> placemark = await placemarkFromCoordinates(_gpsLatitude, _gpsLongitude);
    locationData = placemark[0].toString();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ors Apps',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScroll(),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: AppBar(
            title: Text('Brújula'.toUpperCase(), style: const TextStyle(fontFamily: 'Major Mono', fontSize: 35, height: 1.5)),
            leading: Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: IconButton(
                    icon: const Icon(Icons.menu, size: 40,),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip: 'Abrir menu de navegación',
                  ),
                );
              },
            ),
          ),
        ),
          drawer: const MyDrawer(),
          body: SingleChildScrollView(
            controller: ScrollVelocity(),
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Image.asset('lib/assets/compass/fondo.png', width: maxWidth(500, context)),
                    RotationTransition(
                      turns: const AlwaysStoppedAnimation(40 / 360),
                      child: Image.asset('lib/assets/compass/agujas.png', width: maxWidth(500, context)),
                    ),
                  ],
                ),
                const Separator(20),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Text('$_gpsLatitude N, $_gpsLongitude E', style: const TextStyle(fontSize: 20, color: Colors.black),),
                  ),
                ),
                const Separator(20),
                Text(locationData, style: const TextStyle(fontSize: 14),)
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: refreshPosition,
            tooltip: 'Refrescar',
            backgroundColor: Colors.orange,
            child: const Icon(Icons.refresh_sharp),
          ),
      ),
    );
  }
}
class MyLight extends StatefulWidget {
  const MyLight({Key? key}) : super(key: key);

  @override
  State<MyLight> createState() => _MyLightState();
}
class _MyLightState extends State<MyLight> {
  Color powerColor = Colors.red;
  String errors = "";
  bool parpadeo = false;
  int intervalP = 0;
  var timerOn = null;
  var timerOff = null;
  void toggleLantern(){
    if(TorchControl.isOff){
      if(parpadeo){
        if(timerOn != null){
          timerOn.cancel();
          timerOn = null;
        }
        if (timerOff != null){
          timerOff.cancel();
          timerOff = null;
        }
        timerOn = Timer.periodic(Duration(milliseconds: intervalP), (timer) {
          TorchControl.turnOn();
        });
        timerOff = Timer(Duration(milliseconds: intervalP ~/ 2), () {
          Timer.periodic(Duration(milliseconds: intervalP), (timer) {
            TorchControl.turnOff();
          });
        });
      }
      else {
        TorchControl.turnOn();
      }
      setState(() {
        powerColor = Colors.green;
      });
    }
    else {
      TorchControl.turnOff();
      setState(() {
        powerColor = Colors.red;
      });
    }
  }
  void writeError(String content){
    setState(() {
      errors = content;
    });
  }
  void prepareTorch() async {
    await TorchControl.ready();
    if(TorchControl.isOn){
      setState(() {
        powerColor = Colors.green;
      });
    }
    else {
      setState(() {
        powerColor = Colors.red;
      });
    }
    if(!(Platform.isAndroid || Platform.isIOS)){
      writeError("Esta utilidad solo funciona en móviles, ya que hace uso de la linterna");
    }
  }
  @override
  Widget build(BuildContext context) {
    prepareTorch();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ors Apps',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScroll(),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: AppBar(
            title: const Text('Linterna', style: TextStyle(fontFamily: 'Shadows Into Light', fontSize: 35, height: 2, letterSpacing: 0.5,)),
            leading: Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: IconButton(
                    icon: const Icon(Icons.menu, size: 40,),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip: 'Abrir menu de navegación',
                  ),
                );
              },
            ),
          ),
        ),
        drawer: const MyDrawer(),
        body: SingleChildScrollView(
          controller: ScrollVelocity(),
          padding: const EdgeInsets.all(20),
          child: Container(
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: (){
                      toggleLantern();
                    },
                    child: Icon(Icons.power_settings_new_outlined, size: 50, color: powerColor,)
                  ),
                ),
                const Separator(10),
                Switch(
                  onChanged: (bool value){
                    parpadeo = !parpadeo;
                  },
                  value: parpadeo,
                ),
                Slider(
                  value: intervalP.toDouble(),
                  max: 3000,
                  divisions: 100,
                  label: "${intervalP.round()}ms",
                  onChanged: (double value) {
                    setState(() {
                      TorchControl.turnOff();
                      intervalP = value.toInt();
                      toggleLantern();
                    });
                  },
                ),
                Text(errors, style: const TextStyle(fontSize: 20, color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class MyWeather extends StatefulWidget {
  const MyWeather({Key? key}) : super(key: key);

  @override
  State<MyWeather> createState() => _MyWeatherState();
}
class _MyWeatherState extends State<MyWeather> {
  final RefreshController _refreshController = RefreshController(initialRefresh: true);
  final textFieldLocationControler = TextEditingController();
  late ScrollController _scrollController;
  int scrollOffsetAllPage = 100;
  double _currentWeatherSize = 0;
  void _scrollListener(){
    if(_scrollController.offset > 15){
      setState(() {
        scrollOffsetAllPage = 500;
        _currentWeatherSize = 150;
        animatedBackgroundColor = const Color(0xFFFFFF);
      });
    }
    else {
      setState(() {
        scrollOffsetAllPage = 100;
        _currentWeatherSize = MediaQuery.of(context).size.height - 290;
        animatedBackgroundColor = topBackgroundColor;
      });
    }
  }
  final Map<int, dynamic> weatherIconsDay = {
    0: WeatherIcons.day_sunny,
    1: WeatherIcons.day_sunny,
    2: WeatherIcons.day_sunny_overcast,
    3: WeatherIcons.day_cloudy,
    45: WeatherIcons.day_fog,
    48: WeatherIcons.fog,
    51: WeatherIcons.raindrop,
    53: WeatherIcons.raindrops,
    55: WeatherIcons.raindrops,
    56: WeatherIcons.snowflake_cold,
    57: WeatherIcons.snowflake_cold,
    61: WeatherIcons.day_rain_mix,
    63: WeatherIcons.rain,
    65: WeatherIcons.rain_wind,
    66: WeatherIcons.rain_wind,
    67: WeatherIcons.rain_wind,
    71: WeatherIcons.day_snow,
    73: WeatherIcons.snow,
    75: WeatherIcons.snow_wind,
    77: WeatherIcons.snow,
    80: WeatherIcons.day_rain_mix,
    81: WeatherIcons.day_rain,
    82: WeatherIcons.rain,
    85: WeatherIcons.day_snow,
    86: WeatherIcons.day_snow_wind,
    95: WeatherIcons.day_thunderstorm,
    96: WeatherIcons.day_thunderstorm,
    99: WeatherIcons.day_snow_thunderstorm,
  };
  final Map<int, dynamic> weatherIconsNight = {
    0: WeatherIcons.night_clear,
    1: WeatherIcons.night_clear,
    2: WeatherIcons.night_alt_partly_cloudy,
    3: WeatherIcons.night_alt_cloudy,
    45: WeatherIcons.night_fog,
    48: WeatherIcons.night_fog,
    51: WeatherIcons.night_alt_showers,
    53: WeatherIcons.night_alt_showers,
    55: WeatherIcons.night_alt_showers,
    56: WeatherIcons.snowflake_cold,
    57: WeatherIcons.snowflake_cold,
    61: WeatherIcons.night_alt_rain_mix,
    63: WeatherIcons.night_alt_rain,
    65: WeatherIcons.rain_wind,
    66: WeatherIcons.rain_wind,
    67: WeatherIcons.rain_wind,
    71: WeatherIcons.night_alt_snow,
    73: WeatherIcons.snow,
    75: WeatherIcons.snow_wind,
    77: WeatherIcons.snow,
    80: WeatherIcons.night_alt_rain_mix,
    81: WeatherIcons.night_alt_rain,
    82: WeatherIcons.rain,
    85: WeatherIcons.night_alt_snow,
    86: WeatherIcons.night_alt_snow_wind,
    95: WeatherIcons.night_alt_thunderstorm,
    96: WeatherIcons.night_alt_thunderstorm,
    99: WeatherIcons.night_alt_snow_thunderstorm,
  };
  IconData dayNightWeatherIcon(int position, DateTime nowTime, DateTime sunrise, DateTime sunset){
    if(nowTime.isAfter(sunrise) && nowTime.isBefore(sunset)){
      return weatherIconsDay[position];
    }
    return weatherIconsNight[position];
  }
  double longitude = 0;
  double latitude = 0;
  int winddirection = 0;
  Map<String, dynamic> currentValues = {
    'locality' : 'Cargando...',
    'temperature': '...',
    'windspeed': '...',
    'weathercode': Container(margin: const EdgeInsets.symmetric(horizontal: 60), child: SpinKitFoldingCube(
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.orange : Colors.orangeAccent,
          ),
        );
      },
      duration: const Duration(milliseconds: 900),
    ),
    ),
  };
  Map<String, dynamic> hourlyUnits = {};
  Map<String, dynamic> dailyUnits = {};
  Map<String, dynamic> sunRiseSetValue = {};
  bool showingFirstCapeHourCard = true;
  Widget createHourCard(Map<dynamic, dynamic> data){
    return SizedBox(
      width: 110,
      child: Card(
        child: InkWell(
            splashColor: Colors.grey.withAlpha(30),
            onTap: (){
              showingFirstCapeHourCard = !showingFirstCapeHourCard;
              generateHourCards();
            },
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                // Primera cara (información importante)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  top: showingFirstCapeHourCard ? 0 : -150,
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: showingFirstCapeHourCard ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: <Widget>[
                          Text('${data['temperature_2m']} ${hourlyUnits['temperature_2m'] ?? "..."}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.lightGreen)),
                          Text('${data['precipitation']} ${hourlyUnits['precipitation'] ?? "..."}', style: const TextStyle(fontSize: 18, color: Colors.blue),),
                          const SizedBox(height: 5),
                          Icon(dayNightWeatherIcon(data['weathercode'].toInt(), data['nowtime'], data['sunrise'], data['sunset'])),
                          const SizedBox(height: 10),
                          Text('${data['windspeed_10m']} ${hourlyUnits['windspeed_10m'] ?? "..."}'),
                          const SizedBox(height: 5),
                          Text('${data['time']}', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
                // Segunda cara (información no tan importante)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  top: !showingFirstCapeHourCard ? 0 : 150,
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: !showingFirstCapeHourCard ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: <Widget>[
                          Text('${data['apparent_temperature']} ${hourlyUnits['apparent_temperature'] ?? "..."}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: Colors.red)),
                          const SizedBox(height: 5),
                          Text('${data['relativehumidity_2m']}${hourlyUnits['relativehumidity_2m'] ?? "..."}', style: const TextStyle(fontSize: 18, color: Colors.blue),),
                          const SizedBox(height: 5),
                          Text('${data['visibility'].toInt()} ${hourlyUnits['visibility'] ?? "..."}'),
                          const SizedBox(height: 5),
                          Text('${data['direct_radiation_instant'].toInt()} ${hourlyUnits['direct_radiation_instant'] ?? "..."}'),
                          const SizedBox(height: 10),
                          Text('${data['time']}', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
    );

  }
  List<Widget> hourCards = [];
  List<Widget> dailyCards = [];
  List<bool> dailyCardsExpanded = [false, false, false, false, false, false];
  Color topBackgroundColor = const Color(0xFF4FB3FF);
  Color animatedBackgroundColor = const Color(0xFF4FB3FF);
  void changeDeterminatedLocation() async {
    FocusScope.of(context).unfocus();
    String address = textFieldLocationControler.text;
    List<dynamic> locations = await locationFromAddress(address);
    longitude = locations[0].longitude.toDouble();
    latitude = locations[0].latitude.toDouble();
    debugPrint('Longitude: $longitude');
    debugPrint('Latitude: $latitude');
    refreshWeather(searchingDeterminatedLocation : true);
  }
  void getTopBackgroundColor(int weatherCode){
    if(MediaQuery.of(context).platformBrightness == Brightness.dark){
      setState((){
        topBackgroundColor = Colors.transparent;
      });
      return;
    }
    if(weatherCode >= 0 && weatherCode <= 3){
      setState((){
        topBackgroundColor = const Color(0xFF4FB3FF);
      });
    }
    else if(weatherCode > 3 && weatherCode <= 48){
      setState(() {
        topBackgroundColor = Colors.grey;
      });
    }
    else if(weatherCode >= 51 && weatherCode <= 57 || weatherCode >= 80 && weatherCode <= 86){
      setState(() {
        topBackgroundColor = Colors.tealAccent;
      });
    }
    else if(weatherCode >= 61 && weatherCode <= 67){
      setState(() {
        topBackgroundColor = Colors.blueGrey;
      });
    }
    else if(weatherCode >= 71 && weatherCode <= 77){
      setState(() {
        topBackgroundColor = Colors.white;
      });
    }
    else if(weatherCode >= 95 && weatherCode <= 99){
      setState(() {
        topBackgroundColor = Colors.yellow;
      });
    }
  }
  void getSunRiseSet(){
    sunRiseSetValue = {};
    for(int i = 0; i < jsonWeather['daily']['sunrise'].length; i++){
      sunRiseSetValue[jsonWeather['daily']['sunrise'][i].split("T")[0]] = {
        'sunrise': jsonWeather['daily']['sunrise'][i],
        'sunset': jsonWeather['daily']['sunset'][i]
      };
    }
  }
  void getLocality(double latitude, double longitude) async {
    List<Placemark> adressList = await placemarkFromCoordinates(latitude, longitude);
    changeLocality(adressList[0].locality.toString());
  }
  void changeLocality(String content){
    setState(() {
      currentValues['locality'] = content;
    });
  }
  void getCurrentTemperature(){
    setState(() {
      currentValues['temperature'] = "${jsonWeather['current_weather']['temperature']}ºC";
    });
  }
  void getCurrentWind(){
    setState(() {
      currentValues['windspeed'] = "${jsonWeather['current_weather']['windspeed']}Km/h";
      winddirection = jsonWeather['current_weather']['winddirection'].toInt();
    });
  }
  void getCurrentWeatherCode(){
    setState(() {
      currentValues['weathercode'] = Icon(dayNightWeatherIcon(
        jsonWeather['current_weather']['weathercode'].toInt(),
        DateTime.now(),
        DateTime.parse(jsonWeather['daily']['sunrise'][0]),
        DateTime.parse(jsonWeather['daily']['sunset'][0]),
      ), size: 100,);
    });
  }
  void setHourlyUnits(){
    hourlyUnits = jsonWeather['hourly_units'];
    dailyUnits = jsonWeather['daily_units'];
  }
  bool forceShowInfoCard = false;
  generateHourCards() async {
    final prefs = await SharedPreferences.getInstance();
    int indexList = 0;
    hourCards = [];
    if(prefs.getBool('firstTimeWeather') == null || prefs.getBool('firstTimeWeather') == false || forceShowInfoCard){
      indexList = 1;
      hourCards = [
        Card(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInCubic,
            height: 150,
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                Icon(Icons.touch_app_outlined, size: 50,),
                Text('Toca las targetas para ver más información', textAlign: TextAlign.center,)
              ],
            ),
          ),
        ),
      ];
      prefs.setBool('firstTimeWeather', true);
      forceShowInfoCard = true;
    }
    String twoDigit(number){
      if(number.toString().length == 1){
        return '${number}0';
      }
      return '$number';
    }
    final DateTime now = DateTime.now();

    for(int i = 0; indexList <= 25; i++){
      // Ignorar si es anterior a la fecha actual
      DateTime time = DateTime.parse(jsonWeather['hourly']['time'][i].toString());
      String date = jsonWeather['hourly']['time'][i].split("T")[0];
      if(!(time.compareTo(now) < 0)){
        setState(() {
          hourCards.insert(indexList, createHourCard({
            'temperature_2m': '${jsonWeather['hourly']['temperature_2m'][i]}',
            'time': '${time.hour}:${twoDigit(time.minute)}\n${time.day}/${time.month}',
            'nowtime': time,
            'weathercode': jsonWeather['hourly']['weathercode'][i],
            'precipitation': jsonWeather['hourly']['precipitation'][i],
            'windspeed_10m': jsonWeather['hourly']['windspeed_10m'][i],
            'apparent_temperature': jsonWeather['hourly']['apparent_temperature'][i],
            'relativehumidity_2m': jsonWeather['hourly']['relativehumidity_2m'][i],
            'visibility': jsonWeather['hourly']['visibility'][i],
            'direct_radiation_instant': jsonWeather['hourly']['direct_radiation_instant'][i],
            'sunrise': DateTime.parse(sunRiseSetValue[date]['sunrise']),
            'sunset': DateTime.parse(sunRiseSetValue[date]['sunset']),
          }));
        });
        indexList++;
      }
    }
  }
  generateDailyCards(){
    String nombreDia(int numero, int i){
      if(i == 0){
        return 'Hoy';
      }
      List<String> nameDays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      return nameDays[numero - 1];
    }
    dailyCards = [];
    for(int i = 0; i < jsonWeather['daily']['time'].length - 1; i++){
      DateTime sunriseT = DateTime.parse(jsonWeather['daily']['sunrise'][i]);
      String sunrise = '${sunriseT.hour}:${sunriseT.minute}';
      DateTime sunsetT = DateTime.parse(jsonWeather['daily']['sunset'][i]);
      String sunset = '${sunsetT.hour}:${sunsetT.minute}';
      setState(() {
        dailyCards.insert(i, AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.decelerate,
          height: dailyCardsExpanded[i] == true ? 220 : 30,
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: (){
              setState(() {
                dailyCardsExpanded[i] = !dailyCardsExpanded[i];
                generateDailyCards();
              });
            },
            onLongPress: (){
              // Toggles all the cards
              if(!dailyCardsExpanded.contains(false)){
                dailyCardsExpanded = [false, false, false, false, false, false];
              }
              else {
                dailyCardsExpanded = [true, true, true, true, true, true];
              }
              generateDailyCards();
            },
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${nombreDia(DateTime.parse(jsonWeather['daily']['time'][i]).weekday, i)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.start,),
                    Container(
                      margin: const EdgeInsets.only(bottom: 4, right: 15),
                      child: Icon(weatherIconsDay[jsonWeather['daily']['weathercode'][i]], size: 20,),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 3, right: 10),
                      child: Text('${jsonWeather['daily']['temperature_2m_min'][i]} ºC', style: const TextStyle(fontSize: 20, color: Colors.blue)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      child: Text('${jsonWeather['daily']['temperature_2m_max'][i]} ºC', style: const TextStyle(fontSize: 20, color: Colors.red)),
                    ),
                  ],
                ),
                AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.decelerate,
                    height: dailyCardsExpanded[i] == true ? 173 : 0,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.decelerate,
                          height: dailyCardsExpanded[i] == true ? 120 : 0,
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Amanecer', style: TextStyle(fontSize: 18), textAlign: TextAlign.end,),
                                  Container(
                                    height: 65,
                                    margin: const EdgeInsets.only(right: 9),
                                    child: const Icon(WeatherIcons.sunrise, size: 50, color: Colors.orangeAccent,),
                                  ),
                                  Text(sunrise, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Atardecer', style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                                  Container(
                                    height: 65,
                                    margin: const EdgeInsets.only(right: 9),
                                    child: const Icon(WeatherIcons.sunset, size: 50, color: Colors.red,),
                                  ),
                                  Text(sunset, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                                ],
                              )
                            ],
                          ),
                        ),
                        AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.decelerate,
                            height: dailyCardsExpanded[i] == true ? 23 : 0,
                            alignment: Alignment.topLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sensación térmica:', style: TextStyle(fontSize: 17), textAlign: TextAlign.start,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 3, right: 10),
                                      child: Text('${jsonWeather['daily']['apparent_temperature_min'][i]} ${dailyUnits['apparent_temperature_min']}', style: const TextStyle(fontSize: 20, color: Colors.blue)),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      child: Text('${jsonWeather['daily']['apparent_temperature_max'][i]} ${dailyUnits['apparent_temperature_max']}', style: const TextStyle(fontSize: 20, color: Colors.red)),
                                    ),
                                  ],
                                )
                              ],
                            )
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.decelerate,
                          height: dailyCardsExpanded[i] == true ? 30 : 0,
                          alignment: Alignment.topLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Precipitaciones:', style: TextStyle(fontSize: 17), textAlign: TextAlign.start,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 3, right: 10),
                                    child: Text('${jsonWeather['daily']['precipitation_sum'][i]} ${dailyUnits['precipitation_sum']}', style: const TextStyle(fontSize: 20, color: Colors.blue)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    )
                )
              ],
            ),
          ),
        ));
      });
    }
  }
  refreshWeather({bool searchingDeterminatedLocation = false}) async {
    final prefs = await SharedPreferences.getInstance();
    void getAllValues(double latitude, double longitude) async {
      getTopBackgroundColor(jsonWeather['current_weather']['weathercode']);
      _scrollListener();
      getSunRiseSet();
      getCurrentWeatherCode();
      setHourlyUnits();
      generateHourCards();
      generateDailyCards();
      getCurrentTemperature();
      getCurrentWind();
      getLocality(latitude, longitude);
    }
    if(prefs.getString('jsonWeather') != null && !searchingDeterminatedLocation){
      jsonWeather = jsonDecode(prefs.getString('jsonWeather').toString()) as Map<String, dynamic>;
      setState(() {
        getAllValues(gpsLatitude, gpsLongitude);
      });
    }
    serviceStatusLocation();
    setState((){
      winddirection = 0;
      currentValues = {
        'locality' : 'Cargando...',
        'temperature': '...',
        'windspeed': '...',
        'weathercode': Container(margin: const EdgeInsets.symmetric(horizontal: 60), child: SpinKitFoldingCube(
          itemBuilder: (BuildContext context, int index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: index.isEven ? Colors.orange : Colors.orangeAccent,
              ),
            );
          },
          duration: const Duration(milliseconds: 900),
        ),
        ),
      };
      hourlyUnits = {};
      dailyCardsExpanded = [false, false, false, false, false, false];
      showingFirstCapeHourCard = true;
    });
    if(searchingDeterminatedLocation){
      await fetchWeatherData(latitude, longitude);
      getAllValues(latitude, longitude);
    } else {
      await getLocationPosition(LocationAccuracy.best);
      await fetchWeatherData(gpsLatitude, gpsLongitude);
      getAllValues(gpsLatitude, gpsLongitude);
    }    
    setState(() {
      _currentWeatherSize = MediaQuery.of(context).size.height - 290;
    });
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    prefs.setString('jsonWeather', jsonEncode(jsonWeather));
    _refreshController.refreshCompleted();
  }
  Future<void> showStationsDialog(BuildContext context){
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          title: const Text('Estaciones meteorológicas', style: TextStyle(fontSize: 30),),
          content: const Text('(En desarrollo)\nLas estaciones meteorológicas te permiten guardar ubicaciones para poder consultar el tiempo de cualquier sitio'),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            )
          ],
        );
      }
    );
  }
  @override
  void initState() {
    serviceStatusLocation();
    // initialize scroll controllers
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationPermision();
      refreshWeather();
      _scrollListener();
    });
    super.initState();
  }
  @override
  void dispose() {
    textFieldLocationControler.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ors Apps',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScroll(),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: AppBar(
            title: const Text('Clima', style: TextStyle(fontFamily: 'Aclonica', fontSize: 35, height: 2.2, overflow: TextOverflow.fade)),
            leading: Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: IconButton(
                    icon: const Icon(Icons.menu, size: 40,),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip: 'Abrir menu de navegación',
                  ),
                );
              },
            ),
          ),
        ),
        drawer: const MyDrawer(),
        body: WebSmoothScroll(
          controller: _scrollController,
          scrollOffset: scrollOffsetAllPage,
          animationDuration: 400,
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            color: animatedBackgroundColor,
            child: RefreshConfiguration(
              maxOverScrollExtent: 50,
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: const WaterDropMaterialHeader(),
                onRefresh: refreshWeather,
                controller: _refreshController,
                child: ListView(
                    padding: const EdgeInsets.all(0),
                    controller: _scrollController,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 25, right: 25, top: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 180,
                              height: 60,
                              child: TextField(
                                controller: textFieldLocationControler,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Introduce una dirección"
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: 60,
                              height: 58,
                              child: ElevatedButton(onPressed: changeDeterminatedLocation, child: const Icon(Icons.search)),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              width: 60,
                              height: 58,
                              child: ElevatedButton(onPressed: ()=> showStationsDialog(context), child: const Icon(Icons.menu)),
                            ),
                          ],
                        ),
                      ),

                      // Container current weather
                      AnimatedSize(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child: SizedBox(
                          height: _currentWeatherSize,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: <Widget>[
                              Positioned(
                                  left: 20,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 40),
                                    child: currentValues['weathercode'],
                                  )
                              ),
                              Positioned(
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width - 200,
                                        child: Wrap(
                                          alignment: WrapAlignment.end,
                                          children: [
                                            Text(currentValues['locality'].toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400), overflow: TextOverflow.ellipsis, maxLines: 3, softWrap: false, textAlign: TextAlign.end),
                                          ],
                                        ),
                                      ),
                                      Row(
                                          children: [
                                            Text(currentValues['temperature'].toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)
                                          ]
                                      ),
                                      Row(
                                          children: [
                                            Text(currentValues['windspeed'].toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),)
                                          ]
                                      )
                                    ],
                                  )
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Weather foreach hour
                      SizedBox(
                        height: 165,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: hourCards,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Card(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: dailyCards,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 1000,
                      ),
                    ]
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Translate extends StatefulWidget {
  const Translate({Key? key}) : super(key: key);

  @override
  State<Translate> createState() => _TranslateState();
}
class _TranslateState extends State<Translate> {
  late ScrollController _scrollController;
  @override
  void initState() {
    serviceStatusLocation();
    // initialize scroll controllers
    _scrollController = ScrollController();
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
    });*/
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ors Apps',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScroll(),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: AppBar(
            title: const Text('Ors Translate', style: TextStyle(fontFamily: 'Aclonica', fontSize: 35, height: 2.2, overflow: TextOverflow.fade)),
            leading: Builder(
              builder: (BuildContext context) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: IconButton(
                    icon: const Icon(Icons.menu, size: 40,),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    tooltip: 'Abrir menu de navegación',
                  ),
                );
              },
            ),
          ),
        ),
        drawer: const MyDrawer(),
        body: WebSmoothScroll(
          controller: _scrollController,
          animationDuration: 400,
          curve: Curves.easeInOut,
          child: Container(),
        ),
      ),
    );
  }
}
class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}
class _SettingsState extends State<Settings> {
  String onOpenPreference = "homePage";
  String searchUpdatesText = "Buscar actualizaciones";
  final _formKey = GlobalKey<FormState>();
  Widget header(String text){
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15, bottom: 5),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
              ),
            ),
          ),
          child: Text(text, style: const TextStyle(fontSize: 25), overflow: TextOverflow.fade,),
        )
      ],
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ors Apps',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScroll(),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(20),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 5, top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.orange,
                    width: 2,
                  )
                )
              ),
              child: const Text('Configuración', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
            ),
            header('Actualizaciones:'),
            OutlinedButton(
                onPressed: () async {
                  setState(() {
                    searchUpdatesText = "Buscando...";
                  });
                  bool update = await lastUpdate();
                  if(update){
                    setState(() {
                      searchUpdatesText = "Tienes la ultima version";
                    });
                  }
                  /// Going to web and downloading the packages
                  else {
                    setState(() {
                      searchUpdatesText = "Abriendo navegador...";
                      if(Platform.isAndroid){
                        launch('https://raw.githubusercontent.com/oriolgds/orsapps/main/Ors%20Apps.apk', forceWebView: false, forceSafariVC: true, enableJavaScript: true, enableDomStorage: true);
                      }
                      else {
                        launch('https://raw.githubusercontent.com/oriolgds/orsapps/main/Ors%20Apps.zip', forceWebView: false, forceSafariVC: true, enableJavaScript: true, enableDomStorage: true);
                      }
                      Timer(const Duration(seconds: 3), () {
                        setState(() {
                          searchUpdatesText = "Buscar actualizaciones";
                        });
                      });
                    });
                  }
                },
                child: Text(searchUpdatesText),
            ),
            header('Al abrir:'),
            Form(
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('Abrir la página de inicio'),
                    value: "homePage",
                    groupValue: onOpenPreference,
                    activeColor: Colors.orange,
                    onChanged: (value){
                      setState(() {
                        onOpenPreference = value.toString();
                      });
                    }
                  ),
                  RadioListTile(
                      title: const Text('Abrir tal como estaba antes de cerrar'),
                      value: "lastPage",
                      groupValue: onOpenPreference,
                      activeColor: Colors.orange,
                      onChanged: (value){
                        setState(() {
                          onOpenPreference = value.toString();
                        });
                      }
                  ),
                  RadioListTile(
                      title: const Text('Abrir una página en especifico'),
                      value: "especificPage",
                      groupValue: onOpenPreference,
                      activeColor: Colors.orange,
                      onChanged: (value){
                        setState(() {
                          onOpenPreference = value.toString();
                        });
                      }
                  ),
                ],
              )
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pop(context);
            Navigator.of(context).push(routeShowPageVertical(const MyHomePage(title: 'Ors Apps')));
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.home),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
class Creditos extends StatefulWidget {
  const Creditos({Key? key}) : super(key: key);

  @override
  State<Creditos> createState() => _CreditosState();
}
class _CreditosState extends State<Creditos> {
  var scrollController = ScrollController();
  @override
  void initState() {
    scrollController.animateTo(500, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOutSine);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width,
        color: Colors.black87,
        child: WebSmoothScroll(
          controller: scrollController,
          scrollOffset: 100,
          animationDuration: 400,
          curve: Curves.easeInOut,
          child: SingleChildScrollView(
            physics: scrollPysics(context),
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 300,
                ),
                const Text('Creado por:', style: TextStyle(color: Colors.white, fontSize: 50), textAlign: TextAlign.center,),
                const Text('Oriol Giner', style: TextStyle(color: Colors.orange, fontSize: 30), textAlign: TextAlign.center,),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await launch('http://oriol.22web.org/', forceSafariVC: true, forceWebView: false, enableJavaScript: true, enableDomStorage: true);

                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('oriol.22web.org', style: TextStyle(color: Colors.white, fontSize: 30),),
                  )
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text('Agradecimientos:', style: TextStyle(color: Colors.white, fontSize: 40), textAlign: TextAlign.center,),
                const SizedBox(
                  height: 10,
                ),
                const Text('A mis padres:', style: TextStyle(color: Colors.orange, fontSize: 30), textAlign: TextAlign.center,),
                const Text('Por el equipo y el apoyo', style: TextStyle(color: Colors.deepOrange, fontSize: 25), textAlign: TextAlign.center,),
                const SizedBox(
                  height: 25,
                ),
                const Text('A todos los creadores de contenido:', style: TextStyle(color: Colors.orange, fontSize: 30), textAlign: TextAlign.center,),
                const Text('Por su información y sus explicaciones', style: TextStyle(color: Colors.deepOrange, fontSize: 25), textAlign: TextAlign.center,),
                const SizedBox(
                  height: 25,
                ),
                const Text('A Stack Overflow:', style: TextStyle(color: Colors.orange, fontSize: 30), textAlign: TextAlign.center,),
                const Text('Y todos los que contestan las preguntas', style: TextStyle(color: Colors.deepOrange, fontSize: 25), textAlign: TextAlign.center,),
                const SizedBox(
                  height: 25,
                ),
                const Text('A Google:', style: TextStyle(color: Colors.orange, fontSize: 30), textAlign: TextAlign.center,),
                const Text('Por este magnifico lenguaje de programación', style: TextStyle(color: Colors.deepOrange, fontSize: 25), textAlign: TextAlign.center,),
                const SizedBox(
                  height: 25,
                ),
                const Text('Al código abierto:', style: TextStyle(color: Colors.orange, fontSize: 30), textAlign: TextAlign.center,),
                const Text('Por esos programadores que desarrollan para desarrollar más', style: TextStyle(color: Colors.deepOrange, fontSize: 25), textAlign: TextAlign.center,),
                const SizedBox(
                  height: 25,
                ),
                const SizedBox(
                  height: 300,
                ),
              ],
            ),
          )
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pop(context);
          Navigator.of(context).push(routeShowPageVertical(const MyHomePage(title: 'Ors Apps')));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.home),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark
  ));
  runApp(const MyApp());
  await getLocationPosition(LocationAccuracy.best);
}
Route routeShowPage(var function) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => function,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
Route routeShowPageVertical(var function) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => function,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
Future<void> serviceStatusLocation() async {
  bool servicestatus = await Geolocator.isLocationServiceEnabled();
  if(servicestatus){
    debugPrint("GPS service is enabled");
  }else{
    debugPrint("GPS service is disabled.");
  }
  locationPermision();
}
Future<void> locationPermision() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('Location permissions are denied');
    }else if(permission == LocationPermission.deniedForever){
      debugPrint("Location permissions are permanently denied");
    }else{
      debugPrint("GPS Location service is granted");
    }
  }else{
    debugPrint("GPS Location permission granted.");
  }
}
Future<Map<String, double>> getLocationPosition(accuracy) async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
  gpsLongitude = position.longitude;
  gpsLatitude = position.latitude;
  return {
    'longitude': position.longitude,
    'latitude': position.latitude
  };
}
Future<Map<dynamic, dynamic>> fetchWeatherData(double latitude, double longitude) async {
  Map<dynamic, dynamic> jsonParsed = {};
  await getLocationPosition(LocationAccuracy.best);
  Uri jsonURL = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,relativehumidity_2m,apparent_temperature,precipitation,weathercode,visibility,windspeed_10m,direct_radiation_instant&models=best_match&daily=weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,precipitation_sum&current_weather=true&timezone=auto');
  await http.get(jsonURL).then((res){
    jsonParsed = jsonDecode(res.body);
    jsonWeather = jsonParsed;
  });
  return jsonParsed;
}
/// Returns false if you don't have the last version
Future<bool> lastUpdate() async {
  Map<dynamic, dynamic> json = {};
  await http.get(Uri.parse('https://raw.githubusercontent.com/oriolgds/orsapps/main/versions.json')).then((res){
    json = jsonDecode(res.body);
  });
  int version = json['lastVersion'];
  if(version > appVersion()){
    return false;
  }
  return true;
}
int appVersion(){
  return 302;
}