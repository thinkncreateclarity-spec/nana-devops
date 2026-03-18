const chalk = require('chalk');
const args = process.argv.slice(2);

if(args.length < 3) {
  console.log('CALCULATOR-CLI');
  console.log('calc 10 + 5 | 20 * 3 | 100 / 4');
  process.exit(0);
}

const num1 = parseFloat(args[0]);
const operator = args[1];
const num2 = parseFloat(args[2]);

let result;

switch(operator) {
  case '+': result = num1 + num2; break;
  case '-': result = num1 - num2; break;
  case '*': result = num1 * num2; break;
  case 'x': result = num1 * num2; break;  // ADD THIS LINE
  case 'X': result = num1 * num2; break;  // ADD THIS LINE
  case '/': 
    if(num2 === 0) {
      console.log(chalk.red('Error: Division by zero'));
      process.exit(1);
    }
    result = num1 / num2; 
    break;
  default:
    console.log(chalk.red('Error: Invalid operator'));
    process.exit(1);
}

console.log(chalk.green(`${num1} ${operator} ${num2} = ${result}`));
