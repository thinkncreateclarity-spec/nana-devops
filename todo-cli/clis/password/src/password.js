const chalk = require('chalk');
const args = process.argv.slice(2);
const length = parseInt(args[0]) || 12;

function generatePassword(len) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
  let pass = '';
  for(let i = 0; i < len; i++) {
    pass += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return pass;
}

if(isNaN(length)) {
  console.log('PASSWORD-CLI');
  console.log('password 16 | strength strong | hist');
} else {
  const pass = generatePassword(length);
  console.log('Generated: ' + pass);
  console.log('Length: ' + length);
}
