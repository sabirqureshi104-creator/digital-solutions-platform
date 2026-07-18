<?php
declare(strict_types=1);

require_once __DIR__ . '/app/Config.php';
require_once __DIR__ . '/app/helpers.php';
require_once __DIR__ . '/app/autoload.php';

loadComponents();

$router = new Router();

$router->get('/', HomeController::class, 'index');

// Temporary routes
$router->get('/services', HomeController::class, 'index');
$router->get('/products', HomeController::class, 'index');
$router->get('/industries', HomeController::class, 'index');
$router->get('/projects', HomeController::class, 'index');
$router->get('/contact', HomeController::class, 'index');

$router->dispatch();