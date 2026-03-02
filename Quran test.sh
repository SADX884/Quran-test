#!/bin/bash

# --- ألوان متطورة ---
G='\033[0;32m' # Green
B='\033[0;34m' # Blue
C='\033[0;36m' # Cyan
Y='\033[1;33m' # Yellow
R='\033[0;31m' # Red
P='\033[0;35m' # Purple
NC='\033[0m'    # No Color
BOLD='\033[1m'

# --- الإعدادات ---
API_KEY="S0lkxoivGSmG4rTW2QhqGFF8I5xAIGodbWPRKxU0IEWiKBKpzi3gSwbf"
OUTPUT_DIR="$HOME/storage/downloads"
TEMP_DIR=".quran_engine_v5"
FONT_URL="https://github.com/googlefonts/amiri/raw/main/fonts/ttf/Amiri-Bold.ttf"

# --- دالة الرسوم المتحركة (Spinner) ---
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# --- واجهة البداية ---
show_banner() {
    clear
    echo -e "${P}"
    echo "    ██████╗ ██╗   ██╗██████╗  █████╗ ███╗   ██╗"
    echo "   ██╔═══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║"
    echo "   ██║   ██║██║   ██║██████╔╝███████║██╔██╗ ██║"
    echo "   ██║▄▄ ██║██║   ██║██╔══██╗██╔══██║██║╚██╗██║"
    echo "   ╚██████╔╝╚██████╔╝██║  ██║██║  ██║██║ ╚████║"
    echo "    ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝"
    echo -e "             ${C}${BOLD}PREMIUM VIDEO ENGINE v5.0${NC}"
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# --- التحقق من الخطوط ---
setup_font() {
    echo -e "${Y}[*] جاري تجهيز الخط الاحترافي...${NC}"
    local paths=(
        "/system/fonts/NotoNaskhArabic-Bold.ttf"
        "/system/fonts/DroidSansArabic.ttf"
        "$HOME/.fonts/Amiri-Bold.ttf"
    )
    
    for p in "${paths[@]}"; do
        if [ -f "$p" ]; then SELECTED_FONT="$p"; break; fi
    done

    if [ -z "$SELECTED_FONT" ]; then
        echo -e "${C}[!] يتم الآن تحميل خط Amiri من GitHub للتميز...${NC}"
        curl -L -s -o "$TEMP_DIR/font.ttf" "$FONT_URL"
        SELECTED_FONT="$TEMP_DIR/font.ttf"
    fi
}

# --- بداية العمل ---
mkdir -p "$TEMP_DIR" "$OUTPUT_DIR"
show_banner

# الإدخال بشكل أنيق
echo -e "${BOLD}${Y}┌──( ${C}إعدادات المشروع${Y} )"
read -p "├─[?] مسار ملف الصوت: " AUDIO_INPUT
read -p "└─[?] رقم السورة (1-114): " SURAH_NUM

if [[ ! -f "$AUDIO_INPUT" ]]; then echo -e "${R}❌ خطأ: ملف الصوت غير موجود!${NC}"; exit 1; fi

# جلب البيانات مع Spinner
echo -ne "${Y}[*] جاري جلب الآيات وتنسيقها...  ${NC}"
( curl -s "https://api.alquran.cloud/v1/surah/$SURAH_NUM/ar.alafasy" > "$TEMP_DIR/data.json" ) &
spinner $!
DATA=$(cat "$TEMP_DIR/data.json")
AUDIO_DURATION=$(soxi -D "$AUDIO_INPUT")

echo -ne "\n${Y}[*] جاري اختيار خلفية سينمائية 4K...  ${NC}"
QUERY=$(shuf -e "stars" "nature" "galaxy" "deep-sea" "clouds" -n 1)
( curl -s -H "Authorization: $API_KEY" "https://api.pexels.com/videos/search?query=$QUERY&per_page=1" > "$TEMP_DIR/vid.json" ) &
spinner $!
VIDEO_URL=$(cat "$TEMP_DIR/vid.json" | jq -r '.videos[0].video_files[] | select(.width==1920) | .link' | head -n 1)

echo -ne "\n${Y}[*] جاري تحميل الفيديو...  ${NC}"
( curl -L -s -o "$TEMP_DIR/bg.mp4" "$VIDEO_URL" ) &
spinner $!
echo -e "\n"

setup_font

# بناء الترجمة SRT
echo -e "${G}[✔] تم تجهيز جميع الموارد. جاري بناء التوقيت...${NC}"
COUNT=$(echo "$DATA" | jq '.data.ayahs | length')
TOTAL_CHARS=$(echo "$DATA" | jq -r '.data.ayahs[].text' | wc -m)
CURRENT_OFFSET=0
echo "1" > "$TEMP_DIR/sub.srt"

for (( i=0; i<$COUNT; i++ )); do
    TEXT=$(echo "$DATA" | jq -r ".data.ayahs[$i].text")
    CHAR_COUNT=${#TEXT}
    DURATION=$(echo "scale=3; ($CHAR_COUNT / $TOTAL_CHARS) * $AUDIO_DURATION" | bc -l)
    START=$CURRENT_OFFSET
    END=$(echo "$CURRENT_OFFSET + $DURATION" | bc)
    
    F_START=$(printf '%02d:%02d:%02d,%03d' $(echo "$START/3600" | bc) $(echo "($START%3600)/60" | bc) $(echo "$START%60" | bc | cut -d. -f1) $(echo "$START*1000/1%1000" | bc))
    F_END=$(printf '%02d:%02d:%02d,%03d' $(echo "$END/3600" | bc) $(echo "($END%3600)/60" | bc) $(echo "$END%60" | bc | cut -d. -f1) $(echo "$END*1000/1%1000" | bc))
    
    echo -e "$F_START --> $F_END\n$TEXT\n" >> "$TEMP_DIR/sub.srt"
    CURRENT_OFFSET=$END
    echo $((i+2)) >> "$TEMP_DIR/sub.srt"
done

# --- الرندر الاحترافي ---
OUTPUT_FILE="$OUTPUT_DIR/Quran_Cinema_$(date +%s).mp4"
echo -e "${P}🚀 البدء في إنتاج الفيديو (رندر سينمائي)...${NC}"

ffmpeg -hide_banner -loglevel error -stats -y \
-stream_loop -1 -i "$TEMP_DIR/bg.mp4" \
-i "$AUDIO_INPUT" \
-filter_complex \
"[1:a]loudnorm=I=-16:TP=-1.5,afade=t=in:st=0:d=2,afade=t=out:st=$(echo "$AUDIO_DURATION-2" | bc):d=2[a]; \
 [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080, \
 vignette=angle=PI/4, \
 eq=brightness=-0.15:contrast=1.2:saturation=1.4, \
 subtitles=$TEMP_DIR/sub.srt:force_style='FontName=$SELECTED_FONT,FontSize=28,PrimaryColour=&H00FFFFFF,OutlineColour=&H80000000,BorderStyle=3,Outline=1,Shadow=2,Alignment=2,MarginV=60', \
 fade=t=in:st=0:d=2,fade=t=out:st=$(echo "$AUDIO_DURATION-2" | bc):d=2[v]" \
-map "[v]" -map "[a]" \
-c:v libx264 -preset fast -crf 20 -c:a aac -b:a 192k -shortest "$OUTPUT_FILE"

# النهاية
rm -rf "$TEMP_DIR"
echo -e "\n${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${G}${BOLD}✅ اكتمل العمل بنجاح! 😍${NC}"
echo -e "${Y}📍 الملف هنا: ${C}$OUTPUT_FILE${NC}"
echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
