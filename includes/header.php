<?php
declare(strict_types=1);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle ?? Config::APP_NAME) ?> | <?= Config::APP_NAME ?></title>

    <link rel="stylesheet" href="<?= asset('css/style.css') ?>">
</head>
<body>

<header class="site-header">
    <div class="container nav-wrap">

        <a href="<?= url() ?>" class="brand">
            <?= Config::APP_NAME ?>
        </a>

        <nav>
           <a href="<?= route_url() ?>">Home</a>
<a href="<?= route_url('services') ?>">Services</a>
<a href="<?= route_url('products') ?>">Products</a>
<a href="<?= route_url('industries') ?>">Industries</a>
<a href="<?= route_url('projects') ?>">Projects</a>
<a href="<?= route_url('contact') ?>">Contact</a>
        </nav>

    </div>
</header>

<main>