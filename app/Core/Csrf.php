<?php
declare(strict_types=1);

final class Csrf
{
    public static function token(): string
    {
        Session::start();

        if (empty($_SESSION['_token'])) {
            $_SESSION['_token'] = bin2hex(random_bytes(32));
        }

        return $_SESSION['_token'];
    }

    public static function verify(?string $token): bool
    {
        Session::start();

        return is_string($token)
            && isset($_SESSION['_token'])
            && hash_equals($_SESSION['_token'], $token);
    }
}
