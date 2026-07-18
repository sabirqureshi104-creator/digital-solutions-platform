<?php
declare(strict_types=1);

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed.']);
    exit;
}

$name = trim($_POST['name'] ?? '');
$email = filter_var($_POST['email'] ?? '', FILTER_VALIDATE_EMAIL);
$message = trim($_POST['message'] ?? '');

if ($name === '' || !$email || $message === '') {
    http_response_code(422);
    echo json_encode(['success' => false, 'message' => 'Please complete all required fields.']);
    exit;
}

echo json_encode(['success' => true, 'message' => 'Your inquiry has been received.']);
