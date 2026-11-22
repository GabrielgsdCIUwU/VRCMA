import 'package:equatable/equatable.dart';

enum VrcTagCategory { admin, system, trust, language }

class VrcTag extends Equatable {
  final String id;
  final String name;
  final String description;
  final VrcTagCategory category;
  
  const VrcTag({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
  
  @override List<Object?> get props => [id, name, description, category];
  
  static const List<VrcTag> allTags = [
    // Trust Ranks
    VrcTag(id: 'system_trust_basic', name: 'New User', description: 'Blue Trust rank', category: VrcTagCategory.trust),
    VrcTag(id: 'system_trust_known', name: 'User', description: 'Green Trust rank', category: VrcTagCategory.trust),
    VrcTag(id: 'system_trust_trusted', name: 'Known User', description: 'Orange Trust rank', category: VrcTagCategory.trust),
    VrcTag(id: 'system_trust_veteran', name: 'Trusted User', description: 'Purple Trust rank', category: VrcTagCategory.trust),
    VrcTag(id: 'system_trust_legend', name: 'Veteran User', description: 'Gold Trust rank (Deprecated)', category: VrcTagCategory.trust),
    
    // System and VRC+
    VrcTag(id: 'system_supporter', name: 'VRC+ Supporter', description: 'User has an active VRC+ subscription', category: VrcTagCategory.system),
    VrcTag(id: 'system_early_adopter', name: 'Early Adopter', description: 'Bought VRC+ in December 2020', category: VrcTagCategory.system),
    VrcTag(id: 'system_world_access', name: 'World Uploader', description: 'Can upload and publish Worlds', category: VrcTagCategory.system),
    VrcTag(id: 'system_avatar_access', name: 'Avatar Uploader', description: 'Can upload and publish Avatars', category: VrcTagCategory.system),
    VrcTag(id: 'system_feedback_access', name: 'Feedback Access', description: 'User can send Feedback', category: VrcTagCategory.system),
    VrcTag(id: 'system_troll', name: 'Confirmed Troll', description: 'User is a confirmed troll', category: VrcTagCategory.system),
    VrcTag(id: 'system_probable_troll', name: 'Probable Troll', description: 'Reported multiple times', category: VrcTagCategory.system),
    
    // Admin
    VrcTag(id: 'admin_moderator', name: 'VRChat Staff', description: 'Part of the VRChat Staff team', category: VrcTagCategory.admin),
    VrcTag(id: 'admin_world_access', name: 'Admin World Access', description: 'Can upload Worlds regardless of trust', category: VrcTagCategory.admin),
    VrcTag(id: 'admin_avatar_access', name: 'Admin Avatar Access', description: 'Can upload Avatars regardless of trust', category: VrcTagCategory.admin),
    VrcTag(id: 'admin_can_grant_licenses', name: 'License Granter', description: 'Can give out licenses', category: VrcTagCategory.admin),
    VrcTag(id: 'admin_canny_access', name: 'Canny Access', description: 'Access Canny regardless of trust', category: VrcTagCategory.admin),
    VrcTag(id: 'admin_lock_tags', name: 'Tags Locked', description: 'User tags locked by system', category: VrcTagCategory.admin),
    VrcTag(id: 'admin_lock_level', name: 'Level Locked', description: 'Trust rank locked by system', category: VrcTagCategory.admin),
    VrcTag(id: 'admin_official_thumbnail', name: 'Official Thumbnail', description: 'VRChat logo replacing profile picture', category: VrcTagCategory.admin),
    VrcTag(id: 'show_mod_tag', name: 'Show Mod Tag', description: 'Shows Red Staff nameplate', category: VrcTagCategory.admin),
    
    // Languages
    VrcTag(id: 'language_afr', name: 'Afrikaans', description: 'Afrikaans', category: VrcTagCategory.language),
    VrcTag(id: 'language_ara', name: 'Arabic', description: 'العربية', category: VrcTagCategory.language),
    VrcTag(id: 'language_ase', name: 'American Sign Language', description: 'American Sign Language', category: VrcTagCategory.language),
    VrcTag(id: 'language_asf', name: 'Australian Sign Language', description: 'Auslan (Australian Sign Language)', category: VrcTagCategory.language),
    VrcTag(id: 'language_ben', name: 'Bengali', description: 'বাংলা', category: VrcTagCategory.language),
    VrcTag(id: 'language_bfi', name: 'British Sign Language', description: 'British Sign Language', category: VrcTagCategory.language),
    VrcTag(id: 'language_bul', name: 'Bulgarian', description: 'български', category: VrcTagCategory.language),
    VrcTag(id: 'language_ces', name: 'Czech', description: 'Čeština', category: VrcTagCategory.language),
    VrcTag(id: 'language_cmn', name: 'Mandarin Chinese', description: '官话', category: VrcTagCategory.language),
    VrcTag(id: 'language_cym', name: 'Welsh', description: 'Cymraeg', category: VrcTagCategory.language),
    VrcTag(id: 'language_dan', name: 'Danish', description: 'Dansk', category: VrcTagCategory.language),
    VrcTag(id: 'language_deu', name: 'German', description: 'Deutsch', category: VrcTagCategory.language),
    VrcTag(id: 'language_dse', name: 'Dutch Sign Language', description: 'Nederlandse Gebarentaal', category: VrcTagCategory.language),
    VrcTag(id: 'language_ell', name: 'Modern Greek (1453-)', description: 'Ελληνικά', category: VrcTagCategory.language),
    VrcTag(id: 'language_eng', name: 'English', description: 'English', category: VrcTagCategory.language),
    VrcTag(id: 'language_epo', name: 'Esperanto', description: 'Esperanto', category: VrcTagCategory.language),
    VrcTag(id: 'language_est', name: 'Estonian', description: 'eesti', category: VrcTagCategory.language),
    VrcTag(id: 'language_fil', name: 'Filipino', description: 'Filipino', category: VrcTagCategory.language),
    VrcTag(id: 'language_fin', name: 'Finnish', description: 'Suomi', category: VrcTagCategory.language),
    VrcTag(id: 'language_fra', name: 'French', description: 'Français', category: VrcTagCategory.language),
    VrcTag(id: 'language_fsl', name: 'French Sign Language', description: 'langue des signes française', category: VrcTagCategory.language),
    VrcTag(id: 'language_gla', name: 'Scottish Gaelic', description: 'Gàidhlig', category: VrcTagCategory.language),
    VrcTag(id: 'language_gle', name: 'Irish', description: 'Gaeilge', category: VrcTagCategory.language),
    VrcTag(id: 'language_gsg', name: 'German Sign Language', description: 'Deutsche Gebärdensprache', category: VrcTagCategory.language),
    VrcTag(id: 'language_heb', name: 'Hebrew', description: 'עברית', category: VrcTagCategory.language),
    VrcTag(id: 'language_hin', name: 'Hindi', description: 'हिन्दी', category: VrcTagCategory.language),
    VrcTag(id: 'language_hmn', name: 'Hmong', description: 'Hmoob', category: VrcTagCategory.language),
    VrcTag(id: 'language_hrv', name: 'Croatian', description: 'hrvatski', category: VrcTagCategory.language),
    VrcTag(id: 'language_hun', name: 'Hungarian', description: 'Magyar', category: VrcTagCategory.language),
    VrcTag(id: 'language_hye', name: 'Armenian', description: 'հայերեն', category: VrcTagCategory.language),
    VrcTag(id: 'language_ind', name: 'Indonesian', description: 'Bahasa Indonesia', category: VrcTagCategory.language),
    VrcTag(id: 'language_isl', name: 'Icelandic', description: 'íslenska', category: VrcTagCategory.language),
    VrcTag(id: 'language_ita', name: 'Italian', description: 'Italiano', category: VrcTagCategory.language),
    VrcTag(id: 'language_jpn', name: 'Japanese', description: '日本語', category: VrcTagCategory.language),
    VrcTag(id: 'language_jsl', name: 'Japanese Sign Language', description: '日本手話', category: VrcTagCategory.language),
    VrcTag(id: 'language_kor', name: 'Korean', description: '한국어', category: VrcTagCategory.language),
    VrcTag(id: 'language_kvk', name: 'Korean Sign Language', description: '한국 수화 언어', category: VrcTagCategory.language),
    VrcTag(id: 'language_lav', name: 'Latvian', description: 'Latviešu', category: VrcTagCategory.language),
    VrcTag(id: 'language_lit', name: 'Lithuanian', description: 'lietuvių', category: VrcTagCategory.language),
    VrcTag(id: 'language_ltz', name: 'Luxembourgish', description: 'Lëtzebuergesch', category: VrcTagCategory.language),
    VrcTag(id: 'language_mar', name: 'Marathi', description: 'मराठी', category: VrcTagCategory.language),
    VrcTag(id: 'language_mkd', name: 'Macedonian', description: 'македонски', category: VrcTagCategory.language),
    VrcTag(id: 'language_mlt', name: 'Maltese', description: 'Malti', category: VrcTagCategory.language),
    VrcTag(id: 'language_mri', name: 'Maori', description: 'Māori', category: VrcTagCategory.language),
    VrcTag(id: 'language_msa', name: 'Malay', description: 'Bahasa Melayu', category: VrcTagCategory.language),
    VrcTag(id: 'language_nld', name: 'Dutch', description: 'Nederlands', category: VrcTagCategory.language),
    VrcTag(id: 'language_nor', name: 'Norwegian', description: 'Norsk', category: VrcTagCategory.language),
    VrcTag(id: 'language_nzs', name: 'New Zealand Sign Language', description: 'New Zealand Sign Language', category: VrcTagCategory.language),
    VrcTag(id: 'language_pol', name: 'Polish', description: 'Polski', category: VrcTagCategory.language),
    VrcTag(id: 'language_por', name: 'Portuguese', description: 'Português', category: VrcTagCategory.language),
    VrcTag(id: 'language_ron', name: 'Romanian', description: 'Română', category: VrcTagCategory.language),
    VrcTag(id: 'language_rus', name: 'Russian', description: 'Русский', category: VrcTagCategory.language),
    VrcTag(id: 'language_sco', name: 'Scots', description: 'Scots', category: VrcTagCategory.language),
    VrcTag(id: 'language_slk', name: 'Slovak', description: 'slovenčina', category: VrcTagCategory.language),
    VrcTag(id: 'language_slv', name: 'Slovenian', description: 'slovenščina', category: VrcTagCategory.language),
    VrcTag(id: 'language_spa', name: 'Spanish', description: 'Español', category: VrcTagCategory.language),
    VrcTag(id: 'language_swe', name: 'Swedish', description: 'Svenska', category: VrcTagCategory.language),
    VrcTag(id: 'language_tel', name: 'Telugu', description: 'తెలుగు', category: VrcTagCategory.language),
    VrcTag(id: 'language_tha', name: 'Thai', description: 'ภาษาไทย', category: VrcTagCategory.language),
    VrcTag(id: 'language_tok', name: 'Toki Pona', description: 'toki pona', category: VrcTagCategory.language),
    VrcTag(id: 'language_tur', name: 'Turkish', description: 'Türkçe', category: VrcTagCategory.language),
    VrcTag(id: 'language_tws', name: 'Tio-Sua', description: '潮州話', category: VrcTagCategory.language),
    VrcTag(id: 'language_ukr', name: 'Ukrainian', description: 'украї́нська', category: VrcTagCategory.language),
    VrcTag(id: 'language_vie', name: 'Vietnamese', description: 'Tiếng Việt', category: VrcTagCategory.language),
    VrcTag(id: 'language_wuu', name: 'Wu Chinese', description: '吳語', category: VrcTagCategory.language),
    VrcTag(id: 'language_yue', name: 'Yue Chinese', description: '廣東話', category: VrcTagCategory.language),
    VrcTag(id: 'language_zho', name: 'Chinese', description: '中文', category: VrcTagCategory.language),
    VrcTag(id: 'language_zxx', name: 'No linguistic content', description: 'No linguistic content', category: VrcTagCategory.language),
  ];
}