enum DocumentStatus { pending, uploaded, processing, verified, rejected }

class Document {
  final String id;
  final String name;
  final String type;
  final DocumentStatus status;
  final double progress;
  final DateTime uploadedAt;
  final String? rejectionReason;

  const Document({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.progress,
    required this.uploadedAt,
    this.rejectionReason,
  });

  Document copyWith({
    DocumentStatus? status,
    double? progress,
    String? rejectionReason,
  }) {
    return Document(
      id: id,
      name: name,
      type: type,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      uploadedAt: uploadedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
