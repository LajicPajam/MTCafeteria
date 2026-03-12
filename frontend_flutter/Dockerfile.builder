FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY frontend_flutter/ ./
RUN flutter pub get
RUN flutter build web --release --dart-define=API_BASE_URL=

FROM nginx:1.27-alpine

COPY frontend_flutter/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
