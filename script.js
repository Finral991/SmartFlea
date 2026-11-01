<<<<<<< HEAD
 // Посилання на кнопку та контейнер для фото
 const showPhotosButton = document.querySelector('#show-photos-btn');
 const photosContainer = document.querySelector('#photos-container');
 
 // Масив з URL-адресами фотографій та назвами файлів
 const photoUrls = [
   {url: 'images/OIP44.jpg', name: 'Фото 1'},
   {url: 'images/OIP55.jpg', name: 'Фото 2'},
   {url: 'images/OIP88.jpg', name: 'Фото 3'},
   {url: 'images/OIP.jpg', name: 'Фото 4'},
   {url: 'images/OIP2.jpg', name: 'Фото 5'},
   {url: 'images/OIP3.jpg', name: 'Фото 6'},
   {url: 'images/OIP4.jpg', name: 'Фото 7'},
   {url: 'images/OIP5.jpg', name: 'Фото 8'},
   {url: 'images/OIP6.jpg', name: 'Фото 9'},
   {url: 'images/OIP7.jpg', name: 'Фото 10'},
   {url: 'images/OIP8.jpg', name: 'Фото 11'},
   {url: 'images/OIP9.jpg', name: 'Фото 12'},
   {url: 'images/OIP11.jpg', name: 'Фото 13'},
   {url: 'images/OIP22.jpg', name: 'Фото 14'},
 ];
 
 showPhotosButton.addEventListener('click', () => {
     photoUrls.forEach(photoUrl => {
       // Створюємо посилання на нову сторінку
       const link = document.createElement('a');
       link.href = `photo.html?url=${photoUrl}`;
   
       // Створюємо зображення
       const img = document.createElement('img');
       img.src = photoUrl;
       img.alt = 'Фото';
       link.appendChild(img);
   
       // Додаємо посилання з зображенням до контейнера
       photosContainer.appendChild(link);
     });
   });
=======
 // Посилання на кнопку та контейнер для фото
 const showPhotosButton = document.querySelector('#show-photos-btn');
 const photosContainer = document.querySelector('#photos-container');
 
 // Масив з URL-адресами фотографій та назвами файлів
 const photoUrls = [
   {url: 'images/OIP44.jpg', name: 'Фото 1'},
   {url: 'images/OIP55.jpg', name: 'Фото 2'},
   {url: 'images/OIP88.jpg', name: 'Фото 3'},
   {url: 'images/OIP.jpg', name: 'Фото 4'},
   {url: 'images/OIP2.jpg', name: 'Фото 5'},
   {url: 'images/OIP3.jpg', name: 'Фото 6'},
   {url: 'images/OIP4.jpg', name: 'Фото 7'},
   {url: 'images/OIP5.jpg', name: 'Фото 8'},
   {url: 'images/OIP6.jpg', name: 'Фото 9'},
   {url: 'images/OIP7.jpg', name: 'Фото 10'},
   {url: 'images/OIP8.jpg', name: 'Фото 11'},
   {url: 'images/OIP9.jpg', name: 'Фото 12'},
   {url: 'images/OIP11.jpg', name: 'Фото 13'},
   {url: 'images/OIP22.jpg', name: 'Фото 14'},
 ];
 
 showPhotosButton.addEventListener('click', () => {
     photoUrls.forEach(photoUrl => {
       // Створюємо посилання на нову сторінку
       const link = document.createElement('a');
       link.href = `photo.html?url=${photoUrl}`;
   
       // Створюємо зображення
       const img = document.createElement('img');
       img.src = photoUrl;
       img.alt = 'Фото';
       link.appendChild(img);
   
       // Додаємо посилання з зображенням до контейнера
       photosContainer.appendChild(link);
     });
   });
>>>>>>> 132febc4c97488c94d9e0eacaefca2cfef479bb6
 