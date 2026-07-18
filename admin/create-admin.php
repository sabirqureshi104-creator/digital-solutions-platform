<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/bootstrap.php';

$message = '';
$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!Csrf::verify($_POST['_token'] ?? null)) {
        $error = 'Invalid session token.';
    } else {
        $name = trim((string) ($_POST['name'] ?? ''));
        $email = strtolower(trim((string) ($_POST['email'] ?? '')));
        $password = (string) ($_POST['password'] ?? '');

        if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 8) {
            $error = 'Use a valid name, email, and password of at least 8 characters.';
        } else {
            try {
                $statement = Database::connection()->prepare(
                    'INSERT INTO users (name, email, password, status)
                     VALUES (:name, :email, :password, "active")'
                );

                $statement->execute([
                    'name' => $name,
                    'email' => $email,
                    'password' => password_hash($password, PASSWORD_DEFAULT),
                ]);

                $message = 'Admin account created. Delete create-admin.php now.';
            } catch (PDOException $exception) {
                $error = 'Could not create the account. The email may already exist.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Admin</title>
    <link rel="stylesheet" href="assets/css/admin.css">
</head>
<body class="auth-page">
<main class="auth-card">
    <h1>Create Admin</h1>

    <?php if ($message): ?><div class="success"><?= htmlspecialchars($message) ?></div><?php endif; ?>
    <?php if ($error): ?><div class="alert"><?= htmlspecialchars($error) ?></div><?php endif; ?>

    <form method="post" class="auth-form">
        <input type="hidden" name="_token" value="<?= Csrf::token() ?>">
        <label>Name<input name="name" required></label>
        <label>Email<input type="email" name="email" required></label>
        <label>Password<input type="password" name="password" minlength="8" required></label>
        <button type="submit">Create account</button>
    </form>
</main>
</body>
</html>
