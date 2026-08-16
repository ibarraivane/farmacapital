#!/usr/bin/env node
'use strict';

const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const apiRoot = path.resolve(__dirname, '..', 'api');
const files = [];

function walk(dir) {
  for (const name of fs.readdirSync(dir)) {
    const full = path.join(dir, name);
    const stat = fs.statSync(full);
    if (stat.isDirectory()) walk(full);
    else if (name.endsWith('.js')) files.push(full);
  }
}

walk(apiRoot);

let failed = false;
for (const file of files) {
  const rel = path.relative(path.resolve(__dirname, '..'), file);
  const result = spawnSync(process.execPath, ['--check', file], { encoding: 'utf8' });
  if (result.status !== 0) {
    failed = true;
    console.error(`[check-api-syntax] ${rel}`);
    if (result.stderr) process.stderr.write(result.stderr);
  }
}

if (failed) {
  console.error('[check-api-syntax] Corrige los archivos anteriores antes del deploy.');
  process.exit(1);
}

console.log(`[check-api-syntax] OK (${files.length} archivos)`);
