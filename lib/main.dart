import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/save_certificate.dart' as saver;

// Cross-platform utility functions
Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> saveCertificateToFile(Uint8List pngBytes, String name) async {
  await saver.saveCertificate(pngBytes, name);
}

String _sanitize(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9._ -]+'), '_');

// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1200;
}

// Responsive helper functions
bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;
bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobile && MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;
bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;

// Get responsive values
double getResponsiveValue(BuildContext context, {required double mobile, required double tablet, required double desktop}) {
  if (isMobile(context)) return mobile;
  if (isTablet(context)) return tablet;
  return desktop;
}

// Direct navigation to search page
void navigateToSearchPage(BuildContext context) {
  Navigator.pushNamed(context, '/search');
}

// Mobile menu (hamburger) helpers
void _showMobileMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      Widget buildItem(String label, VoidCallback onTap, {IconData icon = Icons.chevron_right}) {
        return ListTile(
          leading: Icon(icon, color: const Color(0xFFE91E63)),
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.of(ctx).pop();
            onTap();
          },
        );
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            buildItem('Home', () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }, icon: Icons.home_outlined),
            buildItem('Race Results', () {
              Navigator.pushNamed(context, '/results');
            }, icon: Icons.emoji_events_outlined),
            buildItem('Pricing', () {
              Navigator.pushNamed(context, '/pricing');
            }, icon: Icons.attach_money_outlined),
            buildItem('Features', () {
              Navigator.pushNamed(context, '/features');
            }, icon: Icons.star_border),
            buildItem('Contact', () {
              Navigator.pushNamed(context, '/contact');
            }, icon: Icons.mail_outline),
            buildItem('FAQ', () {
              Navigator.pushNamed(context, '/faq');
            }, icon: Icons.help_outline),
            const SizedBox(height: 6),
          ],
        ),
      );
    },
  );
}

Widget _buildMobileMenuButton(BuildContext context) {
  return Row(
    children: [
      IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _showMobileMenu(context),
        tooltip: 'Menu',
      ),
    ],
  );
}

const String kStartTimeStr = '2025-08-10 06:54:55';
final DateTime kStartTime = DateTime.parse(kStartTimeStr.replaceFirst(' ', 'T'));
const int kDNFSecs = 1 << 30;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hieyauprjmejzhwxsdld.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpZXlhdXByam1lanpod3hzZGxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDI5MDk3OTUsImV4cCI6MjAxODQ4NTc5NX0.plpTl75gOWjFVK0Ypt7DX75jLnTzts_p7p-zBk1U6tE',
  );
  runApp(const RaceTimingApp());
}

