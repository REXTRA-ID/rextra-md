# rextra_app

Aplikasi Flutter untuk REXTRA.

## Menjalankan secara lokal (localhost:5000)

Setiap orang yang clone/pull repo ini dijalankan dengan port yang sama supaya
konsisten (login redirect, cookie, dsb bergantung ke origin yang sama).

```bash
flutter pub get
flutter run -d chrome --web-port=5000
```

Atau lewat VS Code: buka tab **Run and Debug**, pilih konfigurasi
**"Flutter Web (localhost:5000)"**, lalu tekan F5 (konfigurasi ini sudah ada
di `.vscode/launch.json`).

Aplikasi akan terbuka di `http://localhost:5000` dan secara default memanggil
backend di `http://localhost:8080/api/v1` (lihat `lib/core/config/env.dart`).
Pastikan `rextra-backend` sudah berjalan secara lokal di port 8080 sebelum
mencoba fitur yang butuh login/API.

> Catatan (Linux + Wayland): kalau layar Chrome/Brave blank/hitam saat
> `flutter run`, tambahkan flag berikut untuk memaksa X11:
> `flutter run -d chrome --web-port=5000 --web-browser-flag=--ozone-platform=x11`

## Sumber belajar Flutter

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Dokumentasi online Flutter](https://docs.flutter.dev/)
