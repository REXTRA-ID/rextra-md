import 'package:flutter/material.dart';

class VerifyFailedDialog extends StatelessWidget {
  final VoidCallback onBack;

  const VerifyFailedDialog({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/VerifikasiEmailGagal.png',
              height: 160,
            ),
            const SizedBox(height: 20),
            const Text(
              'Verifikasi Gagal Terkirim',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Permintaan verifikasi sudah diterima. '
                  'Coba lagi setelah 1 jam agar tidak terdeteksi spam, '
                  'dan cek email kamu setelahnya.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onBack();
                },
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}