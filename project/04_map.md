# SPEC: map.html — خريطة المستويات

## الملف: `map.html`
الشاشة الرئيسية - خريطة المستويات زي الصورة المرفقة (Candy Crush style).

---

## المتطلبات
```html
<link rel="stylesheet" href="style.css">
<script src="data.js"></script>
```

---

## التصميم العام

### الخلفية:
```css
background: linear-gradient(180deg, #87CEEB 0%, #98FB98 40%, #90EE90 100%);
```
خلفية طبيعة - سماء زرقا فوق، عشب أخضر تحت، مع:
- نهر/بحيرة صغيرة CSS في المنتصف
- أشجار CSS على الجانبين (مثلثات خضرا)
- سحاب CSS فوق

---

## Header (ثابت فوق)
```
┌─────────────────────────────┐
│ [⚙️]   🪙 120  💎 5    [🐸] │
└─────────────────────────────┘
```
- خلفية: `rgba(255,255,255,0.85)` مع blur
- الأفاتار يأخذ من `getUser().avatar`
- الأرقام تأخذ من `getUser().gold` و `getUser().gems`

---

## مسار المستويات (scrollable)
المستويات مرتبة في zigzag path (متعرج) من تحت لفوق:
- يبدأ المستوى 1 من **أسفل يمين**
- يتعرج لفوق حتى المستوى 16

### شكل كل زرار مستوى:
```
حالة مكتمل (3 نجوم):
  ⭐⭐⭐
  [  7  ]   ← دايرة خضرا 70px
  
حالة مكتمل (1-2 نجوم):
  ⭐⭐☆
  [  7  ]   ← دايرة زرقا 70px

حالة الحالي (current):
  📍
  [  9  ]   ← دايرة خضرا ببضة نبض 80px

حالة مقفول:
  🔒
  [ 10  ]   ← دايرة رمادية 70px opacity 0.6
```

### CSS للدوايا:
```css
.level-btn {
  width: 70px; height: 70px;
  border-radius: 50%;
  border: 4px solid rgba(0,0,0,0.15);
  font-family: var(--font-game);
  font-size: 22px; font-weight: 700;
  color: white;
  cursor: pointer;
  box-shadow: 0 4px 0 rgba(0,0,0,0.2), var(--shadow-md);
  transition: transform 0.2s;
  position: relative;
}

.level-btn.completed  { background: linear-gradient(135deg, #4CAF50, #2E7D32); }
.level-btn.current    { background: linear-gradient(135deg, #FF9800, #E65100); width: 80px; height: 80px; animation: pulse 1.5s infinite; }
.level-btn.locked     { background: linear-gradient(135deg, #9E9E9E, #616161); opacity: 0.7; cursor: not-allowed; }

.level-btn:active:not(.locked) { transform: scale(0.9); }
```

### النجوم فوق كل زرار:
```css
.level-stars {
  position: absolute; top: -18px; left: 50%; transform: translateX(-50%);
  display: flex; gap: 2px; font-size: 14px;
}
```

### المسار (خط متصل):
```css
.path-line {
  position: absolute;
  background: repeating-linear-gradient(90deg, #D2B48C 0, #D2B48C 10px, transparent 10px, transparent 20px);
  height: 8px; border-radius: 4px;
}
```
(خط متقطع بني يربط الدوايا)

---

## Zigzag Layout (16 مستوى)
```
الصف 1 (من فوق): 16 - 15 - 14
الصف 2:          13 - 12 - 11
الصف 3:          10 - 9  - 8
الصف 4:           7 - 6  - 5
الصف 5:           4 - 3  - 2
الصف 6:               1
```
كل صف بيتعاكس الاتجاه (RTL → LTR → RTL...)

**التنفيذ:** استخدم `position: absolute` مع coordinates محسوبة، مش flexbox.

الـ scroll container: `overflow-y: auto; padding-bottom: 100px; padding-top: 80px;`

---

## عند الضغط على مستوى مفتوح:
```js
// حفظ المستوى المختار
localStorage.setItem('selectedLevel', levelId);
// الانتقال للعبة
window.location.href = 'game.html';
```

---

## عند الضغط على مستوى مقفول:
اعرض popup صغير:
```
┌──────────────────────┐
│  🔒 مستوى مقفول!    │
│  أكمل المستوى اللي  │
│  قبله الأول 😊      │
│      [تمام]          │
└──────────────────────┘
```

---

## Bottom Nav Bar
```
[👤 ملفي]  [🏆 ترتيب]  [🗺️ الخريطة★]  [⚙️ إعدادات]
```
- "الخريطة" هو active
- الزرار في النص كبير ورافع لفوق
- "ملفي" → `window.location = 'profile.html'`

---

## عناصر الخلفية (CSS فقط):
```css
/* سحابة */
.cloud { background: white; border-radius: 50px; opacity: 0.8; animation: float 4s ease-in-out infinite; }

/* شجرة */
.tree-trunk { background: #795548; }
.tree-top   { background: #4CAF50; clip-path: polygon(50% 0%, 0% 100%, 100% 100%); }

/* نهر */
.river { background: linear-gradient(90deg, #64B5F6, #42A5F5); border-radius: 40px; opacity: 0.7; }
```
