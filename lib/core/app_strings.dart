import '../main.dart'; // Global languageManager'a erişim için

class AppStrings {
  // O anki dil kodunu al (tr veya en)
  static String get lang => languageManager.locale.languageCode;

  // --- GENEL BUTONLAR & UYARILAR ---
  static String get ok => lang == 'tr' ? "Tamam" : "OK";
  static String get cancel => lang == 'tr' ? "Vazgeç" : "Cancel";
  static String get save => lang == 'tr' ? "Kaydet" : "Save";
  static String get error => lang == 'tr' ? "Hata" : "Error";
  static String get success => lang == 'tr' ? "Başarılı" : "Success";
  static String get loading => lang == 'tr' ? "Yükleniyor..." : "Loading...";

  // --- AUTH (GİRİŞ/KAYIT) ---
  static String get login => lang == 'tr' ? "Giriş Yap" : "Login";
  static String get register => lang == 'tr' ? "Kayıt Ol" : "Register";
  static String get email => lang == 'tr' ? "E-posta" : "Email";
  static String get password => lang == 'tr' ? "Şifre" : "Password";
  static String get forgotPassword => lang == 'tr' ? "Şifremi Unuttum" : "Forgot Password";

  // --- AYARLAR (SETTINGS) ---
  static String get settings => lang == 'tr' ? "Ayarlar" : "Settings";
  static String get theme => lang == 'tr' ? "Tema" : "Theme";
  static String get language => lang == 'tr' ? "Dil" : "Language";
  static String get notifications => lang == 'tr' ? "Bildirimler" : "Notifications";
  static String get account => lang == 'tr' ? "Hesap" : "Account";
  static String get signOut => lang == 'tr' ? "Çıkış Yap" : "Sign Out";
  static String get deleteAccount => lang == 'tr' ? "Hesabı Sil" : "Delete Account";

  // --- PROFİL ---
  static String get profile => lang == 'tr' ? "Profil" : "Profile";
  static String get editProfile => lang == 'tr' ? "Profili Düzenle" : "Edit Profile";
  static String get followers => lang == 'tr' ? "Takipçi" : "Followers";
  static String get following => lang == 'tr' ? "Takip" : "Following";

  // --- GRUP / SOHBET ---
  static String get activeMembers => lang == 'tr' ? "Aktif Üyeler" : "Active Members";
  static String get groupDataError => lang == 'tr' ? "Grup verisi yüklenemedi." : "Failed to load group data.";
  static String get noMembers => lang == 'tr' ? "Henüz kimse yok. " : "No members yet. ";
  static String get you => lang == 'tr' ? "(Sen)" : "(You)";

// --- ANONİM MOD (POPUP) ---
  static String get close => lang == 'tr' ? "Kapat" : "Close";
  static String get invisibleMode => lang == 'tr' ? "Görünmez Mod" : "Invisible Mode";
  static String get liveMode => lang == 'tr' ? "Canlı Mod" : "Live Mode";
  static String get youAreHidden => lang == 'tr' ? "Şu an Gizlisin" : "You are Hidden";
  static String get everyoneSeesYou => lang == 'tr' ? "Herkes Seni Görüyor" : "Everyone Sees You";
  
  static String get ghostDesc => lang == 'tr' 
      ? "Haritada hayalet gibisin. \nKimse konumunu göremez ama sen herkesi izleyebilirsin." 
      : "You are like a ghost on the map. \nNo one can see your location, but you can watch everyone.";
  
  static String get liveDesc => lang == 'tr' 
      ? "Profilin ve konumun haritada aktif. \nArkadaşların nerede olduğunu görebilir." 
      : "Your profile and location are active. \nYour friends can see where you are.";
  
  static String get goVisible => lang == 'tr' ? "Görünür Ol" : "Go Visible";
  static String get goHidden => lang == 'tr' ? "Gizlen" : "Go Ghost";

// --- CHECK-IN / VENUE ---
  static String get checkIn => lang == 'tr' ? "Check-in Yap" : "Check-in";
  static String get checkInSuccess => lang == 'tr' ? "Giriş yapıldı! Sohbet açılıyor..." : "Checked in! Opening chat...";
  static String get checkInError => lang == 'tr' ? "Check-in yapılamadı." : "Check-in failed.";

// --- MEKAN DETAY (VENUE STATS) ---
  static String get rating => lang == 'tr' ? "Puan" : "Rating";
  static String get reviews => lang == 'tr' ? "Yorum" : "Reviews";
  static String get price => lang == 'tr' ? "Fiyat" : "Price";
  static String get status => lang == 'tr' ? "Durum" : "Status";
  static String get open => lang == 'tr' ? "Açık" : "Open";
  static String get closed => lang == 'tr' ? "Kapalı" : "Closed";
  
  static String get visits => lang == 'tr' ? "Ziyaret" : "Visits";
  static String get photos => lang == 'tr' ? "Fotoğraf" : "Photos";
  static String get likes => lang == 'tr' ? "Beğeni" : "Likes";
  
  static String get serviceSpeed => lang == 'tr' ? "Servis Hızı" : "Service Speed";
  static String get cleanliness => lang == 'tr' ? "Temizlik" : "Cleanliness";
  static String get taste => lang == 'tr' ? "Lezzet" : "Taste";
  static String get pricePerf => lang == 'tr' ? "Fiyat/Performans" : "Value";
  
