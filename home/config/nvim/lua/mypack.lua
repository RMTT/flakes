-- from https://yeripratama.com/blog/migrating-from-lazynvim-to-vimpack/
local function normalize_src(src)
    if src:match("^[a-z]+://") then
        return src
    end
    return "https://github.com/" .. src:gsub("^/", "")
end

local function get_src(spec)
    if type(spec) == 'string' then
        return spec
    elseif spec.src then
        return spec.src
    else
        return spec[1]
    end
end

local function setup_specs(specs_ext)
    local specs = {}
    local configs = {}
    local declared_specs = {}

    for _, spec in ipairs(specs_ext) do
        declared_specs[normalize_src(get_src(spec))] = true
    end
    -- resolve specs and configs
    for _, spec in ipairs(specs_ext) do
        if spec.dependencies then
            for _, dep in ipairs(spec.dependencies) do
                local dep_src = normalize_src(get_src(dep))
                if not declared_specs[dep_src] then
                    table.insert(specs, { src = dep_src, version = dep.version })
                end
            end
        end
        table.insert(specs, vim.tbl_extend("force", spec, { src = normalize_src(get_src(spec)) }))
        if spec.config then
            table.insert(configs, spec.config)
        end
    end

    -- install packages
    vim.pack.add(specs, { load = true })

    -- configure packages
    for _, config in ipairs(configs) do
        config()
    end
end

M = {}

-- load plugins under config dir
-- plugin spec:
-- {src="", dependencies={},config=function() end}
function M.init()
    vim.o.packpath = vim.fs.joinpath(vim.fn.stdpath("data"), 'site')
    local packs_path = vim.fs.joinpath(vim.fn.stdpath("config"), 'lua', 'packs')

    local specs = {}
    local handle = vim.uv.fs_scandir(packs_path)
    if handle then
        while true do
            local name, _ = vim.uv.fs_scandir_next(handle)
            if not name then break end

            local mod = loadfile(vim.fs.joinpath(packs_path, name))()
            table.insert(specs, mod)
        end
    end

    setup_specs(specs)
end

return M
