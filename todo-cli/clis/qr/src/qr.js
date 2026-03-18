const QRCode = require('qrcode-terminal');
const args = process.argv.slice(2);
const text = args[0] || 'help';

if(text === 'help' || !text) {
  console.log('QR-CLI');
  console.log('qr "nana-upi.com" | UPI 499 | hist');
} else if(text === 'hist') {
  console.log('Last QR: nana-upi.com/₹49');
} else {
  console.log('QR for: ' + text);
  QRCode.generate(text, {small: true});
}