  static String get menu => lang == 'tr' ? "Menü" : "Menu";

// --- FEED & STORY ---
  static String get justNow => lang == 'tr' ? "Az önce" : "Just now";
  static String get minAgo => lang == 'tr' ? "dk önce" : "m ago";
  static String get hourAgo => lang == 'tr' ? "saat önce" : "h ago";
  static String get dayAgo => lang == 'tr' ? "gün önce" : "d ago";
  
  static String get yourStory => lang == 'tr' ? "Hikayen" : "Your Story";
  static String get user => lang == 'tr' ? "Kullanıcı" : "User";
  
  static String get checkedInAction => lang == 'tr' ? "burada check-in yaptı:" : "checked in at:";
  static String get reviewedAction => lang == 'tr' ? "mekanı değerlendirdi:" : "reviewed the place:";
  static String get noComment => lang == 'tr' ? "Yorum yok." : "No comment.";
  static String get location => lang == 'tr' ? "Konum" : "Location";

// --- ARAMA KARTLARI ---
  static String get add => lang == 'tr' ? "Ekle" : "Add";

// --- ARKADAŞ PROFİLİ ---
  static String get friendAdded => lang == 'tr' ? "Arkadaş eklendi! " : "Friend added! ";
  static String get friendRemoved => lang == 'tr' ? "Arkadaşlardan çıkarıldı." : "Removed from friends.";
  static String get mutualHistory => lang == 'tr' ? "Bizim Geçmişimiz" : "Our History";
  static String get theirFrequentPlaces => lang == 'tr' ? "Sık Uğradığı Yerler" : "Frequent Places";
  static String get theirFavorites => lang == 'tr' ? "Favori Mekanları" : "Favorite Places";
  static String get theirNotes => lang == 'tr' ? "Notları" : "Notes";
  static String get theirSurveys => lang == 'tr' ? "Değerlendirmeler" : "Reviews";
  static String get activity => lang == 'tr' ? "Aktivite" : "Activity";
  static String get gallery => lang == 'tr' ? "Galeri" : "Gallery";
  static String get noActivity => lang == 'tr' ? "Hareket Yok" : "No Activity";
  static String get noActivityDesc => lang == 'tr' ? "Henüz bir aktivite paylaşmamış." : "No activity shared yet.";
  static String get galleryEmpty => lang == 'tr' ? "Galeri Boş" : "Gallery Empty";
  static String get galleryEmptyDesc => lang == 'tr' ? "Paylaşımlarda fotoğraf bulunamadı." : "No photos found in posts.";
  static String get userNotFound => lang == 'tr' ? "Kullanıcı bulunamadı." : "User not found.";

// --- AKIŞ (FEED) ---
  static String get appName => "neer"; // Marka adı küçük harfle
  static String get noPostsYet => lang == 'tr' ? "Henüz hiç gönderi yok." : "No posts yet.";
  static String get startCheckingIn => lang == 'tr' ? "Bir mekana gidip check-in yapmaya ne dersin? " : "How about checking in at a place? ";

// --- PROFİL DÜZENLEME ---
  static String get editProfileTitle => lang == 'tr' ? "Profili Düzenle" : "Edit Profile";
  static String get personalInfo => lang == 'tr' ? "Kişisel Bilgiler" : "Personal Info";
  static String get fullName => lang == 'tr' ? "Ad Soyad" : "Full Name";
  static String get username => lang == 'tr' ? "Kullanıcı Adı" : "Username";
  static String get bio => lang == 'tr' ? "Biyografi" : "Bio";
  static String get profileUpdated => lang == 'tr' ? "Profil başarıyla güncellendi! ✅" : "Profile updated successfully! ✅";
  static String get pickFromGallery => lang == 'tr' ? "Galeriden Seç" : "Pick from Gallery";
  static String get takePhoto => lang == 'tr' ? "Fotoğraf Çek" : "Take Photo";
  static String get emptyFieldsError => lang == 'tr' ? "İsim ve Kullanıcı Adı boş olamaz." : "Name and Username cannot be empty.";

// --- SOHBET DETAY ---
  static String get online => lang == 'tr' ? "Çevrimiçi" : "Online";

// --- NAVİGASYON ---
  static String get navProfile => lang == 'tr' ? "Profil" : "Profile";
  static String get navChat => lang == 'tr' ? "Sohbet" : "Chat";
  static String get navMap => lang == 'tr' ? "Harita" : "Map";
  static String get navFeed => lang == 'tr' ? "Akış" : "Feed";
  static String get navFriends => lang == 'tr' ? "Arkadaş" : "Friends";

// --- MESAJLAR (CHAT LIST) ---
  static String get messagesTitle => lang == 'tr' ? "Mesajlar" : "Messages";
  static String get searchChatsHint => lang == 'tr' ? "Sohbetlerde ara..." : "Search chats...";
  static String get chatsTab => lang == 'tr' ? "Sohbetler" : "Chats";
  static String get placesTab => lang == 'tr' ? "Mekanlar" : "Places";
  
  static String get noMessages => lang == 'tr' ? "Henüz mesajın yok." : "No messages yet.";
  static String get noChatFound => lang == 'tr' ? "Sohbet bulunamadı." : "No chat found.";
  static String get noCheckins => lang == 'tr' ? "Hiçbir mekanda check-in yapmadın." : "You haven't checked in anywhere.";
  
  static String get leaveVenue => lang == 'tr' ? "Mekandan Ayrıl" : "Leave Venue";
  static String get deleteChat => lang == 'tr' ? "Sohbeti Sil" : "Delete Chat";
  static String get delete => lang == 'tr' ? "Sil" : "Delete";
  
