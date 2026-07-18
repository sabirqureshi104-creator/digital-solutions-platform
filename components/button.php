<?php
declare(strict_types=1);

$text = $text ?? '';
$href = $href ?? '#';
$class = $class ?? 'button';
?>

<a href="<?= e($href) ?>" class="<?= e($class) ?>">
    <?= e($text) ?>
</a>