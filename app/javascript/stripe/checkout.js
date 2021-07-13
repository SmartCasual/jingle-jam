export function addStripeToForm(form) {
  form.addEventListener('submit', function(event) {
    const targetForm = event.target;
    const disabledFields = Array.from(targetForm.querySelectorAll('input:disabled'));

    disabledFields.forEach(field => field.disabled = false);

    if (form.dataset.testMode == "true") {
      return
    }

    event.preventDefault()

    const csrfToken = document.querySelector("[name='csrf-token']").content
    const stripe = Stripe(form.dataset.stripePublicKey);

    fetch(targetForm.action, {
      method: 'POST',
      headers: {
        "X-CSRF-Token": csrfToken,
      },
      body: (new FormData(targetForm)),
    })
    .then(function(response) {
      return response.json();
    })
    .then(function(session) {
      return stripe.redirectToCheckout({ sessionId: session.id });
    })
    .then(function(result) {
      if (result.error) {
        alert(result.error.message);
      }
    })
    .catch(function(error) {
      console.error('Error:', error);
    });
  });
}
