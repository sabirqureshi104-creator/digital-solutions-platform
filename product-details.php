<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/database.php';
require_once __DIR__ . '/includes/functions.php';

$slug = trim($_GET['slug'] ?? '');

$stmt = $pdo->prepare('SELECT * FROM products WHERE slug = ? AND status = "published" LIMIT 1');
$stmt->execute([$slug]);
$product = $stmt->fetch();

if (!$product) {
    http_response_code(404);
    require __DIR__ . '/pages/404.php';
    exit;
}

$pageTitle = $product['name'];
require __DIR__ . '/includes/header.php';
?>
<section class="section">
    <div class="container">
        <p class="eyebrow">Product</p>
        <h1><?= e($product['name']) ?></h1>
        <p class="lead"><?= e($product['short_description'] ?? '') ?></p>
        <div><?= nl2br(e($product['description'] ?? '')) ?></div>
    </div>
</section>
<?php require __DIR__ . '/includes/footer.php'; ?>
