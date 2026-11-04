final class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    this.avatarLocalPath,
  });

  final String id;
  final String username;
  final String? avatarLocalPath;

  AppUser copyWith({String? avatarLocalPath}) {
    return AppUser(
      id: id,
      username: username,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
    );
  }
}
