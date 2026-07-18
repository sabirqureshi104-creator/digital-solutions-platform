<?php
declare(strict_types=1);

function config(string $key): mixed
{
    return defined("Config::$key") ? constant("Config::$key") : null;
}

function url(string $path = ''): string
{
    return rtrim(Config::APP_URL, '/') . '/' . ltrim($path, '/');
}

function asset(string $path): string
{
    return url('assets/' . ltrim($path, '/'));
}

function redirect(string $path): never
{
    header('Location: ' . url($path));
    exit;
}

function dd(mixed $value): never
{
    echo '<pre>';
    var_dump($value);
    echo '</pre>';
    exit;
}

function loadComponents(): void
{
    require_once __DIR__ . '/../components/component.php';
}