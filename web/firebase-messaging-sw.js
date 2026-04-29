importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyA86AiKYmy94rm0Sm_0I5Q0kMnqRr4i_ek',
  authDomain: 'sggw-days.firebaseapp.com',
  projectId: 'sggw-days',
  storageBucket: 'sggw-days.firebasestorage.app',
  messagingSenderId: '583939995714',
  appId: '1:583939995714:web:64bb87337df191160755db',
  measurementId: 'G-GX7TTYCPRG',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const title = notification.title || 'Dni SGGW';
  const options = {
    body: notification.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  };

  self.registration.showNotification(title, options);
});
