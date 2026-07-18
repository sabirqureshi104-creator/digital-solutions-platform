<?php
declare(strict_types=1);

final class ServicesController extends BaseController
{
    public function index(): void
    {
        $this->render('services', [
            'pageTitle' => 'Services',
        ]);
    }
}