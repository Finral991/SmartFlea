import { initializeApp } from 'https://www.gstatic.com/firebasejs/12.10.0/firebase-app.js';
import { getAuth, onAuthStateChanged, createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut, updateProfile } from 'https://www.gstatic.com/firebasejs/12.10.0/firebase-auth.js';
import { getFirestore, doc, getDoc, setDoc, updateDoc, serverTimestamp, collection, addDoc, deleteDoc, getDocs, query, where, orderBy, limit, onSnapshot } from 'https://www.gstatic.com/firebasejs/12.10.0/firebase-firestore.js';
import { getStorage, ref, uploadBytes, getDownloadURL } from 'https://www.gstatic.com/firebasejs/12.10.0/firebase-storage.js';

const firebaseConfig = {
  apiKey: 'AIzaSyAZ8Gdfl62J1SYvWjErt5FNxygpOiTMVkY',
  authDomain: 'smartflea.firebaseapp.com',
  projectId: 'smartflea',
  storageBucket: 'smartflea.firebasestorage.app',
  messagingSenderId: '392300906505',
  appId: '1:392300906505:web:45dbdc9c11e7a2f4ae50d8',
  measurementId: 'G-DLCV7XDCCN'
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);

async function createUniqueUsername(fullName) {
  const base = (fullName || 'user').toLowerCase().normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '').slice(0, 18) || 'user';
  let username = base;
  let number = 2;
  while ((await getDocs(query(collection(db, 'users'), limit(100)))).docs.some(item => item.data().username === username)) username = `${base}${number++}`;
  return username;
}

export { auth, db, storage, doc, getDoc, setDoc, updateDoc, serverTimestamp, collection, addDoc, deleteDoc, getDocs, query, where, orderBy, limit, onSnapshot, ref, uploadBytes, getDownloadURL, onAuthStateChanged, createUserWithEmailAndPassword, signInWithEmailAndPassword, signOut, updateProfile, createUniqueUsername };
