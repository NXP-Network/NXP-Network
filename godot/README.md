# NXP Neon District — Godot ilk oynanabilir sürüm

Godot 4.3 veya üstünde **Import** ile bu klasördeki `project.godot` dosyasını seçin. Editörde **F6** veya **F5** ile oyunu başlatın. Bilgisayarda WASD/ok tuşları ve boşluk; telefonda sol yön alanı ve sağdaki **ATEŞ** düğmesi kullanılır.

Oyuncu ortadaki üssü örümcek saldırılarından korur. Her bölgede gerekli sayıda örümceği yenip üç veri çekirdeğini toplayınca Örümcek Kraliçe gelir. Üssün ya da oyuncunun canı biterse bölüm kaybedilir; patron yenilince sonraki harita açılır, karakter seviyesi ve silah hasarı artar. **Haritalar** düğmesi açılmış bölgeleri tekrar oynamayı sağlar. İlerleme Godot'un telefon içindeki `user://nxp_defense.cfg` kaydında tutulur.

Bölgeler sırayla **Neon District** (şehir), **Data Wasteland** (çöl ve harabeler), **Quantum Port** (liman ve konteynerler), **Orbital Core** (uzay istasyonu) olarak açılır. İnsan karakter, örümcekler, kale ve çevre Godot içinde üç boyutlu geometriyle oluşturulur. Yüz ve zırh, eklemli örümcek bacakları ve farklı kabuk renkleri eklenmiştir. Modeller hâlâ prototiptir; sinematik gerçekçilik için ileride Blender modelleri, dokular ve animasyonlar gerekir.

Android için Godot editöründe Android export şablonları ve Android SDK kurulumu gerekir. Web sürümü `../game` altında, Unity taslağı `../unity` altında durur. Bu Godot projesi henüz web sayfasına gömülmemiştir ve GitHub Pages yalnızca dosyaların yüklenmesiyle Godot oyununu çalıştırmaz; web dışa aktarımı ayrıca gerekir.
