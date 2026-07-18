<?php
declare(strict_types=1);

final class View
{
    public static function render(
        string $page,
        array $data = [],
        string $layout = 'default'
    ): void {
        $pageFile = dirname(__DIR__) . '/pages/' . $page . '.php';
        $layoutFile = dirname(__DIR__) . '/layouts/' . $layout . '.php';

        if (!is_file($pageFile) || !is_file($layoutFile)) {
            throw new RuntimeException('View file not found.');
        }

        extract($data, EXTR_SKIP);

        require $layoutFile;
    }
}