<?php
declare(strict_types=1);

final class User
{
    public static function findByEmail(string $email): ?array
    {
        $statement = Database::connection()->prepare(
            'SELECT id, name, email, password, status
             FROM users
             WHERE email = :email
             LIMIT 1'
        );

        $statement->execute(['email' => strtolower(trim($email))]);
        $user = $statement->fetch();

        if (!$user || $user['status'] !== 'active') {
            return null;
        }

        return $user;
    }

    public static function touchLastLogin(int $id): void
    {
        $statement = Database::connection()->prepare(
            'UPDATE users SET last_login_at = NOW() WHERE id = :id'
        );

        $statement->execute(['id' => $id]);
    }
}
