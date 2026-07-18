<?php
declare(strict_types=1);

final class Router
{
    private array $routes = [];

    public function get(string $route, string $controller, string $method): void
    {
        $this->routes[$route] = [$controller, $method];
    }

    public function dispatch(): void
    {
        $route = trim((string) ($_GET['route'] ?? ''));

        if (!array_key_exists($route, $this->routes)) {
            http_response_code(404);
            View::render('404', ['pageTitle' => 'Page Not Found']);
            return;
        }

        [$controller, $method] = $this->routes[$route];

        if (!class_exists($controller) || !method_exists($controller, $method)) {
            throw new RuntimeException('Invalid route handler.');
        }

        (new $controller())->{$method}();
    }
}