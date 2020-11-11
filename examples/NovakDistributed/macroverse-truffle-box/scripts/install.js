// Copy all the artifacts so we can use them in later deploys. Probably.
const fs = require('fs')
const path = require('path')
const shell = require('shelljs');

// Find the base directory of the Truffle project
const truffleBaseDir = path.join(__dirname, '..')

// Find the directory where the Macroverse built contracts are
const macroverseBuildDir = path.join(truffleBaseDir, 'node_modules/macroverse/build/contracts')

// And the directory where they go
const localBuildDir = path.join(truffleBaseDir, 'build/contracts')
// Make sure it exists
shell.mkdir('-p', localBuildDir)

for (let filename of fs.readdirSync(macroverseBuildDir)) {
  // For every Macroverse contract

  // Work out where it comes from and where it goes to
  const src = path.join(macroverseBuildDir, filename)
  const dst = path.join(localBuildDir, filename)

  // Copy it across unconditionally.
  // Note that this can clobber your testnet deploy addresses if you reinstall.
  // We would use fs.copyFileSync but that was added in node 8.5 and Ubuntu ships 6.11
  fs.createReadStream(src).pipe(fs.createWriteStream(dst))
}

// Now we just hope this script is parsed even if the migration has run.

