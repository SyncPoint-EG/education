# SPEC: game.html — شاشة اللعبة (التخاطب)

## الملف: `game.html`
الشاشة الأساسية - التمارين الكلامية.

---

## المتطلبات
```html
<link rel="stylesheet" href="style.css">
<script src="data.js"></script>
```

---

## عند تحميل الصفحة:
```js
const levelId = localStorage.getItem('selectedLevel');
const level = LEVELS_DATA.find(l => l.id == levelId);
const exercises = level.exercises; // مصفوفة التمارين
let currentExIndex = 0;
let score = 0; // عدد الإجابات الصح
```

---

## تصميم الشاشة العام

### Header:
```
┌─────────────────────────────┐
│ [←]  الحيوانات 🐾  [2 / 5] │
│ ████████░░░░░░░░ Progress   │
└─────────────────────────────┘
```
- `[←]` → `window.history.back()`
- Progress bar تتحدث مع كل تمرين
- اللون بيتأخذ من `level.color`

---

## Progress Bar:
```css
.progress-bar {
  height: 10px; background: #E0E0E0; border-radius: 999px;
  margin: 8px 16px;
}
.progress-fill {
  height: 100%; border-radius: 999px;
  background: linear-gradient(90deg, var(--primary), var(--yellow));
  transition: width 0.5s ease;
}
```

---

## منطقة التمرين (تتغير حسب نوع التمرين)

### النوع 1: `listen_repeat` — استمع وكرر

```
┌─────────────────────────────┐
│                             │
│     [الإيموجي 120px]        │  ← anim-float
│                             │
│    🎧 استمع للكلمة          │  ← instruction text
│                             │
│  ┌─────────────────────────┐│
│  │   [🔊 اسمع الكلمة]      ││  ← btn-blue → speak(word)
│  └─────────────────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   [🎤 قول الكلمة]       ││  ← btn-primary → startListening
│  └─────────────────────────┘│
│                             │
│     💡 تلميح: (...hint...)   │  ← يظهر بعد ثانيتين
└─────────────────────────────┘
```

### النوع 2: `describe_image` — وصف صورة
```
┌─────────────────────────────┐
│                             │
│    [الإيموجي 120px]         │
│                             │
│   📝 وصف اللي شايفه         │
│                             │
│  ┌─────────────────────────┐│
│  │   [🎤 ابدأ الكلام]       ││
│  └─────────────────────────┘│
│                             │
│  ✅ كلمات زي: شجرة، خضرا   │  ← expectedWords (hint)
└─────────────────────────────┘
```

### النوع 3: `answer_question` — أجب على السؤال
```
┌─────────────────────────────┐
│                             │
│    [الإيموجي 120px]         │
│                             │
│  💬 "إيه صوت الكلب؟"        │  ← prompt في بالون كلام
│                             │
│  ┌─────────────────────────┐│
│  │   [🔊 اسمع السؤال]      ││  ← speak(prompt)
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │   [🎤 جاوب]             ││  ← startListening
│  └─────────────────────────┘│
└─────────────────────────────┘
```

---

## حالة الاستماع (Recording State)

بعد ضغط أي زرار 🎤:
```
┌─────────────────────────────┐
│     [الإيموجي]              │
│                             │
│      🎤 بسمعك...            │  ← نص يومض
│                             │
│  ┌──────────────────────── ┐│
│  │ ●  ●  ●  ●  ●  ●  ●   ││  ← sound wave animation (CSS bars)
│  └─────────────────────────┘│
│                             │
│   [إلغاء]                   │
└─────────────────────────────┘
```

**Sound Wave CSS:**
```css
.wave-bars { display: flex; gap: 4px; align-items: center; height: 40px; }
.wave-bar  { width: 6px; background: var(--primary); border-radius: 3px; animation: waveAnim 0.6s ease-in-out infinite; }
.wave-bar:nth-child(2) { animation-delay: 0.1s; }
.wave-bar:nth-child(3) { animation-delay: 0.2s; }
/* إلخ */

@keyframes waveAnim { 0%,100%{height:8px} 50%{height:32px} }
```

---

## Feedback (نتيجة الإجابة)

### ✅ إجابة صح (`perfect` أو `good`):
```
┌─────────────────────────────┐
│                             │
│         ⭐                  │  ← starPop animation
│                             │
│     🎉 ممتاز! أحسنت!       │  ← نص كبير أخضر
│                             │
│    قلت: "قطة" ✓             │  ← ما قاله الطفل
│                             │
│  ┌─────────────────────────┐│
│  │   التالي ←              ││  ← btn-primary
│  └─────────────────────────┘│
└─────────────────────────────┘
```
- خلفية تومض بالأخضر لحظة
- confetti (CSS particles) بتتساقط من فوق

**Confetti CSS:**
```css
.confetti-piece { position: absolute; width: 10px; height: 10px; border-radius: 2px; animation: confettiFall 1s ease-in forwards; }
@keyframes confettiFall { from{top:-10px; opacity:1} to{top:100%; opacity:0; transform:rotate(720deg)} }
```
ألوان مختلفة، positions عشوائية، delays مختلفة.

### ❌ إجابة غلط:
```
┌─────────────────────────────┐
│    [الإيموجي anim-shake]    │
│                             │
│     😅 مش بأس! جرب تاني    │  ← نص
│                             │
│    الكلمة الصح: "قطة"       │  ← اعرض الإجابة
│  ┌──────────┐ ┌────────────┐│
│  │ 🔊 اسمع ││ │ 🎤 جرب تاني││
│  └──────────┘ └────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   تخطي ←                ││  ← btn صغير رمادي
│  └─────────────────────────┘│
└─────────────────────────────┘
```

---

## نهاية المستوى (Level Complete Screen)

بعد كل التمارين:
```
┌─────────────────────────────┐
│                             │
│        🎊 أحسنت! 🎊         │
│    أتممت مستوى الحيوانات   │
│                             │
│      ⭐  ⭐  ⭐              │  ← النجوم بتظهر واحدة واحدة
│                             │
│  ┌────────┐ ┌──────────────┐│
│  │🪙 +30  │ │   💎 +1      ││  ← المكافآت
│  └────────┘ └──────────────┘│
│                             │
│  ┌─────────────────────────┐│
│  │   ↩️ الرجوع للخريطة    ││  ← btn-primary
│  └─────────────────────────┘│
│  ┌─────────────────────────┐│
│  │   🔄 العب تاني          ││  ← btn-secondary (صغير)
│  └─────────────────────────┘│
└─────────────────────────────┘
```

### حساب النجوم:
```js
const total = exercises.length;
let stars = 0;
if (score === total)          stars = 3;
else if (score >= total * 0.6) stars = 2;
else if (score > 0)            stars = 1;
```

### الحفظ:
```js
completeLevel(levelId, stars); // من data.js
```

### الزرار "الرجوع للخريطة":
```js
window.location.href = 'map.html';
```

---

## ملاحظات مهمة
- `speak()` تشتغل تلقائي لما تظهر كل تمرين (بعد 0.5 ثانية)
- لو المتصفح مش بيدعم Speech Recognition: اعرض زرار "تخطي" بدل التسجيل
- كل الـ buttons لازم تكون `min-height: 56px` (accessibility)
- الـ emoji الكبير لازم يكون `user-select: none`
