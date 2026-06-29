class CorrelationFinding {
  final String factor, symptom, strength, mechanism, evidenceLevel, description;
  const CorrelationFinding({
    required this.factor, required this.symptom, required this.strength,
    this.mechanism = '', this.evidenceLevel = 'C', required this.description,
  });
  factory CorrelationFinding.fromJson(Map<String, dynamic> j) =>
      CorrelationFinding(
        factor: j['factor'] ?? '', symptom: j['symptom'] ?? '',
        strength: j['strength'] ?? '', mechanism: j['mechanism'] ?? '',
        evidenceLevel: j['evidence_level'] ?? 'C',
        description: j['description'] ?? '',
      );
  String get strengthLabel =>
      strength == 'strong' ? '强关联' : strength == 'moderate' ? '中等' : '弱关联';
  String get evidenceLabel =>
      evidenceLevel == 'A' ? '🅰️ 高质量证据' : evidenceLevel == 'B' ? '🅱️ 中等证据' : '©️ 理论/案例';
}

class PatternFinding {
  final String pattern, description, clinicalContext, confidence;
  const PatternFinding({
    required this.pattern, required this.description,
    this.clinicalContext = '', required this.confidence,
  });
  factory PatternFinding.fromJson(Map<String, dynamic> j) => PatternFinding(
    pattern: j['pattern'] ?? '', description: j['description'] ?? '',
    clinicalContext: j['clinical_context'] ?? '', confidence: j['confidence'] ?? 'medium',
  );
  String get confidenceLabel => confidence == 'high' ? '高' : confidence == 'medium' ? '中' : '低';
}

class RiskAssessment {
  final String level, summary, suggestedDepartment, suggestedTests, urgency;
  const RiskAssessment({
    required this.level, required this.summary,
    this.suggestedDepartment = '', this.suggestedTests = '',
    required this.urgency,
  });
  factory RiskAssessment.fromJson(Map<String, dynamic> j) => RiskAssessment(
    level: j['level'] ?? 'low', summary: j['summary'] ?? '',
    suggestedDepartment: j['suggested_department'] ?? '',
    suggestedTests: j['suggested_tests'] ?? '',
    urgency: j['urgency'] ?? 'normal',
  );
}

class DoctorSummary {
  final String brief, timeline;
  final List<String> keyPoints, questionsToAsk, differentialDiagnosis;
  const DoctorSummary({
    required this.brief, required this.timeline,
    this.keyPoints = const [], this.questionsToAsk = const [],
    this.differentialDiagnosis = const [],
  });
  factory DoctorSummary.fromJson(Map<String, dynamic> j) => DoctorSummary(
    brief: j['brief'] ?? '', timeline: j['timeline'] ?? '',
    keyPoints: (j['key_points'] as List?)?.cast<String>() ?? [],
    questionsToAsk: (j['questions_to_ask'] as List?)?.cast<String>() ?? [],
    differentialDiagnosis: (j['differential_diagnosis'] as List?)?.cast<String>() ?? [],
  );
}

class AiAnalysisResult {
  final List<CorrelationFinding> correlations;
  final List<PatternFinding> patterns;
  final RiskAssessment? risk;
  final DoctorSummary? doctorSummary;
  final String modelUsed;

  const AiAnalysisResult({
    this.correlations = const [], this.patterns = const [],
    this.risk, this.doctorSummary, this.modelUsed = '',
  });

  bool get isEmpty => correlations.isEmpty && patterns.isEmpty && risk == null && doctorSummary == null;

  factory AiAnalysisResult.fromJson(Map<String, dynamic> j) => AiAnalysisResult(
    correlations: (j['correlations'] as List?)?.map((e) => CorrelationFinding.fromJson(e)).toList() ?? [],
    patterns: (j['patterns'] as List?)?.map((e) => PatternFinding.fromJson(e)).toList() ?? [],
    risk: j['risk'] != null ? RiskAssessment.fromJson(j['risk']) : null,
    doctorSummary: j['doctor_summary'] != null ? DoctorSummary.fromJson(j['doctor_summary']) : null,
    modelUsed: j['model_used'] ?? '',
  );
}
