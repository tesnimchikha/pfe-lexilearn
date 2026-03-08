import 'package:flutter/material.dart';
import 'login_page.dart';

class OnboardingPage extends StatelessWidget {
  // ignore: use_super_parameters
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام ExtendBodyBehindAppBar إذا كنت تحب الصورة تغطي حتى منطقة الساعة
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/onboarding_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              // يخلي العناصر تبدأ من اليسار
              crossAxisAlignment: CrossAxisAlignment.start, 
              // يخلي كل العناصر تهبط لوطا (عوض الـ Spacer)
              mainAxisAlignment: MainAxisAlignment.end, 
              children: [
                // النص
                Text(
                  "let's explore,\nplay, and learn!",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.grey.shade800,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 35), // مسافة بين النص والزر
                
                // الزر 3D
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      // طبقة الظل (3D Effect)
                      Container(
                        width: 170,
                        height: 60,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      // طبقة الزر الأساسية
                      Transform.translate(
                        offset: const Offset(0, -5), // إزاحة للأعلى تعطي جمالية الـ 3D
                        child: Container(
                          width: 170,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A), // أسود شيك
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              "let's Go",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // مسافة صغيرة اختيارية من أسفل الشاشة
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}