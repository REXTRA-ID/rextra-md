import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/js_widgets.dart';

/// Halaman berhasil tambah / hapus data studi (Figma 7754:85125,
/// 7754:85330, 7708:71555).
class JejakStudiSuccessPage extends StatelessWidget {
  final bool deleted;
  const JejakStudiSuccessPage({super.key, this.deleted = false});

  @override
  Widget build(BuildContext context) {
    final title = deleted
        ? 'Data Studi Berhasil Dihapus'
        : 'Data Studi Berhasil Ditambahkan';
    final body = deleted
        ? 'Data studi telah dihapus dari Jejak Studi dan sudah tidak ditampilkan lagi pada daftar maupun detail studi kamu'
        : 'Informasi ini akan disimpan sebagai bagian dari riwayat studi dan dapat digunakan pada fitur lanjutan yang relevan';

    void back() => context.go('/jejak-studi');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: JsColors.text),
            onPressed: back,
          ),
          title: Image.asset('assets/images/rextra.png', height: 26),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1, color: JsColors.divider),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 24),
              child: Column(
                children: [
                  Image.asset(
                    deleted
                        ? 'assets/images/jejak_studi/mascot_berhasil_hapus.png'
                        : 'assets/images/jejak_studi/mascot_berhasil_tambah.png',
                    height: deleted ? 210 : 255,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: deleted ? 22 : 24,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                      color: JsColors.heading,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: Color(0xFF222420),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child:
                        JsButton(label: 'Kembali', height: 52, onPressed: back),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
