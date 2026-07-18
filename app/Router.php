<?php
declare(strict_types=1);

class Router
{
    private array $routes = [];

    public function get(string $uri, string $controller, string $method): void
    {
        $this->routes[$uri] = [$controller, $method];
    }

    public function dispatch(): void
    {
        $uri = '/' . trim($_GET['route'] ?? '', '/');

        if ($uri === '//') {
            $uri = '/';
        }

        if (!isset($this->routes[$uri])) {
            View::render('404', ['pageTitle' => '404']);
            return;
        }

        [$controller, $method] = $this->routes[$uri];

        (new $controller())->$method();
    }
}