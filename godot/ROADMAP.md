# NXP kale savunması geliştirme sırası

Amaç: Telefonda çalışan oyun döngüsünü ve kayıtlı bölüm ilerlemesini koruyarak küçük, ayrı güncellemeler yapmak. Her aşamadan sonra Android Godot editöründe bölüm başlatma, hareket, ateş, düşman doğması, zafer, yeniden oynama ve kaydı kontrol et.

1. [x] Üç sıradan düşman çeşidi: normal örümcek, hızlı ama az canlı izci, yavaş ama çok canlı zırhlı örümcek. Aynı sırayla doğma ve kaleye yönelme düzenini kullanırlar.
2. [x] Her bölümde 12 örümcek ikişerli gruplarla gelir. Hepsi yenilip çekirdekler toplandıktan sonra, boss gelmeden önce bir kez silah hasarı, kale onarımı veya geçici savunma seçimi sunulur. Güçler bölüm sonunda sıfırlanır; kayıt dosyasının eski alanları korunur.
3. [ ] Kale savunması: önce tek bir kurulabilir taret; daha sonra yavaşlatıcı tuzak. Önce telefon performansını kontrol et.
4. [ ] Bölümlere farklı görevler ekle: kale savunması, süreli dayanma, belirli bir hedefi yok etme. Mevcut harita açma ilerleyişini koru.
5. [ ] Kredilerle kalıcı fakat sınırlı karakter, silah ve kale yükseltmeleri; mevcut kaydı yeni alanlar için güvenli varsayılanlarla yükle.
6. [ ] Sonsuz savunma ve haftalık görevler; ödülleri dengeli tut.
7. [ ] Görsel kaliteyi aşamalı geliştir: karakterin yüzü, zırhı ve silahı; kalenin taşları, kapısı ve kuleleri; örümceklerin anatomisi, yürüyüş animasyonu; ardından dokular, ses ve mobil grafik ayarları. Ayrıntılı gerçekçilik için optimize edilmiş 3D model ve animasyon dosyaları gerekir. İlk geometri ayrıntıları eklendi.
8. [ ] Tek oyunculu denge ve performans oturduktan sonra çok oyunculu özellikleri değerlendir.

Kaynak fikirler: Orcs Must Die! 3 (tuzaklar ve savunma çeşitliliği), Fortnite Save the World (hazırlık ve kale savunması), Vampire Survivors (oyun içi ve oyunlar arası gelişim). Bu liste uygulama sırasıdır; tamamlanan maddeler işaretlenir.
