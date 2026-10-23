"""Check the merged manifest, including permissions introduced by plugins."""
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

variant = sys.argv[1] if len(sys.argv) > 1 else 'release'
path = Path(f'build/app/intermediates/merged_manifests/{variant}/process{variant.title()}Manifest/AndroidManifest.xml')
root = ET.parse(path).getroot()
android = '{http://schemas.android.com/apk/res/android}'
permissions = {item.get(android + 'name') for item in root.findall('uses-permission')}
system = {name for name in permissions if name.startswith('android.permission.')}
assert system == {'android.permission.CAMERA', 'android.permission.INTERNET'}, system
assert root.find('uses-sdk').get(android + 'minSdkVersion') == '24'
app = root.find('application')
assert app.get(android + 'allowBackup') == 'false'
assert app.get(android + 'networkSecurityConfig') == '@xml/network_security_config'
blocked = ('TransportBackendDiscovery', 'JobInfoSchedulerService', 'AlarmManagerSchedulerBroadcastReceiver')
assert not any(any(suffix in element.get(android + 'name', '') for suffix in blocked) for element in app)
print(f'{variant}: CAMERA + INTERNET; minSdk 24; OS backup off; DataTransport upload components absent')
