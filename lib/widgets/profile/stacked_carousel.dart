import 'package:flutter/material.dart';

// ==========================================
// 🌟 STACKED CAROUSEL (Manuel Drag Engine + Z-Index Fix)
// ==========================================
class StackedCardCarousel extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double height;

  const StackedCardCarousel({
    super.key, 
    required this.itemCount, 
    required this.itemBuilder,
    this.height = 320, 
  });

  @override
  State<StackedCardCarousel> createState() => _StackedCardCarouselState();
}

class _StackedCardCarouselState extends State<StackedCardCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.75, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- MANUEL KAYDIRMA MANTIĞI ---
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Parmağın hareketini (piksel) PageView'in anlayacağı birime çeviriyoruz
    // viewportDimension genellikle ekran genişliği * viewportFraction'dır.
    if (_pageController.hasClients) {
      _pageController.position.jumpTo(_pageController.offset - details.delta.dx);
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_pageController.hasClients) return;

    // Hız ve konuma göre hangi sayfaya yapışacağını (snap) hesapla
    double velocity = details.primaryVelocity ?? 0;
    int targetPage = _currentPage.round();

    // Hızlı kaydırma (Fling) kontrolü
    if (velocity < -300) { // Sola hızlı çekiş -> Sonraki sayfa
      targetPage = _currentPage.floor() + 1;
    } else if (velocity > 300) { // Sağa hızlı çekiş -> Önceki sayfa
      targetPage = _currentPage.ceil() - 1;
    }

    // Sınırları aşma
    targetPage = targetPage.clamp(0, widget.itemCount - 1);

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuint,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      // Stack Katmanları
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 1. FİZİK MOTORU (Görünmez PageView)
          // Sadece controller'a boyut ve offset sağlamak için arkada durur.
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.itemCount,
              physics: const NeverScrollableScrollPhysics(), // Biz yöneteceğiz
              padEnds: false,
              itemBuilder: (context, index) => const SizedBox(),
            ),
          ),

          // 2. GÖRSEL KATMAN & ETKİLEŞİM
          // Tüm alanı kaplayan bir GestureDetector koyuyoruz.
          // Bu, kaydırmayı (Drag) yakalar. Çocuklar (Card) ise tıklamayı (Tap) yakalar.
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              behavior: HitTestBehavior.translucent, // Boşlukları da yakala
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  List<int> visibleIndices = [];
                  for (int i = 0; i < widget.itemCount; i++) {
                    if ((i - _currentPage).abs() < 3) visibleIndices.add(i);
                  }
                  // Z-Index Sıralaması (Ortadaki en üstte)
                  visibleIndices.sort((a, b) {
                    double distA = (a - _currentPage).abs();
                    double distB = (b - _currentPage).abs();
                    return distB.compareTo(distA); 
                  });

                  return Stack(
                    alignment: Alignment.centerLeft, 
                    clipBehavior: Clip.none, 
                    children: visibleIndices.map((index) => _buildItem(index)).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    double diff = index - _currentPage;
    double scale = (1 - (diff.abs() * 0.15)).clamp(0.85, 1.0);
    double opacity = (1 - (diff.abs() * 0.2)).clamp(0.5, 1.0);
    double leftPadding = 24.0; 
    double itemSpacing = 180.0; 
    double translationX = (diff * itemSpacing) + leftPadding;

    final Matrix4 matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translate(translationX, 0.0, 0.0)
      ..scale(scale);

    return Positioned.fill(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Transform(
          transform: matrix,
          alignment: Alignment.centerLeft,
          child: Opacity(
            opacity: opacity,
            child: SizedBox(
              width: 240, 
              // Kartın kendisine tıklanabilmesi için buraya GestureDetector koymuyoruz,
              // Zaten widget.itemBuilder içindeki kartın kendi onTap'i var.
              // Sadece pointer'ı engellemediğimizden emin oluyoruz.
              child: widget.itemBuilder(context, index),
            ),
          ),
        ),
      ),
    );
  }
}