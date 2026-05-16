return {
  -- Ensure blink.cmp v2 deps are installed and load early enough for JDTLS.
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = { "saghen/blink.lib" },
  },
}
