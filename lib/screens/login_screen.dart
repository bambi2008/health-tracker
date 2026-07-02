import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegister = false;
  final _phoneCtrl = TextEditingController(text: '13800138000');
  final _pwdCtrl = TextEditingController(text: '123456');
  final _nameCtrl = TextEditingController(text: '李姐');
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose(); _pwdCtrl.dispose(); _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneCtrl.text.trim();
    final pwd = _pwdCtrl.text;
    if (phone.isEmpty || pwd.isEmpty) {
      setState(() => _error = '请填写手机号和密码');
      return;
    }

    final prov = context.read<AuthProvider>();
    try {
      if (_isRegister) {
        await prov.register(phone, pwd, _nameCtrl.text.trim());
      } else {
        await prov.login(phone, pwd);
      }
      if (mounted) context.go('/symptoms');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.healing, size: 40, color: Color(0xFF6B9080)),
              ),
              const SizedBox(height: 24),
              Text(_isRegister ? '创建账号' : '欢迎回来',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(_isRegister ? '开始记录你的健康之旅' : '登录以同步你的健康数据',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
              const SizedBox(height: 32),

              if (_isRegister)
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: '昵称', hintText: '让大家怎么称呼你'),
                ),
              if (_isRegister) const SizedBox(height: 16),

              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '手机号', hintText: '输入11位手机号'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwdCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: _isRegister ? '6位以上密码' : '输入密码',
                ),
                onSubmitted: (_) => _submit(),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: prov.loading ? null : _submit,
                  child: prov.loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isRegister ? '注册' : '登录'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() { _isRegister = !_isRegister; _error = null; }),
                child: Text(_isRegister ? '已有账号？登录' : '没有账号？注册'),
              ),

              // 跳过登录
              TextButton(
                onPressed: () => context.go('/symptoms'),
                child: Text('先看看，稍后登录', style: TextStyle(color: Colors.grey.shade400)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
