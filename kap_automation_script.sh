#!/bin/zsh

# Kap으로 녹화된 GIF 파일 최적화 자동화 (ZSH 호환)
# 기본 저장 경로: ~/Desktop (Kap 기본 저장 위치)
# 원본 저장 경로: ./assets/web/originals
# 최적화 후 저장 경로: ./assets/web

# 1. 기본 경로 설정
KAP_SOURCE_DIR=~/Desktop
TARGET_DIR=./assets/web
ORIGINAL_DIR=$TARGET_DIR/originals

# 2. 저장할 경로가 존재하지 않으면 생성
mkdir -p $ORIGINAL_DIR
mkdir -p $TARGET_DIR

# 3. GIF 파일 이름 목록
FILE_NAMES=("로그인" "메인페이지(DashBoard)" "회원조회" "QnA 조회 (필터링)" "QnA 답변 생성" "QnA 답변 수정" "QnA 답변 삭제" "공지사항 조회 및 수정" "공지사항 삭제")

# 4. 가장 최근 녹화된 GIF 파일 찾기
LATEST_GIF=$(ls -t $KAP_SOURCE_DIR/*.gif 2>/dev/null | head -n 1)

if [ -z "$LATEST_GIF" ]; then
  echo "Kap으로 녹화된 GIF 파일이 없습니다."
  exit 1
fi

# 5. 파일 이름 설정
echo "녹화된 GIF 파일의 번호를 선택하세요 (1-10):"
for i in {1..${#FILE_NAMES[@]}}; do
  echo "$i. ${FILE_NAMES[$((i-1))]}"
done

read "?번호: " FILE_INDEX
FILE_NAME=${FILE_NAMES[$((FILE_INDEX-1))]}

if [ -z "$FILE_NAME" ]; then
  echo "잘못된 번호입니다."
  exit 1
fi

# 6. 파일 이름 URL 인코딩 (Markdown에서 호환)
ENCODED_NAME=$(echo $FILE_NAME | sed 's/ /%20/g; s/(/%28/g; s/)/%29/g')

# 7. 원본 파일 저장
BASENAME="$FILE_NAME.gif"
cp "$LATEST_GIF" "$ORIGINAL_DIR/$BASENAME"

# 8. 최적화된 파일명 설정
OPTIMIZED_GIF="$TARGET_DIR/$BASENAME"

# 9. GIF 파일 최적화 (gifsicle 사용)
gifsicle -O3 --resize-width 800 -o "$OPTIMIZED_GIF" "$LATEST_GIF"

# 10. profile/README.md 파일 자동 업데이트
README_FILE="profile/README.md"

# 11. README 파일에서 기존 GIF 링크 교체 (있다면)
sed -i '' "/$FILE_NAME/d" $README_FILE
echo "| $FILE_NAME | ![GIF](../assets/web/$ENCODED_NAME.gif) |" >> $README_FILE

# 12. 완료 메시지 출력
echo "✅ 최적화된 GIF 파일이 저장되었습니다: $OPTIMIZED_GIF"
echo "✅ 원본 GIF 파일이 저장되었습니다: $ORIGINAL_DIR/$BASENAME"
echo "✅ profile/README.md 파일이 자동으로 업데이트되었습니다."