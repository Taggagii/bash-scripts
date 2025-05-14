const { spawn } = require('child_process');

function runBmxWrite() {
  const username = process.env.USERNAME;
  const password = process.env.PASSWORD;

  if (!username || !password) {
    console.error('USERNAME or PASSWORD not set in environment variables.');
    process.exit(1);
  }

  const child = spawn('bmx', ['write'], {
    stdio: ['pipe', 'pipe', 'pipe']
  });

  function handleOutput(data) {
    const output = data.toString();
    console.log(output);

    const toEnter = output.match(/^([^:]*): $/)

    if (toEnter) {
      const match = toEnter[1]

      if (match.includes('username')) {
        child.stdin.write(username + '\n');
      }

      if (match.includes('password')) {
        child.stdin.write(password + '\n');
      }
    } 
  }

  child.stderr.on('data', handleOutput);

  child.on('close', (code) => {
    if (code !== 0) {
      console.error(`bmx write process exited with code ${code}`);
      return;
    } else {
      console.log('Successfully performed bmx write');
    }

  });
}

runBmxWrite();
