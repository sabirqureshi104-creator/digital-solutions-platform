<?php
declare(strict_types=1);

function component(string $name, array $data = []): void
{
    extract($data);

    require __DIR__ . '/' . $name . '.php';
}