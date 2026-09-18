"use strict";

const { describe, it } = require("node:test");
const assert = require("node:assert/strict");
const fs = require("fs");
const path = require("path");

describe("EnvioCotizacionPanel campos claros", () => {
  const src = fs.readFileSync(path.join(__dirname, "EnvioCotizacionPanel.jsx"), "utf8");

  it("usa clases y color-scheme light (no inputs crudos negros en iOS)", () => {
    assert.match(src, /farmacapital-field-input/);
    assert.match(src, /farmacapital-field-select/);
    assert.match(src, /colorScheme:\s*["']light["']/);
    assert.match(src, /background:\s*["']#ffffff["']/);
    assert.doesNotMatch(
      src,
      /<input[\s\S]{0,180}style=\{\{\s*width:\s*80/
    );
  });
});
