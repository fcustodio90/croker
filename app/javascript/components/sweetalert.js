import swal from 'sweetalert';

function bindSweetAlertButtonDemo() {
  const buySubmitBtn = document.getElementById('buy-trade-btn');
  const sellSubmitBtn = document.getElementById('sell-trade-btn');

  if (buySubmitBtn) {
    buySubmitBtn.addEventListener('click', function(event) {
      event.preventDefault();
      const form = document.getElementById('buy-form').closest('form');
      // const form = document.querySelector('.buy-form-sweet-alert');
      const tickerName = document.getElementById('tradeValueCryptoBuy').placeholder;
      const cryptoValue = document.getElementById('tradeValueCryptoBuy').value;
    swal({
      title: "",
      text: `Are you sure you would like to buy ${cryptoValue} ${tickerName}?`,
      icon: "warning",
      buttons: [
      'No, cancel it!',
      'Yes!'
      ],
      dangerMode: true,
    }).then(function(isConfirm) {
      if (isConfirm) {
        swal({
          title: "Congratulations!",
          text: `You have bought ${cryptoValue} ${tickerName}!`,
          icon: "success",
        }).then (()=> {
          form.submit();
        });
        }
      });
    });
  };
  if (sellSubmitBtn) {
    sellSubmitBtn.addEventListener('click', function(event) {
      event.preventDefault();
      const form = document.getElementById('sell-form').closest('form');
      // const form = document.querySelector('.sell-form-sweet-alert');
      const tickerName = document.getElementById('tradeValueCryptoSell').placeholder;
      const cryptoValue = document.getElementById('tradeValueCryptoSell').value;
    swal({
      title: "",
      text: `Are you sure you would like to sell ${cryptoValue} ${tickerName}?`,
      icon: "warning",
      buttons: [
      'No, cancel it!',
      'Yes!'
      ],
      dangerMode: true,
    }).then(function(isConfirm) {
      if (isConfirm) {
        swal({
          title: "Congratulations!",
          text: `You have sold ${cryptoValue} ${tickerName}!`,
          icon: "success",
        }).then (()=> {
          form.submit();
        });
        }
      });
    });
  };
};

  export { bindSweetAlertButtonDemo };
