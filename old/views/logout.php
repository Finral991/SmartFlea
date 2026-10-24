<?php

session_start();

require 'src/auth.php';

logout();

header(string: 'Location: /login.php');