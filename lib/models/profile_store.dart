import 'package:flutter/foundation.dart';

@immutable
class ProfileData {
  const ProfileData({
    required this.name,
    required this.pronoun,
    required this.bio,
    required this.gender,
    required this.education,
    required this.workExperience,
  });

  final String name;
  final String pronoun;
  final String bio;
  final String gender;
  final String education;
  final String workExperience;

  ProfileData copyWith({
    String? name,
    String? pronoun,
    String? bio,
    String? gender,
    String? education,
    String? workExperience,
  }) {
    return ProfileData(
      name: name ?? this.name,
      pronoun: pronoun ?? this.pronoun,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      education: education ?? this.education,
      workExperience: workExperience ?? this.workExperience,
    );
  }
}

class ProfileStore {
  static final ValueNotifier<ProfileData> data = ValueNotifier<ProfileData>(
    const ProfileData(
      name: 'TiffanyPhylicia',
      pronoun: 'Ms.',
      bio: 'Lorem Ipsum dolor sim Amet...',
      gender: 'Perempuan',
      education: 'Universitas Pelita Harapan',
      workExperience: 'Sivetsi',
    ),
  );

  static void update(ProfileData newData) {
    data.value = newData;
  }
}
