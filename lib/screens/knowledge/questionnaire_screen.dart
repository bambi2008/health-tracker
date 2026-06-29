import 'package:flutter/material.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String questionnaireId;
  const QuestionnaireScreen({super.key, required this.questionnaireId});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int _currentQ = 0;
  final Map<int, dynamic> _answers = {};
  bool _finished = false;
  int _totalScore = 0;

  // 内置问卷数据
  static const _questions = [
    {
      'question': '过去两周，您是否经常感到疲劳或精力不足？',
      'type': 'scale',
      'options': ['从不', '偶尔', '有时', '经常', '几乎总是'],
      'scores': [0, 1, 2, 3, 4],
    },
    {
      'question': '您是否经常出现头痛？',
      'type': 'scale',
      'options': ['从不', '偶尔(月1-2次)', '有时(周1-2次)', '经常(每周数次)', '几乎每天'],
      'scores': [0, 1, 2, 3, 4],
    },
    {
      'question': '睡眠质量如何？（入睡困难、易醒、早醒）',
      'type': 'scale',
      'options': ['很好', '较好', '一般', '较差', '很差'],
      'scores': [0, 1, 2, 3, 4],
    },
    {
      'question': '是否经常感到身体某处莫名疼痛？',
      'type': 'scale',
      'options': ['从不', '偶尔', '有时', '经常', '几乎总是'],
      'scores': [0, 1, 2, 3, 4],
    },
    {
      'question': '消化系统是否经常不适？（腹胀、腹痛、反酸等）',
      'type': 'scale',
      'options': ['从不', '偶尔', '有时', '经常', '几乎总是'],
      'scores': [0, 1, 2, 3, 4],
    },
    {
      'question': '是否经常感到焦虑或情绪低落？',
      'type': 'scale',
      'options': ['从不', '偶尔', '有时', '经常', '几乎总是'],
      'scores': [0, 1, 2, 3, 4],
    },
    {
      'question': '您是否经常头晕或感到眩晕？',
      'type': 'scale',
      'options': ['从不', '偶尔', '有时', '经常', '几乎总是'],
      'scores': [0, 1, 2, 3, 4],
    },
    {
      'question': '皮肤是否经常出现异常？（红疹、瘙痒、干燥等）',
      'type': 'scale',
      'options': ['从不', '偶尔', '有时', '经常', '几乎总是'],
      'scores': [0, 1, 2, 3, 4],
    },
  ];

  void _answer(int score) {
    _answers[_currentQ] = score;
    if (_currentQ < _questions.length - 1) {
      setState(() => _currentQ++);
    } else {
      _totalScore = _answers.values.fold<int>(0, (a, b) => a + (b as int));
      setState(() => _finished = true);
    }
  }

  void _prev() {
    if (_currentQ > 0) setState(() => _currentQ--);
  }

  String get _resultTier {
    if (_totalScore <= 4) return 'low';
    if (_totalScore <= 12) return 'medium';
    if (_totalScore <= 20) return 'high';
    return 'urgent';
  }

  String get _resultAdvice {
    switch (_resultTier) {
      case 'low':
        return '自检结果显示您的身体状况良好，症状较少。\n\n建议保持当前的生活方式，定期体检。';
      case 'medium':
        return '自检结果显示您有一些轻微症状。\n\n建议注意作息规律、均衡饮食、适度运动，并记录症状变化。\n如果症状持续或加重，建议咨询医生。';
      case 'high':
        return '自检结果显示您有较多不适症状，可能影响日常生活。\n\n强烈建议您：\n1. 使用本 App 持续记录症状变化\n2. 近期预约医生进行全面检查\n3. 将导出的症状报告带给医生参考';
      case 'urgent':
        return '自检结果提示您可能正在经历较多的身体不适。\n\n⚠️ 请注意：\n1. 本问卷不能替代专业医疗诊断\n2. 建议尽快预约医生\n3. 持续记录症状并导出报告供医生参考\n4. 关注身体信号，不要忽视';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('症状自检')),
      body: _finished ? _buildResult() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentQ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 进度
          LinearProgressIndicator(
            value: (_currentQ) / _questions.length,
          ),
          const SizedBox(height: 8),
          Text(
            '问题 ${_currentQ + 1} / ${_questions.length}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // 问题
          Text(
            q['question'] as String,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5),
          ),
          const SizedBox(height: 32),

          // 选项
          ...List.generate(
            (q['options'] as List).length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _answer((q['scores'] as List)[i] as int),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    (q['options'] as List)[i] as String,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),
          if (_currentQ > 0)
            TextButton.icon(
              onPressed: _prev,
              icon: const Icon(Icons.arrow_back),
              label: const Text('上一题'),
            ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final color = _resultTier == 'low'
        ? Colors.green
        : _resultTier == 'medium'
            ? Colors.orange
            : _resultTier == 'high'
                ? Colors.deepOrange
                : Colors.red;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.assignment_turned_in, size: 64, color: Colors.teal),
          const SizedBox(height: 16),
          const Text('自检完成',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('得分 $_totalScore / ${_questions.length * 4}',
              style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_resultAdvice,
                  style: const TextStyle(fontSize: 16, height: 1.7)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '* 本问卷仅供参考，不能替代专业医疗诊断',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _currentQ = 0;
                _answers.clear();
                _finished = false;
                _totalScore = 0;
              });
            },
            child: const Text('重新自检'),
          ),
        ],
      ),
    );
  }
}
