export default class Payments {
  static addStripe(button) {
    (new this(button)).addStripe();
  }

  static addPaypal(button) {
    (new this(button)).addPaypal();
  }

  constructor(button) {
    this.button = button;
    this.form = button.closest('form');

    this.csfrToken = null;
    const csrfElement = document.querySelector("[name='csrf-token']")
    if (csrfElement) {
      this.csfrToken = csrfElement.content;
    }

    this.postingForm = false;
  }

  addStripe() {
    const self = this;
    this.form.addEventListener('submit', function(event) {
      self._undisableFields();
      event.preventDefault();

      if (self.postingForm) {
        return;
      }

      self.postingForm = true;
      self._disableStripeButton();

      const stripe = Stripe(self.form.dataset.stripePublicKey);

      self._postForm("/stripe/prep-checkout")
        .then(function(session) {
          self.postingForm = false;
          self._enableStripeButton();

          return stripe.redirectToCheckout({ sessionId: session.id });
        });
    });
  }

  addPaypal() {
    const self = this;
    this.button.innerHTML = "";
    this._undisableFields();

    paypal.Buttons({
      createOrder: () => {
        return self._postForm("/paypal/prep-checkout")
          .then((order) => order.id);
      },
      onApprove: (data) => {
        return self._post(`/paypal/complete-checkout/${data.orderID}`)
          .then(() => location.reload());
      },
      style: {
        color: "silver",
        tagline: false,
      },
    }).render(self.button);
  }

  _undisableFields() {
    const disabledFields = Array.from(this.form.querySelectorAll('input:disabled'));
    disabledFields.forEach(field => field.disabled = false);
  }

  _post(url) {
    return fetch(url, {
      method: 'POST',
      headers: {
        "X-CSRF-Token": this.csfrToken,
        "Accept": "application/json",
      },
    }).then((resp) => resp.json());
  }

  _postForm(url) {
    return fetch(url, {
      method: 'POST',
      headers: {
        "X-CSRF-Token": this.csfrToken,
        "Accept": "application/json",
      },
      body: (new FormData(this.form)),
    })
    .then((resp) => resp.json())
    .then((resp) => {
      if (resp.errors) {
        throw resp.errors;
      } else {
        return resp;
      }
    })
    .catch((errors) => this._displayErrors(errors));
  }

  _disableStripeButton() {
    this.button.disabled = true;
  }

  _enableStripeButton() {
    this.button.disabled = false;
  }

  _displayErrors(errors) {
    const errorList = this.form.querySelector("ul.errors");
    errorList.innerHTML = "";
    errors.forEach(error => {
      const errorItem = document.createElement("li");
      errorItem.textContent = error;
      errorList.appendChild(errorItem);
    });
  }
}
