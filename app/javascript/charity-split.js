import currency from "currency.js"

const GBP = (value, options) => currency(value, Object.assign({}, (options || {}), { symbol: '£' }));

export function enableCharitySplit(sliders) {
  if (sliders === undefined) {
    return;
  }

  sliders.removeAttribute('hidden');

  const form = sliders.closest('form');
  const elements = form.elements;
  const listItems = Array.from(sliders.children);
  const ranges = Array.from(sliders.querySelectorAll('input[type="range"]'));
  let donationAmount = GBP(elements['donation[human_amount]'].value);

  const sumWarning = form.querySelector('.sum-warning');
  const submitButton = form.querySelector('button');

  listItems.forEach((slider) => {
    let range = slider.querySelector('input[type="range"]');
    range.min = 0;
    range.value = 0;
    updateLabel(range);

    const manual_input = slider.querySelector('input.manual');

    manual_input.addEventListener('change', event => {
      range.value = GBP(event.target.value).intValue;
      range.dispatchEvent(new InputEvent('input'));
    });

    slider.querySelector('input.lock')
      .addEventListener('change', event => {
        range.dataset.locked = event.target.checked;
        range.disabled = event.target.checked;
        manual_input.disabled = event.target.checked;
      });

    range.addEventListener('input', (event) => {
      let otherRanges = Array.from(event.target.closest('ul').querySelectorAll('input[type="range"]'));
      otherRanges = otherRanges.filter(r => r.id != event.target.id);
      let amount = GBP(event.target.value, { fromCents: true });
      let previousAmount = GBP(event.target.dataset.previousAmount, { fromCents: true });

      if (event.target.value == event.target.max) {
        otherRanges.forEach(r => {
          r.value = 0;
          r.dataset.previousAmount = 0;
          updateLabel(r);
        });
      } else {
        let inverted = GBP(0).subtract(amount.subtract(previousAmount));
        distribute(inverted, otherRanges);
      }

      event.target.dataset.previousAmount = event.target.value;

      updateLabel(event.target);

      correctDisparity(ranges, otherRanges, donationAmount, sumWarning, submitButton);
    });
  });

  updateRangeCaps(donationAmount, ranges)
  distribute(donationAmount, ranges);
  ranges.forEach(range => {
    range.dataset.previousAmount = range.value;
  });

  elements['donation[human_amount]'].addEventListener('change', (event) => {
    donationAmount = GBP(event.target.value);

    updateRangeCaps(donationAmount, ranges);
    resetValues(ranges);
    distribute(donationAmount, ranges);
    ranges.forEach(range => {
      range.dataset.previousAmount = range.value;
    });
  });
}

function updateRangeCaps(maxAmount, ranges) {
  ranges.forEach(range => {
    range.max = maxAmount.intValue;
  });
}

function resetValues(ranges) {
  ranges.forEach(range => {
    range.value = 0;
    range.dataset.locked = null;
    updateLabel(range);
  });
}

function distribute(fullAmount, ranges) {
  ranges = ranges.filter(r => r.dataset.locked != 'true');
  let evenSplit = fullAmount.distribute(ranges.length);

  ranges.forEach((range, i) => {
    range.dataset.previousAmount = range.value;
    range.value = GBP(range.value, { fromCents: true }).add(evenSplit[i]).intValue;
    updateLabel(range);
  });
}

function updateLabel(range) {
  let amountText = range.closest('li').querySelector('input.manual');
  amountText.value = GBP(range.value, { fromCents: true }).format();
}

function correctDisparity(ranges, otherRanges, fullAmount, sumWarning, submitButton) {
  let sum = ranges.reduce((amount, range) => amount.add(GBP(range.value, { fromCents: true })), GBP(0));
  const disparity = fullAmount.subtract(sum);

  sumWarning.setAttribute('hidden', '');
  submitButton.removeAttribute('disabled');

  if (disparity.intValue != 0) {
    distribute(disparity, otherRanges.filter(r => GBP(r.value, { fromCents: true }).intValue > 0));
  }

  sum = ranges.reduce((amount, range) => amount.add(GBP(range.value, { fromCents: true })), GBP(0));

  // There are ways that this still might not add up, for instance if the user
  // has locked some of the sliders.
  if (sum.intValue != fullAmount.intValue) {
    sumWarning.removeAttribute('hidden');
    submitButton.setAttribute('disabled', '');
  }
}
