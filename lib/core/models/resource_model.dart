class ResourceModel {
  const ResourceModel({
    required this.id,
    required this.title,
    required this.thematic,
    required this.format,
    required this.description,
    required this.level,
    required this.content,
    required this.validation,
    this.author,
    this.source,
    this.isInstitutional = false,
  });

  final String id;
  final String title;
  final String thematic;
  final String format;
  final String description;
  final String level;
  final String content;
  final String validation;
  final String? author;
  final String? source;
  final bool isInstitutional;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'thematic': thematic,
      'format': format,
      'description': description,
      'level': level,
      'content': content,
      'validation': validation,
      'author': author,
      'source': source,
      'isInstitutional': isInstitutional,
    };
  }

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'] as String,
      title: map['title'] as String,
      thematic: map['thematic'] as String,
      format: map['format'] as String,
      description: map['description'] as String,
      level: map['level'] as String,
      content: map['content'] as String,
      validation: map['validation'] as String,
      author: map['author'] as String?,
      source: map['source'] as String?,
      isInstitutional: map['isInstitutional'] as bool? ?? false,
    );
  }
}
