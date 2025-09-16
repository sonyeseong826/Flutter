// main.dart 파일
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
        elevation: 1, // 앱바 아래 그림자 효과
        actions: [
          // 오른쪽 상단에 '나가기' 아이콘 버튼 추가
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.deepPurple),
            onPressed: () {
              // TODO: 앱 종료 또는 이전 화면으로 이동하는 기능
            },
          ),
        ],
      ),
      // 화면의 본문
      body: Stack(
        children: [
          // 1. 지도 위젯 (가장 아래에 배치)
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            zoomControlsEnabled: false, // 확대/축소 버튼 제거
          ),
          // 2. 상단 '이용시간 설정하기' 버튼
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      '이용시간 설정하기',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 3. 오른쪽 '내 위치' 버튼
          Positioned(
            right: 16,
            bottom: 50, // 하단 내비게이션 바 위로 위치 조정
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              shape: const CircleBorder(), // 버튼 모양을 원형으로
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.deepPurple),
            ),
          ),
        ],
      ),
      // 하단 내비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 아이템 수가 많을 때 사용
        backgroundColor: Colors.deepPurple.shade100, // 배경색 연보라색으로
        selectedItemColor: Colors.deepPurple, // 선택된 아이콘/라벨 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이콘/라벨 색상
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