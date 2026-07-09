class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final int duration;
  final int calories;
  final int steps;
  final double? distance;
  final int? heartRate;
  final String difficulty;
  final DateTime date;
  final String notes;
  bool synced;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.duration,
    required this.calories,
    this.steps = 0,
    this.distance,
    this.heartRate,
    this.difficulty = 'Medium',
    required this.date,
    this.notes = '',
    this.synced = false,
  });

  // ── Calorie estimator (MET formula) ───────────────────────
  static int estimateCalories({
    required String type,
    required int durationMinutes,
    double weightKg = 65,
    double? distanceKm,
  }) {
    const mets = {
      'Running':           9.8,
      'Walking':           3.5,
      'Cycling':           7.5,
      'Swimming':          8.0,
      'HIIT':              10.0,
      'Gym':               5.0,
      'Strength Training': 5.0,
      'Yoga':              3.0,
      'Stretching':        2.5,
      'Other':             4.0,
    };
    final met  = mets[type] ?? 5.0;
    final cals = met * weightKg * (durationMinutes / 60.0);
    return cals.round();
  }

  // ── Steps ↔ Distance conversion ───────────────────────────
  static double stepsToDistance(int steps, String type) {
    // Different stride lengths per activity
    switch (type) {
      case 'Running':  return steps * 0.00137; // 1.37m per stride
      case 'Walking':  return steps * 0.00076; // 0.76m per step
      case 'Cycling':  return steps * 0.00300; // wheel revolution ~3m
      case 'Swimming': return steps * 0.00200; // stroke ~2m
      default:         return steps * 0.00076;
    }
  }

  static int distanceToSteps(double km, String type) {
    switch (type) {
      case 'Running':  return (km / 0.00137).round();
      case 'Walking':  return (km / 0.00076).round();
      case 'Cycling':  return (km / 0.00300).round();
      case 'Swimming': return (km / 0.00200).round();
      default:         return (km / 0.00076).round();
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'name': name, 'type': type,
    'duration': duration, 'calories': calories, 'steps': steps,
    'distance': distance, 'heartRate': heartRate,
    'difficulty': difficulty,
    'date': date.toIso8601String(),
    'notes': notes, 'synced': synced ? 1 : 0,
  };

  factory WorkoutModel.fromMap(Map<String, dynamic> m) => WorkoutModel(
    id:         m['id'] ?? '',
    userId:     m['userId'] ?? '',
    name:       m['name'] ?? m['type'] ?? '',
    type:       m['type'] ?? 'Other',
    duration:   m['duration'] ?? 0,
    calories:   m['calories'] ?? 0,
    steps:      m['steps'] ?? 0,
    distance:   m['distance']?.toDouble(),
    heartRate:  m['heartRate'],
    difficulty: m['difficulty'] ?? 'Medium',
    date:       DateTime.parse(m['date']),
    notes:      m['notes'] ?? '',
    synced:     (m['synced'] ?? 0) == 1,
  );

  Map<String, dynamic> toFirestore() => {
    'id': id, 'userId': userId, 'name': name, 'type': type,
    'duration': duration, 'calories': calories, 'steps': steps,
    'distance': distance, 'heartRate': heartRate,
    'difficulty': difficulty,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  WorkoutModel copyWith({
    String? name, String? type, int? duration, int? calories,
    int? steps, double? distance, int? heartRate,
    String? difficulty, DateTime? date, String? notes,
  }) => WorkoutModel(
    id: id, userId: userId,
    name:       name       ?? this.name,
    type:       type       ?? this.type,
    duration:   duration   ?? this.duration,
    calories:   calories   ?? this.calories,
    steps:      steps      ?? this.steps,
    distance:   distance   ?? this.distance,
    heartRate:  heartRate  ?? this.heartRate,
    difficulty: difficulty ?? this.difficulty,
    date:       date       ?? this.date,
    notes:      notes      ?? this.notes,
    synced:     synced,
  );
}

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final double height;
  final double weight;
  final int age;
  final String gender;
  final int dailyCalorieGoal;
  final int dailyStepGoal;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.height = 165,
    this.weight = 55,
    this.age    = 21,
    this.gender = 'Female',
    this.dailyCalorieGoal = 500,
    this.dailyStepGoal    = 8000,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25)   return 'Normal';
    if (bmi < 30)   return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toMap() => {
    'uid': uid, 'name': name, 'email': email,
    'photoUrl': photoUrl, 'height': height, 'weight': weight,
    'age': age, 'gender': gender,
    'dailyCalorieGoal': dailyCalorieGoal,
    'dailyStepGoal':    dailyStepGoal,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    uid:    m['uid']    ?? '',
    name:   m['name']   ?? '',
    email:  m['email']  ?? '',
    photoUrl: m['photoUrl'],
    height: (m['height'] ?? 165).toDouble(),
    weight: (m['weight'] ?? 55).toDouble(),
    age:    m['age']    ?? 21,
    gender: m['gender'] ?? 'Female',
    dailyCalorieGoal: m['dailyCalorieGoal'] ?? 500,
    dailyStepGoal:    m['dailyStepGoal']    ?? 8000,
  );

  UserProfile copyWith({
    String? name, String? photoUrl, double? height,
    double? weight, int? age, String? gender,
    int? dailyCalorieGoal, int? dailyStepGoal,
  }) => UserProfile(
    uid:    uid,
    name:   name    ?? this.name,
    email:  email,
    photoUrl: photoUrl ?? this.photoUrl,
    height: height  ?? this.height,
    weight: weight  ?? this.weight,
    age:    age     ?? this.age,
    gender: gender  ?? this.gender,
    dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
    dailyStepGoal:    dailyStepGoal    ?? this.dailyStepGoal,
  );
}