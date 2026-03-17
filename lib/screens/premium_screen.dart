import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'dart:ui'; // ImageFilter

// CORE IMPORTLARI
import '../core/app_strings.dart';
import '../core/snackbar_helper.dart'; 

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  late PageController _pageController;
  int _selectedPlanIndex = 1; // 1: Yıllık (Varsayılan)
  int _currentPage = 0; 

  // Özellik Listesi (Dinamik Dil Desteği İçin Getter)
  List<Map<String, dynamic>> get _features => [
    {
      "title": AppStrings.ghostMode,
      "desc": AppStrings.ghostModeDesc,
      "icon": Icons.visibility_off_outlined,
      "color": const Color(0xFF6C63FF), // Mor
    },
    {
      "title": AppStrings.stalkDetector,
      "desc": AppStrings.stalkDetectorDesc,
      "icon": Icons.fingerprint,
      "color": const Color(0xFF00BFA5), // Teal
    },
    {
      "title": AppStrings.unlimited,
      "desc": AppStrings.unlimitedDesc,
      "icon": Icons.all_inclusive_rounded,
      "color": const Color(0xFFFF6D00), // Turuncu
    },
    {
      "title": AppStrings.goldBadge,
      "desc": AppStrings.goldBadgeDesc,
      "icon": Icons.verified,
      "color": const Color(0xFFFFD700), // Altın
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85); // Yan kartların ucu görünsün
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPlan(int index) {
    if (_selectedPlanIndex != index) {
      HapticFeedback.selectionClick(); // Titreşim
      setState(() => _selectedPlanIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Temel renk siyah
      body: Stack(
        children: [
          // --------------------------------------------------
          // 1. KATMAN: AMBIENT BACKGROUND (Marka Renkleriyle)
          // --------------------------------------------------
          // Altın Işık (Sağ Üst)
          Positioned(
            top: -100, right: -50, 
            child: _buildLightBlob(const Color(0xFFFFD700).withValues(alpha: 0.3))
          ),
          // Bordo Işık (Sol Alt - Marka Rengi)
          Positioned(
            bottom: -50, left: -50, 
            child: _buildLightBlob(const Color(0xFF8C003A).withValues(alpha: 0.4))
          ),
          // Mavi Işık (Orta - Derinlik)
          Positioned(
            top: 200, left: -80, 
            child: _buildLightBlob(Colors.blueAccent.withValues(alpha: 0.2), size: 200)
          ),
          
          // Blur Efekti (Tüm ışıkları yumuşatır)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(color: Colors.white.withValues(alpha: 0.2)),
            ),
          ),

          // --------------------------------------------------
          // 2. KATMAN: İÇERİK
          // --------------------------------------------------
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- HEADER (Kapat & Badge) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kapat Butonu (Glass)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.2), 
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5))
                          ),
                          child: const Text(
                            "GOLD MEMBER", 
                            style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- ELMAS İKONU & BAŞLIK ---
                  Hero(
                    tag: 'premium_diamond',
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.02)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5)
                        ]
                      ),
                      child: const Icon(Icons.diamond_rounded, size: 60, color: Color(0xFFFFD700)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    AppStrings.premiumTitle, // "NEER PREMIUM"
                    style: const TextStyle(
                      fontFamily: 'Visby', // Varsa font
                      fontSize: 32, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white, 
                      letterSpacing: 1.5,
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Text(
                      AppStrings.premiumSlogan,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- ÖZELLİK SLIDER (CAROUSEL) ---
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _pageController,
                      padEnds: true,
                      onPageChanged: (i) {
                        setState(() => _currentPage = i);
                        HapticFeedback.selectionClick();
                      },
                      itemCount: _features.length,
                      itemBuilder: (context, index) => _buildFeatureCard(_features[index], index == _currentPage),
                    ),
                  ),

                  // Nokta Göstergesi
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_features.length, (index) => _buildDot(index)),
                  ),

                  const SizedBox(height: 50),

                  // --- PLAN SEÇİMİ ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Yıllık Plan
                        _buildPlanCard(
                          index: 1,
                          title: AppStrings.yearlyPlan,
                          price: "₺39.99 / ay", // TODO: Dinamik Fiyatlandırma
                          subtitle: "${AppStrings.payOnce} ₺479",
                          badge: AppStrings.mostPopular,
                          isBest: true,
                        ),
                        const SizedBox(height: 16),
                        // Aylık Plan
                        _buildPlanCard(
                          index: 0,
                          title: AppStrings.monthlyPlan,
                          price: "₺49.99 / ay",
                          subtitle: AppStrings.cancelAnytime,
                          badge: "",
                          isBest: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SATIN AL BUTONU ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)], // Altın Gradyan
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))
                        ]
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          AppSnackBar.info(context, "Ödeme sistemi hazırlanıyor...");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          AppStrings.goPremium, // "PREMIUM'A GEÇ"
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w900, 
                            color: Colors.black, 
                            letterSpacing: 1
                          )
                        ),
                      ),
                    ),
                  ),

                  // Yasal Metinler
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      AppStrings.legalText,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---

  // Arka plan ışık topu
  Widget _buildLightBlob(Color color, {double size = 300}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 60)]
      ),
    );
  }

  // Özellik Kartı (Beyaz ve Şık)
  Widget _buildFeatureCard(Map<String, dynamic> item, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: isActive ? 0 : 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white, // Tam beyaz (Dark modda kontrast yaratır)
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item['color'].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'], size: 40, color: item['color']),
          ),
          const SizedBox(height: 20),
          Text(
            item['title'], 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87), 
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            item['desc'], 
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4), 
            maxLines: 3, 
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Sayfa Noktaları
  Widget _buildDot(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFD700) : Colors.white24,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // Plan Seçim Kartı
  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String subtitle,
    required String badge,
    required bool isBest,
  }) {
    bool isSelected = _selectedPlanIndex == index;
    
    return GestureDetector(
      onTap: () => _selectPlan(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white12, 
            width: isSelected ? 2 : 1
          ),
        ),
        child: Row(
          children: [
            // Radio Button
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFFFFA000) : Colors.white30,
              size: 28,
            ),
            const SizedBox(width: 16),

            // Metinler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBest)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFFFD700).withValues(alpha: 0.2), 
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: Text(
                        badge, 
                        style: TextStyle(
                          color: isSelected ? Colors.black : const Color(0xFFFFD700), 
                          fontSize: 10, 
                          fontWeight: FontWeight.w800
                        )
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isSelected ? Colors.black87 : Colors.white)),
                      Text(price, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isSelected ? Colors.black87 : Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: isSelected ? Colors.grey[600] : Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}