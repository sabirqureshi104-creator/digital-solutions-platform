<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';

$host = '127.0.0.1';
$port = '3306';
$dbName = 'digital_solutions';
$username = 'root';
$password = '';

$dsn = "mysql:host={$host};port={$port};dbname={$dbName};charset=utf8mb4";

try {
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $exception) {
    http_response_code(500);
    exit('Database connection failed.');
}