  static String get leaveGroupConfirm => lang == 'tr' ? "grubundan çıkmak istediğine emin misin?" : "Are you sure you want to leave this group?";
  static String get deleteChatConfirm => lang == 'tr' ? "ile olan sohbetini silmek istediğine emin misin?" : "Are you sure you want to delete this chat?";

// --- ŞİFRE DEĞİŞTİRME ---
  static String get changePasswordTitle => lang == 'tr' ? "Şifre Değiştir" : "Change Password";
  static String get currentPassword => lang == 'tr' ? "Mevcut Şifre" : "Current Password";
  static String get newPassword => lang == 'tr' ? "Yeni Şifre" : "New Password";
  static String get confirmPassword => lang == 'tr' ? "Yeni Şifre (Tekrar)" : "Confirm New Password";
  static String get updatePasswordBtn => lang == 'tr' ? "Şifreyi Güncelle" : "Update Password";
  static String get passwordUpdated => lang == 'tr' ? "Şifren başarıyla güncellendi! " : "Password updated successfully! ";
  static String get passwordInfo => lang == 'tr' 
      ? "Güvenliğiniz için mevcut şifrenizi doğruladıktan sonra yeni şifrenizi belirleyebilirsiniz." 
      : "For your security, verify your current password before setting a new one.";
  
  // Hata Mesajları
  static String get errorWrongPassword => lang == 'tr' ? "Mevcut şifrenizi yanlış girdiniz." : "Incorrect current password.";
  static String get errorWeakPassword => lang == 'tr' ? "Yeni şifre çok zayıf. En az 6 karakter olmalı." : "Password too weak. Must be 6+ chars.";
  static String get errorMismatch => lang == 'tr' ? "Şifreler uyuşmuyor" : "Passwords do not match";
  static String get enterCurrentPass => lang == 'tr' ? "Mevcut şifreni girmelisin" : "Please enter current password";

// --- MEKAN PROFİLİ ---
  static String get overview => lang == 'tr' ? "Genel Bakış" : "Overview";
  static String get mediaGallery => lang == 'tr' ? "Medya Galeri" : "Media Gallery";
  static String get popular => lang == 'tr' ? "POPÜLER" : "POPULAR";
  static String get upcomingEvents => lang == 'tr' ? "Yaklaşan Etkinlikler" : "Upcoming Events";
  static String get historyWithPlace => lang == 'tr' ? "Mekanla Geçmişin" : "Your History";
  static String get regulars => lang == 'tr' ? "Mekanın Müdavimleri" : "Regulars";
  static String get friendsSay => lang == 'tr' ? "Arkadaşların Ne Diyor?" : "What Friends Say";
  static String get detailedRatings => lang == 'tr' ? "Detaylı Puanlar" : "Detailed Ratings";
  static String get reportIssue => lang == 'tr' ? "Hatalı Bilgi Bildir" : "Report Issue";
  static String get businessPhotos => lang == 'tr' ? "İşletme Fotoğrafları" : "Business Photos";
  static String get userPhotos => lang == 'tr' ? "Kullanıcı Fotoğrafları" : "User Photos";

// --- PROFİL BAŞLIĞI ---
  static String get defaultLevel => lang == 'tr' ? "Seviye 1: Yeni Üye" : "Level 1: New Member";

// --- ENGELLENENLER ---
  static String get blockedUsersTitle => lang == 'tr' ? "Engellenenler" : "Blocked Users";
  static String get unblockUser => lang == 'tr' ? "Engeli Kaldır" : "Unblock";
  static String get unblockConfirm => lang == 'tr' ? "kullanıcısının engeli kaldırılsın mı?" : "Unblock this user?";
  static String get unblockedSuccess => lang == 'tr' ? "kullanıcısının engeli kaldırıldı. 🔓" : "User unblocked. ";
  static String get noBlockedUsers => lang == 'tr' ? "Engellenen kimse yok" : "No blocked users";
  static String get listClean => lang == 'tr' ? "Listen temiz görünüyor! " : "Your list is clean! ";

// --- HESAP BİLGİLERİ ---
  static String get accountInfoTitle => lang == 'tr' ? "Hesap Bilgileri" : "Account Info";
  static String get contactInfo => lang == 'tr' ? "İLETİŞİM BİLGİLERİ" : "CONTACT INFO";
  static String get emailAddress => lang == 'tr' ? "E-posta Adresi" : "Email Address";
  static String get phoneNumber => lang == 'tr' ? "Telefon Numarası" : "Phone Number";
  static String get emailChangeWarning => lang == 'tr' 
      ? "E-posta adresinizi değiştirdiğinizde, güvenliğiniz için yeni adresinize bir doğrulama bağlantısı gönderilecektir." 
      : "When you change your email address, a verification link will be sent to your new address for your security.";
  static String get saveChanges => lang == 'tr' ? "Değişiklikleri Kaydet" : "Save Changes";
  static String get infoUpdated => lang == 'tr' ? "Bilgiler başarıyla güncellendi! " : "Info updated successfully! ";
  static String get reLoginRequired => lang == 'tr' ? "Güvenlik nedeniyle e-posta değişimi için tekrar giriş yapmalısınız." : "For security reasons, you must log in again to change email.";

// --- BİLDİRİMLER ---
  static String get notificationsTitle => lang == 'tr' ? "Bildirimler" : "Notifications";
  static String get clearAll => lang == 'tr' ? "Tümünü Sil" : "Clear All";
  static String get generalSection => lang == 'tr' ? "GENEL" : "GENERAL";
  static String get noNotifications => lang == 'tr' ? "Hiç bildirim yok" : "No notifications";
  static String get allQuiet => lang == 'tr' ? "Şu an için her şey sakin görünüyor." : "It looks quiet for now.";

// --- KAYIT EKRANI ---
  static String get registerTitle => lang == 'tr' ? "Kayıt Ol" : "Sign Up"; // Hem başlık hem buton için kullanılabilir
  static String get joinUs => lang == 'tr' ? "Hemen Aramıza Katıl!" : "Join Us Now!";
  static String get createAccountSubtitle => lang == 'tr' ? "Yeni bir hesap oluşturarak keşfetmeye başla." : "Create a new account to start exploring.";
  static String get haveAccount => lang == 'tr' ? "Zaten hesabın var mı?" : "Already have an account?";

// --- AYARLAR ---
  static String get settingsTitle => lang == 'tr' ? "Ayarlar" : "Settings";
  
