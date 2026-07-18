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
            <a href="<?= url() ?>">Home</a>
            <a href="<?= url('?route=services') ?>">Services</a>
            <a href="<?= url('?route=products') ?>">Products</a>
            <a href="<?= url('?route=industries') ?>">Industries</a>
            <a href="<?= url('?route=projects') ?>">Projects</a>
            <a href="<?= url('?route=contact') ?>">Contact</a>
        </nav>

    </div>
</header>

<main>