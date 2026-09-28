# NXP 3D görsel kalite hedefi

## Görsel hedef

`../nxp-neon-district4.png` tanıtım görselindeki Neon District: arkadan görülen, silahı ve zırhı net okunan asker; yakından bakıldığında kabuk, göz ve bacak ayrıntıları olan büyük örümcek; ıslak yol, neon tabelalar, yoğun şehir ve savunulan üs. Bu tanıtım resmi oynanış görüntüsü değildir. Hedef aynı kompozisyon ve sanat diliyle çalışan bir 3D oyun sahnesidir.

## Hazır varlık adayları (satın alma yapılmadı)

| Alan | Aday | Kontrol edilecekler |
|---|---|---|
| İnsan karakter | https://www.fab.com/listings/0c08569d-df84-4dfb-89e7-1b53588d7c50 | İlanda rig, tüfek ve GLB/FBX var; animasyon klipleri ayrıca doğrulanmalı. Silah tutuşu üçüncü şahıs kamerasında görülmeli. |
| Örümcek | https://www.fab.com/listings/e0665ade-f151-4f98-9b62-2ed7c35b81c6 | İlanda yürüyüş, bekleme, saldırı ve ölüm animasyonları ile GLB/FBX var. Doğal tarantula görünümünü Neon District'e uydurmak için yeniden renklendirme/ek zırh gerekebilir. |
| Kale/üs | https://www.fab.com/listings/55118a9f-0569-4087-8ff4-9952eb6201b6 | Modüler bilimkurgu karakolu; üs silueti, kapı ve savunma alanı mevcut oyun sınırlarına uygun kurulmalı. |
| Neon çevre | https://www.fab.com/listings/b754180c-26dd-4ddd-aeae-e9ad99df48a3 | Modüler şehir; performans ve parçaların Godot'ta düzenlenebilirliği incelenmeli. |
| Zemin | https://polyhaven.com/a/asphalt_02 | CC0 asfalt dokusu; normal/roughness ile yüzey ve yansıma uygulanabilir. |

Fab Standard License ücretli varlıkların oyunda kullanılmasına izin verebilir; ham dosyalar herkese açık GitHub deposuna veya ayrı ZIP içine konmamalıdır. Lisansın tam metni satın alma öncesinde denetlenmeli: https://www.fab.com/eula . Lisanslı varlıklar yalnızca yetkili özel çalışma alanında tutulacak, halka yalnızca oyunun dağıtılabilir çıktısı verilecek.

## Teknik kabul ölçütleri

1. Karakter: rigli humanoid, silahla uyumlu eller, bekleme/koşma/ateş/hasar/ölüm klipleri, PBR base color/normal/roughness/metallic, üçüncü şahıs kamera testi.
2. Örümcek: sekiz bacaklı rig; bekleme/yürüme/saldırı/ölüm klipleri; normal, hızlı, zırhlı ve boss varyantlarında aynı davranış kodu korunur.
3. Üs ve şehir: kale can çubuğu aynı kök düğümde kalır; kapı hedefi ve örümcek yolu korunur; ıslak asfalt ve okunabilir neon ışıkları kullanılır.
4. Android: önce kullanıcının telefonunda kalite ve kare hızı ölçülür; yüksek çözünürlüklü kaynak dosyalar saklanır, dağıtımda gerektiğinde 1K/2K dokular ve LOD kullanılır.
5. Entegrasyon: Godot 4 `.glb` sahnelerini içe aktarır. Model ölçüsü/ekseni, animasyon, materyal, görünürlük ve oyun akışı ayrı ayrı test edilmeden mevcut oynanabilir sürümün üzerine geçilmez.

Bu belge satın alma ya da hazır dosyaların kalite garantisi değildir. Model önizlemesi ve gerçek dosyalar görülmeden animasyonların Godot'ta çalıştığı veya afiş kalitesinin elde edildiği söylenemez.
