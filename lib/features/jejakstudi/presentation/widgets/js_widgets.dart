import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/nav_utils.dart';
import '../../domain/education_models.dart';

/// Warna & komponen bersama halaman Jejak Studi (Figma Task Flow 4).
class JsColors {
  JsColors._();
  static const primary = Color(0xFF0046CC);
  static const accent = Color(0xFF0057FF);
  static const title = Color(0xFF1E63F6);
  static const text = Color(0xFF111415);
  static const heading = Color(0xFF212729);
  static const hint = Color(0xFF6B6F70);
  static const border = Color(0xFFDFE1E7);
  static const cardBorder = Color(0xFFB5B5B5);
  static const divider = Color(0xFFCACACA);
  static const focusRing = Color(0xFFCCDDFF);
  static const error = Color(0xFFE24A4A);
  static const errorRing = Color(0xFFFBD5D5);
  static const disabledFill = Color(0xFFF1F2F4);
  static const disabledText = Color(0xFF9CA3AF);
  static const selectedRow = Color(0xFFF3F4F6);
}

PreferredSizeWidget jsAppBar(BuildContext context,
    {String title = 'JEJAK STUDI', String fallback = '/jejak-studi'}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: JsColors.text),
      onPressed: () => popOrGo(context, fallback),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: JsColors.title,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    ),
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: JsColors.divider),
    ),
  );
}

/// Bar tombol di bawah layar (putih, garis atas abu).
class JsBottomBar extends StatelessWidget {
  final List<Widget> children;
  const JsBottomBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: JsColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 20),
              Expanded(child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class JsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final double height;
  final double fontSize;
  final bool loading;

  const JsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.height = 48,
    this.fontSize = 16,
    this.loading = false,
  });

  const JsButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 48,
    this.fontSize = 16,
  })  : primary = false,
        loading = false;

  @override
  Widget build(BuildContext context) {
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    final text = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: primary ? Colors.white : const Color(0xFF0D0D12),
            ),
          );
    return SizedBox(
      height: height,
      child: primary
          ? ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: JsColors.primary,
                disabledBackgroundColor:
                    JsColors.primary.withValues(alpha: 0.6),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: shape,
              ),
              child: text,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: JsColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: shape,
              ),
              child: text,
            ),
    );
  }
}

/// Label + field + pesan error, dengan jarak antar-field seperti Figma.
class JsField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? error;
  final String? helper;

  const JsField({
    super.key,
    required this.label,
    required this.child,
    this.error,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: JsColors.text,
            ),
          ),
          const SizedBox(height: 8),
          child,
          if (error != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 15, color: JsColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    error!,
                    style: const TextStyle(fontSize: 13, color: JsColors.error),
                  ),
                ),
              ],
            ),
          ] else if (helper != null) ...[
            const SizedBox(height: 6),
            Text(helper!,
                style: const TextStyle(fontSize: 12, color: JsColors.hint)),
          ],
        ],
      ),
    );
  }
}

BoxDecoration _boxDecoration({
  required bool focused,
  required bool hasError,
  required bool enabled,
}) {
  final borderColor = hasError
      ? JsColors.error
      : focused
          ? JsColors.accent
          : JsColors.border;
  return BoxDecoration(
    color: enabled ? Colors.white : JsColors.disabledFill,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: borderColor),
    boxShadow: hasError || focused
        ? [
            BoxShadow(
              color: hasError ? JsColors.errorRing : JsColors.focusRing,
              spreadRadius: 3,
            ),
          ]
        : null,
  );
}

/// Kotak 48px yang bisa diketuk (dropdown / picker bulan).
class _TapBox extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final bool open;
  final bool hasError;
  final bool enabled;
  final VoidCallback onTap;

  const _TapBox({
    required this.value,
    required this.hint,
    required this.icon,
    required this.open,
    required this.hasError,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration:
            _boxDecoration(focused: open, hasError: hasError, enabled: enabled),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: !enabled
                      ? JsColors.disabledText
                      : value == null
                          ? JsColors.hint
                          : JsColors.text,
                ),
              ),
            ),
            Icon(icon,
                size: 22,
                color: enabled ? JsColors.text : JsColors.disabledText),
          ],
        ),
      ),
    );
  }
}

Widget _popupCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: JsColors.border),
      boxShadow: const [
        BoxShadow(
            color: Color(0x140D0D12), blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: child,
  );
}

Widget _optionRow(String label, bool selected, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? JsColors.selectedRow : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 15, color: JsColors.text)),
          ),
          if (selected) const Icon(Icons.check, size: 20, color: JsColors.text),
        ],
      ),
    ),
  );
}

class JsTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool hasError;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const JsTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.hasError = false,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  State<JsTextField> createState() => _JsTextFieldState();
}

class _JsTextFieldState extends State<JsTextField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _boxDecoration(
        focused: _focus.hasFocus,
        hasError: widget.hasError,
        enabled: widget.enabled,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontSize: 15,
          color: widget.enabled ? JsColors.text : JsColors.disabledText,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 15, color: JsColors.hint),
        ),
      ),
    );
  }
}

/// Dropdown yang membuka daftar pilihan di bawah field (bukan popup),
/// sesuai Figma.
class JsSelectField<T> extends StatefulWidget {
  final T? value;
  final List<T> options;
  final String Function(T) labelOf;
  final String hint;
  final bool hasError;
  final bool enabled;
  final ValueChanged<T> onChanged;

