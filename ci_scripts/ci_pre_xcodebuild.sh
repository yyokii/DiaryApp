#!/bin/sh

# GoogleService-Info.plistをXcode Cloudの環境変数より生成
echo $GOOGLE_SERVICE_INFO > ../Diary/GoogleService-Info.plist
