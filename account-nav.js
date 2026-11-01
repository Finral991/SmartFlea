import { auth, db, doc, getDoc, onAuthStateChanged, updateDoc, serverTimestamp } from './firebase.js';

export function attachAccountNav(root = '') {
  const slot = document.querySelector('[data-account-nav]');
  if (!slot) return;
  const loginUrl = `${root}views/login.html`;
  const profileUrl = `${root}views/profile.html`;
  const adminUrl = `${root}views/admin.html`;

  onAuthStateChanged(auth, async user => {
    if (!user) { slot.innerHTML = `<a href="${loginUrl}">LOG IN</a>`; return; }
    const snapshot = await getDoc(doc(db, 'users', user.uid));
    if (!snapshot.exists()) { slot.innerHTML = `<a href="${profileUrl}">PROFILE</a>`; return; }
    const profile = snapshot.data();
    await updateDoc(doc(db, 'users', user.uid), { online: true, lastSeen: serverTimestamp() });
    slot.innerHTML = `<a href="${profileUrl}" title="My profile">PROFILE</a>`;
  });
}