  // Bölüm Başlıkları
  static String get accountSecurity => lang == 'tr' ? "HESAP & GÜVENLİK" : "ACCOUNT & SECURITY";
  static String get appAppearance => lang == 'tr' ? "UYGULAMA & GÖRÜNÜM" : "APP & APPEARANCE";
  static String get privacyData => lang == 'tr' ? "GİZLİLİK & VERİ" : "PRIVACY & DATA";
  static String get support => lang == 'tr' ? "DESTEK" : "SUPPORT";
  static String get session => lang == 'tr' ? "OTURUM" : "SESSION";
  
  // Seçenekler
  static String get accountInfo => lang == 'tr' ? "Hesap Bilgileri" : "Account Info";
  static String get passwordSecurity => lang == 'tr' ? "Şifre ve Güvenlik" : "Password & Security";
  static String get linkedAccounts => lang == 'tr' ? "Bağlı Hesaplar" : "Linked Accounts";
  static String get goPremiumBtn => lang == 'tr' ? "Neer Premium'a Geç" : "Get Neer Premium";
  static String get unlimitedFeatures => lang == 'tr' ? "Sınırsız özellikler." : "Unlimited features.";
  static String get upgrade => lang == 'tr' ? "YÜKSELT" : "UPGRADE";
  
  
  static String get anonymousMode => lang == 'tr' ? "Anonim Mod" : "Anonymous Mode";
  static String get hideLastSeen => lang == 'tr' ? "Son Görülmeyi Gizle" : "Hide Last Seen";
  static String get blockedUsers => lang == 'tr' ? "Engellenenler" : "Blocked Users";
  static String get dataSaver => lang == 'tr' ? "Düşük Veri Modu" : "Data Saver";
  static String get downloadData => lang == 'tr' ? "Verilerimi İndir" : "Download My Data";
  static String get chatBackup => lang == 'tr' ? "Sohbet Yedeği" : "Chat Backup";
  
  static String get helpCenter => lang == 'tr' ? "Yardım Merkezi" : "Help Center";
  static String get contactUs => lang == 'tr' ? "Bize Ulaşın" : "Contact Us";
  static String get rateApp => lang == 'tr' ? "Uygulamayı Puanla" : "Rate App";
  
// --- AUTH SERVİS MESAJLARI ---
  static String get wrongPassword => lang == 'tr' ? "Hatalı şifre." : "Wrong password.";
  static String get invalidCredential => lang == 'tr' ? "Bilgiler hatalı." : "Invalid credentials.";
  static String get loginFailed => lang == 'tr' ? "Giriş başarısız:" : "Login failed:";
  
  static String get weakPassword => lang == 'tr' ? "Şifre çok zayıf." : "Password too weak.";
  static String get emailInUse => lang == 'tr' ? "Bu e-posta zaten kullanılıyor." : "Email already in use.";
  static String get invalidEmail => lang == 'tr' ? "Geçersiz e-posta formatı." : "Invalid email format.";
  static String get registrationFailed => lang == 'tr' ? "Kayıt başarısız:" : "Registration failed:";
  
  static String get defaultBio => lang == 'tr' ? "Merhaba, ben Neer kullanıyorum! " : "Hello, I'm using Neer! ";
  static String get resetEmailFailed => lang == 'tr' ? "Sıfırlama e-postası gönderilemedi." : "Could not send reset email.";
  
  // Genel Hata
  static String get unknownError => lang == 'tr' ? "Bir hata oluştu." : "An error occurred.";

  // Diyaloglar ve Mesajlar
  static String get themeSelection => lang == 'tr' ? "Tema Seçimi" : "Theme Selection";
  static String get systemTheme => lang == 'tr' ? "Sistem Teması" : "System Theme";
  static String get lightMode => lang == 'tr' ? "Aydınlık Mod" : "Light Mode";
  static String get darkMode => lang == 'tr' ? "Karanlık Mod" : "Dark Mode";
  
  static String get languageSelection => lang == 'tr' ? "Dil Seçimi" : "Language Selection";
  
  static String get signOutConfirm => lang == 'tr' ? "Hesabından çıkış yapmak istiyor musun?" : "Do you want to sign out?";
  static String get deleteAccountConfirm => lang == 'tr' ? "DİKKAT: Hesabın ve tüm verilerin kalıcı olarak silinecek!" : "WARNING: Your account and all data will be permanently deleted!";
  static String get confirm => lang == 'tr' ? "Onayla" : "Confirm";
  
