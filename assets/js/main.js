document.documentElement.classList.add('js');

const cards = document.querySelectorAll('.card');

cards.forEach((card) => {
    card.addEventListener('mousemove', (event) => {
        const rect = card.getBoundingClientRect();
        card.style.setProperty('--mouse-x', `${event.clientX - rect.left}px`);
        card.style.setProperty('--mouse-y', `${event.clientY - rect.top}px`);
    });
});
