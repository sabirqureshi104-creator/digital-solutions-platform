<?php
declare(strict_types=1);

function e(?string $value): string
{
    return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8');
}

function asset(string $path): string
{
    return 'assets/' . ltrim($path, '/');
}

function page_title(string $title = ''): string
{
    return $title !== '' ? $title . ' | ' . APP_NAME : APP_NAME;
}
