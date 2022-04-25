import RealPayments from './payments';

export default class FakePayments extends RealPayments {
  addStripe() {
    const self = this;
    this.form.addEventListener('submit', function(event) {
      event.preventDefault();
      self._undisableFields();

      self._postForm("/stripe/prep-checkout");
    });
  }

  addPaypal() {
    const self = this;
    this.button.addEventListener('click', (event) => {
      event.preventDefault();
      self._undisableFields();

      self._postForm("/paypal/prep-checkout")
        .then((order) => {
          self._post(`/paypal/complete-checkout/${order.id}`)
        }).then(() => location.reload())
    });
  }
}
