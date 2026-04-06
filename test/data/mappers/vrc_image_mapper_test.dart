import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/data/mappers/vrc_image_mapper.dart';

void main() {
  final VRCatUrl = "https://wiki-files.vrchat.com/VRCat.webp";
  final VRRatUrl = "https://wiki-files.vrchat.com/thumb/Vrrat_thumbsup.png/234px-Vrrat_thumbsup.png";
  final VRChatUrl = "https://wiki-files.vrchat.com/thumb/VRLogo.png/60px-VRLogo.png";
  
  group("VrcImageMapper - URL Resolution Logic", () {
    test("Should return profilePic when it is the only one provided", () {
      final result = VrcImageMapper.mapAvatarUrl(profilePic: VRCatUrl);
      expect(result, VRCatUrl);
    });
    
    test("Should prioritize profilePic over all other fields", () {
      final result = VrcImageMapper.mapAvatarUrl(
        profilePic: VRCatUrl,
        thumbnail: VRRatUrl,
        imageUrl: VRChatUrl
      );
      expect(result, VRCatUrl);
    });
    
    test("Should fallback to thumbnail if profilePic is null or empty", () {
      final result = VrcImageMapper.mapAvatarUrl(
        profilePic: '',
        thumbnail: VRRatUrl,
      );
      expect(result, VRRatUrl);
    });
    
    test("Should return an empty string if all inputs are null or empty", () {
      final result = VrcImageMapper.mapAvatarUrl(
        profilePic: null,
        thumbnail: '',
        currentAvatar: null,
        imageUrl: ''
      );
      expect(result, '');
    });
  });
}