const chalk = require('chalk');
const args = process.argv.slice(2);
const city = args[0] || 'Chennai';

const weatherData = {
  Chennai: { temp: 32, condition: 'Sunny', humidity: 65 },
  Mumbai: { temp: 29, condition: 'Partly Cloudy', humidity: 78 },
  Delhi: { temp: 28, condition: 'Hazy', humidity: 55 },
  Bangalore: { temp: 27, condition: 'Clear', humidity: 60 }
};

const data = weatherData[city] || { temp: 25, condition: 'Unknown', humidity: 70 };

console.log(chalk.blue(`🌤️ ${city}: ${data.condition}`));
console.log(chalk.yellow(`🌡️  ${data.temp}°C`));
console.log(chalk.gray(`💧  Humidity: ${data.humidity}%`));
