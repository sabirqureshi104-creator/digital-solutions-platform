<?php
declare(strict_types=1);

final class ContactController extends BaseController
{
    public function index(): void
    {
        $this->render('contact', [
            'pageTitle' => 'Contact',
        ]);
    }
}