<section class="section">
    <div class="container narrow">
        <h1>Start a Project</h1>
        <form class="contact-form" method="post" action="api/contact-submit.php">
            <label>Name<input type="text" name="name" required></label>
            <label>Email<input type="email" name="email" required></label>
            <label>Company<input type="text" name="company"></label>
            <label>Message<textarea name="message" rows="6" required></textarea></label>
            <button class="button" type="submit">Send Inquiry</button>
        </form>
    </div>
</section>