  static String get dataPreparing => lang == 'tr' ? "Verileriniz hazırlanıyor. E-posta alacaksınız." : "Preparing your data. You will receive an email.";
  static String get backingUp => lang == 'tr' ? "Sohbet geçmişi buluta yedekleniyor..." : "Backing up chat history to cloud...";

// --- PROFİL EKRANI ---
  static String get profileTab => lang == 'tr' ? "Profil" : "Profile";
  static String get activityTab => lang == 'tr' ? "Aktivite" : "Activity";
  static String get galleryTab => lang == 'tr' ? "Galeri" : "Gallery";
  
  static String get questsTitle => lang == 'tr' ? "Görevler" : "Quests";
  static String get allQuests => lang == 'tr' ? "Tüm Görevler" : "All Quests";
  static String get noQuests => lang == 'tr' ? "Görev Yok" : "No Quests";
  static String get noQuestsDesc => lang == 'tr' ? "Henüz aktif bir görevin bulunmuyor." : "No active quests yet.";
  
  static String get favoritesTitle => lang == 'tr' ? "Favori Mekanlar" : "Favorite Places";
  static String get myFavoritesTitle => lang == 'tr' ? "Favori Mekanlarım" : "My Favorite Places";
  static String get noFavorites => lang == 'tr' ? "Favori Yok" : "No Favorites";
  static String get noFavoritesDesc => lang == 'tr' ? "Henüz favori mekanın yok." : "No favorite places yet.";
  
  static String get frequentPlacesTitle => lang == 'tr' ? "Sık Uğradıklarım" : "Frequent Places";
  static String get visitHistory => lang == 'tr' ? "Ziyaret Geçmişi" : "Visit History";
  static String get noVisitData => lang == 'tr' ? "Henüz ziyaret verisi yok." : "No visit data yet.";
  
  static String get myNotes => lang == 'tr' ? "Notlarım" : "My Notes";
  static String get notebookTitle => lang == 'tr' ? "Not Defterim" : "My Notebook";
  static String get notebookEmpty => lang == 'tr' ? "Not Defteri Boş" : "Notebook Empty";
  static String get notebookEmptyDesc => lang == 'tr' ? "Anketlerden gelen notlar burada toplanır." : "Notes from surveys appear here.";
  
  static String get surveyHistoryTitle => lang == 'tr' ? "Değerlendirme Geçmişi" : "Review History";
  static String get noSurveys => lang == 'tr' ? "Değerlendirme Yok" : "No Reviews";
  static String get noSurveysDesc => lang == 'tr' ? "Henüz bir değerlendirme yapmadın." : "You haven't reviewed any places yet.";
  
