local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Better up/down
keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to left window", remap = true })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines (consistent with ideavim)
keymap.set("v", "<C-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
keymap.set("v", "<C-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
-- Keep Alt versions for alternative
-- Alt+j/k previously duplicated move-lines; keep Ctrl+j/k only

-- Buffers
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Better buffer management - save and close current buffer, return to previous
keymap.set("n", "<leader>bd", function()
    local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
    if buf_count > 1 then
        vim.cmd("bp|bd #") -- Go to previous buffer, then delete the one we were on
    else
        vim.cmd("enew") -- If only one buffer, create a new empty buffer
    end
end, { desc = "Delete buffer and return to previous" })

-- Save and close current buffer, return to previous
keymap.set("n", "<leader>bq", function()
    vim.cmd("w") -- Save first
    local buf_count = #vim.fn.getbufinfo({ buflisted = 1 })
    if buf_count > 1 then
        vim.cmd("bp|bd #") -- Go to previous buffer, then delete the one we saved
    else
        vim.cmd("enew") -- If only one buffer, create a new empty buffer
    end
end, { desc = "Save, close buffer, and return to previous" })

-- Alternative: Create a custom :wq replacement
vim.api.nvim_create_user_command("WQ", function()
    local buf = vim.api.nvim_get_current_buf()
    local is_normal = (vim.bo.buftype == "")
    local can_write = is_normal and vim.bo.modifiable and not vim.bo.readonly

    -- Try to save only when it is a normal, writable file buffer
    if can_write then
        pcall(vim.cmd, "silent write")
    end

    local buflisted = vim.fn.buflisted(buf) == 1
    local listed_count = #vim.fn.getbufinfo({ buflisted = 1 })

    if buflisted and listed_count > 1 then
        -- Switch away, then delete the original buffer
        vim.cmd("bprevious")
        pcall(vim.cmd, "bdelete " .. buf)
    else
        -- If more than one window, just close this window; otherwise quit
        if vim.fn.winnr("$") > 1 then
            vim.cmd("close")
        else
            vim.cmd("quit")
        end
    end
end, { desc = "Write and close buffer (like :wq but better)" })

-- Make :wq behave better by creating an abbreviation
vim.cmd("cnoreabbrev wq WQ")

-- Make :q behave like :wq (save and close buffer) safely
-- Only when the exact command is ':q', not 'qall', 'qa', or 'q!'
vim.cmd(
    [[cnoreabbrev <expr> q (getcmdtype() == ':' && getcmdline() ==# 'q' && &buftype == '' && &modifiable && !&readonly) ? 'WQ' : 'q']]
)

-- Clear search with <esc>
keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
keymap.set(
    "n",
    "<leader>ur",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / clear hlsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
keymap.set("i", ",", ",<c-g>u")
keymap.set("i", ".", ".<c-g>u")
keymap.set("i", ";", ";<c-g>u")

-- Save file
keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Better indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Lazy
keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- New file
keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- Location and quickfix lists
keymap.set("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

-- Diagnostic keymaps
keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Quit
keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Highlights under cursor
keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- Terminal Mappings
keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- Windows
keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- Tabs
keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Quick tab navigation with Alt+numbers
keymap.set("n", "<A-1>", "1gt", { desc = "Go to tab 1" })
keymap.set("n", "<A-2>", "2gt", { desc = "Go to tab 2" })
keymap.set("n", "<A-3>", "3gt", { desc = "Go to tab 3" })
keymap.set("n", "<A-4>", "4gt", { desc = "Go to tab 4" })
keymap.set("n", "<A-5>", "5gt", { desc = "Go to tab 5" })
keymap.set("n", "<A-6>", "6gt", { desc = "Go to tab 6" })
keymap.set("n", "<A-7>", "7gt", { desc = "Go to tab 7" })
keymap.set("n", "<A-8>", "8gt", { desc = "Go to tab 8" })
keymap.set("n", "<A-9>", "9gt", { desc = "Go to tab 9" })

-- Quick next/previous with Alt (using buffers - most common)
-- Window splits
keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertical" })
keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontal" })

-- Resize splits with Alt+hjkl
keymap.set("n", "<A-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap.set("n", "<A-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
keymap.set("n", "<A-j>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap.set("n", "<A-k>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })

-- Navigate between buffers with Alt+arrows (most common workflow)
keymap.set("n", "<A-Left>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
keymap.set("n", "<A-Right>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Navigate between actual tabs with Ctrl+Alt+arrows (if you use tabs)
keymap.set("n", "<C-A-Left>", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
keymap.set("n", "<C-A-Right>", "<cmd>tabnext<cr>", { desc = "Next tab" })

-- Additional keymaps to match ideavim configuration
-- File operations (matching ideavim <Space>f* mappings)
keymap.set("n", "<leader>ff", function()
    require("telescope.builtin").find_files()
end, { desc = "Find files" })
keymap.set("n", "<leader>fs", function()
    require("telescope.builtin").live_grep()
end, { desc = "Find in files" })
keymap.set("n", "<leader>fc", function()
    local builtin = require("telescope.builtin")

    local function any_client_supports(method)
        for _, client in pairs(vim.lsp.get_active_clients()) do
            if client.supports_method and client:supports_method(method) then
                return true
            end
        end
        return false
    end

    local tried_lsp = false
    if any_client_supports("workspace/symbol") then
        tried_lsp = true
        local ok = pcall(builtin.lsp_dynamic_workspace_symbols, { symbols = { "Class" } })
        if not ok then
            ok = pcall(builtin.lsp_workspace_symbols, { query = "", symbols = { "Class" } })
        end
        if ok then
            return
        end
    end

    -- Fallback (no LSP or it failed): grep for common class keywords
    builtin.live_grep({
        default_text = "class ",
        prompt_title = tried_lsp and "Classes (fallback grep)" or "Classes (grep)",
    })
end, { desc = "Find classes in project" })
keymap.set("n", "<leader>fr", function()
    require("telescope.builtin").oldfiles()
end, { desc = "Recent files" })

-- Code navigation (matching ideavim)
keymap.set("n", "<leader>ss", function()
    require("telescope.builtin").lsp_document_symbols({ symbols = { "Method", "Field" } })
end, { desc = "Document methods/fields" })
keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
keymap.set("n", "<leader>gs", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap.set("n", "<leader>su", function()
    require("telescope.builtin").lsp_references()
end, { desc = "Show usages" })

-- Code editing (matching ideavim) - <leader>/ is now handled by Comment plugin
keymap.set("n", "<leader>co", function()
    require("utils.code_action").organize()
end, { desc = "Organize imports" })
keymap.set("n", "<leader>ci", vim.lsp.buf.code_action, { desc = "Code actions" })

-- Refactoring (matching ideavim)
keymap.set("n", "<leader>re", function()
    require("utils.rename").smart()
end, { desc = "Rename element" })

-- File tree (matching ideavim <Space>e* mappings)
keymap.set("n", "<leader>ee", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ef", "<cmd>Neotree reveal<cr>", { desc = "Find file in explorer" })

-- Terminal (matching ideavim Ctrl+Enter)
keymap.set("n", "<C-CR>", function()
    require("toggleterm").toggle()
end, { desc = "Toggle terminal" })
keymap.set("n", "<C-Enter>", function()
    require("toggleterm").toggle()
end, { desc = "Toggle terminal" })

-- Java-specific debug commands
keymap.set("n", "<leader>jd", "<cmd>JavaLspDebug<cr>", { desc = "Java LSP Debug" })
keymap.set("n", "<leader>jr", "<cmd>JavaLspRestart<cr>", { desc = "Java LSP Restart" })
keymap.set("n", "<leader>ja", "<cmd>JavaLspAttach<cr>", { desc = "Java LSP Force Attach" })
keymap.set("n", "<leader>jf", "<cmd>JavaFixAttach<cr>", { desc = "Java Fix Attach (Alternative)" })
keymap.set("n", "<leader>jc", "<cmd>JavaCheckAll<cr>", { desc = "Check All Java Buffers" })

-- Build and run (matching ideavim patterns)
keymap.set("n", "<leader>cc", function()
    if vim.bo.filetype == "java" then
        -- Try different build tools
        if vim.fn.filereadable("pom.xml") == 1 then
            vim.cmd("!mvn compile")
        elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
            vim.cmd("!./gradlew build")
        else
            vim.cmd("!javac *.java")
        end
    else
        vim.cmd("make")
    end
end, { desc = "Compile project" })

-- Test keymap to verify keymaps are working
keymap.set("n", "<leader>test", function()
    vim.notify("Keymap test works!", vim.log.levels.INFO)
end, { desc = "Test keymap" })

-- Debug keymaps (IntelliJ-style with leader prefix)
keymap.set("n", "<leader>tb", function()
    require("dap").toggle_breakpoint()
end, { desc = "Toggle Line Breakpoint" })
keymap.set("v", "<leader>tb", function()
    require("dap").toggle_breakpoint()
end, { desc = "Toggle Line Breakpoint" })
keymap.set("n", "<leader>ds", function()
    require("dap").continue()
end, { desc = "Debug/Start" })
keymap.set("n", "<leader>dn", function()
    require("dap").step_over()
end, { desc = "Step Over" })
keymap.set("n", "<leader>di", function()
    require("dap").step_into()
end, { desc = "Step Into" })
keymap.set("n", "<leader>dr", function()
    require("dap").continue()
end, { desc = "Resume" })
keymap.set("n", "<leader>de", function()
    require("dapui").eval()
end, { desc = "Evaluate Expression" })
keymap.set("n", "<leader>dt", function()
    require("dap").run_to_cursor()
end, { desc = "Run to Cursor" })

-- Additional debug shortcuts for completeness
keymap.set("n", "<leader>do", function()
    require("dap").step_out()
end, { desc = "Step Out" })
keymap.set("n", "<leader>dq", function()
    require("dap").terminate()
end, { desc = "Stop Debug" })
keymap.set("n", "<leader>du", function()
    require("dapui").toggle()
end, { desc = "Toggle Debug UI" })

keymap.set("n", "<leader>xr", function()
    local filetype = vim.bo.filetype
    local cwd = vim.fn.getcwd()

    if filetype == "java" then
        -- Java projects
        if vim.fn.filereadable("pom.xml") == 1 then
            vim.cmd("split | terminal mvn spring-boot:run")
        elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
            vim.cmd("split | terminal ./gradlew bootRun")
        else
            local filename = vim.fn.expand("%:t:r")
            vim.cmd("split | terminal java " .. filename)
        end
    elseif filetype == "kotlin" then
        -- Kotlin projects
        if vim.fn.filereadable("build.gradle.kts") == 1 or vim.fn.filereadable("build.gradle") == 1 then
            vim.cmd("split | terminal ./gradlew run")
        elseif vim.fn.filereadable("pom.xml") == 1 then
            vim.cmd("split | terminal mvn compile exec:java")
        else
            local filename = vim.fn.expand("%:t:r")
            vim.cmd(
                "split | terminal kotlinc "
                    .. vim.fn.expand("%")
                    .. " -include-runtime -d "
                    .. filename
                    .. ".jar && java -jar "
                    .. filename
                    .. ".jar"
            )
        end
    elseif filetype == "rust" then
        -- Rust projects
        if vim.fn.filereadable("Cargo.toml") == 1 then
            vim.cmd("split | terminal cargo run")
        else
            local filename = vim.fn.expand("%:t:r")
            vim.cmd("split | terminal rustc " .. vim.fn.expand("%") .. " && ./" .. filename)
        end
    elseif filetype == "go" then
        -- Go projects
        if vim.fn.filereadable("go.mod") == 1 then
            vim.cmd("split | terminal go run .")
        else
            vim.cmd("split | terminal go run " .. vim.fn.expand("%"))
        end
    elseif filetype == "python" then
        -- Python projects
        if vim.fn.filereadable("pyproject.toml") == 1 then
            vim.cmd("split | terminal poetry run python " .. vim.fn.expand("%"))
        elseif vim.fn.filereadable("requirements.txt") == 1 then
            vim.cmd("split | terminal python " .. vim.fn.expand("%"))
        elseif vim.fn.filereadable("Pipfile") == 1 then
            vim.cmd("split | terminal pipenv run python " .. vim.fn.expand("%"))
        else
            vim.cmd("split | terminal python " .. vim.fn.expand("%"))
        end
    elseif filetype == "javascript" then
        -- JavaScript/Node.js projects
        if vim.fn.filereadable("package.json") == 1 then
            local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))
            if package_json.scripts and package_json.scripts.start then
                vim.cmd("split | terminal npm start")
            elseif package_json.scripts and package_json.scripts.dev then
                vim.cmd("split | terminal npm run dev")
            else
                vim.cmd("split | terminal node " .. vim.fn.expand("%"))
            end
        else
            vim.cmd("split | terminal node " .. vim.fn.expand("%"))
        end
    elseif filetype == "typescript" then
        -- TypeScript projects
        if vim.fn.filereadable("package.json") == 1 then
            local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))
            if package_json.scripts and package_json.scripts.start then
                vim.cmd("split | terminal npm start")
            elseif package_json.scripts and package_json.scripts.dev then
                vim.cmd("split | terminal npm run dev")
            else
                vim.cmd("split | terminal npx tsx " .. vim.fn.expand("%"))
            end
        else
            vim.cmd("split | terminal npx tsx " .. vim.fn.expand("%"))
        end
    elseif filetype == "typescriptreact" or filetype == "javascriptreact" then
        -- React projects
        if vim.fn.filereadable("package.json") == 1 then
            local package_json = vim.fn.json_decode(vim.fn.readfile("package.json"))
            if package_json.scripts and package_json.scripts.start then
                vim.cmd("split | terminal npm start")
            elseif package_json.scripts and package_json.scripts.dev then
                vim.cmd("split | terminal npm run dev")
            else
                vim.cmd("split | terminal npm run build")
            end
        else
            vim.notify("No package.json found for React project", vim.log.levels.WARN)
        end
    elseif filetype == "c" then
        -- C projects
        if vim.fn.filereadable("Makefile") == 1 then
            vim.cmd("split | terminal make && ./main")
        elseif vim.fn.filereadable("CMakeLists.txt") == 1 then
            vim.cmd("split | terminal cmake . && make && ./main")
        else
            local filename = vim.fn.expand("%:t:r")
            vim.cmd("split | terminal gcc -o " .. filename .. " " .. vim.fn.expand("%") .. " && ./" .. filename)
        end
    elseif filetype == "cpp" then
        -- C++ projects
        if vim.fn.filereadable("Makefile") == 1 then
            vim.cmd("split | terminal make && ./main")
        elseif vim.fn.filereadable("CMakeLists.txt") == 1 then
            vim.cmd("split | terminal cmake . && make && ./main")
        else
            local filename = vim.fn.expand("%:t:r")
            vim.cmd("split | terminal g++ -o " .. filename .. " " .. vim.fn.expand("%") .. " && ./" .. filename)
        end
    elseif filetype == "cs" then
        -- C# projects
        if vim.fn.filereadable("*.csproj") == 1 or vim.fn.filereadable("*.sln") == 1 then
            vim.cmd("split | terminal dotnet run")
        else
            local filename = vim.fn.expand("%:t:r")
            vim.cmd("split | terminal dotnet run " .. filename .. ".cs")
        end
    elseif filetype == "lua" then
        -- Lua projects
        vim.cmd("split | terminal lua " .. vim.fn.expand("%"))
    elseif filetype == "sh" or filetype == "bash" then
        -- Shell scripts
        vim.cmd("split | terminal bash " .. vim.fn.expand("%"))
    elseif filetype == "dockerfile" then
        -- Docker projects
        vim.cmd("split | terminal docker build -t temp-image . && docker run --rm temp-image")
    else
        -- Fallback: try common project runners
        if vim.fn.filereadable("Makefile") == 1 then
            vim.cmd("split | terminal make run")
        elseif vim.fn.filereadable("package.json") == 1 then
            vim.cmd("split | terminal npm start")
        elseif vim.fn.filereadable("Cargo.toml") == 1 then
            vim.cmd("split | terminal cargo run")
        elseif vim.fn.filereadable("go.mod") == 1 then
            vim.cmd("split | terminal go run .")
        elseif vim.fn.executable("./run") == 1 then
            vim.cmd("split | terminal ./run")
        else
            vim.notify("No known project runner found for filetype: " .. filetype, vim.log.levels.WARN)
        end
    end
end, { desc = "Run project (universal)" })

-- Additional Java-specific commands
keymap.set("n", "<leader>xt", function()
    if vim.bo.filetype == "java" then
        if vim.fn.filereadable("pom.xml") == 1 then
            vim.cmd("!mvn test")
        elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
            vim.cmd("!./gradlew test")
        else
            vim.notify("No test framework detected", vim.log.levels.WARN)
        end
    end
end, { desc = "Run tests (Java)" })

keymap.set("n", "<leader>xc", function()
    if vim.bo.filetype == "java" then
        if vim.fn.filereadable("pom.xml") == 1 then
            vim.cmd("!mvn clean")
        elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
            vim.cmd("!./gradlew clean")
        else
            vim.cmd("!rm -f *.class")
        end
    end
end, { desc = "Clean project (Java)" })

keymap.set("n", "<leader>xp", function()
    if vim.bo.filetype == "java" then
        if vim.fn.filereadable("pom.xml") == 1 then
            vim.cmd("!mvn package")
        elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
            vim.cmd("!./gradlew build")
        else
            vim.notify("No build tool detected for packaging", vim.log.levels.WARN)
        end
    end
end, { desc = "Package project (Java)" })

-- Create user commands for Java project management
vim.api.nvim_create_user_command("JavaRun", function()
    if vim.fn.filereadable("pom.xml") == 1 then
        vim.cmd("!mvn spring-boot:run")
    elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
        vim.cmd("!./gradlew bootRun")
    else
        local filename = vim.fn.expand("%:t:r")
        vim.cmd("!java " .. filename)
    end
end, { desc = "Run Java project" })

vim.api.nvim_create_user_command("JavaCompile", function()
    if vim.fn.filereadable("pom.xml") == 1 then
        vim.cmd("!mvn compile")
    elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
        vim.cmd("!./gradlew compileJava")
    else
        vim.cmd("!javac *.java")
    end
end, { desc = "Compile Java project" })

vim.api.nvim_create_user_command("JavaTest", function()
    if vim.fn.filereadable("pom.xml") == 1 then
        vim.cmd("!mvn test")
    elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
        vim.cmd("!./gradlew test")
    else
        vim.notify("No test framework detected", vim.log.levels.WARN)
    end
end, { desc = "Run Java tests" })

vim.api.nvim_create_user_command("JavaClean", function()
    if vim.fn.filereadable("pom.xml") == 1 then
        vim.cmd("!mvn clean")
    elseif vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 then
        vim.cmd("!./gradlew clean")
    else
        vim.cmd("!rm -f *.class")
    end
end, { desc = "Clean Java project" })
