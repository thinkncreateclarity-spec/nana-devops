const chalk = require('chalk');
const args = process.argv.slice(2);
const seconds = parseInt(args[0]) || 5;

console.log('Timer: ' + seconds + 's');
let timeLeft = seconds;

const interval = setInterval(function() {console.log('.' + timeLeft); timeLeft--; if(timeLeft < 0) {clearInterval(interval); console.log('DING! Complete!');
}
}, 1000);
