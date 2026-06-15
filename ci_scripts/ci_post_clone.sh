#!/bin/sh

#  ci_post_clone.sh
#  Xcode Cloud — 클론 직후 실행.
#
#  gitignore로 저장소에서 제외된 시크릿/Firebase 설정 파일을,
#  Xcode Cloud 워크플로 "Environment Variables"에 base64로 저장해 둔 값에서 복원한다.
#  (스크립트에는 비밀값을 직접 넣지 않는다 — 전부 env var에서 읽는다.)
#
#  필요한 환경변수(전부 "Secret"으로 등록):
#    - SECRETS_DEBUG_XCCONFIG_BASE64
#    - SECRETS_RELEASE_XCCONFIG_BASE64
#    - GOOGLE_SERVICE_INFO_PLIST_BASE64        (prod, com.apu.saerok)
#    - GOOGLE_SERVICE_INFO_DEV_PLIST_BASE64    (dev,  com.apu.saerok.dev)

set -e

ROOT="$CI_PRIMARY_REPOSITORY_PATH"

restore() {
    # $1 = base64 env value, $2 = 복원할 경로
    if [ -z "$1" ]; then
        echo "❌ 환경변수가 비어 있음 → $2 복원 불가. Xcode Cloud 워크플로의 Environment Variables를 확인하세요."
        exit 1
    fi
    mkdir -p "$(dirname "$2")"
    printf '%s' "$1" | base64 --decode > "$2"
    echo "✅ restored: $2"
}

restore "$SECRETS_DEBUG_XCCONFIG_BASE64"        "$ROOT/saerok/Config/Secrets.Debug.xcconfig"
restore "$SECRETS_RELEASE_XCCONFIG_BASE64"      "$ROOT/saerok/Config/Secrets.Release.xcconfig"
restore "$GOOGLE_SERVICE_INFO_PLIST_BASE64"     "$ROOT/saerok/GoogleService-Info.plist"
restore "$GOOGLE_SERVICE_INFO_DEV_PLIST_BASE64" "$ROOT/saerok/GoogleService-Info-Dev.plist"

echo "🎉 모든 시크릿/설정 파일 복원 완료"
