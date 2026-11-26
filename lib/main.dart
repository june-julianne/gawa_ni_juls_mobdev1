import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const TaskoraApp());
}

// ===========================================================================
// FRONT-END USER PROFILE & TASK STATE STORES
// ===========================================================================
class UserStore extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _password = '';

  String get name => _name;
  String get email => _email;
  String get password => _password;

  String get displayName => _name.isNotEmpty ? _name : 'Your name';
  String get displayEmail => _email.isNotEmpty ? _email : 'No email added';

  String _deriveNameFromEmail(String emailOrPhone) {
    final String trimmed = emailOrPhone.trim();
    if (!trimmed.contains('@')) return '';
    final String localPart = trimmed.split('@').first;
    final List<String> parts = localPart
        .split(RegExp(r'[._\-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .toList();
    return parts.join(' ');
  }

  void setAccount({String? name, String? email, String? password}) {
    final String cleanEmail = (email ?? '').trim();
    final String cleanName = (name ?? '').trim();

    if (cleanName.isNotEmpty) {
      _name = cleanName;
    } else if (cleanEmail.isNotEmpty &&
        (_name.isEmpty || cleanEmail != _email)) {
      _name = _deriveNameFromEmail(cleanEmail);
    }

    if (cleanEmail.isNotEmpty) {
      _email = cleanEmail;
    }

    if (password != null && password.isNotEmpty) {
      _password = password;
    }

    notifyListeners();
  }

  void updateName(String newName) {
    _name = newName.trim();
    notifyListeners();
  }

  void updatePassword(String newPassword) {
    if (newPassword.isNotEmpty) {
      _password = newPassword;
      notifyListeners();
    }
  }

  void clearAccount() {
    _name = '';
    _email = '';
    _password = '';
    notifyListeners();
  }
}

final UserStore userStore = UserStore();

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String dueDate;
  final String time;
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.priority,
    this.dueDate = '',
    this.time = '',
    this.isCompleted = false,
  });
}

class TaskStore extends ChangeNotifier {
  final List<TaskItem> _tasks = [];

  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  List<TaskItem> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  List<TaskItem> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  TaskItem? getTaskById(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return null;
    return _tasks[index];
  }

