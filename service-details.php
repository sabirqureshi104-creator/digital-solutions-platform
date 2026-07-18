<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/database.php';
require_once __DIR__ . '/includes/functions.php';

$slug = trim($_GET['slug'] ?? '');

$stmt = $pdo->prepare('SELECT * FROM services WHERE slug = ? AND status = "published" LIMIT 1');
$stmt->execute([$slug]);
$service = $stmt->fetch();

if (!$service) {
    http_response_code(404);
    require __DIR__ . '/pages/404.php';
    exit;
}

$pageTitle = $service['title'];
require __DIR__ . '/includes/header.php';
?>
<section class="section">
    <div class="container">
        <p class="eyebrow">Service</p>
        <h1><?= e($service['title']) ?></h1>
        <p class="lead"><?= e($service['short_description'] ?? '') ?></p>
    </div>
</section>
<?php require __DIR__ . '/includes/footer.php'; ?>
