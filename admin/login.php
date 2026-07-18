<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

if (Auth::check()) {
    header('Location: dashboard.php');
    exit;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!Csrf::verify($_POST['_token'] ?? null)) {
        $error = 'Your session expired. Please try again.';
    } else {
        $email = trim((string) ($_POST['email'] ?? ''));
        $password = (string) ($_POST['password'] ?? '');

        if (Auth::attempt($email, $password)) {
            header('Location: dashboard.php');
            exit;
        }

        $error = 'Invalid email or password.';
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login</title>
    <link rel="stylesheet" href="assets/css/admin.css">
</head>
<body class="auth-page">
    <main class="auth-card">
        <p class="eyebrow">Digital Solutions Platform</p>
        <h1>Admin Login</h1>

        <?php if ($error !== ''): ?>
            <div class="alert"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></div>
        <?php endif; ?>

        <form method="post" class="auth-form">
            <input type="hidden" name="_token" value="<?= Csrf::token() ?>">

            <label>
                Email
                <input type="email" name="email" autocomplete="email" required>
            </label>

            <label>
                Password
                <input type="password" name="password" autocomplete="current-password" required>
            </label>

            <button type="submit">Sign in</button>
        </form>
    </main>
</body>
</html>