  void addTask(TaskItem task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTask(TaskItem updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }
}

final TaskStore taskStore = TaskStore();

// ===========================================================================
// APP ROOT
// ===========================================================================
class TaskoraApp extends StatelessWidget {
  const TaskoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}

// ===========================================================================
// 1. LANDING PAGE
// ===========================================================================
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: _LandingBackgroundPainter(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Top Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FAFC),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'YOUR DAY, SIMPLIFIED',
                    style: TextStyle(
                      color: Color(0xFF546C7B),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Center Logo Emblem
                SizedBox(
                  width: 220,
                  height: 210,
                  child: CustomPaint(painter: _TaskoraLogoPainter()),
                ),

                const SizedBox(height: 4),

                // Brand Title
                const Text(
                  'TASKORA',
                  style: TextStyle(
                    color: Color(0xFF233B53),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.5,
                  ),
                ),

                const Spacer(flex: 4),

                // Subtitle
                const Text(
                  'Bring your tasks together and make\nspace for what matters most.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF546C7B),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),

                // Pillars
                const Text(
                  'PLAN   ·   FOCUS   ·   ACHIEVE',
                  style: TextStyle(
                    color: Color(0xFF546C7B),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF233B53),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0x33233B53),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Footer Text
                const Text(
                  'A fresh start, one task at a time.',
                  style: TextStyle(color: Color(0xFF546C7B), fontSize: 10.5),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final creamPaint = Paint()..color = const Color(0xFFFAF9F4);
    canvas.drawRect(Offset.zero & size, creamPaint);

    final bandPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.59)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.80,
        0,
        size.height * 0.59,
      )
      ..close();
    canvas.drawPath(bandPath, Paint()..color = const Color(0xFFEEF5F8));

    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.53)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.72,
        0,
        size.height * 0.53,
      )
      ..close();

    final topPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFCDE1ED), Color(0xFFDCEAF2)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.65));

    canvas.drawPath(topPath, topPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TaskoraLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 92.0;

    final ringPaint = Paint()
      ..color = const Color(0xFFB8D0DE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, radius, ringPaint);

    canvas.drawCircle(
      Offset(center.dx - radius * 0.88, center.dy + radius * 0.45),
      3.2,
      Paint()..color = Colors.white,
    );

    canvas.drawCircle(
      Offset(center.dx + radius * 0.78, center.dy - radius * 0.62),
      2.5,
      Paint()..color = const Color(0xFF4395F2),
    );

    final dashPaint = Paint()
      ..color = const Color(0xFF4798F4)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.5;
    canvas.drawLine(
      Offset(center.dx - 58, center.dy - 36),
      Offset(center.dx - 47, center.dy - 30),
      dashPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 45, center.dy - 51),
      Offset(center.dx - 40, center.dy - 40),
      dashPaint,
    );

    canvas.save();
    canvas.translate(center.dx, center.dy + 4);
    canvas.rotate(-0.42);
    final orbitBackPaint = Paint()
      ..color = const Color(0x6692C5F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;
    canvas.drawArc(
      Rect.fromCenter(center: Offset.zero, width: 138, height: 38),
      math.pi,
      math.pi,
      false,
      orbitBackPaint,
    );
    canvas.restore();

    final stemRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - 4, center.dy + 12),
        width: 34,
        height: 76,
      ),
      const Radius.circular(16),
    );
    final stemPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3E8EEB), Color(0xFF56A9F8)],
      ).createShader(stemRect.outerRect);
    canvas.drawRRect(stemRect, stemPaint);

    final topBarRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - 2, center.dy - 18),
        width: 88,
        height: 36,
      ),
      const Radius.circular(18),
    );
    final topBarPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF66C1FA), Color(0xFF3684E6)],
      ).createShader(topBarRect.outerRect);
    canvas.drawRRect(topBarRect, topBarPaint);

    final checkPath = Path()
      ..moveTo(center.dx + 12, center.dy - 18)
      ..lineTo(center.dx + 19, center.dy - 11)
      ..lineTo(center.dx + 31, center.dy - 24);
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(checkPath, checkPaint);

    canvas.save();
    canvas.translate(center.dx, center.dy + 4);
    canvas.rotate(-0.42);
    final orbitFrontPaint = Paint()
      ..color = const Color(0x99A5D2FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset.zero, width: 138, height: 38),
      0.08,
      math.pi - 0.16,
      false,
      orbitFrontPaint,
    );
    canvas.restore();

    final starCenter = Offset(center.dx + 60, center.dy + 18);
    const sOuter = 11.0;
    const sInner = 3.2;
    final starPath = Path()
      ..moveTo(starCenter.dx, starCenter.dy - sOuter)
      ..quadraticBezierTo(
        starCenter.dx,
        starCenter.dy,
        starCenter.dx + sOuter,
        starCenter.dy,
      )
      ..quadraticBezierTo(
        starCenter.dx,
        starCenter.dy,
        starCenter.dx,
        starCenter.dy + sOuter,
      )
      ..quadraticBezierTo(
        starCenter.dx,
        starCenter.dy,
        starCenter.dx - sOuter,
        starCenter.dy,
      )
      ..quadraticBezierTo(
        starCenter.dx,
        starCenter.dy,
        starCenter.dx,
        starCenter.dy - sOuter,
      )
      ..close();
    canvas.drawPath(starPath, Paint()..color = const Color(0xFF4798F4));
    canvas.drawCircle(
      starCenter,
      sInner,
      Paint()..color = const Color(0xFF4798F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===========================================================================
// 2. SIGN IN PAGE
// ===========================================================================
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    userStore.setAccount(
      email: _emailController.text,
      password: _passwordController.text,
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: const _WaveBackgroundPainter(showOrnaments: true),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 155),

                          // Top small horizontal indicator
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF83ABC4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 5,
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: const Color(0x6683ABC4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // SIGN IN Heading
                          const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Thin line under SIGN IN
                          Container(
                            width: 58,
                            height: 1,
                            color: const Color(0xFF8CA5B5),
                          ),

                          const SizedBox(height: 8),

                          // Welcome to TASKORA
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF233B53),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Welcome to ',
                                  style: TextStyle(fontFamily: 'Georgia'),
                                ),
                                TextSpan(
                                  text: 'TASKORA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 44),

                          // Email Address Label
                          const Text(
                            'Email Address',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 13,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Email Input Field
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5E0E6),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.mail_rounded,
                                  size: 17,
                                  color: Color(0xFF54626B),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  width: 1,
                                  color: const Color(0xFF9EB0BA),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF1E2D38),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                        right: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Password Label
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 13,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Password Input Field
                          Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5E0E6),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 17,
                                  color: Color(0xFF54626B),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  width: 1,
                                  color: const Color(0xFF9EB0BA),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF1E2D38),
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    size: 17,
                                    color: const Color(0xFF3E4B52),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Forgot Password? -> ResetPassword
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ResetPassword(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2878B5),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF2878B5),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // LOG IN Button -> Dashboard
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _handleSignIn,
                              style:
                                  ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ).copyWith(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>((
                                          Set<WidgetState> states,
                                        ) {
                                          if (states.contains(
                                                WidgetState.hovered,
                                              ) ||
                                              states.contains(
                                                WidgetState.pressed,
                                              )) {
                                            return const Color(0xFF83ABC4);
                                          }
                                          return const Color(0xFFC5DCEB);
                                        }),
                                  ),
                              child: const Text(
                                'LOG IN',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // New here? Create an account -> CreateAccount
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CreateAccount(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 11,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'New here? ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Create an account',
                                      style: TextStyle(
                                        color: Color(0xFF2878B5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Bottom Ornament (— · —)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 1,
                                color: const Color(0xFFBACCD6),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFBACCD6),
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 1,
                                color: const Color(0xFFBACCD6),
                              ),
                            ],
                          ),

                          const Spacer(),
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 3. CREATE ACCOUNT PAGE
// ===========================================================================
class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() {
    userStore.setAccount(
      name: _nameController.text,
      email: _emailOrPhoneController.text,
      password: _passwordController.text,
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Dashboard()),
      (route) => false,
    );
  }

  Widget _buildPillField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFD5E0E6),
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 12.5,
          color: Color(0xFF1E2D38),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 11.5,
            color: Color(0xFF54626B),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: const _WaveBackgroundPainter(showOrnaments: false),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 165),

                          // CREATE ACCOUNT Heading
                          const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Thin line under CREATE ACCOUNT
                          Container(
                            width: 68,
                            height: 1,
                            color: const Color(0xFF263F56),
                          ),

                          const SizedBox(height: 10),

                          // Make room for what matters with TASKORA.
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF233B53),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Make room for what matters with ',
                                  style: TextStyle(fontFamily: 'Georgia'),
                                ),
                                TextSpan(
                                  text: 'TASKORA.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 38),

                          // Name Label & Input
                          const Text(
                            'Name',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 7),
                          _buildPillField(
                            controller: _nameController,
                            hintText: 'Enter your full name',
                          ),

                          const SizedBox(height: 18),

                          // Email or phone Label & Input
                          const Text(
                            'Email or phone',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 7),
                          _buildPillField(
                            controller: _emailOrPhoneController,
                            hintText: 'Enter your email or phone number',
                          ),

                          const SizedBox(height: 18),

                          // Password Label & Input
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 7),
                          _buildPillField(
                            controller: _passwordController,
                            hintText: 'Create a password',
                            obscureText: true,
                          ),

                          const SizedBox(height: 36),

                          // CREATE ACCOUNT Button -> Dashboard
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _handleCreateAccount,
                              style:
                                  ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ).copyWith(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>((
                                          Set<WidgetState> states,
                                        ) {
                                          if (states.contains(
                                                WidgetState.hovered,
                                              ) ||
                                              states.contains(
                                                WidgetState.pressed,
                                              )) {
                                            return const Color(0xFF1A2D3E);
                                          }
                                          return const Color(0xFF263F56);
                                        }),
                                  ),
                              child: const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Already have an account? Sign in
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 11,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Already have an account?  ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sign in',
                                      style: TextStyle(
                                        color: Color(0xFF2878B5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 4. RESET PASSWORD PAGE
// ===========================================================================
class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use at least 8 characters for your new password.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    userStore.updatePassword(newPassword);
    Navigator.pop(context);
  }

  Widget _buildPillField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFD5E0E6),
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: true,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 12.5,
          color: Color(0xFF1E2D38),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 11.5,
            color: Color(0xFF54626B),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: const _WaveBackgroundPainter(showOrnaments: false),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 165),

                          // RESET PASSWORD Heading
                          const Text(
                            'RESET PASSWORD',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Thin line under RESET PASSWORD
                          Container(
                            width: 68,
                            height: 1,
                            color: const Color(0xFF263F56),
                          ),

                          const SizedBox(height: 10),

                          // Subtitle
                          const Text(
                            'Choose a new password to secure your account.',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 11,
                              color: Color(0xFF233B53),
                            ),
                          ),

                          const SizedBox(height: 38),

                          // New password Label & Input
                          const Text(
                            'New password',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 7),
                          _buildPillField(
                            controller: _newPasswordController,
                            hintText: 'Enter your new password',
                          ),

                          const SizedBox(height: 18),

                          // Re-enter password Label & Input
                          const Text(
                            'Re-enter password',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 12.5,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 7),
                          _buildPillField(
                            controller: _confirmPasswordController,
                            hintText: 'Re-enter your new password',
                          ),

                          const SizedBox(height: 10),

                          // Helper text
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Text(
                              'Use at least 8 characters for your new password.',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 10.5,
                                color: Color(0xFF495C6C),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // RESET PASSWORD Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _handleResetPassword,
                              style:
                                  ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ).copyWith(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>((
                                          Set<WidgetState> states,
                                        ) {
                                          if (states.contains(
                                                WidgetState.hovered,
                                              ) ||
                                              states.contains(
                                                WidgetState.pressed,
                                              )) {
                                            return const Color(0xFF1A2D3E);
                                          }
                                          return const Color(0xFF263F56);
                                        }),
                                  ),
                              child: const Text(
                                'RESET PASSWORD',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Back to sign in
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 11,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Back to ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'sign in',
                                      style: TextStyle(
                                        color: Color(0xFF2878B5),
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFF2878B5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// SHARED TASK CARD WIDGETS
// ===========================================================================
class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  Color _priorityBgColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFF3E4DB);
      case 'Medium':
        return const Color(0xFFDFECF3);
      default:
        return const Color(0xFFE7EEF0);
    }
  }

  Color _priorityTextColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFF805233);
      case 'Medium':
        return const Color(0xFF263F56);
      default:
        return const Color(0xFF586E7D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String subtitleDate = task.dueDate.trim().isNotEmpty
        ? task.dueDate.trim()
        : 'Month, date number';
    final String subtitle = task.time.trim().isNotEmpty
        ? '${task.category.toUpperCase()} · $subtitleDate · ${task.time.trim()}'
        : '${task.category.toUpperCase()} · $subtitleDate';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD7E1E4), width: 1),
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        width: double.infinity,
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: task.isCompleted
                        ? const Color(0xFF263F56)
                        : const Color(0xFF8BA4B4),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  color: task.isCompleted
                      ? const Color(0xFF263F56)
                      : Colors.white,
                ),
                width: 22,
                height: 22,
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: task.isCompleted
                          ? const Color(0xFF8BA4B4)
                          : const Color(0xFF263F56),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF586E7D),
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _priorityBgColor(task.priority),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          task.priority,
                          style: TextStyle(
                            color: _priorityTextColor(task.priority),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedTaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _CompletedTaskCard({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String subtitleDate = task.dueDate.trim().isNotEmpty
        ? task.dueDate.trim()
        : 'Month, date number';
    final String subtitle = '${task.category} · $subtitleDate';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD7E1E4), width: 1),
          borderRadius: BorderRadius.circular(17),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        width: double.infinity,
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF263F56), width: 1),
                  borderRadius: BorderRadius.circular(7),
                  color: const Color(0xFF263F56),
                ),
                width: 22,
                height: 22,
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      color: Color(0xFF263F56),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF586E7D),
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFE3EDE7),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Color(0xFF365F50),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddTaskCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyAddTaskCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD7E1E4), width: 1),
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        width: double.infinity,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF8BA4B4), width: 1.2),
                borderRadius: BorderRadius.circular(7),
                color: Colors.white,
              ),
              width: 22,
              height: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add a task',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: Color(0xFF263F56),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TASKORA · Month, date number',
                        style: TextStyle(
                          color: Color(0xFF586E7D),
                          fontSize: 10.5,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFF3E4DB),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: const Text(
                          'High',
                          style: TextStyle(
                            color: Color(0xFF805233),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 5. DASHBOARD PAGE
// ===========================================================================
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  void _openAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTask()),
    );
  }

  void _openTaskDetails(TaskItem task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetails(taskId: task.id)),
    );
  }

  void _openLogOut() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogOut()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: taskStore,
      builder: (context, _) {
        final int total = taskStore.totalCount;
        final int pending = taskStore.pendingCount;
        final int completed = taskStore.completedCount;
        final double progressRatio = total == 0 ? 0.0 : completed / total;

        final List<TaskItem> upcomingTasks = [
          ...taskStore.pendingTasks,
          ...taskStore.completedTasks,
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F4),
          body: CustomPaint(
            painter: _DashboardBackgroundPainter(),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top App Header
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 18,
                      bottom: 12,
                      left: 24,
                      right: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TASKORA',
                          style: TextStyle(
                            color: Color(0xFF263F56),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openLogOut,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: Color(0xFF6B8191),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),

                          // Greeting Title & Date Subtitle
                          const Text(
                            'A little focus, every day.',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Day, Month, day number',
                            style: TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 3 Summary Stat Cards Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: const Color(0xFFE9EFF2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$total',
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          color: Color(0xFF263F56),
                                          fontSize: 23,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Total tasks',
                                        style: TextStyle(
                                          color: Color(0xFF4F6575),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: const Color(0xFFB8D6E8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$pending',
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          color: Color(0xFF263F56),
                                          fontSize: 23,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Pending',
                                        style: TextStyle(
                                          color: Color(0xFF263F56),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: const Color(0xFFE9EFF2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$completed',
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          color: Color(0xFF263F56),
                                          fontSize: 23,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Completed',
                                        style: TextStyle(
                                          color: Color(0xFF4F6575),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Dark Navy Progress Card
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: const Color(0xFF233B53),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Small steps, real progress.',
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        color: Color(0xFFFCFAF2),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '$completed of $total',
                                      style: const TextStyle(
                                        color: Color(0xFFFCFAF2),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double fillWidth = total == 0
                                        ? 10.0
                                        : math.max(
                                            10.0,
                                            constraints.maxWidth *
                                                progressRatio,
                                          );
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: const Color(0xFF4E6678),
                                      ),
                                      width: double.infinity,
                                      height: 5,
                                      alignment: Alignment.centerLeft,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          color: const Color(0xFFB5D5E6),
                                        ),
                                        width: fillWidth,
                                        height: 5,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Coming up next Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Coming up next',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF263F56),
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PendingTasks(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View all',
                                  style: TextStyle(
                                    color: Color(0xFF263F56),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Task List or Placeholder Card
                          if (upcomingTasks.isEmpty)
                            _EmptyAddTaskCard(onTap: _openAddTask)
                          else
                            ...upcomingTasks.map(
                              (task) => _TaskCard(
                                task: task,
                                onToggle: () =>
                                    taskStore.toggleTaskCompletion(task.id),
                                onTap: () => _openTaskDetails(task),
                              ),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFCFAF2),
              border: Border(
                top: BorderSide(color: Color(0xFFEBE8DE), width: 1),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 18,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Home (Active)
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Icon(
                            Icons.home_outlined,
                            color: Color(0xFF263F56),
                            size: 22,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: Color(0xFF263F56),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Add -> AddTask
                Expanded(
                  child: GestureDetector(
                    onTap: _openAddTask,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8D6E8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF263F56),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tasks -> PendingTasks
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PendingTasks(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.format_list_bulleted_rounded,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tasks',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile -> ProfileSettings
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileSettings(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
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
      },
    );
  }
}

// ===========================================================================
// 6. PENDING TASKS PAGE
// ===========================================================================
class PendingTasks extends StatefulWidget {
  const PendingTasks({super.key});

  @override
  PendingTasksState createState() => PendingTasksState();
}

class PendingTasksState extends State<PendingTasks> {
  String _selectedCategory = 'All';

  void _openCompletedTasks() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CompletedTasks(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _openProfileSettings() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ProfileSettings(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFFB5D5E6) : const Color(0xFFE8EEEF),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF263F56),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: taskStore,
      builder: (context, _) {
        final List<TaskItem> baseList = taskStore.pendingTasks;

        final List<TaskItem> filteredTasks = _selectedCategory == 'All'
            ? baseList
            : baseList.where((t) => t.category == _selectedCategory).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F4),
          body: CustomPaint(
            painter: _DashboardBackgroundPainter(),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top App Header
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                      bottom: 12,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xFF263F56),
                              size: 26,
                            ),
                          ),
                        ),
                        const Text(
                          'My tasks',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Color(0xFF263F56),
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 28, height: 28),
                      ],
                    ),
                  ),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Page Title
                          const Text(
                            'Make room for what matters.',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Pending / Completed Segmented Control
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFE4ECEE),
                            ),
                            padding: const EdgeInsets.all(4),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFF233B53),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Pending  ${taskStore.pendingCount}',
                                      style: const TextStyle(
                                        color: Color(0xFFFCFAF2),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _openCompletedTasks,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Completed  ${taskStore.completedCount}',
                                        style: const TextStyle(
                                          color: Color(0xFF263F56),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Category Filter Pills
                          Row(
                            children: [
                              _buildFilterChip('All'),
                              const SizedBox(width: 8),
                              _buildFilterChip('School'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Personal'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Work'),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Count & Sort Subtitle
                          Text(
                            '${filteredTasks.length} pending tasks · By due date',
                            style: const TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Task List or Placeholder Card
                          if (filteredTasks.isEmpty)
                            _EmptyAddTaskCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddTask(),
                                  ),
                                );
                              },
                            )
                          else
                            ...filteredTasks.map(
                              (task) => _TaskCard(
                                task: task,
                                onToggle: () =>
                                    taskStore.toggleTaskCompletion(task.id),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetails(taskId: task.id),
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFCFAF2),
              border: Border(
                top: BorderSide(color: Color(0xFFEBE8DE), width: 1),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 18,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Home
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.home_outlined,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add -> AddTask
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTask(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8D6E8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF263F56),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tasks (Active)
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Icon(
                            Icons.format_list_bulleted_rounded,
                            color: Color(0xFF263F56),
                            size: 22,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tasks',
                        style: TextStyle(
                          color: Color(0xFF263F56),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile -> ProfileSettings
                Expanded(
                  child: GestureDetector(
                    onTap: _openProfileSettings,
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
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
      },
    );
  }
}

// ===========================================================================
// 6B. COMPLETED TASKS PAGE
// ===========================================================================
class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  CompletedTasksState createState() => CompletedTasksState();
}

class CompletedTasksState extends State<CompletedTasks> {
  String _selectedCategory = 'All';

  void _openPendingTasks() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PendingTasks(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _openProfileSettings() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ProfileSettings(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFFB5D5E6) : const Color(0xFFE8EEEF),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF263F56),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: taskStore,
      builder: (context, _) {
        final List<TaskItem> baseList = taskStore.completedTasks;

        final List<TaskItem> filteredTasks = _selectedCategory == 'All'
            ? baseList
            : baseList.where((t) => t.category == _selectedCategory).toList();

        final String categoryLabel = _selectedCategory == 'All'
            ? 'All categories'
            : _selectedCategory;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F4),
          body: CustomPaint(
            painter: _TaskCompletedBackgroundPainter(),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top App Header
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                      bottom: 12,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xFF263F56),
                              size: 26,
                            ),
                          ),
                        ),
                        const Text(
                          'My tasks',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Color(0xFF263F56),
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 28, height: 28),
                      ],
                    ),
                  ),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Page Title
                          const Text(
                            'A little more accomplished.',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Pending / Completed Segmented Control
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: const Color(0xFFE4ECEE),
                            ),
                            padding: const EdgeInsets.all(4),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _openPendingTasks,
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 11,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Pending  ${taskStore.pendingCount}',
                                        style: const TextStyle(
                                          color: Color(0xFF263F56),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xFF263F56),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 11,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Completed  ${taskStore.completedCount}',
                                      style: const TextStyle(
                                        color: Color(0xFFFCFAF2),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Category Filter Pills
                          Row(
                            children: [
                              _buildFilterChip('All'),
                              const SizedBox(width: 8),
                              _buildFilterChip('School'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Personal'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Work'),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Count & Category Subtitle
                          Text(
                            '${filteredTasks.length} completed tasks · $categoryLabel',
                            style: const TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Sage Green Encouragement Banner (shown when tasks are completed)
                          if (filteredTasks.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFE3EDE7),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              width: double.infinity,
                              child: const Text(
                                '✓  Task completed. One step closer!',
                                style: TextStyle(
                                  color: Color(0xFF365F50),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          // Completed Task List or Empty Placeholder
                          if (filteredTasks.isEmpty)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFD7E1E4),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(17),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              width: double.infinity,
                              child: const Text(
                                'No completed tasks yet. Finish a task to see your wins here.',
                                style: TextStyle(
                                  color: Color(0xFF586E7D),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            )
                          else
                            ...filteredTasks.map(
                              (task) => _CompletedTaskCard(
                                task: task,
                                onToggle: () =>
                                    taskStore.toggleTaskCompletion(task.id),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetails(taskId: task.id),
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFCFAF2),
              border: Border(
                top: BorderSide(color: Color(0xFFEBE8DE), width: 1),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 18,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Home
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.home_outlined,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add -> AddTask
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTask(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8D6E8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF263F56),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tasks (Active)
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 30,
                        child: Center(
                          child: Icon(
                            Icons.format_list_bulleted_rounded,
                            color: Color(0xFF263F56),
                            size: 22,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tasks',
                        style: TextStyle(
                          color: Color(0xFF263F56),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile -> ProfileSettings
                Expanded(
                  child: GestureDetector(
                    onTap: _openProfileSettings,
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
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
      },
    );
  }
}

// ===========================================================================
// 7. ADD TASK PAGE
// ===========================================================================
class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  AddTaskState createState() => AddTaskState();
}

class AddTaskState extends State<AddTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _selectedCategory = 'School';
  String _selectedPriority = 'Medium';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    taskStore.addTask(
      TaskItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _dueDateController.text.trim(),
        time: _timeController.text.trim(),
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildCategoryChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: isSelected
                ? const Color(0xFFB5D5E6)
                : const Color(0xFFE3ECEF),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF263F56), fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label) {
    final bool isSelected = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: isSelected
                ? const Color(0xFF263F56)
                : const Color(0xFFE3ECEF),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFFCFAF2)
                  : const Color(0xFF263F56),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: CustomPaint(
        painter: _DashboardBackgroundPainter(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top App Header
              Padding(
                padding: const EdgeInsets.only(
                  top: 14,
                  bottom: 12,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF263F56),
                          size: 26,
                        ),
                      ),
                    ),
                    const Text(
                      'Add task',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        color: Color(0xFF263F56),
                        fontSize: 18.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 28, height: 28),
                  ],
                ),
              ),

              // Main Scrollable Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Page Heading & Subtitle
                      const Text(
                        'One task at a time.',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Give your next step a little clarity.',
                        style: TextStyle(
                          color: Color(0xFF586E7D),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Task title
                      const Text(
                        'Task title',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFE3ECEF),
                        ),
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            color: Color(0xFF263F56),
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add a task title.',
                            hintStyle: TextStyle(
                              color: Color(0xFF4F6575),
                              fontSize: 12.5,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFE3ECEF),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          style: const TextStyle(
                            color: Color(0xFF263F56),
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Give a description on your task.',
                            hintStyle: TextStyle(
                              color: Color(0xFF4F6575),
                              fontSize: 12.5,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Category
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCategoryChip('School'),
                          const SizedBox(width: 9),
                          _buildCategoryChip('Personal'),
                          const SizedBox(width: 9),
                          _buildCategoryChip('Work'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Priority level
                      const Text(
                        'Priority level',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityChip('Low'),
                          const SizedBox(width: 9),
                          _buildPriorityChip('Medium'),
                          const SizedBox(width: 9),
                          _buildPriorityChip('High'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Due date & Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Due date',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    color: Color(0xFF263F56),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFE3ECEF),
                                  ),
                                  child: TextField(
                                    controller: _dueDateController,
                                    style: const TextStyle(
                                      color: Color(0xFF263F56),
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Month - day - year',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF4F6575),
                                        fontSize: 12.5,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    color: Color(0xFF263F56),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFE3ECEF),
                                  ),
                                  child: TextField(
                                    controller: _timeController,
                                    style: const TextStyle(
                                      color: Color(0xFF263F56),
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Solar Time',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF4F6575),
                                        fontSize: 12.5,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Helper text
                      const Text(
                        'You can change these details anytime.',
                        style: TextStyle(
                          color: Color(0xFF586E7D),
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAF2),
          border: Border(top: BorderSide(color: Color(0xFFEBE8DE), width: 1)),
        ),
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 22,
          left: 24,
          right: 24,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5D5E6),
              foregroundColor: const Color(0xFF263F56),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: const Text(
              'Save task',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: Color(0xFF263F56),
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 8. TASK DETAILS PAGE
// ===========================================================================
class TaskDetails extends StatefulWidget {
  final String taskId;

  const TaskDetails({super.key, required this.taskId});

  @override
  TaskDetailsState createState() => TaskDetailsState();
}

class TaskDetailsState extends State<TaskDetails> {
  bool _isEditPressed = false;
  bool _isDeletePressed = false;

  Future<void> _handleEditTap(TaskItem task) async {
    setState(() => _isEditPressed = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _isEditPressed = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTask(task: task)),
    );
  }

  Future<void> _handleDeleteTap(TaskItem task) async {
    setState(() => _isDeletePressed = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _isDeletePressed = false);

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0x99263F56),
      builder: (context) => DeleteTaskConfirmation(task: task),
    );

    if (shouldDelete == true && mounted) {
      taskStore.deleteTask(task.id);
      Navigator.pop(context);
    }
  }

  void _handleCompletionToggle(TaskItem task) {
    final bool wasCompleted = task.isCompleted;
    taskStore.toggleTaskCompletion(task.id);
    if (!wasCompleted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskCompleted(taskId: task.id)),
      );
    }
  }

  Color _priorityBgColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFF3E4DB);
      case 'Medium':
        return const Color(0xFFDFECF3);
      default:
        return const Color(0xFFE7EEF0);
    }
  }

  Color _priorityTextColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFF805233);
      case 'Medium':
        return const Color(0xFF263F56);
      default:
        return const Color(0xFF586E7D);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF586E7D), fontSize: 12),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF263F56),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: taskStore,
      builder: (context, _) {
        final TaskItem? task = taskStore.getTaskById(widget.taskId);
        if (task == null) {
          return const SizedBox.shrink();
        }

        final String dueDateText = task.dueDate.trim().isNotEmpty
            ? task.dueDate.trim()
            : 'Month, Day, Year';
        final String timeText = task.time.trim().isNotEmpty
            ? task.time.trim()
            : 'Solar Time';
        final String descriptionText = task.description.trim().isNotEmpty
            ? task.description.trim()
            : 'No description provided.';

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F4),
          body: CustomPaint(
            painter: _DashboardBackgroundPainter(),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top App Header
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                      bottom: 12,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xFF263F56),
                              size: 26,
                            ),
                          ),
                        ),
                        const Text(
                          'Task details',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Color(0xFF263F56),
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: Icon(
                            Icons.more_horiz_rounded,
                            color: Color(0xFF263F56),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Category & Priority Badges
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: const Color(0xFFE3ECEF),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                child: Text(
                                  task.category,
                                  style: const TextStyle(
                                    color: Color(0xFF263F56),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: _priorityBgColor(task.priority),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                child: Text(
                                  task.priority,
                                  style: TextStyle(
                                    color: _priorityTextColor(task.priority),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Task Title
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.18,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Task Description
                          Text(
                            descriptionText,
                            style: const TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Details Card
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFD7E1E4),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 19,
                              vertical: 6,
                            ),
                            width: double.infinity,
                            child: Column(
                              children: [
                                _buildDetailRow('Due date', dueDateText),
                                _buildDetailRow('Time', timeText),
                                _buildDetailRow('Category', task.category),
                                _buildDetailRow(
                                  'Status',
                                  task.isCompleted
                                      ? '✓  Completed'
                                      : '○  Pending',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Edit task & Delete task Row
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => _isEditPressed = true),
                                  onTapCancel: () =>
                                      setState(() => _isEditPressed = false),
                                  onTap: () => _handleEditTap(task),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(17),
                                      color: _isEditPressed
                                          ? const Color(0xFF263F56)
                                          : const Color(0xFFE3ECEF),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Edit task',
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        color: _isEditPressed
                                            ? const Color(0xFFFCFAF2)
                                            : const Color(0xFF263F56),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      setState(() => _isDeletePressed = true),
                                  onTapCancel: () =>
                                      setState(() => _isDeletePressed = false),
                                  onTap: () => _handleDeleteTap(task),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 120),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(17),
                                      color: _isDeletePressed
                                          ? const Color(0xFF943E3E)
                                          : const Color(0xFFFCFAF2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Delete task',
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        color: _isDeletePressed
                                            ? const Color(0xFFFCFAF2)
                                            : const Color(0xFF943E3E),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Helper Text
                          const Text(
                            'Ready when you are. Mark this task complete once everything is done.',
                            style: TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFCFAF2),
              border: Border(
                top: BorderSide(color: Color(0xFFEBE8DE), width: 1),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 22,
              left: 24,
              right: 24,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleCompletionToggle(task),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5D5E6),
                  foregroundColor: const Color(0xFF263F56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Text(
                  task.isCompleted
                      ? '○  Mark as pending'
                      : '✓  Mark as completed',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    color: Color(0xFF263F56),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// 9. EDIT TASK PAGE
// ===========================================================================
class EditTask extends StatefulWidget {
  final TaskItem task;

  const EditTask({super.key, required this.task});

  @override
  EditTaskState createState() => EditTaskState();
}

class EditTaskState extends State<EditTask> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dueDateController;
  late final TextEditingController _timeController;

  late String _selectedCategory;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _dueDateController = TextEditingController(text: widget.task.dueDate);
    _timeController = TextEditingController(text: widget.task.time);
    _selectedCategory = widget.task.category;
    _selectedPriority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    taskStore.updateTask(
      TaskItem(
        id: widget.task.id,
        title: title,
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _dueDateController.text.trim(),
        time: _timeController.text.trim(),
        isCompleted: widget.task.isCompleted,
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildCategoryChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: isSelected
                ? const Color(0xFFB5D5E6)
                : const Color(0xFFE3ECEF),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF263F56), fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label) {
    final bool isSelected = _selectedPriority == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = label;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: isSelected
                ? const Color(0xFF263F56)
                : const Color(0xFFE3ECEF),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFFCFAF2)
                  : const Color(0xFF263F56),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String previewDate = _dueDateController.text.trim().isNotEmpty
        ? _dueDateController.text.trim()
        : 'Month - day';
    final String previewTime = _timeController.text.trim().isNotEmpty
        ? _timeController.text.trim()
        : 'Solar Time';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      body: CustomPaint(
        painter: _DashboardBackgroundPainter(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top App Header
              Padding(
                padding: const EdgeInsets.only(
                  top: 14,
                  bottom: 12,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF263F56),
                          size: 26,
                        ),
                      ),
                    ),
                    const Text(
                      'Edit task',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        color: Color(0xFF263F56),
                        fontSize: 18.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 28, height: 28),
                  ],
                ),
              ),

              // Main Scrollable Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Page Heading & Subtitle
                      const Text(
                        'A little change of plans.',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Update the details. Keep moving forward.',
                        style: TextStyle(
                          color: Color(0xFF586E7D),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Task title
                      const Text(
                        'Task title',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFE3ECEF),
                        ),
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(
                            color: Color(0xFF263F56),
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Add a task title.',
                            hintStyle: TextStyle(
                              color: Color(0xFF4F6575),
                              fontSize: 12.5,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFE3ECEF),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          style: const TextStyle(
                            color: Color(0xFF263F56),
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Give a description on your task',
                            hintStyle: TextStyle(
                              color: Color(0xFF4F6575),
                              fontSize: 12.5,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Category
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCategoryChip('School'),
                          const SizedBox(width: 9),
                          _buildCategoryChip('Personal'),
                          const SizedBox(width: 9),
                          _buildCategoryChip('Work'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Priority level
                      const Text(
                        'Priority level',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: Color(0xFF263F56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildPriorityChip('Low'),
                          const SizedBox(width: 9),
                          _buildPriorityChip('Medium'),
                          const SizedBox(width: 9),
                          _buildPriorityChip('High'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Due date & Time
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Due date',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    color: Color(0xFF263F56),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFE3ECEF),
                                  ),
                                  child: TextField(
                                    controller: _dueDateController,
                                    onChanged: (_) => setState(() {}),
                                    style: const TextStyle(
                                      color: Color(0xFF263F56),
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Month - day - year',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF4F6575),
                                        fontSize: 12.5,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    color: Color(0xFF263F56),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFE3ECEF),
                                  ),
                                  child: TextField(
                                    controller: _timeController,
                                    onChanged: (_) => setState(() {}),
                                    style: const TextStyle(
                                      color: Color(0xFF263F56),
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Solar Time',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF4F6575),
                                        fontSize: 12.5,
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // New Deadline Preview Box
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFE8EEEF),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        width: double.infinity,
                        child: Text(
                          'New deadline: $previewDate  - $previewTime',
                          style: const TextStyle(
                            color: Color(0xFF586E7D),
                            fontSize: 11,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFAF2),
          border: Border(top: BorderSide(color: Color(0xFFEBE8DE), width: 1)),
        ),
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 22,
          left: 24,
          right: 24,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5D5E6),
              foregroundColor: const Color(0xFF263F56),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: const Text(
              'Save changes',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: Color(0xFF263F56),
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 10. DELETE TASK CONFIRMATION DIALOG
// ===========================================================================
class DeleteTaskConfirmation extends StatefulWidget {
  final TaskItem task;

  const DeleteTaskConfirmation({super.key, required this.task});

  @override
  DeleteTaskConfirmationState createState() => DeleteTaskConfirmationState();
}

class DeleteTaskConfirmationState extends State<DeleteTaskConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFFFCFAF2),
        ),
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trash Can Icon Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E4DB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFF943E3E),
                size: 22,
              ),
            ),

            const SizedBox(height: 18),

            // Dialog Title
            const Text(
              'Delete this task?',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: Color(0xFF263F56),
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            // Confirmation Message
            Text(
              '“${widget.task.title}” will be permanently removed. This can’t be undone.',
              style: const TextStyle(
                color: Color(0xFF586E7D),
                fontSize: 13,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 22),

            // Delete task Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF943E3E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Text(
                  'Delete task',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Keep task Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE3ECEF),
                  foregroundColor: const Color(0xFF263F56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Text(
                  'Keep task',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    color: Color(0xFF263F56),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// 11. TASK COMPLETED PAGE
// ===========================================================================
class TaskCompleted extends StatefulWidget {
  final String taskId;

  const TaskCompleted({super.key, required this.taskId});

  @override
  TaskCompletedState createState() => TaskCompletedState();
}

class TaskCompletedState extends State<TaskCompleted> {
  Color _priorityBgColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFF3E4DB);
      case 'Medium':
        return const Color(0xFFDFECF3);
      default:
        return const Color(0xFFE7EEF0);
    }
  }

  Color _priorityTextColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFF805233);
      case 'Medium':
        return const Color(0xFF263F56);
      default:
        return const Color(0xFF586E7D);
    }
  }

  String _progressHeadline(int completed, int total) {
    if (total > 0 && completed == total) {
      return 'All caught up.';
    }
    if (total > 0 && (completed / total) >= 0.5) {
      return 'Halfway there.';
    }
    return 'One step closer.';
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color valueColor = const Color(0xFF263F56),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF586E7D), fontSize: 12),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: taskStore,
      builder: (context, _) {
        final TaskItem? task = taskStore.getTaskById(widget.taskId);
        if (task == null) {
          return const SizedBox.shrink();
        }

        final int total = taskStore.totalCount;
        final int completed = taskStore.completedCount;
        final int pending = taskStore.pendingCount;
        final double progressRatio = total == 0 ? 1.0 : completed / total;

        final String dueDateText = task.dueDate.trim().isNotEmpty
            ? task.dueDate.trim()
            : 'Month, Day, Year';
        final String timeText = task.time.trim().isNotEmpty
            ? task.time.trim()
            : 'Solar Time';
        final String descriptionText = task.description.trim().isNotEmpty
            ? task.description.trim()
            : 'No description provided.';

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F4),
          body: CustomPaint(
            painter: _TaskCompletedBackgroundPainter(),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top App Header
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                      bottom: 12,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xFF263F56),
                              size: 26,
                            ),
                          ),
                        ),
                        const Text(
                          'Task completed',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: Color(0xFF263F56),
                            fontSize: 18.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 28, height: 28),
                      ],
                    ),
                  ),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Sage Green Celebration Banner
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: const Color(0xFFE3EDE7),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            width: double.infinity,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '✓  A little win, well earned.',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    color: Color(0xFF365F50),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Your task is now marked as completed.',
                                  style: TextStyle(
                                    color: Color(0xFF365F50),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Category & Priority Badges
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: const Color(0xFFE3ECEF),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                child: Text(
                                  task.category,
                                  style: const TextStyle(
                                    color: Color(0xFF263F56),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9),
                                  color: _priorityBgColor(task.priority),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                child: Text(
                                  task.priority,
                                  style: TextStyle(
                                    color: _priorityTextColor(task.priority),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Task Title
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.18,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Task Description
                          Text(
                            descriptionText,
                            style: const TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Details Card
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFD7E1E4),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 19,
                              vertical: 6,
                            ),
                            width: double.infinity,
                            child: Column(
                              children: [
                                _buildDetailRow('Due date', dueDateText),
                                _buildDetailRow('Time', timeText),
                                _buildDetailRow('Category', task.category),
                                _buildDetailRow(
                                  'Status',
                                  '✓  Completed',
                                  valueColor: const Color(0xFF365F50),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Progress Milestone Section
                          Text(
                            _progressHeadline(completed, total),
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$completed of $total tasks completed · $pending still pending',
                            style: const TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double fillWidth = total == 0
                                  ? constraints.maxWidth
                                  : math.max(
                                      12.0,
                                      constraints.maxWidth * progressRatio,
                                    );
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: const Color(0xFFD7E1E4),
                                ),
                                width: double.infinity,
                                height: 8,
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: const Color(0xFF527B98),
                                  ),
                                  width: fillWidth,
                                  height: 8,
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFCFAF2),
              border: Border(
                top: BorderSide(color: Color(0xFFEBE8DE), width: 1),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 22,
              left: 24,
              right: 24,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PendingTasks(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5D5E6),
                  foregroundColor: const Color(0xFF263F56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: const Text(
                  'Back to tasks',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    color: Color(0xFF263F56),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// 12. PROFILE SETTINGS PAGE
// ===========================================================================
class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  ProfileSettingsState createState() => ProfileSettingsState();
}

class ProfileSettingsState extends State<ProfileSettings> {
  late final TextEditingController _nameController;
  bool _showEmail = true;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: userStore.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _maskedEmail(String email) {
    if (email.isEmpty) return 'No email added';
    final int atIndex = email.indexOf('@');
    if (atIndex == -1) {
      if (email.length <= 2) return '•' * email.length;
      return '${email[0]}${'•' * (email.length - 1)}';
    }
    if (atIndex <= 1) {
      return '•' * email.length;
    }
    return '${email[0]}${'•' * (atIndex - 1)}${email.substring(atIndex)}';
  }

  String _maskedPassword(String password) {
    if (password.isEmpty) return '••••••••••••';
    return '•' * password.length;
  }

  void _openPendingTasks() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PendingTasks(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  void _handleSignOut() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogOut()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: userStore,
      builder: (context, _) {
        final String displayEmail = _showEmail
            ? userStore.displayEmail
            : _maskedEmail(userStore.email);
        final String displayPassword = _showPassword
            ? (userStore.password.isNotEmpty
                  ? userStore.password
                  : 'No password set')
            : _maskedPassword(userStore.password);

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9F4),
          body: CustomPaint(
            painter: _TaskCompletedBackgroundPainter(),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top App Header
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 18,
                      bottom: 12,
                      left: 24,
                      right: 24,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'TASKORA',
                        style: TextStyle(
                          color: Color(0xFF263F56),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),

                          // Page Heading & Subtitle
                          const Text(
                            'Your profile',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Your account, all in one place.',
                            style: TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Profile Summary Card
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: const Color(0xFFE7EEF0),
                            ),
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFB8D6E8),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF263F56),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userStore.displayName,
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          color: Color(0xFF263F56),
                                          fontSize: 18.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        displayEmail,
                                        style: const TextStyle(
                                          color: Color(0xFF586E7D),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Account details Section
                          const Text(
                            'Account details',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 19.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Name Field
                          const Text(
                            'Name',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              color: const Color(0xFFE7EEF0),
                            ),
                            width: double.infinity,
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                color: Color(0xFF263F56),
                                fontSize: 13,
                              ),
                              onChanged: (value) {
                                userStore.updateName(value);
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter your name',
                                hintStyle: TextStyle(
                                  color: Color(0xFF586E7D),
                                  fontSize: 13,
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Email address Field with Hide/Show
                          const Text(
                            'Email address',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              color: const Color(0xFFE7EEF0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayEmail,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF263F56),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showEmail = !_showEmail;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      _showEmail ? 'Hide' : 'Show',
                                      style: const TextStyle(
                                        color: Color(0xFF263F56),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Password Field with Show/Hide
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(17),
                              color: const Color(0xFFE7EEF0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayPassword,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF263F56),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      _showPassword ? 'Hide' : 'Show',
                                      style: const TextStyle(
                                        color: Color(0xFF263F56),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Hidden by default. Only show it in private.',
                            style: TextStyle(
                              color: Color(0xFF586E7D),
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign out Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _handleSignOut,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF263F56),
                                side: const BorderSide(
                                  color: Color(0xFFB5D5E6),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                              child: const Text(
                                'Sign out',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF263F56),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Center(
                            child: Text(
                              'You can sign back in anytime.',
                              style: TextStyle(
                                color: Color(0xFF586E7D),
                                fontSize: 11,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFCFAF2),
              border: Border(
                top: BorderSide(color: Color(0xFFEBE8DE), width: 1),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 18,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Home
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.home_outlined,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Add -> AddTask
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTask(),
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8D6E8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF263F56),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tasks -> PendingTasks
                Expanded(
                  child: GestureDetector(
                    onTap: _openPendingTasks,
                    behavior: HitTestBehavior.opaque,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Icon(
                              Icons.format_list_bulleted_rounded,
                              color: Color(0xFF263F56),
                              size: 22,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tasks',
                          style: TextStyle(
                            color: Color(0xFF4F6575),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile (Active)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 54,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8D6E8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF263F56),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Color(0xFF263F56),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ===========================================================================
// 13. LOG OUT PAGE
// ===========================================================================
class LogOut extends StatefulWidget {
  const LogOut({super.key});

  @override
  LogOutState createState() => LogOutState();
}

class LogOutState extends State<LogOut> {
  void _handleStay() {
    Navigator.pop(context);
  }

  void _handleExitApp() {
    userStore.clearAccount();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: const _WaveBackgroundPainter(showOrnaments: false),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 42),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 185),

                          // Heading
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Leaving so soon? ♡',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                color: Color(0xFF111111),
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Accent Divider Line
                          Container(
                            width: 73,
                            height: 1.5,
                            color: const Color(0xFF263F56),
                          ),

                          const SizedBox(height: 12),

                          // Encouraging Message
                          const Text(
                            "You've made progress today, bestie! Every little step counts. Come back anytime to continue your journey.",
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0xFF263F56),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              height: 1.42,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Stay ♡ Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _handleStay,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC4DEEC),
                                foregroundColor: const Color(0xFF263F56),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                              child: const Text(
                                'Stay ♡',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF263F56),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Exit App Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              onPressed: _handleExitApp,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF263F56),
                                side: const BorderSide(
                                  color: Color(0xFFB5D5E6),
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                ),
                              ),
                              child: const Text(
                                'Exit App',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  color: Color(0xFF263F56),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TaskCompletedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base off-white fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFAF9F4),
    );

    // Top soft sage-tinted curved wave behind header and banner
    final topSageWave = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.36)
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.40,
        size.width * 0.52,
        size.height * 0.22,
        0,
        size.height * 0.24,
      )
      ..close();

    canvas.drawPath(topSageWave, Paint()..color = const Color(0x88DCE6E1));

    // Bottom layered waves above bottom bar
    final wave1 = Path()
      ..moveTo(0, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.81,
        size.width * 0.48,
        size.height * 0.90,
      )
      ..lineTo(size.width, size.height * 0.94)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave1, Paint()..color = const Color(0x66C7D6DF));

    final wave2 = Path()
      ..moveTo(0, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.78,
        size.width * 0.62,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.91,
        size.width * 0.56,
        size.height * 0.94,
      )
      ..lineTo(size.width, size.height * 0.94)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave2, Paint()..color = const Color(0x66BCCCD6));

    final wave3 = Path()
      ..moveTo(size.width * 0.50, size.height * 0.94)
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.84,
        size.width,
        size.height * 0.86,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave3, Paint()..color = const Color(0x66B0C2CE));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashboardBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base off-white fill
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFAF9F4),
    );

    // Subtle mid-upper pale blue wave behind cards
    final midWave = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.24,
        size.width * 0.65,
        size.height * 0.33,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.38,
        size.width,
        size.height * 0.36,
      )
      ..lineTo(size.width, size.height * 0.43)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.44,
        size.width * 0.52,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.28,
        0,
        size.height * 0.31,
      )
      ..close();

    canvas.drawPath(midWave, Paint()..color = const Color(0x66D5E3EC));

    // Bottom layered waves above bottom navigation bar
    final wave1 = Path()
      ..moveTo(0, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.22,
        size.height * 0.81,
        size.width * 0.48,
        size.height * 0.90,
      )
      ..lineTo(size.width, size.height * 0.94)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave1, Paint()..color = const Color(0x66C7D6DF));

    final wave2 = Path()
      ..moveTo(0, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.78,
        size.width * 0.62,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.91,
        size.width * 0.56,
        size.height * 0.94,
      )
      ..lineTo(size.width, size.height * 0.94)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave2, Paint()..color = const Color(0x66BCCCD6));

    final wave3 = Path()
      ..moveTo(size.width * 0.50, size.height * 0.94)
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.84,
        size.width,
        size.height * 0.86,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave3, Paint()..color = const Color(0x66B0C2CE));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===========================================================================
// SHARED WAVE BACKGROUND PAINTER (SIGN IN / CREATE ACCOUNT / RESET PASSWORD)
// ===========================================================================
class _WaveBackgroundPainter extends CustomPainter {
  final bool showOrnaments;

  const _WaveBackgroundPainter({required this.showOrnaments});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFAF9F4),
    );

    final topWave = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.34)
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.38,
        size.width * 0.45,
        size.height * 0.21,
        0,
        size.height * 0.23,
      )
      ..close();

    canvas.drawPath(topWave, Paint()..color = const Color(0xFFD5E3EC));

    if (showOrnaments) {
      final circleCenter = Offset(size.width * 0.77, size.height * 0.13);
      canvas.drawCircle(
        circleCenter,
        36,
        Paint()
          ..color = const Color(0xFFB5C9D6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawCircle(
        circleCenter,
        24,
        Paint()
          ..color = const Color(0x88FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.drawCircle(
        Offset(circleCenter.dx + 27, circleCenter.dy - 22),
        3,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(circleCenter.dx - 42, circleCenter.dy + 36),
        2.5,
        Paint()..color = const Color(0xFFA7C0D0),
      );

      final dotPaint = Paint()..color = const Color(0xFF9EB5C4);
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          canvas.drawCircle(
            Offset(size.width * 0.76 + c * 9, size.height * 0.25 + r * 9),
            1.3,
            dotPaint,
          );
        }
      }
    }

    final wave1 = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.78,
        size.width * 0.65,
        size.height * 0.90,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.96,
        size.width,
        size.height * 0.91,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave1, Paint()..color = const Color(0x88BCCCD6));

    final wave2 = Path()
      ..moveTo(0, size.height * 0.93)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.94,
        size.width * 0.78,
        size.height * 0.86,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.83,
        size.width,
        size.height * 0.85,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave2, Paint()..color = const Color(0x99AEBFD0));

    final wave3 = Path()
      ..moveTo(0, size.height * 0.96)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.87,
        size.width * 0.75,
        size.height * 0.94,
      )
      ..lineTo(size.width, size.height * 0.97)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave3, Paint()..color = const Color(0x9999AFC0));

    final edgePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 1.05,
        colors: [Color(0x00C6D9E6), Color(0x55B8CEDC)],
        stops: [0.68, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, edgePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveBackgroundPainter oldDelegate) =>
      oldDelegate.showOrnaments != showOrnaments;
}
