<?php
declare(strict_types=1);

final class ProjectsController extends BaseController
{
    public function index(): void
    {
        $this->render('projects', [
            'pageTitle' => 'Projects',
        ]);
    }
}