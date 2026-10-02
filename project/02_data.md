# SPEC: data.js — بيانات اللعبة (محلية)

## الملف: `data.js`
يُستورد في كل صفحة. يدير كل البيانات عبر localStorage.

---

## 1. هيكل بيانات المستخدم (localStorage key: `user`)
```json
{
  "name": "أحمد",
  "avatar": "🐸",
  "gold": 120,
  "gems": 5,
  "currentLevel": 3,
  "completedLevels": {
    "1": { "stars": 3, "completed": true },
    "2": { "stars": 2, "completed": true },
    "3": { "stars": 1, "completed": true }
  },
  "totalSessions": 12,
  "createdAt": "2026-06-01"
}
```

---

## 2. بيانات المستويات (LEVELS_DATA)
مصفوفة من 16 مستوى. كل مستوى:

```js
{
  id: 1,
  title: "الحيوانات",
  emoji: "🐾",
  color: "#4CAF50",
  bgColor: "#E8F5E9",
  exercises: [
    {
      id: "1-1",
      type: "listen_repeat",   // استمع وكرر
      prompt: "قول: قطة 🐱",
      word: "قطة",
      audio: null,             // مفيش audio - بيعتمد على Web Speech API
      image: "🐱",
      hint: "الحيوان اللي بيموء"
    },
    {
      id: "1-2",
      type: "describe_image",  // وصف صورة
      prompt: "وصف اللي شايفه",
      image: "🌳",
      expectedWords: ["شجرة", "خضرا", "كبير"]
    },
    {
      id: "1-3",
      type: "answer_question", // إجابة سؤال
      prompt: "إيه صوت الكلب؟",
      image: "🐶",
      expectedAnswer: "هاو",
      hint: "الكلب بيقول..."
    }
  ]
}
```

**المستويات الـ 16:**
| ID | العنوان | الإيموجي | اللون |
|----|---------|---------|-------|
| 1  | الحيوانات | 🐾 | #4CAF50 |
| 2  | الفواكه | 🍎 | #FF9800 |
| 3  | الألوان | 🎨 | #9C27B0 |
| 4  | الأرقام | 🔢 | #2196F3 |
| 5  | الجسم | 👀 | #F44336 |
| 6  | المواصلات | 🚗 | #009688 |
| 7  | الطقس | ⛅ | #03A9F4 |
| 8  | الملابس | 👕 | #E91E8C |
| 9  | الطعام | 🍕 | #FF5722 |
| 10 | المشاعر | 😊 | #FFC107 |
| 11 | المنزل | 🏠 | #795548 |
| 12 | المدرسة | 📚 | #3F51B5 |
| 13 | الطبيعة | 🌿 | #8BC34A |
| 14 | الأشكال | ⭐ | #FF4081 |
| 15 | الأسرة | 👨‍👩‍👧 | #607D8B |
| 16 | المهن | 👨‍⚕️ | #FF6F00 |

---

## 3. دوال localStorage

```js
// تحميل بيانات المستخدم
function getUser() {
  const raw = localStorage.getItem('user');
  if (!raw) return null;
  return JSON.parse(raw);
}

// حفظ بيانات المستخدم
function saveUser(userData) {
  localStorage.setItem('user', JSON.stringify(userData));
}

// إنشاء مستخدم جديد
function createUser(name, avatar) {
  const user = {
    name, avatar, gold: 0, gems: 0,
    currentLevel: 1, completedLevels: {},
    totalSessions: 0, createdAt: new Date().toISOString().split('T')[0]
  };
  saveUser(user);
  return user;
}

// إضافة ذهب
function addGold(amount) {
  const user = getUser();
  user.gold += amount;
  saveUser(user);
}

// إضافة جواهر
function addGems(amount) {
  const user = getUser();
  user.gems += amount;
  saveUser(user);
}

// تسجيل إنهاء مستوى
function completeLevel(levelId, stars) {
  const user = getUser();
  const prev = user.completedLevels[levelId];
  // احتفظ بأعلى نجوم
  if (!prev || prev.stars < stars) {
    user.completedLevels[levelId] = { stars, completed: true };
  }
  // افتح المستوى التالي
  if (levelId >= user.currentLevel) {
    user.currentLevel = levelId + 1;
  }
  user.totalSessions += 1;
  // مكافأة ذهب
  user.gold += stars * 10;
  if (stars === 3) user.gems += 1;
  saveUser(user);
}

// حساب المستوى مفتوح ولا لا
function isLevelUnlocked(levelId) {
  const user = getUser();
  if (!user) return false;
  return levelId <= user.currentLevel;
}

// حذف بيانات المستخدم (ريست)
function resetUser() {
  localStorage.removeItem('user');
}
```

---

## 4. Web Speech API (للتخاطب)

```js
// تشغيل صوت (Text-to-Speech)
function speak(text, onEnd) {
  const synth = window.speechSynthesis;
  synth.cancel();
  const utter = new SpeechSynthesisUtterance(text);
  utter.lang = 'ar-EG';
  utter.rate = 0.8;
  utter.pitch = 1.1;
  if (onEnd) utter.onend = onEnd;
  synth.speak(utter);
}

// التعرف على الصوت (Speech-to-Text)
function startListening(onResult, onError) {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SpeechRecognition) {
    onError('المتصفح مش بيدعم التعرف على الصوت');
    return null;
  }
  const recog = new SpeechRecognition();
  recog.lang = 'ar-EG';
  recog.interimResults = false;
  recog.maxAlternatives = 3;
  recog.onresult = (e) => {
    const results = Array.from(e.results[0]).map(r => r.transcript.trim());
    onResult(results);
  };
  recog.onerror = (e) => onError(e.error);
  recog.start();
  return recog;
}

// مقارنة إجابة الطفل بالإجابة الصحيحة
function checkAnswer(spoken, expected) {
  const normalize = str => str.trim().replace(/[^\u0621-\u064A\u0660-\u0669a-zA-Z0-9]/g, '').toLowerCase();
  const spokenClean = normalize(spoken);
  const expectedClean = normalize(expected);
  if (spokenClean === expectedClean) return 'perfect';
  if (spokenClean.includes(expectedClean) || expectedClean.includes(spokenClean)) return 'good';
  return 'wrong';
}
```

---

## 5. الملف الكامل (data.js)
اكتب الملف بهذا الترتيب:
1. `const LEVELS_DATA = [...]` — كل المستويات
2. دوال localStorage
3. دوال Web Speech API
4. `export` لا تستخدمه — كل الدوال global
