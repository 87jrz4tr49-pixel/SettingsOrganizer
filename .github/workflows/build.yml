name: Build

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Theos
        run: |
          git clone --recursive https://github.com/theos/theos.git $HOME/theos
          mkdir -p $HOME/theos/sdks
          cd $HOME/theos/sdks
          curl -LO https://github.com/theos/sdks/raw/master/iPhoneOS16.0.sdk.zip
          unzip -q iPhoneOS16.0.sdk.zip
          ln -s iPhoneOS16.0.sdk iPhoneOS.sdk
      - name: Build
        run: |
          export THEOS=$HOME/theos
          make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
      - name: Upload
        uses: actions/upload-artifact@v4
        with:
          name: deb
          path: packages/*.deb