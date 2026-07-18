<?php
declare(strict_types=1);

spl_autoload_register(function (string $class): void {
    $paths = [
        __DIR__,
        __DIR__ . '/Core',
        __DIR__ . '/Controllers',
        __DIR__ . '/Models',
        __DIR__ . '/Services',
        __DIR__ . '/Security',
        __DIR__ . '/Support',
    ];

    foreach ($paths as $path) {
        $file = $path . '/' . $class . '.php';

        if (is_file($file)) {
            require_once $file;
            return;
        }
    }
});