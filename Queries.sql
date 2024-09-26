/*
  Sağlıklı bir db oluşturmak için Normalizasyon kavramı bilinmeli.
    3 Kuralı var.

	1. Bir tabloda satır bazında tekrar olmamalı. Yani satır tekrarı bir kolon sayesinde önlenmeli. Bu kolon da PK olarak tanımlanmalı
	2. Bir tabloda kolon bazında tekrar eden veri olmamalı. Tekrar eden(cek) veriler, ayrı bir tabloda tutulmalı ve o tablodan referans alınmalı.
	3. İki tablo arasında çoka çok ilişki olmaz! Bir ara tablo ile bire-çok ve çoka-bir biçiminde ayrılmalı

*/