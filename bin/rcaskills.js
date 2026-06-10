#!/usr/bin/env node

import { runCli } from "../src/cli.js";

runCli().catch((error) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`Error: ${message}`);
  process.exitCode = 1;
});
