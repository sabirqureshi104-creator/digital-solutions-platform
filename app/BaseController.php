<?php
declare(strict_types=1);

abstract class BaseController
{
    protected function render(string $page, array $data = []): void
    {
        View::render($page, $data);
    }
}