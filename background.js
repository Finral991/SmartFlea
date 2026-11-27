import {
  auth,
  db,
  doc,
  getDoc,
  updateDoc,
  onAuthStateChanged,
} from "./firebase.js";

const ACTIVE_KEY = "smartflea-active-bg";
const USER_KEY_PREFIX = "smartflea-bg-";
const GUEST_KEY = "smartflea-bg-guest";

let currentUser = null;

// Apply active background immediately on script evaluation to prevent visual flicker
applyInitialBackground();

function applyInitialBackground() {
  try {
    const active =
      localStorage.getItem(ACTIVE_KEY) ||
      localStorage.getItem("smartflea-background");
    if (active) {
      if (!localStorage.getItem(ACTIVE_KEY)) {
        localStorage.setItem(ACTIVE_KEY, active);
      }
      injectBackgroundStyle(active);
    }
  } catch (err) {
    console.warn("Could not read background from storage:", err);
  }
}

function injectBackgroundStyle(dataUrl) {
  let styleEl = document.getElementById("sf-active-bg-style");
  if (dataUrl) {
    if (!styleEl) {
      styleEl = document.createElement("style");
      styleEl.id = "sf-active-bg-style";
      document.head.appendChild(styleEl);
    }
    styleEl.textContent = `
      body {
        background-image: url("${dataUrl}") !important;
        background-size: cover !important;
        background-position: center center !important;
        background-attachment: fixed !important;
        background-repeat: no-repeat !important;
      }
    `;
    if (document.body) {
      document.body.style.backgroundImage = `url("${dataUrl}")`;
      document.body.style.backgroundSize = "cover";
      document.body.style.backgroundPosition = "center center";
      document.body.style.backgroundAttachment = "fixed";
      document.body.style.backgroundRepeat = "no-repeat";
    }
  } else {
    if (styleEl) styleEl.remove();
    if (document.body) {
      document.body.style.backgroundImage = "";
      document.body.style.backgroundSize = "";
      document.body.style.backgroundPosition = "";
      document.body.style.backgroundAttachment = "";
      document.body.style.backgroundRepeat = "";
    }
  }
}

export function compressBackground(
  file,
  maxWidth = 1920,
  maxHeight = 1080,
  quality = 0.82,
) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onerror = reject;
    reader.onload = (e) => {
      const img = new Image();
      img.onerror = reject;
      img.onload = () => {
        let w = img.width;
        let h = img.height;
        if (w > maxWidth || h > maxHeight) {
          const ratio = Math.min(maxWidth / w, maxHeight / h);
          w = Math.round(w * ratio);
          h = Math.round(h * ratio);
        }
        const canvas = document.createElement("canvas");
        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext("2d");
        ctx.imageSmoothingQuality = "high";
        ctx.drawImage(img, 0, 0, w, h);
        resolve(canvas.toDataURL("image/jpeg", quality));
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  });
}

export async function setCustomBackground(dataUrl) {
  try {
    if (dataUrl) {
      localStorage.setItem(ACTIVE_KEY, dataUrl);
      if (currentUser) {
        localStorage.setItem(`${USER_KEY_PREFIX}${currentUser.uid}`, dataUrl);
        try {
          await updateDoc(doc(db, "users", currentUser.uid), {
            customBg: dataUrl,
          });
        } catch (e) {
          console.warn("Could not save background to Firestore:", e);
        }
      } else {
        localStorage.setItem(GUEST_KEY, dataUrl);
      }
    } else {
      localStorage.removeItem(ACTIVE_KEY);
      localStorage.removeItem("smartflea-background");
      if (currentUser) {
        localStorage.removeItem(`${USER_KEY_PREFIX}${currentUser.uid}`);
        try {
          await updateDoc(doc(db, "users", currentUser.uid), {
            customBg: "",
          });
        } catch (e) {
          console.warn("Could not clear background in Firestore:", e);
        }
      } else {
        localStorage.removeItem(GUEST_KEY);
      }
    }
  } catch (err) {
    console.error("Storage error while setting background:", err);
  }

  injectBackgroundStyle(dataUrl);
}

export function initBackground() {
  onAuthStateChanged(auth, async (user) => {
    currentUser = user;
    if (user) {
      // User is logged in: load their personal background
      let userBg = localStorage.getItem(`${USER_KEY_PREFIX}${user.uid}`);
      try {
        const snap = await getDoc(doc(db, "users", user.uid));
        if (snap.exists()) {
          const profile = snap.data();
          if (profile.customBg) {
            userBg = profile.customBg;
            localStorage.setItem(`${USER_KEY_PREFIX}${user.uid}`, userBg);
          } else if (userBg) {
            // Local background exists for user, sync it to Firestore
            await updateDoc(doc(db, "users", user.uid), {
              customBg: userBg,
            });
          }
        }
      } catch (e) {
        console.warn("Could not check user background from Firestore:", e);
      }

      if (userBg) {
        localStorage.setItem(ACTIVE_KEY, userBg);
        injectBackgroundStyle(userBg);
      } else {
        // No custom background set for this user -> show standard default background!
        localStorage.removeItem(ACTIVE_KEY);
        injectBackgroundStyle(null);
      }
    } else {
      // Guest: check guest background or show default
      const guestBg = localStorage.getItem(GUEST_KEY);
      if (guestBg) {
        localStorage.setItem(ACTIVE_KEY, guestBg);
        injectBackgroundStyle(guestBg);
      } else {
        localStorage.removeItem(ACTIVE_KEY);
        injectBackgroundStyle(null);
      }
    }
  });
}

// Auto-initialize when imported
initBackground();