class RaceTimingApp extends StatelessWidget {
  const RaceTimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Race Timing Solution',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63)),
        useMaterial3: true,
        textTheme: GoogleFonts.lexendTextTheme(),
      ),
      home: const SplashScreen(),
      routes: {
        '/results': (context) => const RaceResultsPage(),
        '/search': (context) => const SearchResultsPage(),
        '/pricing': (context) => const PricingPage(),
        '/features': (context) => const FeaturesPage(),
        '/contact': (context) => const ContactPage(),
        '/faq': (context) => const FAQPage(),
        '/terms': (context) => const TermsPage(),
        '/event-detail': (context) => const EventDetailPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animation
    _fadeController.forward();

    // Navigate to main page after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
              Color(0xFFE91E63),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Splash GIF animation
              Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/splash.gif',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              
              // App title with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Race Timing Solution',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Professional Race Management',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Loading indicator
                    Container(
                      width: 40,
                      height: 40,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Read optional search query from navigation arguments
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String searchQuery = (routeArgs is Map && routeArgs['query'] is String)
        ? (routeArgs['query'] as String).trim().toLowerCase()
        : '';

    // Static events list (can be replaced with data source)
    final List<Map<String, String>> allEvents = [
      {
        'title': 'Agromed Run 2025',
        'date': 'March 15, 2025',
        'category': '5K & 10K Race',
        'location': 'Jakarta, Indonesia',
      },
      {
        'title': 'Happy Challenge 5K',
        'date': 'August 10, 2025',
        'category': '5K Race',
        'location': 'Bandung, Indonesia',
      },
      {
        'title': 'City Marathon 2025',
        'date': 'December 1, 2025',
        'category': 'Marathon & Half Marathon',
        'location': 'Surabaya, Indonesia',
      },
    ];

    final List<Map<String, String>> filteredEvents = searchQuery.isEmpty
        ? allEvents
        : allEvents.where((event) {
            final haystack = (
              '${event['title']} ${event['date']} ${event['category']} ${event['location']}'
            ).toLowerCase();
            return haystack.contains(searchQuery);
          }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', true),
                        _buildNavItem(context, 'Race Results', false, onTap: () {
                          Navigator.pushNamed(context, '/results');
                        }),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  Container(
                    height: MediaQuery.of(context).size.width < 768 ? 300 : 500,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/backgroundlari.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Subtle background overlay (removed base64 SVG to avoid web crash)
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white.withOpacity(0.02),
                        ),
                        // Overlay with gradient
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        // Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Race Timing Solution',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width < 768 ? 28 : 56,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: getResponsiveValue(
                                    context,
                                    mobile: 20,
                                    tablet: 25,
                                    desktop: 30,
                                  ),
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE91E63).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Precision • Speed • Reliability',
                                  style: TextStyle(
                                    fontSize: MediaQuery.of(context).size.width < 768 ? 14 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFF8F9FA),
                          const Color(0xFFE9ECEF),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Hi, race directors!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFE91E63),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 25),
                              Text(
                                'Looking for a seamless and accurate race timing solution? Our RFID technology guarantees precise tracking for every participant, giving you one less thing to worry about on race day!',
                                style: TextStyle(
                                  fontSize: getResponsiveValue(
                                    context,
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ),
                                  color: const Color(0xFF2C3E50),
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              Text(
                                'Learn more about our offerings through the links below:',
                                style: TextStyle(
                                  fontSize: getResponsiveValue(
                                    context,
                                    mobile: 16,
                                    tablet: 17,
                                    desktop: 18,
                                  ),
                                  color: const Color(0xFF34495E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 25),
                              isMobile(context) 
                                ? Column(
                                    children: [
                                      _buildPinkLink(context, 'PRICING', '/pricing'),
                                      const SizedBox(height: 15),
                                      _buildPinkLink(context, 'FEATURES', '/features'),
                                      const SizedBox(height: 15),
                                      _buildPinkLink(context, 'FAQ', '/faq'),
                                    ],
                                  )
                                : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                      _buildPinkLink(context, 'PRICING', '/pricing'),
                                  const SizedBox(width: 40),
                                      _buildPinkLink(context, 'FEATURES', '/features'),
                                  const SizedBox(width: 40),
                                      _buildPinkLink(context, 'FAQ', '/faq'),
                                ],
                              ),
                              const SizedBox(height: 35),
                              _buildModernButton(context, 'Request Quote', () {
                                final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                                openUrl(whatsappUrl);
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Sport Cards Section
                        Text(
                          'Our Expertise',
                          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 768 ? 24 : 36,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Professional timing solutions for every sport',
                          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 768 ? 14 : 18,
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 50),
                        _buildSportCardsSharedHover(),
                        const SizedBox(height: 50),
                        _buildModernButton(context, 'Get Started Today', () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer: desktop original, mobile flexible full-width
          RevealOnBottom(child: Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context) ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                  _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                  _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                  _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                  _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                  _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                  _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                  const SizedBox(width: 10),
                  _footerLink(context, 'Request Quote (via Whatsapp)', () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }),
                  const SizedBox(width: 10), const Icon(Icons.email, color: Colors.white, size: 18), const SizedBox(width: 6), const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ) : Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(onTap: () { Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); }, child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(onTap: () { Navigator.pushNamed(context, '/pricing'); }, child: Text('Pricing', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(onTap: () { Navigator.pushNamed(context, '/features'); }, child: Text('Features', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(onTap: () { Navigator.pushNamed(context, '/terms'); }, child: Text('T&C', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(onTap: () { Navigator.pushNamed(context, '/contact'); }, child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(onTap: () { Navigator.pushNamed(context, '/faq'); }, child: Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                  ],
                ),
                const Spacer(),
                GestureDetector(onTap: () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }, child: Text('Request Quote (via Whatsapp)', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                const Spacer(),
                const Icon(Icons.email, color: Colors.white, size: 20), const SizedBox(width: 10), Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 14)), const SizedBox(width: 20),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: isMobile(context) ? 13 : 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPinkLink(BuildContext context, String text, String route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Builder(builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 768 ? 15 : 20,
          vertical: MediaQuery.of(context).size.width < 768 ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE91E63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFFE91E63),
            fontSize: MediaQuery.of(context).size.width < 768 ? 12 : 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      )),
    );
  }

  Widget _buildModernButton(BuildContext context, String text, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
      width: MediaQuery.of(context).size.width < 768 ? 320 : 320,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 768 ? 320 : 320,
        minWidth: 220,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 768 ? 24 : 44,
            vertical: MediaQuery.of(context).size.width < 768 ? 18 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
        ),
      ),
    );
  }

  // Opens a simple search dialog from header and routes to Results
  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Search'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search events or results...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String query = searchController.text.trim();
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/results', arguments: {'query': query});
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSportCard(String title, String imagePath, Color accentColor, String description) {
    return StatefulBuilder(builder: (context, setState) {
      bool showInfo = false;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => showInfo = !showInfo),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()
              ..scale(showInfo ? 1.03 : 1.0),
            width: MediaQuery.of(context).size.width < 768 ? 280 : 250,
            height: MediaQuery.of(context).size.width < 768 ? 200 : 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
                  color: showInfo 
                    ? accentColor.withOpacity(0.4)
                    : Colors.black.withOpacity(0.1),
                  blurRadius: showInfo ? 28 : 20,
                  offset: Offset(0, showInfo ? 16 : 10),
                  spreadRadius: showInfo ? 1 : 0,
                ),
                if (showInfo)
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                    spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
                // Image section - full width and height
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
            decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Image
                          Positioned.fill(
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Tap catcher over the whole image area
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => showInfo = !showInfo),
                                splashColor: Colors.white24,
                                highlightColor: Colors.white10,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          // Border highlight on hover
                          if (showInfo)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: accentColor.withOpacity(0.8), width: 3),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          // Description overlay with fade + slide (bottom band)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, animation) {
                                  final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
                                  final slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
                                      .animate(fade);
                                  return FadeTransition(
                                    opacity: fade,
                                    child: SlideTransition(position: slide, child: child),
                                  );
                                },
                                child: showInfo
                                    ? Container(
                                        key: const ValueKey('overlay')
                                        ,height: 96,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0x00000000),
                                              Color(0xEE000000),
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          description,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            height: 1.25,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : const SizedBox.shrink(key: ValueKey('hidden')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Text section
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
          Text(
            title,
            style: TextStyle(
                            fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
                        const SizedBox(height: 4),
          Text(
            'Professional Timing',
            style: TextStyle(
                            fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      );
    });
  }

  // Shared hover row so only the hovered card zooms, others dim slightly
  Widget _buildSportCardsSharedHover() {
    return StatefulBuilder(
      builder: (context, setState) {
        int? hoveredIndex;

        Widget buildItem(int index, String title, String image, Color accent, String desc) {
          return _buildSportCard(title, image, accent, desc);
        }

        return isMobile(context) 
          ? Column(
              children: [
                buildItem(0, 'Running', 'assets/lari.jpg', const Color(0xFF3498DB),
                    'Running events demand speed, stamina, and precise split timing for every athlete.'),
                const SizedBox(height: 20),
                buildItem(1, 'Cycling', 'assets/sepeda.jpg', const Color(0xFFE74C3C),
                    'Cycling races require accurate checkpoints, drafting awareness, and secure lap tracking.'),
                const SizedBox(height: 20),
                buildItem(2, 'Triathlon', 'assets/triathlon.jpg', const Color(0xFF2ECC71),
                    'Triathlon combines swim, bike, and run with flawless transitions and end-to-end timing.'),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildItem(0, 'Running', 'assets/lari.jpg', const Color(0xFF3498DB),
                    'Running events demand speed, stamina, and precise split timing for every athlete.'),
                buildItem(1, 'Cycling', 'assets/sepeda.jpg', const Color(0xFFE74C3C),
                    'Cycling races require accurate checkpoints, drafting awareness, and secure lap tracking.'),
                buildItem(2, 'Triathlon', 'assets/triathlon.jpg', const Color(0xFF2ECC71),
                    'Triathlon combines swim, bike, and run with flawless transitions and end-to-end timing.'),
              ],
            );
      },
    );
  }

}

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});


  @override
  Widget build(BuildContext context) {
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String searchQuery = (routeArgs is Map && routeArgs['query'] is String)
        ? (routeArgs['query'] as String).trim().toLowerCase()
        : '';

    final List<Map<String, String>> allEvents = [
      {
        'title': 'Agromed Run 2025',
        'date': 'March 15, 2025',
        'category': '5K & 10K Race',
        'location': 'Jakarta, Indonesia',
      },
      {
        'title': 'Happy Challenge 5K',
        'date': 'August 10, 2025',
        'category': '5K Race',
        'location': 'Bandung, Indonesia',
      },
      {
        'title': 'City Marathon 2025',
        'date': 'December 1, 2025',
        'category': 'Marathon & Half Marathon',
        'location': 'Surabaya, Indonesia',
      },
    ];

    final List<Map<String, String>> filteredEvents = searchQuery.isEmpty
        ? allEvents
        : allEvents.where((event) {
            final haystack = (
              '${event['title']} ${event['date']} ${event['category']} ${event['location']}'
            ).toLowerCase();
            return haystack.contains(searchQuery);
          }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', false, onTap: () {
                          Navigator.pushNamed(context, '/results');
                        }),
                        _buildNavItem(context, 'Pricing', true),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF8F9FA),
                          const Color(0xFFE9ECEF),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Pricing',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE91E63),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  // Pricing Packages
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile(context) ? 16 : 60,
                      vertical: isMobile(context) ? 24 : 60,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Choose Your Perfect Package',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Professional race timing solutions for every event size',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Pricing Cards
                        isMobile(context)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildPricingCard(
                                    context,
                                    'Basic',
                                    '500',
                                    [
                                      'Race Timing System',
                                      'BIB + chip',
                                      'BIB check at racepack collection',
                                      'BIB check at finish line',
                                    ],
                                    '34.500.000',
                                    false,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPricingCard(
                                    context,
                                    'Standard',
                                    '1000',
                                    [
                                      'Race Timing System',
                                      'BIB + chip',
                                      'BIB check at racepack collection',
                                      'Additional check point',
                                      'BIB check at finish line',
                                    ],
                                    '52.000.000',
                                    false,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPricingCard(
                                    context,
                                    'Pro',
                                    '1500',
                                    [
                                      'Race Timing System',
                                      'BIB + chip',
                                      'BIB check at racepack collection',
                                      '2 Additional check point',
                                      'BIB check at finish line',
                                    ],
                                    '69.500.000',
                                    true,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildPricingCard(
                                    context,
                                    'Elite',
                                    '2000',
                                    [
                                      'Race Timing System',
                                      'BIB + chip',
                                      'BIB check at racepack collection',
                                      '2 Additional check point',
                                      'BIB check at finish line',
                                    ],
                                    '74.000.000',
                                    false,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildPricingCard(
                                      context,
                                      'Basic',
                                      '500',
                                      [
                                        'Race Timing System',
                                        'BIB + chip',
                                        'BIB check at racepack collection',
                                        'BIB check at finish line',
                                      ],
                                      '34.500.000',
                                      false,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildPricingCard(
                                      context,
                                      'Standard',
                                      '1000',
                                      [
                                        'Race Timing System',
                                        'BIB + chip',
                                        'BIB check at racepack collection',
                                        'Additional check point',
                                        'BIB check at finish line',
                                      ],
                                      '52.000.000',
                                      false,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildPricingCard(
                                      context,
                                      'Pro',
                                      '1500',
                                      [
                                        'Race Timing System',
                                        'BIB + chip',
                                        'BIB check at racepack collection',
                                        '2 Additional check point',
                                        'BIB check at finish line',
                                      ],
                                      '69.500.000',
                                      true,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildPricingCard(
                                      context,
                                      'Elite',
                                      '2000',
                                      [
                                        'Race Timing System',
                                        'BIB + chip',
                                        'BIB check at racepack collection',
                                        '2 Additional check point',
                                        'BIB check at finish line',
                                      ],
                                      '74.000.000',
                                      false,
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 80),
                        // Custom Solution Section
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE91E63).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Looking for a customized solution?',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Contact us today to discuss your specific needs and get a tailored quote for your race event.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF7F8C8D),
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              _buildModernButton(context, 'Request Custom Quote', () {
                                final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                                openUrl(whatsappUrl);
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer: desktop original, mobile flexible full-width
          RevealOnBottom(child: Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context)
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 18),
                      _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                      _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                      _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                      _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                      _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                      _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                      const SizedBox(width: 10),
                      _footerLink(context, 'Request Quote (via Whatsapp)', () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }),
                      const SizedBox(width: 10), const Icon(Icons.email, color: Colors.white, size: 18), const SizedBox(width: 6), const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                )
              : Row(
                  children: [
                    const SizedBox(width: 20),
                    const Icon(Icons.info_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        GestureDetector(onTap: () { Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); }, child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                        Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                        GestureDetector(onTap: () { Navigator.pushNamed(context, '/pricing'); }, child: Text('Pricing', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                        Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                        GestureDetector(onTap: () { Navigator.pushNamed(context, '/features'); }, child: Text('Features', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                        Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                        GestureDetector(onTap: () { Navigator.pushNamed(context, '/terms'); }, child: Text('T&C', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                        Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                        GestureDetector(onTap: () { Navigator.pushNamed(context, '/contact'); }, child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                        Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                        GestureDetector(onTap: () { Navigator.pushNamed(context, '/faq'); }, child: Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(onTap: () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }, child: Text('Request Quote (via Whatsapp)', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                    const Spacer(),
                    const Icon(Icons.email, color: Colors.white, size: 20), const SizedBox(width: 10), Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 14)), const SizedBox(width: 20),
                  ],
                ),
          )),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: isMobile(context) ? 13 : 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, String title, String runners, List<String> features, String price, bool isPopular) {
    return Container(
      height: isPopular ? 580 : 540, // Reduced height for all packages
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isPopular ? 0.15 : 0.1),
            blurRadius: isPopular ? 25 : 20,
            offset: Offset(0, isPopular ? 15 : 10),
          ),
        ],
        border: isPopular ? Border.all(
          color: const Color(0xFFE91E63),
          width: 3,
        ) : null,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: -1,
              left: 50,
              right: 50,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE91E63),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Package',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2C3E50),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '($runners runners)',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 30),
                Text(
                  'IDR $price',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFE91E63),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: _buildModernButton(context, 'Request Quote', () {
                    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                    openUrl(whatsappUrl);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(BuildContext context, String text, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
      width: MediaQuery.of(context).size.width < 768 ? 320 : 320,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 768 ? 320 : 320,
        minWidth: 220,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 768 ? 24 : 44,
            vertical: MediaQuery.of(context).size.width < 768 ? 18 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', false, onTap: () {
                          Navigator.pushNamed(context, '/results');
                        }),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', true),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF8F9FA),
                          const Color(0xFFE9ECEF),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Features',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE91E63),
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Features Section
                  Container(
                    color: const Color(0xFFF8F9FA),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile(context) ? 16 : 60,
                      vertical: isMobile(context) ? 24 : 60,
                    ),
                    child: Column(
                      children: [
                        // First Row of Features
                        isMobile(context)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildFeatureCard(
                                    Icons.phone_android,
                                    'RFID Technology for Accurate Timing',
                                    'Our system uses advanced RFID (Radio Frequency Identification) technology, ensuring every participant\'s start, checkpoint, and finish times are captured accurately. This eliminates the need for manual timing and guarantees reliable results with minimal error.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureCard(
                                    Icons.local_shipping,
                                    'Real-Time Tracking and Results',
                                    'Stay in control with live tracking. Our system offers real-time updates from multiple checkpoints, allowing race organizers and spectators to monitor progress. Runners can also access their results instantly after crossing the finish line.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureCard(
                                    Icons.view_module,
                                    'Customizable for Any Event Size',
                                    'Whether your event has 100 or 10,000 runners, our race timing system is scalable and customizable. We offer a range of packages, ensuring you get the right solution for your race, no matter its size.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureCard(
                                    Icons.credit_card,
                                    'BIB Integration with RFID Chips',
                                    'Each runner receives a BIB with an embedded RFID chip, which seamlessly communicates with our timing system. These chips are highly durable and work in all weather conditions, ensuring reliability throughout the race.',
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.phone_android,
                                      'RFID Technology for Accurate Timing',
                                      'Our system uses advanced RFID (Radio Frequency Identification) technology, ensuring every participant\'s start, checkpoint, and finish times are captured accurately. This eliminates the need for manual timing and guarantees reliable results with minimal error.',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.local_shipping,
                                      'Real-Time Tracking and Results',
                                      'Stay in control with live tracking. Our system offers real-time updates from multiple checkpoints, allowing race organizers and spectators to monitor progress. Runners can also access their results instantly after crossing the finish line.',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.view_module,
                                      'Customizable for Any Event Size',
                                      'Whether your event has 100 or 10,000 runners, our race timing system is scalable and customizable. We offer a range of packages, ensuring you get the right solution for your race, no matter its size.',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.credit_card,
                                      'BIB Integration with RFID Chips',
                                      'Each runner receives a BIB with an embedded RFID chip, which seamlessly communicates with our timing system. These chips are highly durable and work in all weather conditions, ensuring reliability throughout the race.',
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 30),
                        // Second Row of Features
                        isMobile(context)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildFeatureCard(
                                    Icons.location_on,
                                    'Multiple Checkpoints for Greater Accuracy',
                                    'Our system allows you to set up multiple checkpoints throughout the course, providing split times and tracking participants across different stages of the race. This is ideal for longer races or events with complex routes.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureCard(
                                    Icons.flag,
                                    'Finish Line Precision',
                                    'With an additional BIB check at the finish line, you can ensure that every runner\'s result is captured instantly and accurately. No missed times, no delays—just flawless results.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureCard(
                                    Icons.smartphone,
                                    'User-Friendly Interface',
                                    'Our system is designed to be intuitive for both race directors and participants. With an easy-to-navigate dashboard, you can monitor runners, manage checkpoints, and view results—all in real-time.',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFeatureCard(
                                    Icons.analytics,
                                    'Comprehensive Data Reporting',
                                    'Post-race, access detailed reports on participants, their times, splits, and overall race statistics. This data can be used to analyze performance, plan future events, and improve race logistics.',
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.location_on,
                                      'Multiple Checkpoints for Greater Accuracy',
                                      'Our system allows you to set up multiple checkpoints throughout the course, providing split times and tracking participants across different stages of the race. This is ideal for longer races or events with complex routes.',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.flag,
                                      'Finish Line Precision',
                                      'With an additional BIB check at the finish line, you can ensure that every runner\'s result is captured instantly and accurately. No missed times, no delays—just flawless results.',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.smartphone,
                                      'User-Friendly Interface',
                                      'Our system is designed to be intuitive for both race directors and participants. With an easy-to-navigate dashboard, you can monitor runners, manage checkpoints, and view results—all in real-time.',
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      Icons.analytics,
                                      'Comprehensive Data Reporting',
                                      'Post-race, access detailed reports on participants, their times, splits, and overall race statistics. This data can be used to analyze performance, plan future events, and improve race logistics.',
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 50),
                        // Request Quote Button (centered)
                        Center(
                          child: _buildModernButton(
                            context,
                            'Request Quote',
                            () {
                              // Open WhatsApp with pre-filled message
                              final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                              openUrl(whatsappUrl);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer: desktop full-width row, mobile flexible wrap
          RevealOnBottom(child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: isMobile(context) ? 0 : 0),
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context) ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                const SizedBox(width: 10),
                _footerLink(context, 'Request Quote (via Whatsapp)', () {
                  final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                  openUrl(whatsappUrl);
                }),
                const SizedBox(width: 10),
                const Icon(Icons.email, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
            ) : Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/pricing');
                      },
                      child: Text(
                        'Pricing',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/features');
                      },
                      child: Text(
                        'Features',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: Text(
                        'T&C',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                      child: Text(
                        'Contact',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/faq');
                      },
                      child: Text(
                        'FAQ',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                    openUrl(whatsappUrl);
                  },
                  child: Text(
                    'Request Quote (via Whatsapp)',
                    style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.email, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'runmlgrun@gmail.com',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 20),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: isMobile(context) ? 13 : 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      height: 350, // Fixed height for all cards
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 40,
              color: const Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width < 768 ? 320 : 260,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 768 ? 320 : 260,
        minWidth: 220,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 768 ? 24 : 44,
              vertical: 18,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', false, onTap: () {
                          Navigator.pushNamed(context, '/results');
                        }),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', true),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Hero Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF5F5F5),
                  const Color(0xFFE8E8E8),
                ],
              ),
            ),
            child: Center(
              child: Text(
                'Contact',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE91E63),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    // Get in Touch Section
                    Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE91E63),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'We\'re here to help you make your race a success! Whether you have questions about our race timing system, need a customized solution, or want to discuss your event in detail, our team is ready to assist you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Divider
                    Container(
                      height: 1,
                      color: const Color(0xFFE0E0E0),
                      margin: const EdgeInsets.symmetric(horizontal: 100),
                    ),
                    const SizedBox(height: 40),
                    // Contact Information Section
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Contact Details
                    Column(
                      children: [
                        Text(
                          'Phone: +62-852-0411-5000',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            // Open email client
                            final emailUrl = 'mailto:runmlgrun@gmail.com';
                            openUrl(emailUrl);
                          },
                          child: Text(
                            'Email: runmlgrun@gmail.com',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Office: Jl. Mandalika, Malang, Jawa Timur, Indonesia',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    // Request a Quote Section
                    Text(
                      'Request a Quote',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Interested in our race timing services? Contact us for a personalized quote tailored to your event\'s needs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Request Quote Button
                    _buildModernButton(
                      context,
                      'Request Quote',
                      () {
                        final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                        openUrl(whatsappUrl);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer: desktop original, mobile flexible full-width
          RevealOnBottom(child: Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context)
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white, size: 18),
                        _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                        _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                        _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                        _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                        _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                        _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                        const SizedBox(width: 10),
                        _footerLink(context, 'Request Quote (via Whatsapp)', () {
                          final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                          openUrl(whatsappUrl);
                        }),
                        const SizedBox(width: 10),
                        const Icon(Icons.email, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          GestureDetector(onTap: () { Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); }, child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                          Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                          GestureDetector(onTap: () { Navigator.pushNamed(context, '/pricing'); }, child: Text('Pricing', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                          Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                          GestureDetector(onTap: () { Navigator.pushNamed(context, '/features'); }, child: Text('Features', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                          Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                          GestureDetector(onTap: () { Navigator.pushNamed(context, '/terms'); }, child: Text('T&C', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                          Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                          GestureDetector(onTap: () { Navigator.pushNamed(context, '/contact'); }, child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                          Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                          GestureDetector(onTap: () { Navigator.pushNamed(context, '/faq'); }, child: Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(onTap: () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }, child: Text('Request Quote (via Whatsapp)', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5))),
                      const Spacer(),
                      const Icon(Icons.email, color: Colors.white, size: 20), const SizedBox(width: 10), Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 14)), const SizedBox(width: 20),
                    ],
                  ),
          )),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile(context) ? 13 : 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width < 768 ? 320 : 240,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 768 ? 320 : 240,
        minWidth: 220,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 768 ? 24 : 44,
              vertical: 18,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', false, onTap: () {
                          Navigator.pushNamed(context, '/results');
                        }),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', true),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Hero Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF5F5F5),
                  const Color(0xFFE8E8E8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'FAQ',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE91E63),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Frequently Asked Questions (FAQ)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE91E63),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    // Introduction
                    Text(
                      'We understand that planning a race event comes with many questions. Below are some of the most common inquiries about our race timing system and services. If you don\'t find the answer you\'re looking for, feel free to reach out!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // FAQ Items
                    _buildFAQItem(
                      '1. What types of races can your timing system be used for?',
                      'Our race timing system is highly versatile and can be used for various events, including marathons, triathlons, cycling races, obstacle courses, and fun runs. No matter the scale or type of race, our system is designed to deliver precise results.',
                    ),
                    _buildFAQItem(
                      '2. How does the RFID timing system work?',
                      'Each participant is assigned a BIB with an embedded RFID chip. As runners pass timing checkpoints and the finish line, the chip communicates with our antennas to record their time accurately. This ensures real-time results and precise tracking.',
                    ),
                    _buildFAQItem(
                      '3. How accurate is your timing system?',
                      'Our RFID-based timing system is designed for high accuracy, typically within seconds. We use multiple checkpoints and advanced equipment to ensure every split and finish time is captured accurately.',
                    ),
                    _buildFAQItem(
                      '4. Can I customize the number of checkpoints?',
                      'Yes, absolutely! Our system is flexible and can be customized to meet your specific race requirements. Whether you need a simple start and finish timing or multiple checkpoints throughout the course, we can accommodate your needs.',
                    ),
                    _buildFAQItem(
                      '5. What equipment do you provide?',
                      'We provide all necessary timing equipment including RFID chips, antennas, timing mats, and backup systems. Our team also brings laptops, printers for instant results, and all technical support equipment needed for a successful event.',
                    ),
                    _buildFAQItem(
                      '6. How do participants receive their results?',
                      'Participants can access their results in real-time through our online portal. We also provide instant printed results at the finish line and can send results via email or SMS. Results are typically available within minutes of crossing the finish line.',
                    ),
                    _buildFAQItem(
                      '7. Do you offer support during the race?',
                      'Yes, we provide full technical support during your event. Our team will assist with setup, monitor the system throughout the race, and ensure that all results are accurately recorded and reported.',
                    ),
                    _buildFAQItem(
                      '8. How far in advance should I book your race timing services?',
                      'We recommend booking as early as possible to secure your event date. Ideally, contact us at least 1-2 months before your race to ensure availability and adequate preparation time.',
                    ),
                    _buildFAQItem(
                      '9. Can I get a customized quote for my event?',
                      'Absolutely! We provide tailored quotes based on the specifics of your event, including the number of participants, checkpoints, and additional services required. Contact us for a personalized quote.',
                    ),
                    _buildFAQItem(
                      '10. What regions do you serve?',
                      'While we are headquartered in Indonesia, our race timing services are available across Southeast Asia and Australia. We are fully equipped to support events throughout these regions, ensuring accurate and reliable timing for races of any size.',
                    ),
                    const SizedBox(height: 40),
                    // Request Quote Button
                    _buildModernButton(
                      context,
                      'Request Quote',
                      () {
                        final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                        openUrl(whatsappUrl);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Still have questions? Don\'t hesitate to contact us, and we\'ll be happy to assist you!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer: desktop original, mobile flexible
          Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context) ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                  _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                  _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                  _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                  _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                  _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                  _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                  const SizedBox(width: 10),
                  _footerLink(context, 'Request Quote (via Whatsapp)', () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }),
                  const SizedBox(width: 10), const Icon(Icons.email, color: Colors.white, size: 18), const SizedBox(width: 6), const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ) : Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/pricing');
                      },
                      child: Text(
                        'Pricing',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/features');
                      },
                      child: Text(
                        'Features',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: Text(
                        'T&C',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                      child: Text(
                        'Contact',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/faq');
                      },
                      child: Text(
                        'FAQ',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                    openUrl(whatsappUrl);
                  },
                  child: Text(
                    'Request Quote (via Whatsapp)',
                    style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.email, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'runmlgrun@gmail.com',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile(context) ? 13 : 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      height: 240, // Fixed height for all FAQ cards
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
                height: 1.6,
              ),
              maxLines: 7,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width < 768 ? 320 : 240,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 768 ? 320 : 240,
        minWidth: 220,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 768 ? 24 : 44,
              vertical: 18,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dedicated Search Results page (site-wide search)
class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    // Initialize with empty values, will be set in didChangeDependencies
    _currentSearchQuery = '';
    _searchController.text = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get initial search query from route arguments
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String initialQuery = (routeArgs is Map && routeArgs['query'] is String)
        ? (routeArgs['query'] as String).trim()
        : '';
    if (initialQuery.isNotEmpty && _currentSearchQuery.isEmpty) {
      _currentSearchQuery = initialQuery.toLowerCase();
      _searchController.text = initialQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _currentSearchQuery = query.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> allPages = [
      {
        'title': 'Home',
        'route': '/',
        'snippet': 'Dashboard overview, hero content, and call to action.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Pricing',
        'route': '/pricing',
        'snippet': 'Basic, Standard, Pro (Most Popular), and Elite packages.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'FAQ – Pricing & Packages',
        'route': '/faq',
        'snippet': 'Answers about pricing, inclusions, and custom quotes.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Features',
        'route': '/features',
        'snippet': 'Live tracking, results processing, certificates, RFID chips, etc.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Contact – Request Quote',
        'route': '/contact',
        'snippet': 'Contact info and WhatsApp "Request Quote" button.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Terms & Conditions',
        'route': '/terms',
        'snippet': 'Booking, payment, cancellation, refund, privacy, law.',
        'lastModified': 'Jul 28, 2025',
      },
    ];

    final List<Map<String, String>> filteredPages = _currentSearchQuery.isEmpty
        ? []
        : allPages.where((p) {
            final haystack = ('${p['title']} ${p['snippet']}').toLowerCase();
            return haystack.contains(_currentSearchQuery);
          }).toList();

    final List<Map<String, String>> allEvents = [
      {
        'title': 'Agromed Run 2025',
        'date': 'March 15, 2025',
        'category': '5K & 10K Race',
        'location': 'Jakarta, Indonesia',
      },
      {
        'title': 'Happy Challenge 5K',
        'date': 'August 10, 2025',
        'category': '5K Race',
        'location': 'Bandung, Indonesia',
      },
    ];

    final List<Map<String, String>> allRaceResults = [
      {
        'name': 'Ahmad Rizki',
        'bib': 'A001',
        'time': '00:18:45',
        'category': '5K Male',
        'event': 'Happy Challenge 5K',
        'rank': '1st Place',
      },
      {
        'name': 'Siti Nurhaliza',
        'bib': 'A002',
        'time': '00:19:12',
        'category': '5K Female',
        'event': 'Happy Challenge 5K',
        'rank': '1st Place',
      },
      {
        'name': 'Budi Santoso',
        'bib': 'B001',
        'time': '00:42:30',
        'category': '10K Male',
        'event': 'Agromed Run 2025',
        'rank': '3rd Place',
      },
      {
        'name': 'Dewi Kartika',
        'bib': 'B002',
        'time': '00:45:15',
        'category': '10K Female',
        'event': 'Agromed Run 2025',
        'rank': '2nd Place',
      },
    ];

    final List<Map<String, String>> filteredEvents = _currentSearchQuery.isEmpty
        ? []
        : allEvents.where((event) {
            final haystack = ('${event['title']} ${event['date']} ${event['category']} ${event['location']}').toLowerCase();
            return haystack.contains(_currentSearchQuery);
          }).toList();

    final List<Map<String, String>> filteredRaceResults = _currentSearchQuery.isEmpty
        ? []
        : allRaceResults.where((result) {
            final haystack = ('${result['name']} ${result['bib']} ${result['time']} ${result['category']} ${result['event']} ${result['rank']}').toLowerCase();
            return haystack.contains(_currentSearchQuery);
          }).toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/lariterus_logo.png', height: 24, fit: BoxFit.contain),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', false, onTap: () {
                          Navigator.pushNamed(context, '/results');
                        }),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(40, 26, 40, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Search results', style: TextStyle(fontSize: 14, color: Color(0xFF99A3A4), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEAECEF)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 20, color: Color(0xFF7F8C8D)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search events, pages, or results...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                                  onChanged: _performSearch,
                                  onSubmitted: _performSearch,
                                ),
                              ),
                              if (_currentSearchQuery.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch('');
                                  },
                                  icon: const Icon(Icons.clear, size: 20, color: Color(0xFF7F8C8D)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Results from this site', style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w600)),
                            if (_currentSearchQuery.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${filteredPages.length}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_currentSearchQuery.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEAECEF)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.search, size: 48, color: Color(0xFFBDC3C7)),
                                SizedBox(height: 12),
                                Text('Start typing to search pages, events, and race results', 
                                     style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
                              ],
                            ),
                          )
                        else if (filteredPages.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEAECEF)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Color(0xFFBDC3C7)),
                                const SizedBox(height: 12),
                                Text('No pages found for "${_currentSearchQuery}"', 
                                     style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
                              ],
                            ),
                          )
                        else ...filteredPages.map((p) => _buildSearchResultItem(
                          context,
                          p['title']!,
                          p['snippet']!,
                          p['lastModified']!,
                          p['route']!,
                        )),
                      ],
                    ),
                  ),

                  Container(
                    color: const Color(0xFFF8F9FA),
                    padding: const EdgeInsets.fromLTRB(40, 10, 40, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Past Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                            if (_currentSearchQuery.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3498DB),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${filteredEvents.length}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_currentSearchQuery.isNotEmpty && filteredEvents.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEAECEF)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.event_busy, size: 48, color: Color(0xFFBDC3C7)),
                                SizedBox(height: 12),
                                Text('No events found for your search.', 
                                     style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
                              ],
                            ),
                          )
                        else ...filteredEvents.expand((event) => [
                          _buildEventCard(
                            event['title']!,
                            event['date']!,
                            event['category']!,
                            event['location']!,
                            () { Navigator.pushNamed(context, '/event-detail'); },
                          ),
                          const SizedBox(height: 14),
                        ]),
                        
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const Text('Race Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                            if (_currentSearchQuery.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF27AE60),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${filteredRaceResults.length}',
                                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_currentSearchQuery.isNotEmpty && filteredRaceResults.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEAECEF)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.emoji_events_outlined, size: 48, color: Color(0xFFBDC3C7)),
                                SizedBox(height: 12),
                                Text('No race results found for your search.', 
                                     style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D))),
                              ],
                            ),
                          )
                        else ...filteredRaceResults.expand((result) => [
                          _buildRaceResultCard(
                            result['name']!,
                            result['bib']!,
                            result['time']!,
                            result['category']!,
                            result['event']!,
                            result['rank']!,
                          ),
                          const SizedBox(height: 14),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 60,
            color: const Color(0xFF424242),
            child: Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () { Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); },
                      child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () { Navigator.pushNamed(context, '/pricing'); },
                      child: Text('Pricing', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () { Navigator.pushNamed(context, '/features'); },
                      child: Text('Features', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () { Navigator.pushNamed(context, '/terms'); },
                      child: Text('T&C', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () { Navigator.pushNamed(context, '/contact'); },
                      child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () { Navigator.pushNamed(context, '/faq'); },
                      child: Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                    openUrl(whatsappUrl);
                  },
                  child: Text(
                    'Request Quote (via Whatsapp)',
                    style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.email, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'runmlgrun@gmail.com',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for navigation items
  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile(context) ? 13 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Helper function for search result items
  Widget _buildSearchResultItem(BuildContext context, String title, String snippet, String lastModified, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFFEAECEF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
                style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              snippet,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              'Last modified on $lastModified',
              style: const TextStyle(fontSize: 12, color: Color(0xFF99A3A4)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for event cards
  Widget _buildEventCard(String title, String date, String type, String location, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.directions_run,
                size: 40,
                color: Color(0xFFE91E63),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7F8C8D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 16, color: Color(0xFF7F8C8D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF7F8C8D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFE91E63),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for race result cards
  Widget _buildRaceResultCard(String name, String bib, String time, String category, String event, String rank) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rank.contains('1st') ? const Color(0xFFFFD700) : 
                         rank.contains('2nd') ? const Color(0xFFC0C0C0) :
                         rank.contains('3rd') ? const Color(0xFFCD7F32) : const Color(0xFFE8F4FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rank,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: rank.contains('1st') || rank.contains('2nd') || rank.contains('3rd') 
                        ? Colors.white : const Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.confirmation_number, size: 16, color: Color(0xFF7F8C8D)),
              const SizedBox(width: 8),
              Text(
                'Bib: $bib',
                style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.timer, size: 16, color: Color(0xFF7F8C8D)),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.category, size: 16, color: Color(0xFF7F8C8D)),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.event, size: 16, color: Color(0xFF7F8C8D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RaceResultsPage extends StatelessWidget {
  const RaceResultsPage({super.key});
  
  // Use the global search dialog
  void _showSearchDialog(BuildContext context) => navigateToSearchPage(context);

  @override
  Widget build(BuildContext context) {
    // Read optional search query from navigation arguments
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;
    final String searchQuery = (routeArgs is Map && routeArgs['query'] is String)
        ? (routeArgs['query'] as String).trim().toLowerCase()
        : '';

    // Static events
    final List<Map<String, String>> allEvents = [
      {
        'title': 'Agromed Run 2025',
        'date': 'March 15, 2025',
        'category': '5K & 10K Race',
        'location': 'Jakarta, Indonesia',
      },
      {
        'title': 'Happy Challenge 5K',
        'date': 'August 10, 2025',
        'category': '5K Race',
        'location': 'Bandung, Indonesia',
      },
      {
        'title': 'City Marathon 2025',
        'date': 'December 1, 2025',
        'category': 'Marathon & Half Marathon',
        'location': 'Surabaya, Indonesia',
      },
    ];

    final List<Map<String, String>> filteredEvents = searchQuery.isEmpty
        ? allEvents
        : allEvents.where((event) {
            final haystack = (
              '${event['title']} ${event['date']} ${event['category']} ${event['location']}'
            ).toLowerCase();
            return haystack.contains(searchQuery);
          }).toList();

    // Pages metadata to simulate site-wide results like the sample screenshot
    // Duplicate/sectioned entries are allowed so one keyword can return multiple hits.
    final List<Map<String, String>> allPages = [
      {
        'title': 'FAQ',
        'route': '/faq',
        'snippet': 'FAQ about pricing, features, setup, certificates, results, and support.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Pricing',
        'route': '/pricing',
        'snippet': 'Pricing page: Basic, Standard, Pro (Most Popular), and Elite packages.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'FAQ – Pricing & Packages',
        'route': '/faq',
        'snippet': 'Questions about pricing, custom quotes, and what\'s included per package.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Contact – Request Quote',
        'route': '/contact',
        'snippet': 'Contact and WhatsApp link to request a custom pricing quote.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Features',
        'route': '/features',
        'snippet': 'Live tracking, results processing, certificates, RFID chips, and more.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Contact',
        'route': '/contact',
        'snippet': 'Contact us for support, pricing details, or a custom quote via email/WhatsApp.',
        'lastModified': 'Jul 28, 2025',
      },
      {
        'title': 'Terms & Conditions',
        'route': '/terms',
        'snippet': 'Booking, payment, cancellation & refund policy, data privacy, governing law.',
        'lastModified': 'Jul 28, 2025',
      },
    ];

    final List<Map<String, String>> filteredPages = searchQuery.isEmpty
        ? []
        : allPages.where((p) {
            final haystack = ('${p['title']} ${p['snippet']}').toLowerCase();
            return haystack.contains(searchQuery);
          }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', true),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero Section with background image
                  Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/tiga.jpg'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Race Results',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Site-wide results section (pages)
                  if (searchQuery.isNotEmpty) Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Results from this site',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (filteredPages.isEmpty)
                          Text(
                            'No pages found.',
                            style: TextStyle(fontSize: 14, color: Color(0xFF99A3A4)),
                          )
                        else ...filteredPages.map((p) => _buildSearchResultItem(
                          context,
                          p['title']!,
                          p['snippet']!,
                          p['lastModified']!,
                          p['route']!,
                        )),
                      ],
                    ),
                  ),

                  // Events Section
                  Container(
                    color: const Color(0xFFF8F9FA),
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      children: [
                        Text(
                          'Past Events',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Click on any event to view race results',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Event Cards (filtered)
                        Column(
                          children: [
                            if (filteredEvents.isEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No events found for your search.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF7F8C8D),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              ...filteredEvents.expand((event) => [
                                _buildEventCard(
                                  event['title']!,
                                  event['date']!,
                                  event['category']!,
                                  event['location']!,
                                  () { Navigator.pushNamed(context, '/event-detail'); },
                                ),
                                const SizedBox(height: 20),
                              ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Footer: desktop original, mobile flexible
          Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context) ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                  _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                  _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                  _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                  _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                  _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                  _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                  const SizedBox(width: 10),
                  _footerLink(context, 'Request Quote (via Whatsapp)', () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }),
                  const SizedBox(width: 10), const Icon(Icons.email, color: Colors.white, size: 18), const SizedBox(width: 6), const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ) : Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/pricing');
                      },
                      child: Text(
                        'Pricing',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/features');
                      },
                      child: Text(
                        'Features',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: Text(
                        'T&C',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                      child: Text(
                        'Contact',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/faq');
                      },
                      child: Text(
                        'FAQ',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                    openUrl(whatsappUrl);
                  },
                  child: Text(
                    'Request Quote (via Whatsapp)',
                    style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.email, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'runmlgrun@gmail.com',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Common footer used across pages
  Widget _buildFooter(BuildContext context) {
    const String reportUrl = 'https://reportingwidget.google.com/u/0/widget/35?cid=https://sites.google.com/view/lariterus-timing-system&hl='; // [Google report widget]
    return Container(
      color: const Color(0xFF424242),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile(context) ? 16 : 20,
        vertical: isMobile(context) ? 16 : 12,
      ),
      child: isMobile(context) 
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info icon and main navigation links (wrapped)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => openUrl(reportUrl),
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                  ),
                  Text('|', style: TextStyle(color: Colors.white, fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/pricing'),
                    child: Text('Pricing', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                  ),
                  Text('|', style: TextStyle(color: Colors.white, fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/features'),
                    child: Text('Features', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                  ),
                  Text('|', style: TextStyle(color: Colors.white, fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/terms'),
                    child: Text('T&C', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                  ),
                  Text('|', style: TextStyle(color: Colors.white, fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/contact'),
                    child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                  ),
                  Text('|', style: TextStyle(color: Colors.white, fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/faq'),
                    child: Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationThickness: 1.5)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Additional info (wrapped)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text('Page updated Jul 28, 2025', style: TextStyle(color: Colors.white, fontSize: 11)),
                  Text('|', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  GestureDetector(
                    onTap: () => openUrl('https://workspace.google.com/'),
                    child: Text('Google Workspace', style: TextStyle(color: Colors.white, fontSize: 11, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ],
          )
        : Row(
            children: [
              const SizedBox(width: 20),
          // Make the info icon clickable -> open report widget
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => openUrl(reportUrl),
              child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          // Navigation quick links
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                child: Text('Home', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
              ),
              Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pricing'),
                child: Text('Pricing', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
              ),
              Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/features'),
                child: Text('Features', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
              ),
              Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/terms'),
                child: Text('T&C', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
              ),
              Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/contact'),
                child: Text('Contact', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
              ),
              Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/faq'),
                child: Text('FAQ', style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5)),
              ),
            ],
          ),
          const Spacer(),
          // Right info: updated | Google Workspace | Report
          Row(
            children: [
              Text('Page updated Jul 28, 2025', style: TextStyle(color: Colors.white, fontSize: 13)),
              Text('  |  ', style: TextStyle(color: Colors.white70)),
              GestureDetector(
                onTap: () => openUrl('https://workspace.google.com/'),
                child: Text('Google Workspace', style: TextStyle(color: Colors.white, fontSize: 13, decoration: TextDecoration.underline)),
              ),
              const SizedBox(width: 14),
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text('Report: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 6),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => openUrl(reportUrl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Entire site', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => openUrl(reportUrl),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Current page', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: isMobile(context) ? 13 : 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String date, String type, String location, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.directions_run,
                size: 40,
                color: Color(0xFFE91E63),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7F8C8D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 16, color: Color(0xFF7F8C8D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFF7F8C8D)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          softWrap: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFE91E63),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Simple search result tile similar to the sample screenshot
  Widget _buildSearchResultItem(BuildContext context, String title, String snippet, String lastModified, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: const Color(0xFFEAECEF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
                style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              snippet,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              'Last modified on $lastModified',
              style: const TextStyle(fontSize: 12, color: Color(0xFF99A3A4)),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget: show footer only when user reaches bottom; hide when scrolling up
class RevealOnBottom extends StatefulWidget {
  final Widget child;
  const RevealOnBottom({super.key, required this.child});

  @override
  State<RevealOnBottom> createState() => _RevealOnBottomState();
}

class _RevealOnBottomState extends State<RevealOnBottom> {
  ScrollController? _controller;
  double _lastPixels = 0.0;
  bool _visible = false; // hidden by default; shown near bottom

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachToPrimaryController();
  }

  void _attachToPrimaryController() {
    final ctrl = PrimaryScrollController.maybeOf(context);
    if (ctrl == _controller) return;
    _controller?.removeListener(_onScroll);
    _controller = ctrl;
    _controller?.addListener(_onScroll);
    // Evaluate initial position
    _onScroll();
  }

  void _onScroll() {
    final c = _controller;
    if (c == null || !c.hasClients) {
      // No scroll controller → always show footer
      if (!_visible) setState(() => _visible = true);
      return;
    }
    final pos = c.position;
    final pixels = pos.pixels;
    final max = pos.maxScrollExtent;
    
    // Debug info
    print('Scroll: pixels=$pixels, max=$max, atBottom=${(max - pixels) <= 100}');
    
    // If not scrollable (max <= 0) keep footer visible
    final bool notScrollable = max <= 0.0;
    // More generous threshold
    final atBottom = notScrollable || (max - pixels) <= 100.0;

    // Show at bottom; hide otherwise
    final nextVisible = atBottom;
    if (nextVisible != _visible) {
      print('Footer visibility changed: $_visible -> $nextVisible');
      setState(() => _visible = nextVisible);
    }

    _lastPixels = pixels;
  }

  @override
  void dispose() {
    _controller?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only animate/hide on mobile; on desktop keep always visible
    final bool isMobileWidth = MediaQuery.of(context).size.width < 768;
    if (!isMobileWidth) return widget.child;
    // Slide the footer off-screen vertically when not visible
    return AnimatedSlide(
      duration: const Duration(milliseconds: 180),
      offset: _visible ? const Offset(0, 0) : const Offset(0, 1),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _visible ? 1.0 : 0.0,
        child: widget.child,
      ),
    );
  }
}

Widget _sep() => const Text(' | ', style: TextStyle(color: Colors.white, fontSize: 12));
Widget _footerLink(BuildContext context, String text, VoidCallback onTap) => GestureDetector(
  onTap: onTap,
  child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline, decorationThickness: 1.5)),
);

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late ResultsDataSource _dataSource;
  bool _loading = true;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _rowsPerPage = 100;

  // Use the global search dialog
  void _showSearchDialog(BuildContext context) => navigateToSearchPage(context);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<RaceResult> _allResults = [];

  @override
  void initState() {
    super.initState();
    _dataSource = ResultsDataSource([]);
    _loadFromSupabase();
  }

  Future<void> _loadFromSupabase() async {
    final cli = Supabase.instance.client;
    final rows = await cli.from('rts_happy').select('bib,name,cp1,cp2,gender,is_dns');

    final List<Map<String, dynamic>> partial = [];
    for (final r in rows) {
      final bib = (r['bib'] ?? '').toString();
      final name = (r['name'] ?? '').toString();
      final gender = (r['gender'] ?? '').toString().trim().toLowerCase();
      final cp1 = (r['cp1'] ?? '').toString().trim();
      final cp2 = (r['cp2'] ?? '').toString().trim();
      final isDns = r['is_dns'] == true;


      // Parse cp1 and cp2 strings you've already read
      final dt1 = (cp1.isNotEmpty) ? _parseCp2(cp1) : null;
      final dt2 = (cp2.isNotEmpty) ? _parseCp2(cp2) : null;

      // 1) Check Point display (blank if cp1 missing/invalid)
      String cp1Display = '';
      if (dt1 != null) {
        final diff1 = dt1.difference(kStartTime);
        final safe1 = diff1.isNegative ? Duration.zero : diff1;
        cp1Display = _formatDuration(safe1);
      }

      // cp1Secs is a number we will sort on later
      int cp1Secs =
          kDNFSecs; // use your large "DNF seconds" constant for missing values
      if (dt1 != null) {
        final diff1 = dt1.difference(kStartTime);
        final safe1 = diff1.isNegative ? Duration.zero : diff1;
        cp1Secs = safe1.inSeconds;
      }


      // 2) Time column should show cp2 - start IF cp2 exists (even if DNF)
      // Time display: blank if cp2 missing, else cp2 - start
      int secs = kDNFSecs;
      String display = '';
      if (dt2 != null) {
        final diff2 = dt2.difference(kStartTime);
        final safe2 = diff2.isNegative ? Duration.zero : diff2;
        secs = safe2.inSeconds;
        display = _formatDuration(safe2);
      }

      // 3) Finished flag = BOTH cp1 and cp2 present & valid
      final bool finished = (dt1 != null) && (dt2 != null);

      // Add to partial
      partial.add({
        'bib': bib,
        'name': name,
        'gender': gender,
        'secs': secs, // for sorting Time
        'display': display, // Time column text
        'finished': finished, // for Rank / Gender Rank logic
        'cp1Display': cp1Display, // Check Point column text
        'cp1Secs': cp1Secs,
        'isDns': isDns,

      });



    }

    partial.sort((a, b) => (a['secs'] as int).compareTo(b['secs'] as int));

    int overall = 0, m = 0, f = 0;
    final results = <RaceResult>[];
    for (final p in partial) {
      overall++;
      int? gRank;
      if ((p['finished'] == true) &&
          (p['gender'] == 'male' || p['gender'] == 'female')) {
        if (p['gender'] == 'male') {
          m++;
          gRank = m;
        } else {
          f++;
          gRank = f;
        }
      }
      results.add(
        RaceResult(
          rank: overall,
          name: p['name'] as String,
          bib: p['bib'] as String,
          gender: p['gender'] as String,
          timeSeconds: p['secs'] as int,
          timeDisplay: p['display'] as String,
          genderRank: gRank, // null if not finished
          cp1Display:
              p['cp1Display']
                  as String, // <-- ensure this field exists in your model
          finished:
              p['finished']
                  as bool, // <-- ensure this field exists in your model
          cp1Secs: p['cp1Secs'] as int, 
          isDns: p['isDns'] as bool,
        ),
      );

    }

    setState(() {
      _allResults = results;
      _dataSource = ResultsDataSource(_allResults);
      _loading = false;
    });

  }

  DateTime? _parseCp2(String raw) {
    final s = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  void _sort<T>(Comparable<T> Function(RaceResult d) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    _dataSource.sort<T>(getField, ascending);
  }

  void _filterResults(String query) {
    final q = query.toLowerCase();
    final filtered = _allResults.where((r) =>
      r.name.toLowerCase().contains(q) ||
      r.bib.toLowerCase().contains(q)
    ).toList();
    setState(() {
      _dataSource = ResultsDataSource(filtered);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', true),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Event Header Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF8F9FA),
                          const Color(0xFFE9ECEF),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        // Event Logo
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                    'assets/happy_logo.png',
                            height: 80,
                    fit: BoxFit.contain,
                  ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'AGROMED RUN 2025',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 2,
                          ),
                  ),
                  const SizedBox(height: 8),
                        Text(
                          '5K & 10K Race • March 15, 2025 • Jakarta, Indonesia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7F8C8D),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                    Text(
                    'RESULTS',
                    style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE91E63),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Search Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Color(0xFFE91E63), size: 24),
                              const SizedBox(width: 15),
                              Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                                    hintText: 'Search by Bib or Name...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Color(0xFF7F8C8D),
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2C3E50),
                        ),
                        onChanged: _filterResults,
                      ),
                      ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Results Table Section
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      margin: const EdgeInsets.only(left: 40, right: 80),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: double.infinity,
                          child: PaginatedDataTable(
                            columnSpacing: 0,
                            horizontalMargin: 0,
                            headingRowHeight: 50,
                            dataRowMinHeight: 40,
                            dataRowMaxHeight: 45,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        onPageChanged: (firstRowIndex) {
                          _scrollController.jumpTo(0);
                        },
                          headingRowColor: MaterialStateProperty.all(
                            const Color(0xFFF8F9FA),
                          ),
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: 60,
                              child: Text(
                                'Rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            numeric: true,
                            onSort: (i, asc) =>
                                _sort<num>((d) => d.rank, i, asc),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 200,
                              child: Text(
                                'Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onSort: (i, asc) =>
                                _sort<String>((d) => d.name, i, asc),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 80,
                              child: Text(
                                'Bib',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            numeric: true,
                            onSort: (i, asc) => _sort<num>(
                              (d) => int.tryParse(d.bib) ?? 0,
                              i,
                              asc,
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 80,
                              child: Text(
                                'Gender',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onSort: (i, asc) =>
                                _sort<String>((d) => d.gender, i, asc),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                'Check Point',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onSort: (columnIndex, ascending) {
                              _sort<num>(
                                (d) => d.cp1Secs,
                                columnIndex,
                                ascending,
                              );
                            },
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text(
                                'Time',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onSort: (i, asc) =>
                                _sort<num>((d) => d.timeSeconds, i, asc),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                'Gender Rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            numeric: true,
                            onSort: (i, asc) => _sort<num>(
                              (d) => d.genderRank ?? kDNFSecs,
                              i,
                              asc,
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 100,
                              child: Text(
                                'Certificate',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                        source: _dataSource,
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [10, 20, 30, 50, 100],
                        onRowsPerPageChanged: (v) {
                          if (v != null) setState(() => _rowsPerPage = v);
                        },
                      ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          // Footer: desktop original, mobile flexible
          Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context) ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                  _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                  _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                  _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                  _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                  _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                  _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                  const SizedBox(width: 10),
                  _footerLink(context, 'Request Quote (via Whatsapp)', () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }),
                  const SizedBox(width: 10), const Icon(Icons.email, color: Colors.white, size: 18), const SizedBox(width: 6), const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ) : Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/pricing');
                      },
                      child: Text(
                        'Pricing',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/features');
                      },
                      child: Text(
                        'Features',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: Text(
                        'T&C',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                      child: Text(
                        'Contact',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/faq');
                      },
                      child: Text(
                        'FAQ',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                    openUrl(whatsappUrl);
                  },
                  child: Text(
                    'Request Quote (via Whatsapp)',
                    style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.email, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'runmlgrun@gmail.com',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 12 : 20,
          vertical: isMobile(context) ? 15 : 25,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: isMobile(context) ? 13 : 15,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class RaceResult {
  final int rank;
  final String name;
  final String bib;
  final String gender;
  final int timeSeconds;
  final String timeDisplay;
  final int? genderRank;
  final String cp1Display;
  final bool finished;
  final int cp1Secs;
  final bool isDns;

  const RaceResult({
    required this.rank,
    required this.name,
    required this.bib,
    required this.gender,
    required this.timeSeconds,
    required this.timeDisplay,
    required this.genderRank,
    required this.cp1Display,
    required this.finished,
    required this.cp1Secs,
    required this.isDns,

  });
}

class ResultsDataSource extends DataTableSource {
  ResultsDataSource(this._results);
  final List<RaceResult> _results;

  void sort<T>(Comparable<T> Function(RaceResult d) getField, bool ascending) {
    _results.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      final order = Comparable.compare(aValue, bValue);
      return ascending ? order : -order;
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= _results.length) return null;
    final r = _results[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          SizedBox(
            width: 60,
            child: Text(r.isDns ? 'DNS' : (r.finished ? r.rank.toString() : 'DNF')),
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Text(r.name, overflow: TextOverflow.ellipsis),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Text(r.bib),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Text(r.gender),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Text(r.cp1Display),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(r.timeDisplay),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Text(r.finished ? (r.genderRank?.toString() ?? '') : ''),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: r.finished
                ? TextButton.icon(
                    onPressed: () async {
                      try {
                        await CertificateService.downloadCertificate(
                      name: r.name,
                      timeText: r.timeDisplay.isEmpty
                          ? '—'
                          : r.timeDisplay, // show time if available
                        );
                      } catch (e) {
                        print('Error downloading certificate: $e');
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: Text('Download'),
                  )
                : Text(''),
          ),
        ),


      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _results.length;
  @override
  int get selectedRowCount => 0;
}

class CertificateService {
  static Future<void> downloadCertificate({
    required String name,
    required String timeText,
  }) async {
    // 1) Load background
    final bg = await rootBundle.load('assets/certificate.png');
    final Uint8List bytes = bg.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image bgImg = frame.image;


    // 2) Draw onto a canvas
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, bgImg.width.toDouble(), bgImg.height.toDouble()));
    final paint = ui.Paint();

    // background
    canvas.drawImage(bgImg, const ui.Offset(0, 0), paint);

    // 3) Text painters
    TextPainter _tp(String text, double size, FontWeight w) {
      final tp = TextPainter(
      text: TextSpan(
        style: TextStyle(
        fontFamily: 'DINCondensed',
        fontSize: size,
        fontWeight: w,
        color: Colors.black,
        ),
        text: text,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      );
      tp.layout(minWidth: 0, maxWidth: bgImg.width.toDouble());
      return tp;
    }

    final nameTp = _tp(name.toUpperCase(), bgImg.width * 0.06, FontWeight.w600);
    final timeTp = _tp(timeText,            bgImg.width * 0.045, FontWeight.w600);

    // 4) Center text (tweak Y as needed)
    nameTp.paint(canvas, ui.Offset((bgImg.width - nameTp.width) / 2, bgImg.height * 0.45));
    timeTp.paint(canvas, ui.Offset((bgImg.width - timeTp.width) / 2, bgImg.height * 0.79));

    // 5) Export PNG
    final pic = recorder.endRecording();
    final img = await pic.toImage(bgImg.width, bgImg.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // 6) Trigger download
    await saveCertificateToFile(pngBytes, name);
  }

  static String _sanitize(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9._ -]+'), '_');
}


String _formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  return [h, m, s].map((v) => v.toString().padLeft(2, '0')).join(':');
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  // Opens a simple search dialog from header and routes to Results
  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Search'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search events or results...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/results');
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C3E50),
                  const Color(0xFF34495E),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                // Logo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/lariterus_logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(),
                // Navigation
                isMobile(context)
                  ? Row(
                      children: [
                        _buildMobileMenuButton(context),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    )
                  : Row(
                      children: [
                        _buildNavItem(context, 'Home', false, onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }),
                        _buildNavItem(context, 'Race Results', false, onTap: () {
                          Navigator.pushNamed(context, '/results');
                        }),
                        _buildNavItem(context, 'Pricing', false, onTap: () {
                          Navigator.pushNamed(context, '/pricing');
                        }),
                        _buildNavItem(context, 'Features', false, onTap: () {
                          Navigator.pushNamed(context, '/features');
                        }),
                        _buildNavItem(context, 'Contact', false, onTap: () {
                          Navigator.pushNamed(context, '/contact');
                        }),
                        _buildNavItem(context, 'FAQ', false, onTap: () {
                          Navigator.pushNamed(context, '/faq');
                        }),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () => navigateToSearchPage(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.search, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
              ],
            ),
          ),
          // Hero Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF5F5F5),
                  const Color(0xFFE8E8E8),
                ],
              ),
            ),
            child: Center(
              child: Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFE91E63),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F5F5),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'LARI TERUS – Terms and Conditions of Service',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Introduction
                    Text(
                      'These Terms and Conditions ("Terms") constitute a legally binding agreement between the client ("Client") and LARI TERUS ("Company") with respect to the provision of race timing system services. By engaging our services, the Client agrees to be bound by these Terms.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Section 1: Definitions
                    _buildTermsSection(
                      '1. Definitions',
                      [
                        '1.1. "Service" means the provision of race timing systems by the Company for events such as road races, trail runs, and other athletic competitions.',
                        '1.2. "Client" refers to the individual or entity organizing the event and entering into an agreement with the Company.',
                        '1.3. "Agreement" means the formal service order or contract, including these Terms, outlining the scope, schedule, and cost of services.',
                        '1.4. "Force Majeure" means any circumstance beyond the control of either party that prevents or delays performance, including but not limited to natural disasters, war, strikes, epidemics, or government restrictions.',
                      ],
                    ),
                    // Section 2: Scope of Services
                    _buildTermsSection(
                      '2. Scope of Services',
                      [
                        '2.1. The Company agrees to provide race timing system services as outlined in the Service Agreement. This may include RFID chip timing, result processing, and reporting.',
                        '2.2. The Client is responsible for ensuring that the event site is properly prepared, including internet and power supply where required, and for coordinating participant logistics.',
                        '2.3. Any additional services outside the agreed scope may incur additional charges.',
                      ],
                    ),
                    // Section 3: Booking and Payment
                    _buildTermsSection(
                      '3. Booking and Payment',
                      [
                        '3.1. A signed Service Agreement and/or payment of a booking fee is required to confirm the reservation of timing services.',
                        '3.2. The remaining balance must be paid in full no later than 7 days before the event date, unless otherwise stated.',
                        '3.3. Late payments may result in delay or cancellation of services.',
                      ],
                    ),
                    // Section 4: Cancellation and Refund
                    _buildTermsSection(
                      '4. Cancellation and Refund',
                      [
                        '4.1. Full Refunds will only be granted if the Client cancels the service in writing at least 30 days before the event.',
                        '4.2. Partial Refunds (up to 50%) may be issued if cancellation occurs between 15–29 days before the event.',
                        '4.3. No Refund will be given if cancellation is made within 14 days of the event, or if the cancellation is due to Client-side issues (e.g., lack of permits, inaccessible venue).',
                        '4.4. Refunds due to technical failure on the part of the Company will be reviewed on a case-by-case basis.',
                      ],
                    ),
                    // Section 5: Client Responsibilities
                    _buildTermsSection(
                      '5. Client Responsibilities',
                      [
                        '5.1. The Client must provide accurate event details and participant data as per the agreed timeline.',
                        '5.2. The Client must ensure that all necessary permits and approvals for hosting the event are secured.',
                        '5.3. The Client is responsible for ensuring safety and accessibility for participants, spectators, and service providers.',
                      ],
                    ),
                    // Section 6: Liability and Indemnification
                    _buildTermsSection(
                      '6. Liability and Indemnification',
                      [
                        '6.1. The Company shall not be held liable for any direct or indirect loss, delay, or failure in service delivery caused by Force Majeure or actions outside the Company\'s control.',
                        '6.2. The Client agrees to indemnify and hold harmless the Company, its employees, and agents from any claims, damages, or liabilities arising out of or related to the event execution.',
                      ],
                    ),
                    // Section 7: Intellectual Property
                    _buildTermsSection(
                      '7. Intellectual Property',
                      [
                        '7.1. Any software, systems, or branding provided by the Company remain the intellectual property of LARI TERUS.',
                        '7.2. The Client is not permitted to reproduce or distribute any proprietary material without written consent.',
                      ],
                    ),
                    // Section 8: Confidentiality
                    _buildTermsSection(
                      '8. Confidentiality',
                      [
                        '8.1. Both parties agree to maintain the confidentiality of all information deemed confidential or proprietary during the term of the Agreement.',
                        '8.2. This clause shall survive the termination of the Agreement.',
                      ],
                    ),
                    // Section 9: Dispute Resolution
                    _buildTermsSection(
                      '9. Dispute Resolution',
                      [
                        '9.1. In the event of a dispute, both parties shall first attempt to resolve the issue amicably through written communication.',
                        '9.2. If no resolution is reached, the dispute shall be settled by arbitration or mediation in Malang, Indonesia, in accordance with local laws.',
                      ],
                    ),
                    // Section 10: Amendments
                    _buildTermsSection(
                      '10. Amendments',
                      [
                        '10.1. The Company reserves the right to amend these Terms at any time. The updated version will be published on the Company\'s website and communicated to Clients as needed.',
                      ],
                    ),
                    // Section 11: Governing Law
                    _buildTermsSection(
                      '11. Governing Law',
                      [
                        '11.1. These Terms shall be governed by and interpreted in accordance with the laws of INDONESIA.',
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Contact Information
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'For questions regarding these Terms and Conditions, please contact us:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Email: runmlgrun@gmail.com',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Phone: +62-852-0411-5000',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer: desktop original, mobile flexible
          Container(
            width: double.infinity,
            height: 60,
            color: const Color(0xFF424242),
            child: isMobile(context) ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white, size: 18),
                  _footerLink(context, 'Home', () { Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false); }),
                  _sep(), _footerLink(context, 'Pricing', () { Navigator.pushNamed(context, '/pricing'); }),
                  _sep(), _footerLink(context, 'Features', () { Navigator.pushNamed(context, '/features'); }),
                  _sep(), _footerLink(context, 'T&C', () { Navigator.pushNamed(context, '/terms'); }),
                  _sep(), _footerLink(context, 'Contact', () { Navigator.pushNamed(context, '/contact'); }),
                  _sep(), _footerLink(context, 'FAQ', () { Navigator.pushNamed(context, '/faq'); }),
                  const SizedBox(width: 10),
                  _footerLink(context, 'Request Quote (via Whatsapp)', () { final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0'; openUrl(whatsappUrl); }),
                  const SizedBox(width: 10), const Icon(Icons.email, color: Colors.white, size: 18), const SizedBox(width: 6), const Text('runmlgrun@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ) : Row(
              children: [
                const SizedBox(width: 20),
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      },
                      child: Text(
                        'Home',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/pricing');
                      },
                      child: Text(
                        'Pricing',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/features');
                      },
                      child: Text(
                        'Features',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/terms');
                      },
                      child: Text(
                        'T&C',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/contact');
                      },
                      child: Text(
                        'Contact',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.white, fontSize: 14)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/faq');
                      },
                      child: Text(
                        'FAQ',
                        style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final whatsappUrl = 'https://api.whatsapp.com/send/?phone=6285708700863&text=Halo%2C%0A%0ASaya+tertarik+untuk+mengetahui+lebih+lanjut+tentang+solusi+pencatatan+waktu+balap+berbasis+RFID+yang+Anda+tawarkan.+Bisakah+Anda+memberikan+informasi+lebih+lanjut+mengenai+layanan+dan+paket+harga+yang+tersedia%3F&type=phone_number&app_absent=0';
                    openUrl(whatsappUrl);
                  },
                  child: Text(
                    'Request Quote (via Whatsapp)',
                    style: TextStyle(color: Colors.white, fontSize: 14, decoration: TextDecoration.underline, decorationThickness: 1.5),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.email, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'runmlgrun@gmail.com',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFE91E63),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
                height: 1.6,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile(context) ? 10 : 15,
          vertical: isMobile(context) ? 6 : 8,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile(context) ? 12 : 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
