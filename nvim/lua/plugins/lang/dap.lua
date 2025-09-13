return {
    -- Main DAP plugin
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- UI components
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",

            -- Language-specific adapters
            "mfussenegger/nvim-dap-python", -- Python
            "leoluz/nvim-dap-go", -- Go
            "mxsdev/nvim-dap-vscode-js", -- JavaScript/TypeScript
        },
        keys = {
            -- Additional utility keymaps for less common actions
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
            { "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Log Point" },
            { "<leader>dc", function() require("dap").clear_breakpoints() end, desc = "Clear All Breakpoints" },
            { "<leader>dp", function() require("dap").pause() end, desc = "Pause Debug" },
            { "<leader>dj", function() require("dap").step_back() end, desc = "Step Back" },
            { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Debug Hover" },
            { "<leader>dv", function() require("dap.ui.widgets").preview() end, desc = "Debug Preview" },
            { "<leader>df", function() require("dapui").float_element("scopes", { enter = true }) end, desc = "Debug Scopes" },
            { "<leader>dw", function() require("dapui").float_element("watches", { enter = true }) end, desc = "Debug Watches" },
            { "<leader>dR", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Setup UI
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.25 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "stacks", size = 0.25 },
                            { id = "watches", size = 0.25 },
                        },
                        position = "left",
                        size = 40,
                    },
                    {
                        elements = {
                            { id = "repl", size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        position = "bottom",
                        size = 10,
                    },
                },
            })

            -- Setup virtual text
            require("nvim-dap-virtual-text").setup({
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = false,
                only_first_definition = true,
                all_references = false,
                filter_references_pattern = '<module',
                virt_text_pos = 'eol',
                all_frames = false,
                virt_lines = false,
                virt_text_win_col = nil
            })

            -- Auto-open/close UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- Breakpoint signs
            vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '🟡', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
            vim.fn.sign_define('DapLogPoint', { text = '📝', texthl = 'DapLogPoint', linehl = '', numhl = '' })
            vim.fn.sign_define('DapStopped', { text = '▶️', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
            vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })

            -- Language-specific configurations

            -- Java (via nvim-java or manual jdtls setup)
            dap.configurations.java = {
                {
                    type = 'java',
                    request = 'attach',
                    name = "Debug (Attach) - Remote",
                    hostName = "127.0.0.1",
                    port = 5005,
                },
                {
                    type = 'java',
                    request = 'launch',
                    name = "Debug (Launch) - Current File",
                    mainClass = "${file}",
                },
            }

            -- C/C++ (requires gdb)
            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "-i", "dap" }
            }

            dap.configurations.c = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = "${workspaceFolder}",
                    stopAtBeginningOfMainSubprogram = false,
                },
            }
            dap.configurations.cpp = dap.configurations.c

            -- C# (requires netcoredbg)
            dap.adapters.coreclr = {
                type = 'executable',
                command = 'netcoredbg',
                args = {'--interpreter=vscode'}
            }

            dap.configurations.cs = {
                {
                    type = "coreclr",
                    name = "launch - netcoredbg",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
                    end,
                },
            }

            -- Rust (requires lldb-vscode or codelldb)
            dap.adapters.lldb = {
                type = 'executable',
                command = 'lldb-vscode',
                name = 'lldb'
            }

            dap.configurations.rust = {
                {
                    name = 'Launch',
                    type = 'lldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},
                },
            }
        end,
    },

    -- Language-specific setups
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        config = function()
            require("dap-python").setup("python") -- or path to your python with debugpy installed
        end,
    },

    {
        "leoluz/nvim-dap-go",
        ft = "go",
        config = function()
            require("dap-go").setup()
        end,
    },

    {
        "mxsdev/nvim-dap-vscode-js",
        ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        config = function()
            require("dap-vscode-js").setup({
                debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
                adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
            })

            local dap = require("dap")
            for _, language in ipairs({ "typescript", "javascript" }) do
                dap.configurations[language] = {
                    {
                        type = "pwa-node",
                        request = "launch",
                        name = "Launch file",
                        program = "${file}",
                        cwd = "${workspaceFolder}",
                    },
                    {
                        type = "pwa-node",
                        request = "attach",
                        name = "Attach",
                        processId = require'dap.utils'.pick_process,
                        cwd = "${workspaceFolder}",
                    }
                }
            end
        end,
    },
}