  static String get noActivityUser => lang == 'tr' ? "Henüz bir aktivite paylaşmadın." : "You haven't shared any activity yet.";
  static String get galleryEmptyUser => lang == 'tr' ? "Paylaşımlarındaki fotoğraflar burada görünür." : "Photos from your posts appear here.";

// --- PREMIUM ---
  static String get premiumTitle => "NEER PREMIUM";
  static String get premiumSlogan => lang == 'tr' ? "Sınırları kaldır. Sosyalleşmenin zirvesine çık." : "Remove limits. Reach the peak of socializing.";
  static String get ghostMode => lang == 'tr' ? "Hayalet Modu " : "Ghost Mode ";
  static String get ghostModeDesc => lang == 'tr' ? "Tamamen görünmez ol! Haritada dilediğin gibi gez." : "Go completely invisible! Roam the map freely.";
  static String get stalkDetector => lang == 'tr' ? "Stalk Dedektörü " : "Stalk Detector ";
  static String get stalkDetectorDesc => lang == 'tr' ? "Profiline kim baktı? Seni gizlice inceleyenleri yakala." : "Who viewed your profile? Catch your secret admirers.";
  static String get unlimited => lang == 'tr' ? "Sınırsız Özgürlük " : "Unlimited Freedom ";
  static String get unlimitedDesc => lang == 'tr' ? "Günlük check-in ve mesaj sınırlarına takılma." : "No daily limits on check-ins or messages.";
  static String get goldBadge => lang == 'tr' ? "Gold Rozet " : "Gold Badge ";
  static String get goldBadgeDesc => lang == 'tr' ? "Profilinde parlayan Gold Üye rozeti ile fark yarat." : "Stand out with a shiny Gold Member badge.";
  static String get monthlyPlan => lang == 'tr' ? "AYLIK PLAN" : "MONTHLY PLAN";
  static String get yearlyPlan => lang == 'tr' ? "YILLIK PLAN" : "YEARLY PLAN";
  static String get mostPopular => lang == 'tr' ? "EN POPÜLER" : "MOST POPULAR";
  static String get cancelAnytime => lang == 'tr' ? "İstediğin zaman iptal et." : "Cancel anytime.";
  static String get payOnce => lang == 'tr' ? "Tek seferde ödenir." : "Billed once.";
  static String get goPremium => lang == 'tr' ? "PREMIUM'A GEÇ" : "GO PREMIUM";
  static String get legalText => lang == 'tr' ? "Abonelik, iptal edilmediği sürece otomatik yenilenir. Gizlilik Politikası geçerlidir." : "Subscription auto-renews unless canceled. Privacy Policy applies.";

// --- DEĞERLENDİRMELER EKRANI ---
  static String get reviewsTitle => lang == 'tr' ? "Değerlendirmeler" : "Reviews";
  static String get pendingTab => lang == 'tr' ? "Bekleyenler" : "Pending";
  static String get historyTab => lang == 'tr' ? "Geçmiş" : "History";
  static String get listEmpty => lang == 'tr' ? "Liste boş." : "List is empty.";

// --- GİRİŞ EKRANI ---
  static String get loginTitle => lang == 'tr' ? "Giriş Yap" : "Log In";
  static String get loginSubtitle => lang == 'tr' ? "Hesabınıza erişmek için bilgilerinizi girin." : "Enter your details to access your account.";
  static String get slogan => lang == 'tr' ? "Keşfet, Buluş, Sosyalleş" : "Explore, Meet, Socialize";
  static String get emailHint => lang == 'tr' ? "E-posta Adresi" : "Email Address";
  static String get passwordHint => lang == 'tr' ? "Şifre" : "Password";
  static String get noAccount => lang == 'tr' ? "Hesabın yok mu?" : "Don't have an account?";
  static String get signUp => lang == 'tr' ? "Kayıt Ol" : "Sign Up";
  static String get fillAllFields => lang == 'tr' ? "Lütfen tüm alanları doldurun." : "Please fill in all fields.";

// --- HARİTA ---
  static String get mapLocationPermission => lang == 'tr' ? "Lütfen konum servisini açınız." : "Please enable location services.";
  static String get searchModalTitle => lang == 'tr' ? "Arama" : "Search";

// --- GİRİŞ YÖNTEMLERİ ---
  static String get loginMethodsTitle => lang == 'tr' ? "Giriş Yöntemleri" : "Login Methods";
  static String get linkAccounts => lang == 'tr' ? "Hesaplarını Bağla" : "Link Accounts";
  static String get linkAccountsDesc => lang == 'tr' 
      ? "Hesabına birden fazla giriş yöntemi ekleyerek erişimini asla kaybetme." 
      : "Never lose access by adding multiple login methods to your account.";
  static String get emailAddressLogin => lang == 'tr' ? "E-posta Adresi" : "Email Address";
  static String get googleAccount => lang == 'tr' ? "Google Hesabı" : "Google Account";
  static String get appleAccount => lang == 'tr' ? "Apple Hesabı" : "Apple Account";
  static String get connected => lang == 'tr' ? "Bağlı" : "Connected";
  static String get notConnected => lang == 'tr' ? "Bağlı değil" : "Not Connected";
  static String get connect => lang == 'tr' ? "Bağla" : "Connect";
  static String get featureComingSoon => lang == 'tr' ? "hesabını bağlama özelliği çok yakında! " : "account linking coming soon! ";

// --- GRUP SOHBETİ ---
  static String get venueChat => lang == 'tr' ? "Mekan Sohbeti" : "Venue Chat";
  static String get beFirstToMessage => lang == 'tr' ? "Henüz mesaj yok.\nİlk sen yaz!" : "No messages yet.\nBe the first to say hi!";
  static String get chatError => lang == 'tr' ? "Sohbet ID'si bulunamadı." : "Chat ID not found.";
  static String get errorTitle => lang == 'tr' ? "Hata" : "Error";

// --- ARKADAŞLAR LİSTESİ ---
  static String get offline => lang == 'tr' ? "Çevrimdışı" : "Offline";
  static String get friendsTitle => lang == 'tr' ? "Arkadaşlar" : "Friends";
  static String get findOnMap => lang == 'tr' ? "Haritada Bul" : "Find on Map";
  static String get searchFriendsHint => lang == 'tr' ? "Arkadaşlarda ara..." : "Search friends...";
  static String get findFriendsOnMapDesc => lang == 'tr' ? "Haritadan yeni arkadaşlar keşfedebilirsin! " : "Discover new friends on the map! ";
  static String get deleteFriend => lang == 'tr' ? "Arkadaşı Sil" : "Remove Friend";
  static String get deleteFriendConfirm => lang == 'tr' ? "listenden çıkarılsın mı?" : "remove from your list?";
  static String get friendDeleted => lang == 'tr' ? "silindi." : "removed.";
  static String get noFriendsYet => lang == 'tr' ? "Henüz kimseyi eklemedin " : "No friends added yet ";
  static String get findFriendsDesc => lang == 'tr' ? "Harita ekranından arkadaşlarını bulabilirsin." : "You can find friends from the map screen.";

// --- ARKADAŞLIK İSTEKLERİ ---
  static String get followRequestsTitle => lang == 'tr' ? "Takip İstekleri" : "Follow Requests";
  static String get noRequests => lang == 'tr' ? "Bekleyen İstek Yok" : "No Pending Requests";
  static String get noRequestsDesc => lang == 'tr' ? "Şu an için yeni bir takip isteğin bulunmuyor." : "You have no new follow requests at the moment.";

// --- ARAMA EKRANI ---
  static String get searchHint => lang == 'tr' ? "Mekan veya kişi ara..." : "Search places or people...";
  static String get startTyping => lang == 'tr' ? "Aramak için yazmaya başla" : "Start typing to search";
  static String get noPlaceFound => lang == 'tr' ? "Mekan bulunamadı" : "No place found";
  static String get findFriends => lang == 'tr' ? "Arkadaşlarını bul" : "Find friends";
  static String get noPersonFound => lang == 'tr' ? "Kişi bulunamadı" : "No person found";

// --- PROFİL KARTLARI ---
  static String get photo => lang == 'tr' ? "Fotoğraf" : "Photo";
  static String get survey => lang == 'tr' ? "Anket" : "Survey";
  static String get trust => lang == 'tr' ? "Güven" : "Trust";
  static String get viewAll => lang == 'tr' ? "Tümü" : "All";
  static String get visitedTimes => lang == 'tr' ? "kez ziyaret edildi" : "times visited";
  static String get noData => lang == 'tr' ? "Veri yok" : "No data";

// --- PROFİL DÜZENLEME ---
  static String get changePhoto => lang == 'tr' ? "Profil Fotoğrafını Değiştir" : "Change Profile Photo";

// --- DEĞERLENDİRME KARTI ---
  static String get rateNow => lang == 'tr' ? "Şimdi Değerlendir" : "Rate Now";

// --- PUANLAMA (RATING) ---
  static String get rate => lang == 'tr' ? "Puanla" : "Rate";
  static String get needsImprovement => lang == 'tr' ? "Geliştirilmeli" : "Needs Improvement";
  static String get average => lang == 'tr' ? "Ortalama" : "Average";
  static String get veryGood => lang == 'tr' ? "Çok İyi" : "Very Good";
  static String get perfect => lang == 'tr' ? "Mükemmel" : "Perfect";

