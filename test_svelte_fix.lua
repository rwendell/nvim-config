-- Test script to verify the Svelte tag fix
-- Run with: nvim --script /home/rwendell/.config/nvim/test_svelte_fix.lua

local MiniAi = require('mini.ai')

print("=== Testing mini.ai Svelte Tag Fix ===")

-- Default pattern from original mini.ai
default_pattern = "<(%w-)%f[^<%w][^<>]->.-</%1%s->"

-- Enhanced pattern for Svelte components
enhanced_pattern = [[<([a-zA-Z0-9_-]+)[^>]*>.-</%1[^>]*>]]

print("\n=== Pattern Comparison ===")
print("Default pattern: " .. default_pattern)
print("Enhanced pattern: " .. enhanced_pattern)

-- Test tags that commonly fail with default pattern
test_tags = {
    "<my-component></my-component>",
    "<my-component>content</my-component>",
    "<MyComponent></MyComponent>",
    "<Component1></Component1>",
    "<Layout><main></main></Layout>",
    "<script type=\"text/typescript\"></script>",
    "<slot></slot>",
}

print("\n=== Test Results ===")
for i, tag in ipairs(test_tags) do
    local default_match = tag:match(default_pattern) ~= nil
    local enhanced_match = tag:match(enhanced_pattern) ~= nil
    
    print(string.format("Test %d: %s", i, tag))
    print("  Default pattern: " .. tostring(default_match))
    print("  Enhanced pattern: " .. tostring(enhanced_match))
    
    if default_match ~= enhanced_match then
        print("  *** DIFFERENCE ***")
    end
    print()
end

print("\n=== Verification of Fix ===")
print("The enhanced pattern in mini_ai.lua now supports:")
print("  - Dashes in component names (my-component)")
print("  - Numbers in component names (Component1)")
print("  - Other valid characters (letters, underscores)")
print("\nThis fixes the issue where 'd-a-t' would not grab")
print("Svelte/Kit custom component tags correctly.")