  const JsSelectField({
    super.key,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.hint,
    required this.onChanged,
    this.hasError = false,
    this.enabled = true,
  });

  @override
  State<JsSelectField<T>> createState() => _JsSelectFieldState<T>();
}

class _JsSelectFieldState<T> extends State<JsSelectField<T>> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TapBox(
          value: v == null ? null : widget.labelOf(v),
          hint: widget.hint,
          icon: _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          open: _open,
          hasError: widget.hasError,
          enabled: widget.enabled,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() => _open = !_open);
          },
        ),
        if (_open)
          _popupCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (final o in widget.options)
                    _optionRow(widget.labelOf(o), o == v, () {
                      setState(() => _open = false);
                      widget.onChanged(o);
                    }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Field teks dengan saran di bawahnya ("Cari dan pilih ..."). Teks bebas
/// tetap diterima karena belum ada data master kampus/negara dari backend.
class JsSuggestField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final List<String> suggestions;
  final bool hasError;

  const JsSuggestField({
    super.key,
    required this.controller,
    required this.hint,
    required this.suggestions,
    this.hasError = false,
  });

  @override
  State<JsSuggestField> createState() => _JsSuggestFieldState();
}

class _JsSuggestFieldState extends State<JsSuggestField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.controller.text.trim().toLowerCase();
    final matches = widget.suggestions
        .where((s) => q.isEmpty || s.toLowerCase().contains(q))
        .take(5)
        .toList();
    final showList = _focus.hasFocus && matches.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.only(left: 12, right: 8),
          decoration: _boxDecoration(
            focused: _focus.hasFocus,
            hasError: widget.hasError,
            enabled: true,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 15, color: JsColors.text),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle:
                        const TextStyle(fontSize: 15, color: JsColors.hint),
                  ),
                ),
              ),
              Icon(
                showList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: JsColors.text,
              ),
            ],
          ),
        ),
        if (showList)
          _popupCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (final s in matches)
                    _optionRow(s, s == widget.controller.text, () {
                      widget.controller.text = s;
                      _focus.unfocus();
                    }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Picker bulan + tahun yang terbuka di bawah field, sesuai Figma.
class JsMonthField extends StatefulWidget {
  final MonthYear? value;
  final String hint;
  final bool hasError;
  final bool enabled;
  final ValueChanged<MonthYear> onChanged;

  const JsMonthField({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.hasError = false,
    this.enabled = true,
  });

  @override
  State<JsMonthField> createState() => _JsMonthFieldState();
}

class _JsMonthFieldState extends State<JsMonthField> {
  bool _open = false;
  late int _year = widget.value?.year ?? DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TapBox(
          value: v?.label,
          hint: widget.hint,
          icon: Icons.calendar_today_outlined,
          open: _open,
          hasError: widget.hasError,
          enabled: widget.enabled,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              _open = !_open;
              _year = widget.value?.year ?? _year;
            });
          },
        ),
        if (_open)
          _popupCard(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      _circleBtn(
                          Icons.chevron_left, () => setState(() => _year--)),
                      Expanded(
                        child: Text(
                          '$_year',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      _circleBtn(
                          Icons.chevron_right, () => setState(() => _year++)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: JsColors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 16,
                    children: [
                      for (var m = 1; m <= 12; m++)
                        _monthCell(m, v == MonthYear(_year, m)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: JsColors.border),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _monthCell(int m, bool selected) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        setState(() => _open = false);
        widget.onChanged(MonthYear(_year, m));
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? JsColors.primary : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          MonthYear.monthShort[m - 1],
          style: TextStyle(
            fontSize: 15,
            color: selected ? Colors.white : JsColors.text,
          ),
        ),
      ),
    );
  }
}

/// Judul + deskripsi di atas form.
class JsFormHeader extends StatelessWidget {
  final String title;
  final String description;
  final Widget? badge;

  const JsFormHeader({
    super.key,
    required this.title,
    required this.description,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: JsColors.heading,
                  ),
                ),
              ),
              if (badge != null) ...[const SizedBox(width: 10), badge!],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
                fontSize: 13, height: 1.5, color: JsColors.text),
          ),
        ],
      ),
    );
  }
}

/// Filter input IPK: angka dengan maksimal satu pemisah desimal.
final gpaInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  LengthLimitingTextInputFormatter(4),
];

final digitsOnly = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(2),
];

/// Daftar saran (belum ada data master dari backend).
const kUniversitySuggestions = [
  'Universitas Indonesia',
  'Universitas Gadjah Mada',
  'Institut Teknologi Bandung',
  'Institut Teknologi Sepuluh Nopember',
  'Universitas Airlangga',
  'Universitas Brawijaya',
  'Universitas Diponegoro',
  'Universitas Padjadjaran',
  'Institut Pertanian Bogor',
  'Universitas Negeri Surabaya',
  'Universitas Telkom',
  'Universitas Bina Nusantara',
];

const kCountrySuggestions = [
  'Korea Selatan',
  'Jepang',
  'China',
  'Taiwan',
  'Singapura',
  'Malaysia',
  'Thailand',
  'Australia',
  'Belanda',
  'Jerman',
  'Prancis',
  'Inggris',
  'Amerika Serikat',
  'Kanada',
  'Turki',
];
