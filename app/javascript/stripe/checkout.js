export function addStripeToForm(form) {
  form.addEventListener('submit', function(event) {
    const targetForm = event.target;
    const disabledFields = Array.from(targetForm.querySelectorAll('input:disabled'));

    disabledFields.forEach(field => field.disabled = false);

    event.preventDefault();

    let csrfToken = null;
    const csrfElement = document.querySelector("[name='csrf-token']")
    if (csrfElement) {
      csrfToken = csrfElement.content;
    }

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
      if (form.dataset.testMode == "true") {
        window.location = "/donations";
        return true;
      } else {
        return stripe.redirectToCheckout({ sessionId: session.id });
      }
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
