<?php
declare(strict_types=1);

final class ProductsController extends BaseController
{
    public function index(): void
    {
        $this->render('products', [
            'pageTitle' => 'Products',
        ]);
    }
}