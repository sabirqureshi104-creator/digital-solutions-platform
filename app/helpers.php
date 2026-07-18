<?php
declare(strict_types=1);

function url(string $path = ''): string
{
    return rtrim(Config::APP_URL, '/') . '/' . ltrim($path, '/');
}

function route_url(string $route = ''): string
{
    return $route === ''
        ? url()
        : url('?route=' . urlencode($route));
}

function asset(string $path): string
{
    return url('assets/' . ltrim($path, '/'));
}

function e(mixed $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function redirect(string $location): never
{
    header('Location: ' . $location);
    exit;
}

function component(string $name, array $data = []): void
{
    $file = dirname(__DIR__) . '/components/' . $name . '.php';

    if (!is_file($file)) {
        throw new RuntimeException("Component not found: {$name}");
    }

    extract($data, EXTR_SKIP);
    require $file;
}