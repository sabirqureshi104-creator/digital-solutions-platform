<?php
declare(strict_types=1);

require_once __DIR__ . '/app/Config.php';
require_once __DIR__ . '/app/helpers.php';
require_once __DIR__ . '/app/autoload.php';

$router = new Router();

$router->get('', HomeController::class, 'index');
$router->get('services', ServicesController::class, 'index');
$router->get('products', ProductsController::class, 'index');
$router->get('industries', IndustriesController::class, 'index');
$router->get('projects', ProjectsController::class, 'index');
$router->get('contact', ContactController::class, 'index');

$router->dispatch();