  static String get service => lang == 'tr' ? "Servis" : "Service";
  static String get atmosphere => lang == 'tr' ? "Ortam" : "Atmosphere";

  static String get highlights => lang == 'tr' ? "Öne Çıkanlar" : "Highlights";
  static String get commentHint => lang == 'tr' ? "Deneyiminden bahset... (Opsiyonel)" : "Tell us about your experience... (Optional)";
  static String get submitRating => lang == 'tr' ? "DEĞERLENDİRMEYİ GÖNDER" : "SUBMIT RATING";
  static String get ratingSubmitted => lang == 'tr' ? "Değerlendirmen alındı." : "Rating submitted.";

  // Etiketler (Emojili)
  static String get tagFastService => lang == 'tr' ? "Hızlı Servis ⚡️" : "Fast Service ⚡️";
  static String get tagDelicious => lang == 'tr' ? "Lezzetli 🍔" : "Delicious 🍔";
  static String get tagClean => lang == 'tr' ? "Temiz ✨" : "Clean ✨";
  static String get tagNoisy => lang == 'tr' ? "Gürültülü 🔊" : "Noisy 🔊";
  static String get tagExpensive => lang == 'tr' ? "Pahalı 💸" : "Expensive 💸";
  static String get tagView => lang == 'tr' ? "Manzara 🌉" : "View 🌉";

// --- İSTEK ÖZETİ ---
  static String get followRequest => lang == 'tr' ? "Takip İsteği" : "Follow Request";
  static String get followRequests => lang == 'tr' ? "Takip İstekleri" : "Follow Requests";
  static String get and => lang == 'tr' ? "ve" : "and";
  static String get othersWantToFollow => lang == 'tr' ? "diğer kişi seni takip etmek istiyor." : "others want to follow you.";

// --- BALON MENÜ ---
  // notifications ve settings daha önce eklenmişti, varsa tekrar ekleme.
  static String get polls => lang == 'tr' ? "Değerlendirmeler" : "Polls";
  static String get privacyMode => lang == 'tr' ? "Gizlilik Modu" : "Privacy Mode";

// --- BİLDİRİMLER & AKSİYONLAR ---
  static String get accept => lang == 'tr' ? "Kabul Et" : "Accept";
  static String get decline => lang == 'tr' ? "Reddet" : "Decline";
  static String get goToPlace => lang == 'tr' ? "Mekana Git" : "Go to Place";
  
  // Bildirim Tipleri (Backend'den gelmiyorsa burada tanımlanabilir)
  static String get friendRequest => "friend_request";
  static String get checkin => "checkin";
  static String get system => "system";

// --- FIRESTORE MESAJLARI ---
  static String get dataFetchError => lang == 'tr' ? "Veri çekme hatası:" : "Data fetch error:";
  static String get updateFailed => lang == 'tr' ? "Güncelleme başarısız:" : "Update failed:";
  static String get friendAddError => lang == 'tr' ? "Arkadaş eklenemedi:" : "Could not add friend:";
  static String get postShareError => lang == 'tr' ? "Gönderi paylaşılamadı:" : "Could not share post:";
  static String get checkInMade => lang == 'tr' ? "mekanında check-in yaptı! " : "checked in at! ";
  static String get reviewedPlace => lang == 'tr' ? "mekanını değerlendirdi." : "reviewed the place.";

// --- STORAGE ---
  static String get imageUploadError => lang == 'tr' ? "Resim yükleme hatası:" : "Image upload error:";

// --- KULLANICI KARTI (USER SHEET) ---
  static String get about => lang == 'tr' ? "Hakkında" : "About";
  static String get mutualConnections => lang == 'tr' ? "Ortak Bağlantılar" : "Mutual Connections";
  static String get recentPlaces => lang == 'tr' ? "Son Gittiği Yerler" : "Recent Places";
  static String get seeAll => lang == 'tr' ? "Tümünü Gör" : "See All";
  static String get sendMessage => lang == 'tr' ? "Mesaj Gönder" : "Send Message";
  static String get visitProfile => lang == 'tr' ? "Profil" : "Profile";
  static String get level => lang == 'tr' ? "Seviye" : "Level";

// --- MEKAN KARTI (PLACE SHEET) ---
  static String get hereNow => lang == 'tr' ? "Şu an Burada" : "Here Now";
  static String get peopleCount => lang == 'tr' ? "Kişi" : "People";
  static String get friendsVisited => lang == 'tr' ? "Ziyaret Eden Arkadaşlar" : "Friends Visited";
  static String get details => lang == 'tr' ? "Detaylar" : "Details";
  static String get openNow => lang == 'tr' ? "Şu an Açık" : "Open Now";
  static String get freeWifi => lang == 'tr' ? "Ücretsiz WiFi" : "Free WiFi";
  static String get wonderful => lang == 'tr' ? "Harika" : "Great";

// --- ARAMA / ÖNERİLER ---
  static String get placesHeading => lang == 'tr' ? "MEKANLAR" : "PLACES";
  static String get peopleHeading => lang == 'tr' ? "KİŞİLER" : "PEOPLE";
  static String get nameless => lang == 'tr' ? "İsimsiz" : "Untitled";
  static String get generalPlace => lang == 'tr' ? "Genel Mekan" : "General Place";

// --- KAMERA & HARİTA ---
  static String get photoCaptured => lang == 'tr' ? "Fotoğraf çekildi! " : "Photo captured! ";
  static String get cameraError => lang == 'tr' ? "Kamera açılamadı." : "Camera could not be opened.";

// --- ARKADAŞ PROFİLİ ---
  static String get message => lang == 'tr' ? "Mesaj" : "Message";
  static String get trustScore => lang == 'tr' ? "Güven" : "Trust";
  static String get noMutualHistory => lang == 'tr' ? "Henüz ortak bir geçmişiniz yok." : "No mutual history yet.";
  static String get friends => lang == 'tr' ? "Arkadaş" : "Friends";
  // --- HARİTA & CHAT ---
  static String get map => lang == 'tr' ? "Harita" : "Map";
  static String get chats => lang == 'tr' ? "Sohbetler" : "Chats";
  static String get typeMessage => lang == 'tr' ? "Mesaj yaz..." : "Type a message...";

