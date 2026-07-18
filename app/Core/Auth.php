<?php
declare(strict_types=1);

final class Auth
{
    public static function attempt(string $email, string $password): bool
    {
        Session::start();

        $user = User::findByEmail($email);

        if (!$user || !password_verify($password, $user['password'])) {
            return false;
        }

        Session::regenerate();

        $_SESSION['user_id'] = (int) $user['id'];
        $_SESSION['user_name'] = $user['name'];
        $_SESSION['user_email'] = $user['email'];

        User::touchLastLogin((int) $user['id']);

        return true;
    }

    public static function check(): bool
    {
        Session::start();
        return isset($_SESSION['user_id']);
    }

    public static function user(): ?array
    {
        if (!self::check()) {
            return null;
        }

        return [
            'id' => (int) $_SESSION['user_id'],
            'name' => (string) ($_SESSION['user_name'] ?? ''),
            'email' => (string) ($_SESSION['user_email'] ?? ''),
        ];
    }

    public static function logout(): void
    {
        Session::destroy();
    }
}
