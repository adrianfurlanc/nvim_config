-- vim-illuminate: highlights other uses of the word under the cursor.
-- Disabled for markdown (prose repeats words constantly, so the underlines
-- are noise there); the first three entries are the plugin's defaults.
require('illuminate').configure({
    filetypes_denylist = {
        'dirbuf',
        'dirvish',
        'fugitive',
        'markdown',
    },
})
