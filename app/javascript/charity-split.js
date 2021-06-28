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
  const donationAmount = GBP(elements.amount.value);

  listItems.forEach((slider) => {
    let amountText = document.createElement('p');
    amountText.className = "amount";
    slider.append(amountText);

    let range = slider.querySelector('input[type="range"]');
    range.min = 0;
    range.value = 0;
    updateLabel(range);

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

      correctDisparity(ranges, donationAmount);
    });
  });

  updateRangeCaps(donationAmount, ranges)
  distribute(donationAmount, ranges);
  ranges.forEach(range => {
    range.dataset.previousAmount = range.value;
  });

  elements.amount.addEventListener('change', (event) => {
    const donationAmount = GBP(event.target.value);

    updateRangeCaps(donationAmount, ranges);
    resetValues(ranges);
    distribute(donationAmount, ranges);
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
    updateLabel(range);
  });
}

function distribute(fullAmount, ranges) {
  let evenSplit = fullAmount.distribute(ranges.length);

  ranges.forEach((range, i) => {
    range.dataset.previousAmount = range.value;
    range.value = GBP(range.value, { fromCents: true }).add(evenSplit[i]).intValue;
    updateLabel(range);
  });
}

function updateLabel(range) {
  let amountText = range.closest('li').querySelector('p.amount');
  amountText.textContent = GBP(range.value, { fromCents: true }).format();
}

function correctDisparity(ranges, fullAmount) {
  const sum = ranges.reduce((amount, range) => amount.add(GBP(range.value, { fromCents: true })), GBP(0));
  const disparity = fullAmount.subtract(sum);

  if (disparity.intValue != 0) {
    distribute(disparity, ranges.filter(r => GBP(r.value, { fromCents: true }).intValue > 0));
  }
}
