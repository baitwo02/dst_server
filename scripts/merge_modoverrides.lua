#!/usr/bin/env lua5.4

local preset_path = arg[1]
local extra_path = arg[2]

if not preset_path or not extra_path then
  io.stderr:write("usage: merge_modoverrides.lua <preset.lua> <extra.lua>\n")
  os.exit(1)
end

-- 空环境仅允许输入文件返回静态配置表。
local function load_table(path)
  local chunk, err = loadfile(path, "t", {})
  if not chunk then
    io.stderr:write("failed to load ", path, ": ", err, "\n")
    os.exit(1)
  end

  local ok, result = pcall(chunk)
  if not ok then
    io.stderr:write("failed to execute ", path, ": ", result, "\n")
    os.exit(1)
  end

  if type(result) ~= "table" then
    io.stderr:write(path, " must return a table\n")
    os.exit(1)
  end

  return result
end

local function merge(base, override)
  for key, value in pairs(override) do
    base[key] = value
  end
  return base
end

local function is_identifier(value)
  return type(value) == "string" and value:match("^[%a_][%w_]*$") ~= nil
end

local function sorted_keys(tbl)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end)

  return keys
end

local function serialize(value, indent)
  indent = indent or 0
  local pad = string.rep("  ", indent)
  local next_pad = string.rep("  ", indent + 1)
  local value_type = type(value)

  if value_type == "string" then
    return string.format("%q", value)
  end

  if value_type == "number" or value_type == "boolean" then
    return tostring(value)
  end

  if value_type == "nil" then
    return "nil"
  end

  if value_type ~= "table" then
    error("unsupported value type: " .. value_type)
  end

  local parts = {"{"}
  for _, key in ipairs(sorted_keys(value)) do
    local rendered_key
    if is_identifier(key) then
      rendered_key = key
    else
      rendered_key = "[" .. serialize(key, 0) .. "]"
    end

    table.insert(
      parts,
      "\n" .. next_pad .. rendered_key .. " = " .. serialize(value[key], indent + 1) .. ","
    )
  end

  table.insert(parts, "\n" .. pad .. "}")
  return table.concat(parts)
end

local preset = load_table(preset_path)
local extra = load_table(extra_path)
local final = merge(preset, extra)

io.write("return ", serialize(final, 0), "\n")
