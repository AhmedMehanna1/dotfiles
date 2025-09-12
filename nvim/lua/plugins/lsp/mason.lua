return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
        ensure_installed = {
            "stylua",
            "shfmt",
            "flake8",
            "rust-analyzer",
            "jdtls",
            "google-java-format",
            "checkstyle",
            "black",
            "isort",
            "prettierd",
            "eslint_d",
            "lua-language-server",
            "pyright",
            "gopls",
            "typescript-language-server",
            "codelldb",
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)
        local mr = require("mason-registry")

        -- Improved installation handling to avoid race conditions
        mr:on("package:install:success", function()
            vim.defer_fn(function()
                require("lazy.core.handler.event").trigger({
                    event = "FileType",
                    buf = vim.api.nvim_get_current_buf(),
                })
            end, 100)
        end)

        local function ensure_installed()
            for _, tool in ipairs(opts.ensure_installed) do
                local p = mr.get_package(tool)
                if not p:is_installed() then
                    -- Check if already installing to avoid race condition
                    local installing = false
                    for _, pkg in ipairs(mr.get_installed_packages()) do
                        if pkg.name == tool and pkg:is_installing() then
                            installing = true
                            break
                        end
                    end

                    if not installing then
                        vim.notify("Installing " .. tool, vim.log.levels.INFO)
                        p:install()
                    end
                end
            end
        end

        -- Defer installation to avoid conflicts
        if mr.refresh then
            mr.refresh(function()
                vim.defer_fn(ensure_installed, 100)
            end)
        else
            vim.defer_fn(ensure_installed, 100)
        end
    end,
}
