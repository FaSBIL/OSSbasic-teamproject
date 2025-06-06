대피Go
대한민국 전역 오프라인 대피소 안내 Flutter 앱과 데이터 가공용 Node.js 스크립트를 포함한 저장소입니다. 인터넷 없이도 GPS 기반 위치 측정 및 오프라인 지도를 활용하여 최단 경로를 안내합니다.

1. 설치 방법
저장소 클론:

git clone https://github.com/FaSBIL/OSSbasic-teamproject.git


2. 의존성
OS:

Ubuntu 20.04 LTS 이상 (Windows/Mac도 Docker와 호환되는 버전 사용 권장)

라이브러리 및 툴:

Docker Engine ≥ 20.10

Docker Compose ≥ 1.29

Flutter SDK 3.x (개발용; Docker 내부 이미지를 사용하므로 로컬 설치는 선택 사항)

Node.js 18.x LTS (개발용; Docker 내부에서 node:lts-alpine 기본 이미지 사용)

3. 실행 방법

프로젝트 디렉토리 shelter/frontend/assets/region_graphs에 노드/간선 db를 별도로 다운받아 저장하는 것이 필요함. 용량이 1GB를 초과하여 LFS를 사용하지 못했음.

안드로이드 휴대폰 디렉토리의 /sdcard/Android/data/com.example.shelter/files/
에 미리 mbtiles 파일을 넣어둔 후에 그 위에서 앱을 빌드하는 방식으로 시도

따라서 Android 빌드 전에는 pubspec.yaml에서 .mbtiles 관련 항목을 주석 처리하는 방식으로 해결함. iOS에서 빌드 할 때는 아래의 코드를 주석처리 하지 않고 assets 폴더에 포함된 파일을 이용헤서 빌드함.

flutter:
  assets:
    # - assets/mbtiles/8_16kr-map.mbtiles

cd OSSbasic-teamproject/shelter/frontend
(flutter가 frontend 디렉토리에 설치되어있음!)
flutter run

4. 라이선스
모든 소스 코드는 MIT 라이선스 하에 배포됩니다.
자세한 내용은 LICENSE 파일을 확인하세요.

5. 실명/연락처
실명: 이승호 , 김영훈, 심지명, 사네토우 유우나

조장 이메일: sophist0214@naver.com
