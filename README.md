# 🕋 Quran Video Engine v5.0 (Cinema Edition)

![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Termux%20%7C%20Linux-blue)
![Version](https://img.shields.io/badge/Version-5.0-orange)
![FFmpeg](https://img.shields.io/badge/Powered%20By-FFmpeg-red)

أداة احترافية (Bash Script) متطورة لتحويل ملفات الصوت القرآنية (MP3) إلى فيديوهات سينمائية عالية الجودة (1080p) مع ترجمة الآيات تلقائياً، مصممة خصيصاً لتعمل بكفاءة عالية على **تيرمكس (Termux)** وأنظمة **لينكس**.

---

## 🌟 المميزات (Features)

* **🎬 خلفيات Pexels الذكية:** جلب تلقائي لفيديوهات طبيعية 4K/FHD بناءً على الكلمات المفتاحية (Nature, Galaxy, Sea..).
* **📖 مزامنة نصية فورية:** جلب الآيات من `AlQuran Cloud API` ومطابقتها مع التوقيت الصوتي بدقة.
* **🎞️ إخراج سينمائي:** * إضافة تأثير **Vignette** (الظلال الجانبية للفيديو).
    * تعديل الألوان والتشبع (Saturation) لإعطاء مظهر فخم.
    * تأثيرات **Fade In/Out** للصوت والصورة.
* **🔤 نظام الخطوط الذكي (GitHub Fallback):** إذا لم يجد السكربت خطوطاً في نظامك، سيقوم تلقائياً بسحب خط **Amiri Bold** الفاخر من GitHub لضمان ظهور النص بأجمل شكل.
* **🔄 تكرار لا نهائي (Loop):** فيديو الخلفية يتكرر تلقائياً ليلائم طول الملف الصوتي مهما بلغت مدته.
* **🎨 واجهة TUI:** واجهة مستخدم رسومية داخل التيرمينال مع مؤشرات تحميل (Spinners) وألوان تفاعلية.

---

## 🛠️ المتطلبات (Prerequisites)

تأكد من تثبيت الأدوات التالية قبل التشغيل:

### على Termux:
```bash
pkg install ffmpeg curl jq sox bc -y
