<?php
session_start();
require 'src/auth.php';
require 'src/subscription.php';
// Авторизуємо користувача, якщо в запиті є логін і пароль
if (isset($_POST['login']) && isset($_POST['password'])) {
 login($_POST['login'], $_POST['password']);
}
?>
<!doctype html>
<html lang="en">
<head>
 <meta charset="utf-8">
 <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
 <meta name="description" content="">
 <title>Sign in</title>
 <link href="https://getbootstrap.com/docs/4.4/dist/css/bootstrap.min.css" rel="stylesheet">
 <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f5f5f5;
      background-image: url('R.jpg');
      background-repeat: no-repeat;
      background-size: cover;
      
    }
    
    .container {
      max-width: 400px;
      margin: 0 auto;
      padding: 20px;
      border: 2px solid #ff9800;
      border-radius: 10px;
      background-color: rgba(0, 0, 0, 0.7);
      color: #fff;
      text-align: center;
      margin-top: 100px;
      
    }
    
    h1 {
      font-size: 36px;
      margin-bottom: 20px;
      text-shadow: 2px 2px 4px #000;
      color: #fff;
      background-color: #000;
    }
    
    .form-group {
      margin-bottom: 20px;
      background-color: #000;
    }
    
    .form-control {
      border-radius: 5px;
      
    }
    
    .btn {
      background-color: #ff9800;
      color: #fff;
      border-radius: 5px;
      transition: background-color 0.3s ease;
      
    }
    
    .btn:hover {
      background-color: #ff5722;
      
    }
    .form-check-label {
      color: #fff;
    }
  </style>
</head>
<body class="vh-100">
<?php if (isAuthorized()): ?>
 <?php require 'views/admin.php' ?>
<?php else: ?>
 <?php require 'views/login.php' ?>
<?php endif; ?>
</body>
</html>