  // --- CATCH ---
  static String get navCatch => lang == 'tr' ? "Catch" : "Catch";
  static String get catchTitle => lang == 'tr' ? "Catch" : "Catch";
  static String get available => lang == 'tr' ? "Müsait" : "Available";
  static String get busy => lang == 'tr' ? "Meşgul" : "Busy";
  static String get pendingStatus => lang == 'tr' ? "Bekliyor" : "Pending";
  static String get beAvailable => lang == 'tr' ? "Müsait Ol" : "Be Available";
  static String get goBusy => lang == 'tr' ? "Meşgul Ol" : "Go Busy";
  static String get selectDuration => lang == 'tr' ? "Süre Seç" : "Select Duration";
  static String get min30 => lang == 'tr' ? "30 dk" : "30 min";
  static String get hour1 => lang == 'tr' ? "1 saat" : "1 hour";
  static String get hour2 => lang == 'tr' ? "2 saat" : "2 hours";
  static String get hour4 => lang == 'tr' ? "4 saat" : "4 hours";
  static String get catchSent => lang == 'tr' ? "Catch gönderildi!" : "Catch sent!";
  static String get catchAccepted => lang == 'tr' ? "Catch kabul edildi!" : "Catch accepted!";
  static String get catchRejected => lang == 'tr' ? "Catch reddedildi" : "Catch rejected";
  static String get catchExpired => lang == 'tr' ? "Catch süresi doldu" : "Catch expired";
  static String get incomingCatch => lang == 'tr' ? "Catch geliyor!" : "Incoming Catch!";
  static String get wantsToMeet => lang == 'tr' ? "seninle buluşmak istiyor" : "wants to meet you";
  static String get cooldownActive => lang == 'tr' ? "Bekleniyor..." : "Waiting...";
  static String get noFriendsForCatch => lang == 'tr' ? "Henüz arkadaşın yok" : "No friends yet";
  static String get noFriendsForCatchDesc => lang == 'tr' ? "Haritadan kişileri takip ederek arkadaş edin." : "Follow people from the map to add friends.";
  static String get youAreAvailable => lang == 'tr' ? "Müsaitsin" : "You're Available";
  static String get youAreBusy => lang == 'tr' ? "Meşgulsün" : "You're Busy";
  static String get remainingTime => lang == 'tr' ? "Kalan süre" : "Remaining";
  static String get call => lang == 'tr' ? "Ara" : "Call";

  // --- ARKADAŞLIK AKSİYONLARI ---
  static String get youAreFriends => lang == 'tr' ? "Arkadaşsınız" : "Friends";
  static String get requestSent => lang == 'tr' ? "İstek Gönderildi" : "Request Sent";
  static String get addFriend => lang == 'tr' ? "Arkadaş Ekle" : "Add Friend";
  
  // --- GİZLİLİK UYARILARI ---
  static String get accountPrivate => lang == 'tr' ? "Bu Hesap Gizli" : "This Account is Private";
  static String get accountPrivateDesc => lang == 'tr' 
      ? "Fotoğraflarını ve aktivitelerini görmek için arkadaş olmalısın." 
      : "You must be friends to see photos and activities.";
     

static String get removeFriend => lang == 'tr' ? "Arkadaşlardan Çıkar" : "Remove Friend";
static String get removeFriendDesc => lang == 'tr' ? "Bu kişiyi arkadaş listenden çıkarmak istediğine emin misin?" : "Are you sure you want to remove this person from your friends list?";
static String get remove => lang == 'tr' ? "Çıkar" : "Remove";
// --- İSTATİSTİK KART ---
  static String get checkInShort => lang == 'tr' ? "Check-in" : "Check-in";
  static String get friendCount => lang == 'tr' ? "Arkadaş" : "Friend";
  static String get photoShort => lang == 'tr' ? "Foto" : "Photo";
  static String get surveyShort => lang == 'tr' ? "Anket" : "Survey";
  static String get followBack => lang == 'tr' ? "Sen de Takip Et" : "Follow Back";

  // --- BAĞLANTI DURUMU ---
  static String get backOnline => lang == 'tr' ? "Tekrar bağlandı" : "Back online";
}
