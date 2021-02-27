export function addStripeToForm(form) {
  if (form.dataset.testMode == "true") {
    return
  }

  var stripe = Stripe(form.dataset.stripePublicKey);

  form.addEventListener('submit', function(event) {
    event.preventDefault()

    const targetForm = event.target;

    const elements = targetForm.elements;
    const csrfToken = document.querySelector("[name='csrf-token']").content

    fetch(targetForm.action, {
      method: 'POST',
      headers: {
        "X-CSRF-Token": csrfToken,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        currency: elements.currency.value,
        amount: elements.amount.value,
        message: elements.message.value,
      })
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
