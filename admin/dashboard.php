<?php
declare(strict_types=1);

require_once __DIR__ . '/includes/auth.php';

$user = Auth::user();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="assets/css/admin.css">
</head>
<body>
<div class="admin-shell">
    <aside class="sidebar">
        <h2>DSP Admin</h2>
        <nav>
    <a class="active" href="dashboard.php">Dashboard</a>
    <a href="#" aria-disabled="true">Enquiries</a>
    <a href="#" aria-disabled="true">Quote Requests</a>
    <a href="#" aria-disabled="true">Contacts</a>
    <a href="#" aria-disabled="true">Users</a>
    <a href="#" aria-disabled="true">Settings</a>
</nav>
    </aside>

    <main class="dashboard">
        <header class="topbar">
            <div>
                <p class="eyebrow">Overview</p>
                <h1>Welcome, <?= htmlspecialchars($user['name'] ?? 'Admin', ENT_QUOTES, 'UTF-8') ?></h1>
            </div>
            <a class="logout" href="logout.php">Logout</a>
        </header>

        <section class="stats">
    <article>
        <strong><?= $newEnquiries ?></strong>
        <span>New enquiries</span>
    </article>

    <article>
        <strong><?= $openQuotes ?></strong>
        <span>Open quotes</span>
    </article>

    <article>
        <strong><?= $contactCount ?></strong>
        <span>Saved contacts</span>
    </article>

    <article>
        <strong><?= $followUpsDue ?></strong>
        <span>Follow-ups due</span>
    </article>
</section>
    </main>
</div>
</body>
</html>
