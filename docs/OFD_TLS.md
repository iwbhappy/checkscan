# TLS consumer.oofd.kz

## Наблюдение 2026-10-07

На Android запрос к публичному API возвращал
`CERTIFICATE_VERIFY_FAILED: unable to get local issuer certificate`, тогда как
Windows успешно строил цепочку. Два независимых подключения Python с обычной
проверкой TLS показали: сервер передаёт ровно один сертификат — `*.oofd.kz`.
Промежуточный GoGetSSL RSA DV CA отсутствует в серверной цепочке.

[Android описывает этот случай](https://developer.android.com/privacy-and-security/security-ssl#MissingCa):
настольные клиенты могут использовать кэш промежуточных CA, а Android требует
полную цепочку от сервера. Правильное исправление на стороне ОФД — передавать
промежуточный CA вместе с конечным сертификатом.

Корень USERTrust RSA входит в доверенные корни Android начиная с 5.1 согласно
[официальной таблице Sectigo](https://www.sectigo.com/knowledge-base/detail/Sectigo-Root-Certificates).
Причина наблюдаемого сбоя — неполная цепочка, а не отсутствие нового корня.

## Происхождение и проверка

В приложение включён только полный публичный промежуточный сертификат
`assets/certificates/gogetssl_rsa_dv_ca.pem`. Private key отсутствует.

| Поле | Значение |
| --- | --- |
| Subject | C=LV, L=Riga, O=GoGetSSL, CN=GoGetSSL RSA DV CA |
| Issuer | USERTrust RSA Certification Authority |
| Serial | 938BB08E62987B4F75F98CB6A5045C96 |
| Действует с | 2018-09-06 00:00:00 UTC |
| Действует до | 2028-09-05 23:59:59 UTC |
| DER SHA-256 | 43cac31ef8e8ba1b4b16b8206e4c0a26c5badb2fc3aa09e90170e41b66c2fd64 |
| PEM file SHA-256 | 220386e620928a646a2650eff5df5bc59dd3e3d3e878b6fb4a9ec822e056a14e |

Получен из AIA конечного сертификата:
`http://crt.usertrust.com/GoGetSSLRSADVCA.crt` (200, 1499 байт DER,
2026-10-07 14:22:31 UTC). HTTPS на этом AIA-хосте не завершил TLS handshake;
никакие проверки TLS при скачивании не отключались. Подпись скачанного CA
проверена корнем из установленного Git CA bundle.

Второй экземпляр скачан по HTTPS из
[официального CDN GoGetSSL](https://gogetssl-cdn.s3.eu-central-1.amazonaws.com/wiki/gogetssl-rsa-dv-ca.txt),
на который ссылается [каталог CA](https://www.gogetssl.com/wiki/intermediate-certificates/gogetssl-intermediate-root-certificates/),
раздел Legacy / Sectigo / DV RSA. После декодирования PEM его DER SHA-256 полностью
совпал с AIA. Полные локальные тела и заголовки сохранены в `build/tls-research/`.

OpenSSL проверил подпись CA по установленному Git CA bundle. Затем свежий
конечный сертификат проверен вместе с промежуточным CA, включая hostname:

```powershell
openssl verify -show_chain -verify_hostname consumer.oofd.kz `
  -CAfile 'C:/SOFTS/Git/mingw64/etc/ssl/certs/ca-bundle.crt' `
  -untrusted assets/certificates/gogetssl_rsa_dv_ca.pem `
  build/tls-research/consumer-leaf.pem
```

Результат `OK`, цепочка: `*.oofd.kz` → `GoGetSSL RSA DV CA` →
`USERTrust RSA Certification Authority`. Проверка повторена с отдельно
скачанным официальным self-signed USERTrust RSA корнем и также дала `OK`.
Без промежуточного CA серверная цепочка неполна.

Конечный сертификат: serial `58C632D6B63D2233DEA31204A360E6C4`,
действует 2026-05-18 — 2026-12-02, DER SHA-256
`6fe957f4c1e702065ab6a8772ff0a0cc954b0f542daa43a2172096fed4138584`.
USERTrust RSA root DER SHA-256:
`e793c9b02fd8aa13e21c31228accb08119643b749c898964b1746d46c3d4cbd2`.

## Область действия в приложении

`OfdHttpClientAdapter` использует отдельный `SecurityContext(withTrustedRoots: true)`
и добавляет проверенный CA только для HTTPS origin `consumer.oofd.kz:443` без
userinfo. Остальные адреса используют стандартный клиент. Системные корни,
проверки hostname, срока действия и цепочки сохраняются. Проверку сертификатов
через `badCertificateCallback` приложение не отключает. Сертификат конечного
сайта не закреплён: штатная смена серверного сертификата внутри доверенной
цепочки возможна.

Это ограниченная клиентская компенсация неполной цепочки. После исправления
конфигурации ОФД её следует убрать. При смене CA или приближении срока действия
промежуточного сертификата нужно повторить проверку. Ошибки TLS остаются
типизированными ошибками с повтором, а не поводом принимать недоверенный
сертификат.

После подключения adapter отдельная проверка на Android SDK 36 успешно вызвала
реальный OFD provider по HTTPS для контрольного QR: сумма `200200` тиын,
4 позиции. Это живой сетевой запрос без подмены ответа. Данная проверка
покрывает provider и TLS; лог сохранён в `build/network-probe-fixed.log`.
Временный сетевой тест удалён, чтобы живой ОФД не стал зависимостью CI.
Распознавание фотографии проверяется отдельным
интеграционным тестом и не включено в этот сетевой прогон.

## Распространение

[Sectigo CPS 5.3.6, §9.17.3, стр. 116](https://www.sectigo.com/uploads/files/Sectigo_CPS_v5_3_6.pdf)
разрешает неисключительное безвозмездное воспроизведение и распространение полных
сертификатов. В asset сохраняется весь сертификат; изменена только кодировка
DER → PEM. Отдельный notice находится рядом с asset.
