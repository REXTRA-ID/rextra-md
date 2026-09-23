# --- Build stage ---
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Argument disuntikkan oleh Coolify (Build Variables) saat build image
ARG API_BASE_URL=https://api.rextra.io/api/v1

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# --- Serve stage ---
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
