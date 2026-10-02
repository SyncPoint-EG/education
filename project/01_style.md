# SPEC: style.css — النظام البصري المشترك

## الملف: `style.css`
يُستورد في كل صفحة. يحتوي على كل المتغيرات والمكونات المشتركة.

---

## 1. Google Fonts Import
```css
@import url('https://fonts.googleapis.com/css2?family=Fredoka+One&family=Tajawal:wght@400;500;700;800&display=swap');
```

---

## 2. CSS Variables
```css
:root {
  --primary: #4CAF50;
  --primary-dark: #388E3C;
  --secondary: #FF9800;
  --accent: #E91E8C;
  --blue: #2196F3;
  --blue-dark: #1565C0;
  --purple: #9C27B0;
  --yellow: #FFC107;
  --red: #F44336;

  --bg-main: #F0F8FF;
  --bg-card: #FFFFFF;
  --text-dark: #2D3436;
  --text-mid: #636e72;
  --text-light: #b2bec3;

  --shadow-sm: 0 2px 8px rgba(0,0,0,0.1);
  --shadow-md: 0 4px 20px rgba(0,0,0,0.15);
  --shadow-lg: 0 8px 32px rgba(0,0,0,0.2);

  --radius-sm: 12px;
  --radius-md: 20px;
  --radius-lg: 32px;
  --radius-full: 999px;

  --font-ar: 'Tajawal', sans-serif;
  --font-game: 'Fredoka One', cursive;
}
```

---

## 3. Reset & Base
```css
* { margin: 0; padding: 0; box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
html, body { width: 100%; height: 100%; overflow: hidden; font-family: var(--font-ar); direction: rtl; background: var(--bg-main); }
```

---

## 4. App Frame (Mobile Container)
```css
.app-frame {
  width: 100%;
  max-width: 430px;
  height: 100dvh;
  margin: 0 auto;
  position: relative;
  overflow: hidden;
  background: var(--bg-main);
}
```

---

## 5. Buttons
كل زرار له:
- شكل pill (`border-radius: var(--radius-full)`)
- ظل تحيه (3D press effect)
- حركة `active` تضغطه لتحت

```css
.btn { ... padding: 14px 28px; font-size: 18px; font-weight: 700; cursor: pointer; }
.btn:active { transform: translateY(3px) scale(0.98); box-shadow: 0 1px 0 ...; }

.btn-primary  { background: linear-gradient(135deg, #4CAF50, #388E3C); box-shadow: 0 4px 0 #2E7D32; }
.btn-secondary { background: linear-gradient(135deg, #FF9800, #F57C00); box-shadow: 0 4px 0 #E65100; }
.btn-blue     { background: linear-gradient(135deg, #2196F3, #1565C0); box-shadow: 0 4px 0 #0D47A1; }
.btn-red      { background: linear-gradient(135deg, #F44336, #C62828); box-shadow: 0 4px 0 #B71C1C; }
```

---

## 6. Animations
```css
@keyframes bounce    { 0%,100% { transform: translateY(0) } 50% { transform: translateY(-8px) } }
@keyframes pulse     { 0%,100% { transform: scale(1) }     50% { transform: scale(1.05) } }
@keyframes float     { 0%,100% { transform: translateY(0) } 50% { transform: translateY(-12px) } }
@keyframes fadeInUp  { from { opacity:0; transform:translateY(20px) } to { opacity:1; transform:translateY(0) } }
@keyframes starPop   { 0% { transform:scale(0) rotate(-30deg); opacity:0 } 70% { transform:scale(1.3) rotate(10deg) } 100% { transform:scale(1) rotate(0); opacity:1 } }
@keyframes spin      { from { transform:rotate(0deg) } to { transform:rotate(360deg) } }
@keyframes shake     { 0%,100%{transform:translateX(0)} 25%{transform:translateX(-8px)} 75%{transform:translateX(8px)} }

.anim-bounce   { animation: bounce 2s ease-in-out infinite; }
.anim-pulse    { animation: pulse 2s ease-in-out infinite; }
.anim-float    { animation: float 3s ease-in-out infinite; }
.anim-fadeInUp { animation: fadeInUp 0.5s ease forwards; }
.anim-shake    { animation: shake 0.4s ease; }
```

---

## 7. Stars Component
```css
.stars-row { display: flex; gap: 6px; }
.star { font-size: 22px; filter: grayscale(1) brightness(1.5); transition: all 0.3s; }
.star.earned { filter: none; animation: starPop 0.5s ease forwards; }
```

---

## 8. Currency Chips (ذهب + جواهر)
```css
.currency-bar { display: flex; gap: 8px; }
.currency-chip { display: flex; align-items: center; gap: 6px; background: rgba(255,255,255,0.9); border-radius: var(--radius-full); padding: 6px 14px 6px 6px; font-weight: 800; font-size: 15px; }
.chip-gold .icon { background: linear-gradient(135deg, #FFD700, #FFA000); border-radius: 50%; }
.chip-gem  .icon { background: linear-gradient(135deg, #E91E8C, #9C27B0); border-radius: 50%; }
```

---

## 9. Bottom Nav Bar
```css
.nav-bar {
  position: absolute; bottom: 0; left: 0; right: 0;
  height: 72px; background: white;
  border-radius: 24px 24px 0 0;
  box-shadow: 0 -4px 20px rgba(0,0,0,0.1);
  display: flex; align-items: center; justify-content: space-around;
}

/* 4 items: profile - leaderboard - MAP(center) - settings */
.nav-item { flex-direction: column; color: var(--text-light); font-size: 11px; font-weight: 700; }
.nav-item.active { color: var(--primary); }

/* زرار الخريطة في النص رافع لفوق */
.nav-item.nav-center {
  background: linear-gradient(135deg, #4CAF50, #388E3C);
  color: white; border-radius: 50%;
  width: 60px; height: 60px;
  box-shadow: 0 4px 0 #2E7D32;
  margin-top: -20px;
}
```

---

## ملاحظات مهمة
- كل الأيقونات تستخدم Emoji (بدون مكتبات خارجية)
- كل حاجة RTL
- لا تستخدم `overflow: hidden` على `body` - استخدمه على `.app-frame` بس
