-- mini.ai configuration
local function svelte_tag_pattern()
    -- This pattern matches Svelte component tags with dash support
    -- Based on original mini.ai pattern: '<(%w-)%f[^<%w][^<>]->.-</%1%s->'
    -- Changed from (%%w-) to ([a-zA-Z0-9_-]+) to allow dashes within tag name
    local around_pattern = [[<([a-zA-Z0-9_-]+)[^<>]->.-</%1%s->]]
    
    -- Inside (i) textobject pattern (from original: '^<.->().*()</.->$')
    local inside_pattern = [[^<([a-zA-Z0-9_-]+)[^<>]->-().*()</[a-zA-Z0-9_-]+%s->$]]
    
    return { around_pattern, inside_pattern }
end

local function setup_mini_ai()
    local MiniAi = require('mini.ai')
    
    MiniAi.setup({
        custom_textobjects = {
            -- Enhanced tag pattern for Svelte/Kit compatibility
            t = svelte_tag_pattern(),
            
            -- Also add specific Svelte elements that might not match the general pattern
            ['script'] = { '<script[^>]*>', '</script>' },
            ['style'] = { '<style[^>]*>', '</style>' },
            ['slot'] = { '<slot[^>]*>', '</slot>' },
            ['template'] = { '<template[^>]*>', '</template>' },
        }
    })
end

vim.defer_fn(function()
    setup_mini_ai()
end, 100)