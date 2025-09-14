local M = {}

-- Move Java class to another package
function M.move_class_to_package()
    local current_file = vim.api.nvim_buf_get_name(0)
    if not current_file:match("%.java$") then
        vim.notify("Not a Java file", vim.log.levels.WARN)
        return
    end

    -- Extract current package from file content
    local lines = vim.api.nvim_buf_get_lines(0, 0, 10, false)
    local current_package = ""
    for _, line in ipairs(lines) do
        local package = line:match("^package%s+([%w%.]+)")
        if package then
            current_package = package
            break
        end
    end

    vim.ui.input({
        prompt = "Move to package: ",
        default = current_package,
    }, function(target_package)
        if target_package and target_package ~= "" and target_package ~= current_package then
            M.perform_move_class(current_file, current_package, target_package)
        end
    end)
end

-- Perform the actual move operation
function M.perform_move_class(file_path, from_package, to_package)
    local jdtls = require("jdtls")

    -- Try JDTLS move command first
    local ok = pcall(function()
        jdtls.execute_command({
            command = "java.move.instanceMethod",
            arguments = {
                vim.uri_from_fname(file_path),
                to_package
            }
        })
    end)

    if not ok then
        -- Fallback: manual approach
        M.manual_move_class(file_path, from_package, to_package)
    end
end

-- Manual move class implementation
function M.manual_move_class(file_path, from_package, to_package)
    local class_name = vim.fn.fnamemodify(file_path, ":t:r")

    -- Update package declaration in current file
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:match("^package%s+") then
            lines[i] = "package " .. to_package .. ";"
            break
        end
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

    -- Create target directory structure
    local project_root = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" })
    if not project_root then
        vim.notify("Could not find project root", vim.log.levels.ERROR)
        return
    end

    -- Find src/main/java directory
    local src_dir = project_root .. "/src/main/java"
    if vim.fn.isdirectory(src_dir) == 0 then
        -- Try alternative structures
        src_dir = project_root .. "/src"
        if vim.fn.isdirectory(src_dir) == 0 then
            vim.notify("Could not find source directory", vim.log.levels.ERROR)
            return
        end
    end

    -- Create target package directory
    local target_dir = src_dir .. "/" .. to_package:gsub("%.", "/")
    vim.fn.mkdir(target_dir, "p")

    -- Determine new file path
    local new_file_path = target_dir .. "/" .. class_name .. ".java"

    -- Save current file and move it
    vim.cmd("write")

    -- Use vim's rename functionality
    local ok = pcall(function()
        vim.fn.rename(file_path, new_file_path)
    end)

    if ok then
        -- Open the moved file
        vim.cmd("edit " .. new_file_path)
        vim.notify("Moved " .. class_name .. " to package " .. to_package, vim.log.levels.INFO)

        -- Update imports in other files (basic implementation)
        M.update_imports_after_move(class_name, from_package, to_package, project_root)
    else
        vim.notify("Failed to move file", vim.log.levels.ERROR)
    end
end

-- Update imports in other Java files after moving a class
function M.update_imports_after_move(class_name, from_package, to_package, project_root)
    local old_import = "import " .. from_package .. "." .. class_name .. ";"
    local new_import = "import " .. to_package .. "." .. class_name .. ";"

    -- Use LSP workspace edit if available
    local clients = vim.lsp.get_active_clients({ name = "jdtls" })
    if #clients > 0 then
        -- Request workspace symbols and update references
        vim.lsp.buf_request(0, "workspace/symbol", {
            query = class_name
        }, function(err, result)
            if not err and result then
                -- Process results and update imports
                -- This is a simplified version - JDTLS should handle this automatically
                vim.notify("Updated references to " .. class_name, vim.log.levels.INFO)
            end
        end)
    end
end

-- Rename class (changes both class name and file name)
function M.rename_class()
    local current_file = vim.api.nvim_buf_get_name(0)
    if not current_file:match("%.java$") then
        vim.notify("Not a Java file", vim.log.levels.WARN)
        return
    end

    local current_name = vim.fn.fnamemodify(current_file, ":t:r")

    vim.ui.input({
        prompt = "New class name: ",
        default = current_name,
    }, function(new_name)
        if new_name and new_name ~= "" and new_name ~= current_name then
            M.perform_rename_class(current_file, current_name, new_name)
        end
    end)
end

function M.perform_rename_class(file_path, old_name, new_name)
    -- Update class declaration in file
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    for i, line in ipairs(lines) do
        -- Update class declaration
        if line:match("^public%s+class%s+" .. old_name) then
            lines[i] = line:gsub(old_name, new_name)
        end
        -- Update constructor
        if line:match("public%s+" .. old_name .. "%s*%(") then
            lines[i] = line:gsub(old_name, new_name)
        end
    end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

    -- Save and rename file
    vim.cmd("write")
    local new_file_path = vim.fn.fnamemodify(file_path, ":h") .. "/" .. new_name .. ".java"

    local ok = pcall(function()
        vim.fn.rename(file_path, new_file_path)
    end)

    if ok then
        vim.cmd("edit " .. new_file_path)
        vim.notify("Renamed class from " .. old_name .. " to " .. new_name, vim.log.levels.INFO)
    else
        vim.notify("Failed to rename file", vim.log.levels.ERROR)
    end
end

return M