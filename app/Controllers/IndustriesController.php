<?php
declare(strict_types=1);

final class IndustriesController extends BaseController
{
    public function index(): void
    {
        $this->render('industries', [
            'pageTitle' => 'Industries',
        ]);
    }
}