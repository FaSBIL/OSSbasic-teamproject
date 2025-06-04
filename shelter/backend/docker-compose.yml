# 1. 베이스 이미지로 Alpine 기반의 Node.js LTS 버전을 사용합니다.
FROM node:lts-alpine

# 2. 애플리케이션 소스가 올라갈 작업 디렉토리를 설정합니다.
WORKDIR /usr/src/app

# 3. package.json과 package-lock.json(있는 경우)만 먼저 복사하여
#    의존성 설치 단계가 캐시되도록 합니다.
COPY package*.json ./

# 4. 의존성 설치. 프로덕션 빌드를 위한 최적화된 설치 명령 (npm ci)을 사용합니다.
#    (package-lock.json이 없으면 npm install로 대체해도 무방합니다.)
RUN npm ci

# 5. 전체 소스 코드를 복사합니다.
COPY . .

# 6. 컨테이너 외부에서 접속할 포트를 명시합니다.
#    예시에서는 3000번 포트를 사용한다고 가정합니다.
EXPOSE 3000

# 7. 컨테이너가 시작될 때 실행될 기본 커맨드를 정의합니다.
#    개발 중에는 "npm run dev"로 nodemon 등을 사용한 자동 재시작을 할 수 있으며,
#    프로덕션 모드라면 "npm start"로 실제 서버를 띄울 수 있습니다.
#    필요에 따라 docker-compose.yml에서 override 가능합니다.
CMD ["npm", "run", "dev"]
