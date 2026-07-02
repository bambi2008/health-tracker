import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// 语音识别 + AI 解析服务
class VoiceService {
  static const String _deepseekUrl = 'http://10.0.55.17:9000/api/v1/ai/parse-voice';

  /// 用 DeepSeek 把自然语言解析成结构化症状数据
  static Future<Map<String, dynamic>?> parseVoice(String text) async {
    try {
      final resp = await http.post(
        Uri.parse(_deepseekUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      }
      return null;
    } catch (_) {
      // 离线兜底：简单关键词匹配
      return _fallbackParse(text);
    }
  }

  /// 离线兜底解析
  static Map<String, dynamic>? _fallbackParse(String text) {
    final lower = text.toLowerCase();
    final result = <String, dynamic>{
      'body_part': 'general',
      'body_detail': 'general',
      'severity': 5,
      'description': text,
      'onset_type': 'gradual',
    };

    // 身体部位
    final parts = {
      '头': ['head', '头部整体'],
      '太阳穴': ['head', '左侧太阳穴'],
      '脖子': ['neck', '颈部'],
      '颈椎': ['neck', '颈部'],
      '肩膀': ['neck', '颈部'],
      '胸': ['chest', '胸骨/中央'],
      '心': ['chest', '心区'],
      '胃': ['abdomen', '胃区'],
      '肚子': ['abdomen', '上腹部'],
      '腰': ['back', '下背部/腰部'],
      '背': ['back', '上背部'],
      '脚': ['limb', '右脚'],
      '足底': ['limb', '右脚'],
      '膝盖': ['limb', '右膝'],
    };
    for (final e in parts.entries) {
      if (lower.contains(e.key)) {
        result['body_part'] = e.value[0];
        result['body_detail'] = e.value[1];
        break;
      }
    }

    // 严重度
    final severityPatterns = {
      r'[8-9]分|很\S{0,2}(?:严重|厉害|疼|痛)|剧烈|受不了':
          8,
      r'[6-7]分|比较\S{0,2}(?:严重|厉害|疼|痛)|明显': 6,
      r'[4-5]分|有点|稍微|一般': 4,
      r'[1-3]分|轻微|一点点|不太': 2,
    };
    for (final e in severityPatterns.entries) {
      if (RegExp(e.key).hasMatch(text)) {
        result['severity'] = e.value;
        break;
      }
    }

    // 发作类型
    if (RegExp(r'突然|一下子|猛地').hasMatch(text)) {
      result['onset_type'] = 'sudden';
    } else if (RegExp(r'一直|持续|老是|总是').hasMatch(text)) {
      result['onset_type'] = 'persistent';
    } else if (RegExp(r'一阵一阵|时好时坏|偶尔').hasMatch(text)) {
      result['onset_type'] = 'intermittent';
    }

    // 触发因素
    final triggers = <String>[];
    if (RegExp(r'熬夜|没睡|睡不好|失眠').hasMatch(text)) triggers.add('熬夜');
    if (RegExp(r'累|疲劳|加班').hasMatch(text)) triggers.add('劳累');
    if (RegExp(r'压力|焦虑|紧张|担心').hasMatch(text)) triggers.add('压力');
    if (RegExp(r'吃|喝|辣|油腻').hasMatch(text)) triggers.add('饮食');
    if (RegExp(r'看屏幕|看手机|电脑').hasMatch(text)) triggers.add('长时间看屏幕');
    result['triggers'] = triggers;

    return result;
  }
}
