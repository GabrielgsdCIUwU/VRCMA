import 'package:flutter_test/flutter_test.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/models/vrc_user_model.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';

void main() {
  group("VrcUserModel - Factory Mapping Tests", () {
    test("From Library should correctly map LimitedUserFriend to VrcUserModel", () {
      final apiUser = LimitedUserFriend(
        id: "user_123",
        displayName: "<><",
        bio: "Hi",
        tags: ["tag1", "tag2"],
        status: UserStatus.active,
        currentAvatarThumbnailImageUrl: "https://wiki-files.vrchat.com/VRCat.webp",
        imageUrl: "https://wiki-files.vrchat.com/VRCat.webp",
        developerType: DeveloperType.none,
        isFriend: true,
        lastLogin: DateTime.now(),
        statusDescription: '',
        userIcon: '',
        friendKey: '',
        lastActivity: null,
        lastMobile: null,
        lastPlatform: '',
        location: '',
        platform: '',
      );
      
      final model = VrcUserModel.fromLibrary(apiUser);
      
      expect(model, isA<VrcUser>());
      expect(model.id, "user_123");
      expect(model.displayName, "<><");
      expect(model.bio, "Hi");
      expect(model.tags, ["tag1", "tag2"]);
      expect(model.status, 'active');
      expect(model.avatarUrl, "https://wiki-files.vrchat.com/VRCat.webp");
    });
    
    test("fromCurrentUser should correctly map CurrentUser to VrcUserModel", () {
      final currentUser = CurrentUser(
        id: "usr_me",
        displayName: "My Self",
        bio: "I am the owner",
        tags: ["admin"],
        status: UserStatus.joinMe,
        currentAvatarImageUrl: "https://wiki-files.vrchat.com/VRCat.webp",
        //* Just ignore this.
        acceptedTOSVersion: 0, ageVerificationStatus: AgeVerificationStatus.plus18, ageVerified: true, allowAvatarCopying: false, bioLinks: [], currentAvatar: '', currentAvatarTags: [], currentAvatarThumbnailImageUrl: '', dateJoined: DateTime.now(), developerType: DeveloperType.none, emailVerified: true, friendGroupNames: [], friendKey: '', friends: [], hasBirthday: false, hasEmail: true, hasLoggedInFromClient: false, hasPendingEmail: false, homeLocation: '', isAdult: true, lastLogin: DateTime.now(), lastMobile: null, lastPlatform: '', obfuscatedEmail: '', obfuscatedPendingEmail: '', oculusId: '', pastDisplayNames: [], profilePicOverride: '', profilePicOverrideThumbnail: '', pronouns: '', pronounsHistory: [], state: UserState.active, statusDescription: '', statusFirstTime: false, statusHistory: [], steamDetails: false, steamId: '', twoFactorAuthEnabled: true, unsubscribe: false, userIcon: '', usesGeneratedPassword: false,
      );
      
      final model = VrcUserModel.fromCurrentUser(currentUser);

      expect(model.id, "usr_me");
      expect(model.displayName, "My Self");
      expect(model.status, "join me");
      expect(model.avatarUrl, "https://wiki-files.vrchat.com/VRCat.webp");
    });
  });
}