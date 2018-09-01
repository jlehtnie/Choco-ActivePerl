#!/usr/bin/env python3

from bs4 import BeautifulSoup
import urllib.request
import re
from distutils.version import LooseVersion

INSTALLER_PS1 = 'ActivePerl/tools/ChocolateyInstall.ps1'
NUSPEC = 'ActivePerl/ActivePerl.nuspec'

URL = 'https://downloads.activestate.com/ActivePerl/releases/'
page = urllib.request.urlopen(URL)
soup = BeautifulSoup(page.read(), "lxml")

releases = []
for link in soup.find_all('a'):
    href = link.get('href')
    if re.match('(\d+\.)+\d+/', href):
        releases.append(href.rstrip('/'))

releases.sort(key=LooseVersion)
latest = releases[-1]

url = URL + latest + '/SHA256SUM'
page = urllib.request.urlopen(url)
text = page.read().decode('utf-8')

exes = {}
for line in text.split('\n'):
    if line and line.endswith('.exe'):
        sha256, filename = line.split()
        for arch in ['x64']:
            if ('-'+ arch +'-') in filename:
                exes[arch] = { 'url': URL + latest + '/' + filename, 'sha256': sha256 }

with open(INSTALLER_PS1) as f:
    s = f.read()
s = re.sub("https?://.*-x64-.*exe", exes['x64']['url'], s)
s = re.sub("checksum64 = '.*'", "checksum64 = '%s'" % exes['x64']['sha256'], s)

with open(INSTALLER_PS1, 'w') as f:
    f.write(s)

with open(NUSPEC) as f:
    s = f.read()
s = re.sub('<version>[\d\.]+</version>', '<version>%s</version>' % latest, s)

with open(NUSPEC, 'w') as f:
    f.write(s)
