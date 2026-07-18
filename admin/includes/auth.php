<?php
declare(strict_types=1);

require_once __DIR__ . '/bootstrap.php';

if (!Auth::check()) {
    header('Location: login.php');
    exit;
}
