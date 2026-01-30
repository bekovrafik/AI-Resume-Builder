import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'resume_model.g.dart';

@collection
class ResumeIteration {
  Id id = Isar.autoIncrement;

  @Index()
  late String resumeId; // Logical ID to group versions

  late DateTime createdAt;

  late String theme; // Enum value stored as string

  late ResumeData data;
}

@JsonSerializable(explicitToJson: true)
@embedded
class ResumeData {
  String? fullName;
  String? targetRole;
  String? summary;

  List<Experience>? experiences;
  List<Education>? education;
  List<SkillCategory>? skills;

  String? avatarUrl;
  String? email;
  String? phone;
  String? location;
  String? linkedIn;

  bool? isShortInput;
  String? rawHistory;
  String? rawSpecs;

  ResumeData({
    this.fullName,
    this.targetRole,
    this.summary,
    this.experiences,
    this.education,
    this.skills,
    this.avatarUrl,
    this.email,
    this.phone,
    this.location,
    this.linkedIn,
    this.isShortInput,
    this.rawHistory,
    this.rawSpecs,
  });

  factory ResumeData.fromJson(Map<String, dynamic> json) =>
      _$ResumeDataFromJson(json);
  Map<String, dynamic> toJson() => _$ResumeDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
@embedded
class Experience {
  String? company;
  String? role;
  String? period;
  List<String>? achievements;

  Experience({this.company, this.role, this.period, this.achievements});

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);
  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

@JsonSerializable(explicitToJson: true)
@embedded
class Education {
  String? institution;
  String? degree;
  String? period;
  String? details;

  Education({this.institution, this.degree, this.period, this.details});

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}

@JsonSerializable(explicitToJson: true)
@embedded
class SkillCategory {
  String? category; // Technical, Soft Skills, etc.
  List<String>? skills;

  SkillCategory({this.category, this.skills});

  factory SkillCategory.fromJson(Map<String, dynamic> json) =>
      _$SkillCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$SkillCategoryToJson(this);
}
