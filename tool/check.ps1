$ErrorActionPreference = 'Stop'
flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$flutterBin = Split-Path (Get-Command flutter).Source
$flutterDart = Join-Path $flutterBin 'cache\dart-sdk\bin\dart.exe'
& $flutterDart run build_runner build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter gen-l10n
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
flutter test --coverage
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
python tool/check_coverage.py
exit $LASTEXITCODE
