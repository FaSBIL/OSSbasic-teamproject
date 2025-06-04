# 1. Flutter SDK가 설치된 공식 이미지를 사용합니다.
FROM cirrusci/flutter:latest

# 2. 작업 디렉토리를 /app으로 설정합니다.
WORKDIR /app

# 3. 의존성 설치를 위해 pubspec 파일만 먼저 복사하고 flutter pub get을 실행합니다.
#    → 이렇게 하면, 코드가 변경되지 않는 한 pub get 단계가 캐시되어 빌드 속도가 빨라집니다.
COPY pubspec.* ./
RUN flutter pub get

# 4. 애플리케이션 소스코드를 모두 복사합니다.
COPY . .

# 5. 컨테이너가 기동될 때 실행할 기본 명령을 정의합니다.
#    여기서는 개발용 Flutter Web 서버를 띄우도록 구성했습니다.
#    호스트 포트 8080을 내부 8080 포트에 바인딩하고, 0.0.0.0에 바인딩하여 외부(호스트)에서 접근할 수 있게 합니다.
CMD ["bash", "-lc", "flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0"]
