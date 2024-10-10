importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

const firebaseConfig = {
  apiKey: "AIzaSyCAbBDzbNUrbyK9f_vcYOeA_yG1vSxBuHg",
  authDomain: "fyp-project-6a908.firebaseapp.com",
  projectId: "fyp-project-6a908",
  storageBucket: "fyp-project-6a908.appspot.com",
  messagingSenderId: "240403571417",
  appId: "1:240403571417:web:f4d2d20c9f37d620ae54c8",
  measurementId: "G-FS0F0DZ9N8"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});