# NXP Neon District — Godot ilk oynanabilir sürüm

Godot 4.3 veya üstünde **Import** ile bu klasördeki `project.godot` dosyasını seçin. Editörde **F6** veya **F5** ile oyunu başlatın. Bilgisayarda WASD/ok tuşları ve boşluk; telefonda sol yön alanı ve sağdaki **ATEŞ** düğmesi kullanılır.

Oyuncu ortadaki üssü örümcek saldırılarından korur. Her bölgede 12 örümcek ikişerli gruplarla yaklaşık dört saniye aralıklarla farklı şeritlerden kaleye yürür. Hepsini yenip üç veri çekirdeğini toplayınca, Örümcek Kraliçe gelmeden önce bir seçim ekranı açılır. Üssün ya da oyuncunun canı biterse bölüm kaybedilir; patron yenilince sonraki harita açılır, karakter seviyesi ve silah hasarı artar. **Haritalar** düğmesi açılmış bölgeleri tekrar oynamayı sağlar. İlerleme Godot'un telefon içindeki `user://nxp_defense.cfg` kaydında tutulur.

Normal örümceğin yanında daha hızlı ama daha az canlı izciler ve daha yavaş ama daha dayanıklı zırhlı örümcekler sırayla gelir. Seçim ekranı yalnızca boss öncesinde bir kez açılır; oyuncu silah hasarı, kale onarımı veya kale zırhından birini seçer. Silah ve zırh güçleri yalnızca o bölüm boyunca sürer; kayıtlı seviye ve krediler korunur.

Bölgeler sırayla **Neon District** (şehir), **Data Wasteland** (çöl ve harabeler), **Quantum Port** (liman ve konteynerler), **Orbital Core** (uzay istasyonu) olarak açılır. İnsan karakter, örümcekler, kale ve çevre Godot içinde üç boyutlu geometriyle oluşturulur. Yüz ve zırh, eklemli örümcek bacakları ve farklı kabuk renkleri eklenmiştir. Modeller hâlâ prototiptir; sinematik gerçekçilik için ileride Blender modelleri, dokular ve animasyonlar gerekir.

Karakter (`models/character.glb`), kale (`models/castle.glb`) ve dört örümcek türü (`models/spider_*.glb`) artık ayrı 3D model dosyaları olarak yüklenir. Model dosyaları `python tools/build_models.py` ile yeniden üretilebilir ve `python tools/validate_models.py` ile yapısal olarak kontrol edilebilir. Yüzeylerinde düşük çözünürlüklü kumaş, kabuk ve taş dokuları vardır. Karakter ve örümcekler hareket sırasında hafifçe salınır; bacaklara bağlı iskelet animasyonu henüz yoktur. Mevcut oynanış, can çubukları, mobil kontroller ve kayıt düzeni korunur.

Görsel ayrıntı geçişi başladı: karaktere kask vizörü, omuz ve diz zırhı ile sırt ekipmanı; kale kapısına taş çerçeve, ahşap kalas ve metal kuşaklar; örümceklere gövde altı ve çene eklendi. Bu parçalar mevcut 3D geometriyi kullanır ve temel oynanışı değiştirmez.

Görsel sürümde perspektif 3D kamera karakteri arkadan, karşıdan gelen örümcekleri önde gösterir. Örümcekler açılışta kamera görüşünün içinde doğar. Sol yön kontrolü ve WASD/ok tuşları ekrandaki sağ, sol, yukarı ve aşağı yönlerine göre hareket eder. Örümcekler daha yavaş ilerler, tüfek daha hızlı ateş eder. Karakterin iki elle tuttuğu tüfek; kalenin taş dokulu surları, kapısı, dört kulesi ve mazgalları vardır. Karakter, kale ve her örümceğin üzerinde can çubuğu bulunur; hasardan sonra çubuk yavaşça azalır. Bu modeller oyun içinde gerçek 3D geometriyle çizilir. Tanıtım görselindeki ayrıntı düzeyine ulaşmak için ayrıca profesyonel karakter, yaratık ve çevre modelleri ile animasyonlar gerekecektir.

Neon District'te sınırlı mavi ve mor tabelalar ile ıslak zemin parçaları; Data Wasteland'de sıcak gün ışığı ve kum tonları kullanılır. Böylece mevcut 3D dünya, tanıtım görsellerinin bölgelere özgü ışık ve renklerine yaklaşır.

Android için Godot editöründe Android export şablonları ve Android SDK kurulumu gerekir. Web sürümü `../game` altında, Unity taslağı `../unity` altında durur. Bu Godot projesi henüz web sayfasına gömülmemiştir ve GitHub Pages yalnızca dosyaların yüklenmesiyle Godot oyununu çalıştırmaz; web dışa aktarımı ayrıca gerekir.
