import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';

// 앱의 시작점
void main() {
  runApp(const MyApp());
}

// 앱의 기본 설정 및 테마를 정의하는 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 앱의 제목 설정 (작업 관리자 등에 표시)
      title: 'Flutter 구글 지도',
      // 앱의 전체적인 디자인 테마 설정
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 앱의 언어를 한국어로 설정
      locale: const Locale('ko', 'KR'),
      // 현지화(Localization)에 필요한 델리게이트들
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 지원하는 언어 목록
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      // 앱이 시작될 때 보여줄 첫 화면
      home: const GoogleMapScreen(),
    );
  }
}

// 지도를 포함한 메인 화면 위젯 (상태 변화가 있으므로 StatefulWidget 사용)
class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

// GoogleMapScreen의 상태를 관리하는 클래스
class _GoogleMapScreenState extends State<GoogleMapScreen> {
  // 지도의 초기 중심 위치 (서울 시청)
  static const LatLng _center = LatLng(37.5665, 126.9780);

  // 지도 컨트롤러 (지도를 제어하는 데 사용)
  late GoogleMapController mapController;

  // 지도가 생성되었을 때 호출되는 함수
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // 내 위치 버튼을 눌렀을 때 실행되는 함수
  Future<void> _goToCurrentLocation() async {
    // 1. 위치 서비스가 활성화되었는지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 서비스를 활성화해주세요.')),
      );
      return;
    }

    // 2. 위치 권한 상태 확인 및 요청
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 거부되었습니다.')),
        );
        return;
      }
    }

    // 3. 위치 권한이 영구적으로 거부되었는지 확인
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 변경해주세요.')),
      );
      return;
    }

    // 4. 현재 위치 정보 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // 5. 지도 카메라를 현재 위치로 이동시키고 확대
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 17.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱바 (헤더)
      appBar: AppBar(
        title: const Text(
          '고고렌탈',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.deepPurple),
            onPressed: () {
              // TODO: 앱 종료 또는 이전 화면으로 이동하는 기능
            },
          ),
        ],
      ),

      // 화면 본문
      body: Stack(
        children: [
          // 1. 지도
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            zoomControlsEnabled: false,
          ),

          // 2. 상단 '이용시간 설정하기' 카드형 UI
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.schedule, color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  const Text(
                    '이용시간 설정하기',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        '대여 : 2025-09-17(수) 11:00',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Text(
                        '반납 : 2025-09-24(수) 11:00',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),

          // 3. 오른쪽 '내 위치' 버튼
          Positioned(
            right: 16,
            bottom: 50,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.deepPurple),
            ),
          ),
        ],
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.deepPurple.shade100,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: '센터정보',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: '이용내역',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: '고고렌탈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: '1:1문의',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'MY',
          ),
        ],
      ),
    );
  }
}
