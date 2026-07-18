<?php
declare(strict_types=1);

class View
{
    public static function render(string $page, array $data = [], string $layout = 'default'): void
    {
        extract($data);

        require __DIR__ . '/../layouts/' . $layout . '.php';
    }
}